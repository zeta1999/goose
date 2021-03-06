(* autogenerated from append_log *)
From Perennial.goose_lang Require Import prelude.
From Perennial.goose_lang Require Import ffi.disk_prelude.

From Goose Require github_com.tchajed.marshal.

(* Append-only, sequential, crash-safe log.

   The main interesting feature is that the log supports multi-block atomic
   appends, which are implemented by atomically updating an on-disk header with
   the number of valid blocks in the log. *)

Module Log.
  Definition S := struct.decl [
    "m" :: lockRefT;
    "sz" :: uint64T;
    "diskSz" :: uint64T
  ].
End Log.

Definition Log__mkHdr: val :=
  rec: "Log__mkHdr" "log" :=
    let: "enc" := marshal.NewEnc disk.BlockSize in
    marshal.Enc__PutInt "enc" (struct.loadF Log.S "sz" "log");;
    marshal.Enc__PutInt "enc" (struct.loadF Log.S "diskSz" "log");;
    marshal.Enc__Finish "enc".
Theorem Log__mkHdr_t: ⊢ Log__mkHdr : (struct.ptrT Log.S -> disk.blockT).
Proof. typecheck. Qed.
Hint Resolve Log__mkHdr_t : types.

Definition Log__writeHdr: val :=
  rec: "Log__writeHdr" "log" :=
    disk.Write #0 (Log__mkHdr "log").
Theorem Log__writeHdr_t: ⊢ Log__writeHdr : (struct.ptrT Log.S -> unitT).
Proof. typecheck. Qed.
Hint Resolve Log__writeHdr_t : types.

Definition Init: val :=
  rec: "Init" "diskSz" :=
    (if: "diskSz" < #1
    then
      (struct.new Log.S [
         "m" ::= lock.new #();
         "sz" ::= #0;
         "diskSz" ::= #0
       ], #false)
    else
      let: "log" := struct.new Log.S [
        "m" ::= lock.new #();
        "sz" ::= #0;
        "diskSz" ::= "diskSz"
      ] in
      Log__writeHdr "log";;
      ("log", #true)).
Theorem Init_t: ⊢ Init : (uint64T -> (struct.ptrT Log.S * boolT)).
Proof. typecheck. Qed.
Hint Resolve Init_t : types.

Definition Open: val :=
  rec: "Open" <> :=
    let: "hdr" := disk.Read #0 in
    let: "dec" := marshal.NewDec "hdr" in
    let: "sz" := marshal.Dec__GetInt "dec" in
    let: "diskSz" := marshal.Dec__GetInt "dec" in
    struct.new Log.S [
      "m" ::= lock.new #();
      "sz" ::= "sz";
      "diskSz" ::= "diskSz"
    ].
Theorem Open_t: ⊢ Open : (unitT -> struct.ptrT Log.S).
Proof. typecheck. Qed.
Hint Resolve Open_t : types.

Definition Log__get: val :=
  rec: "Log__get" "log" "i" :=
    let: "sz" := struct.loadF Log.S "sz" "log" in
    (if: "i" < "sz"
    then (disk.Read (#1 + "i"), #true)
    else (slice.nil, #false)).
Theorem Log__get_t: ⊢ Log__get : (struct.ptrT Log.S -> uint64T -> (disk.blockT * boolT)).
Proof. typecheck. Qed.
Hint Resolve Log__get_t : types.

Definition Log__Get: val :=
  rec: "Log__Get" "log" "i" :=
    lock.acquire (struct.loadF Log.S "m" "log");;
    let: ("v", "b") := Log__get "log" "i" in
    lock.release (struct.loadF Log.S "m" "log");;
    ("v", "b").
Theorem Log__Get_t: ⊢ Log__Get : (struct.ptrT Log.S -> uint64T -> (disk.blockT * boolT)).
Proof. typecheck. Qed.
Hint Resolve Log__Get_t : types.

Definition writeAll: val :=
  rec: "writeAll" "bks" "off" :=
    ForSlice (slice.T byteT) "i" "bk" "bks"
      (disk.Write ("off" + "i") "bk").
Theorem writeAll_t: ⊢ writeAll : (slice.T disk.blockT -> uint64T -> unitT).
Proof. typecheck. Qed.
Hint Resolve writeAll_t : types.

Definition Log__append: val :=
  rec: "Log__append" "log" "bks" :=
    let: "sz" := struct.loadF Log.S "sz" "log" in
    (if: slice.len "bks" ≥ struct.loadF Log.S "diskSz" "log" - #1 - "sz"
    then #false
    else
      writeAll "bks" (#1 + "sz");;
      struct.storeF Log.S "sz" "log" (struct.loadF Log.S "sz" "log" + slice.len "bks");;
      Log__writeHdr "log";;
      #true).
Theorem Log__append_t: ⊢ Log__append : (struct.ptrT Log.S -> slice.T disk.blockT -> boolT).
Proof. typecheck. Qed.
Hint Resolve Log__append_t : types.

Definition Log__Append: val :=
  rec: "Log__Append" "log" "bks" :=
    lock.acquire (struct.loadF Log.S "m" "log");;
    let: "b" := Log__append "log" "bks" in
    lock.release (struct.loadF Log.S "m" "log");;
    "b".
Theorem Log__Append_t: ⊢ Log__Append : (struct.ptrT Log.S -> slice.T disk.blockT -> boolT).
Proof. typecheck. Qed.
Hint Resolve Log__Append_t : types.

Definition Log__reset: val :=
  rec: "Log__reset" "log" :=
    struct.storeF Log.S "sz" "log" #0;;
    Log__writeHdr "log".
Theorem Log__reset_t: ⊢ Log__reset : (struct.ptrT Log.S -> unitT).
Proof. typecheck. Qed.
Hint Resolve Log__reset_t : types.

Definition Log__Reset: val :=
  rec: "Log__Reset" "log" :=
    lock.acquire (struct.loadF Log.S "m" "log");;
    Log__reset "log";;
    lock.release (struct.loadF Log.S "m" "log").
Theorem Log__Reset_t: ⊢ Log__Reset : (struct.ptrT Log.S -> unitT).
Proof. typecheck. Qed.
Hint Resolve Log__Reset_t : types.
