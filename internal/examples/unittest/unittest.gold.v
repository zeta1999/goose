(* autogenerated from unittest *)
From Perennial.goose_lang Require Import prelude.

(* disk FFI *)
From Perennial.goose_lang Require Import ffi.disk_prelude.

(* comments.go *)

(* This struct is very important.

   This is despite it being empty. *)
Module importantStruct.
  Definition S := struct.decl [
  ].
End importantStruct.

(* doSubtleThings does a number of subtle things:

   (actually, it does nothing) *)
Definition doSubtleThings: val :=
  λ: <>,
    #().

(* const.go *)

Definition GlobalConstant : expr := #(str"foo").

(* an untyped string *)
Definition UntypedStringConstant : expr := #(str"bar").

Definition TypedInt : expr := #32.

Definition ConstWithArith : expr := #4 + #3 * TypedInt.

Definition TypedInt32 : expr := #(U32 3).

(* control_flow.go *)

Definition conditionalReturn: val :=
  λ: "x",
    (if: "x"
    then #0
    else #1).

Definition alwaysReturn: val :=
  λ: "x",
    (if: "x"
    then #0
    else #1).

Definition earlyReturn: val :=
  λ: "x",
    (if: "x"
    then #()
    else #()).

Definition conditionalAssign: val :=
  λ: "x",
    let: "y" := ref (zero_val uint64T) in
    (if: "x"
    then "y" <-[uint64T] #1
    else "y" <-[uint64T] #2);;
    "y" <-[uint64T] ![uint64T] "y" + #1;;
    ![uint64T] "y".

(* conversions.go *)

Definition stringWrapper: ty := stringT.

Definition typedLiteral: val :=
  λ: <>,
    #3.

Definition literalCast: val :=
  λ: <>,
    let: "x" := #2 in
    "x" + #2.

Definition castInt: val :=
  λ: "p",
    slice.len "p".

Definition stringToByteSlice: val :=
  λ: "s",
    let: "p" := Data.stringToBytes "s" in
    "p".

Definition byteSliceToString: val :=
  λ: "p",
    let: "s" := Data.bytesToString "p" in
    "s".

Definition stringToStringWrapper: val :=
  λ: "s",
    "s".

Definition stringWrapperToString: val :=
  λ: "s",
    "s".

(* data_structures.go *)

Definition atomicCreateStub: val :=
  λ: "dir" "fname" "data",
    #().

Definition useSlice: val :=
  λ: <>,
    let: "s" := NewSlice byteT #1 in
    let: "s1" := SliceAppendSlice byteT "s" "s" in
    atomicCreateStub #(str"dir") #(str"file") "s1".

Definition useSliceIndexing: val :=
  λ: <>,
    let: "s" := NewSlice uint64T #2 in
    SliceSet uint64T "s" #1 #2;;
    let: "x" := SliceGet uint64T "s" #0 in
    "x".

Definition useMap: val :=
  λ: <>,
    let: "m" := NewMap (slice.T byteT) in
    MapInsert "m" #1 slice.nil;;
    let: ("x", "ok") := MapGet "m" #2 in
    (if: "ok"
    then #()
    else MapInsert "m" #3 "x").

Definition usePtr: val :=
  λ: <>,
    let: "p" := ref (zero_val uint64T) in
    "p" <-[refT uint64T] #1;;
    let: "x" := ![uint64T] "p" in
    "p" <-[refT uint64T] "x".

Definition iterMapKeysAndValues: val :=
  λ: "m",
    let: "sumPtr" := ref (zero_val uint64T) in
    MapIter "m" (λ: "k" "v",
      let: "sum" := ![uint64T] "sumPtr" in
      "sumPtr" <-[refT uint64T] "sum" + "k" + "v");;
    let: "sum" := ![uint64T] "sumPtr" in
    "sum".

Definition iterMapKeys: val :=
  λ: "m",
    let: "keysSlice" := NewSlice uint64T #0 in
    let: "keysRef" := ref (zero_val (slice.T uint64T)) in
    "keysRef" <-[refT (slice.T uint64T)] "keysSlice";;
    MapIter "m" (λ: "k" <>,
      let: "keys" := ![slice.T uint64T] "keysRef" in
      let: "newKeys" := SliceAppend uint64T "keys" "k" in
      "keysRef" <-[refT (slice.T uint64T)] "newKeys");;
    let: "keys" := ![slice.T uint64T] "keysRef" in
    "keys".

Definition getRandom: val :=
  λ: <>,
    let: "r" := Data.randomUint64 #() in
    "r".

(* empty_functions.go *)

Definition empty: val :=
  λ: <>,
    #().

Definition emptyReturn: val :=
  λ: <>,
    #().

(* encoding.go *)

Module Enc.
  Definition S := struct.decl [
    "p" :: slice.T byteT
  ].
End Enc.

Definition Enc__consume: val :=
  λ: "e" "n",
    let: "b" := SliceTake (struct.loadF Enc.S "p" "e") "n" in
    struct.storeF Enc.S "p" "e" (SliceSkip byteT (struct.loadF Enc.S "p" "e") "n");;
    "b".

Definition Enc__UInt64: val :=
  λ: "e" "x",
    UInt64Put (Enc__consume "e" #8) "x".

Definition Enc__UInt32: val :=
  λ: "e" "x",
    UInt32Put (Enc__consume "e" #4) "x".

Module Dec.
  Definition S := struct.decl [
    "p" :: slice.T byteT
  ].
End Dec.

Definition Dec__consume: val :=
  λ: "d" "n",
    let: "b" := SliceTake (struct.loadF Dec.S "p" "d") "n" in
    struct.storeF Dec.S "p" "d" (SliceSkip byteT (struct.loadF Dec.S "p" "d") "n");;
    "b".

Definition Dec__UInt64: val :=
  λ: "d",
    UInt64Get (Dec__consume "d" #8).

Definition Dec__UInt32: val :=
  λ: "d",
    UInt32Get (Dec__consume "d" #4).

(* ints.go *)

Definition useInts: val :=
  λ: "x" "y",
    let: "z" := ref (zero_val uint64T) in
    "z" <-[uint64T] to_u64 "y";;
    "z" <-[uint64T] ![uint64T] "z" + #1;;
    let: "y2" := ref (zero_val uint32T) in
    "y2" <-[uint32T] "y" + #(U32 3);;
    (![uint64T] "z", ![uint32T] "y2").

Definition u32: ty := uint32T.

Definition also_u32: ty := u32.

Definition ConstWithAbbrevType : expr := #(U32 3).

(* literals.go *)

Module allTheLiterals.
  Definition S := struct.decl [
    "int" :: uint64T;
    "s" :: stringT;
    "b" :: boolT
  ].
End allTheLiterals.

Definition normalLiterals: val :=
  λ: <>,
    struct.mk allTheLiterals.S [
      "int" ::= #0;
      "s" ::= #(str"foo");
      "b" ::= #true
    ].

Definition specialLiterals: val :=
  λ: <>,
    struct.mk allTheLiterals.S [
      "int" ::= #4096;
      "s" ::= #(str"");
      "b" ::= #false
    ].

Definition oddLiterals: val :=
  λ: <>,
    struct.mk allTheLiterals.S [
      "int" ::= #5;
      "s" ::= #(str"backquote string");
      "b" ::= #false
    ].

(* locks.go *)

Definition useLocks: val :=
  λ: <>,
    let: "m" := lock.new #() in
    lock.acquire "m";;
    lock.release "m".

Definition useCondVar: val :=
  λ: <>,
    let: "m" := lock.new #() in
    let: "c" := lock.newCond "m" in
    lock.acquire "m";;
    lock.condSignal "c";;
    lock.condWait "c";;
    lock.release "m".

Module hasCondVar.
  Definition S := struct.decl [
    "cond" :: condvarRefT
  ].
End hasCondVar.

(* log_debugging.go *)

Definition ToBeDebugged: val :=
  λ: "x",
    (* log.Println("starting function") *)
    (* log.Printf("called with %d", x) *)
    (* log.Println("ending function") *)
    "x".

Definition DoNothing: val :=
  λ: <>,
    (* log.Println("doing nothing") *)
    #().

(* loops.go *)

(* DoSomething is an impure function *)
Definition DoSomething: val :=
  λ: "s",
    #().

Definition standardForLoop: val :=
  λ: "s",
    let: "sumPtr" := ref (zero_val uint64T) in
    let: "i" := ref #0 in
    (for: (#true); (Skip) :=
      (if: ![uint64T] "i" < slice.len "s"
      then
        let: "sum" := ![uint64T] "sumPtr" in
        let: "x" := SliceGet uint64T "s" (![uint64T] "i") in
        "sumPtr" <-[refT uint64T] "sum" + "x";;
        "i" <-[uint64T] ![uint64T] "i" + #1;;
        Continue
      else Break));;
    let: "sum" := ![uint64T] "sumPtr" in
    "sum".

Definition conditionalInLoop: val :=
  λ: <>,
    let: "i" := ref #0 in
    (for: (#true); (Skip) :=
      (if: ![uint64T] "i" < #3
      then
        DoSomething (#(str"i is small"));;
        #()
      else #());;
      (if: ![uint64T] "i" > #5
      then Break
      else
        "i" <-[uint64T] ![uint64T] "i" + #1;;
        Continue)).

Definition ImplicitLoopContinue: val :=
  λ: <>,
    let: "i" := ref #0 in
    (for: (#true); (Skip) :=
      (if: ![uint64T] "i" < #4
      then "i" <-[uint64T] #0
      else #());;
      Continue).

Definition nestedLoops: val :=
  λ: <>,
    let: "i" := ref #0 in
    (for: (#true); (Skip) :=
      let: "j" := ref #0 in
      (for: (#true); (Skip) :=
        (if: #true
        then Break
        else
          "j" <-[uint64T] ![uint64T] "j" + #1;;
          Continue));;
      "i" <-[uint64T] ![uint64T] "i" + #1;;
      Continue).

Definition nestedGoStyleLoops: val :=
  λ: <>,
    let: "i" := ref #0 in
    (for: (![uint64T] "i" < #10); ("i" <-[uint64T] ![uint64T] "i" + #1) :=
      let: "j" := ref #0 in
      (for: (![uint64T] "j" < ![uint64T] "i"); ("j" <-[uint64T] ![uint64T] "j" + #1) :=
        (if: #true
        then Break
        else Continue));;
      Continue).

(* maps.go *)

Definition clearMap: val :=
  λ: "m",
    MapClear "m".

Definition IterateMapKeys: val :=
  λ: "m" "sum",
    MapIter "m" (λ: "k" <>,
      let: "oldSum" := ![uint64T] "sum" in
      "sum" <-[refT uint64T] "oldSum" + "k").

Definition MapSize: val :=
  λ: "m",
    MapLen "m".

(* multiple.go *)

Definition returnTwo: val :=
  λ: "p",
    (#0, #0).

Definition returnTwoWrapper: val :=
  λ: "data",
    let: ("a", "b") := returnTwo "data" in
    ("a", "b").

Definition multipleVar: val :=
  λ: "x" "y",
    #().

(* operators.go *)

Definition LogicalOperators: val :=
  λ: "b1" "b2",
    "b1" && "b2" ∥ "b1" && ~ #false.

Definition LogicalAndEqualityOperators: val :=
  λ: "b1" "x",
    ("x" = #3) && ("b1" = #true).

Definition ArithmeticShifts: val :=
  λ: "x" "y",
    to_u64 ("x" ≪ #3) + "y" ≪ to_u64 "x" + "y" ≪ #1.

Definition BitwiseOps: val :=
  λ: "x" "y",
    to_u64 "x" ∥ to_u64 (to_u32 "y") && #43.

Definition Comparison: val :=
  λ: "x" "y",
    (if: "x" < "y"
    then #true
    else
      (if: ("x" = "y")
      then #true
      else
        (if: "x" ≠ "y"
        then #true
        else
          (if: "x" > "y"
          then #true
          else
            (if: "x" + #1 > "y" - #2
            then #true
            else #false))))).

Definition AssignOps: val :=
  λ: <>,
    let: "x" := ref (zero_val uint64T) in
    "x" <-[uint64T] ![uint64T] "x" + #3;;
    "x" <-[uint64T] ![uint64T] "x" - #3;;
    "x" <-[uint64T] ![uint64T] "x" + #1;;
    "x" <-[uint64T] ![uint64T] "x" - #1.

(* panic.go *)

Definition PanicAtTheDisco: val :=
  λ: <>,
    Panic "disco".

(* reassign.go *)

Module composite.
  Definition S := struct.decl [
    "a" :: uint64T;
    "b" :: uint64T
  ].
End composite.

Definition ReassignVars: val :=
  λ: <>,
    let: "x" := ref (zero_val uint64T) in
    let: "y" := #0 in
    "x" <-[uint64T] #3;;
    let: "z" := ref (struct.mk composite.S [
      "a" ::= ![uint64T] "x";
      "b" ::= "y"
    ]) in
    "z" <-[struct.t composite.S] struct.mk composite.S [
      "a" ::= "y";
      "b" ::= ![uint64T] "x"
    ];;
    "x" <-[uint64T] struct.get composite.S "a" (![struct.t composite.S] "z").

(* replicated_disk.go *)

Module Block.
  Definition S := struct.decl [
    "Value" :: uint64T
  ].
End Block.

Definition Disk1 : expr := #0.

Definition Disk2 : expr := #0.

Definition DiskSize : expr := #1000.

(* TwoDiskWrite is a dummy function to represent the base layer's disk write *)
Definition TwoDiskWrite: val :=
  λ: "diskId" "a" "v",
    #true.

(* TwoDiskRead is a dummy function to represent the base layer's disk read *)
Definition TwoDiskRead: val :=
  λ: "diskId" "a",
    (struct.mk Block.S [
       "Value" ::= #0
     ], #true).

(* TwoDiskLock is a dummy function to represent locking an address in the
   base layer *)
Definition TwoDiskLock: val :=
  λ: "a",
    #().

(* TwoDiskUnlock is a dummy function to represent unlocking an address in the
   base layer *)
Definition TwoDiskUnlock: val :=
  λ: "a",
    #().

Definition ReplicatedDiskRead: val :=
  λ: "a",
    TwoDiskLock "a";;
    let: ("v", "ok") := TwoDiskRead Disk1 "a" in
    (if: "ok"
    then
      TwoDiskUnlock "a";;
      "v"
    else
      let: ("v2", <>) := TwoDiskRead Disk2 "a" in
      TwoDiskUnlock "a";;
      "v2").

Definition ReplicatedDiskWrite: val :=
  λ: "a" "v",
    TwoDiskLock "a";;
    TwoDiskWrite Disk1 "a" "v";;
    TwoDiskWrite Disk2 "a" "v";;
    TwoDiskUnlock "a".

Definition ReplicatedDiskRecover: val :=
  λ: <>,
    let: "a" := ref #0 in
    (for: (#true); (Skip) :=
      (if: ![uint64T] "a" > DiskSize
      then Break
      else
        let: ("v", "ok") := TwoDiskRead Disk1 (![uint64T] "a") in
        (if: "ok"
        then
          TwoDiskWrite Disk2 (![uint64T] "a") "v";;
          #()
        else #());;
        "a" <-[uint64T] ![uint64T] "a" + #1;;
        Continue)).

(* semantics.go *)

(* test that encoding and decoding roundtrips *)
Definition roundtripEncDec32: val :=
  λ: "x",
    let: "r" := NewSlice byteT #4 in
    let: "e" := struct.new Enc.S [
      "p" ::= "r"
    ] in
    let: "d" := struct.new Dec.S [
      "p" ::= "r"
    ] in
    Enc__UInt32 "e" "x";;
    Dec__UInt32 "d".

Definition testEncDec32: val :=
  λ: "x",
    (roundtripEncDec32 "x" = "x").

Definition roundtripEncDec64: val :=
  λ: "x",
    let: "r" := NewSlice byteT #8 in
    let: "e" := struct.new Enc.S [
      "p" ::= "r"
    ] in
    let: "d" := struct.new Dec.S [
      "p" ::= "r"
    ] in
    Enc__UInt64 "e" "x";;
    Dec__UInt64 "d".

Definition testEncDec64: val :=
  λ: "x",
    (roundtripEncDec64 "x" = "x").

(* test that y defaults to 0 and subtraction always reverses addition *)
Definition reverseAssignOps64: val :=
  λ: "x",
    let: "y" := ref (zero_val uint64T) in
    "y" <-[uint64T] ![uint64T] "y" + "x";;
    "y" <-[uint64T] ![uint64T] "y" - "x";;
    "y" <-[uint64T] ![uint64T] "y" + #1;;
    "y" <-[uint64T] ![uint64T] "y" - #1;;
    ![uint64T] "y".

Definition testReverseAssignOps64: val :=
  λ: "x",
    (reverseAssignOps64 "x" = #0).

Definition reverseAssignOps32: val :=
  λ: "x",
    let: "y" := ref (zero_val uint32T) in
    "y" <-[uint32T] ![uint32T] "y" + "x";;
    "y" <-[uint32T] ![uint32T] "y" - "x";;
    "y" <-[uint32T] ![uint32T] "y" + #1;;
    "y" <-[uint32T] ![uint32T] "y" - #1;;
    ![uint32T] "y".

Definition testReverseAssignOps32: val :=
  λ: "x",
    (reverseAssignOps32 "x" = #(U32 0)).

(* test shortcircuiting behaviors for logical operators *)
Module BoolTest.
  Definition S := struct.decl [
    "t" :: boolT;
    "f" :: boolT;
    "tc" :: uint64T;
    "fc" :: uint64T
  ].
End BoolTest.

Definition CheckTrue: val :=
  λ: "b",
    struct.storeF BoolTest.S "tc" "b" (struct.loadF BoolTest.S "tc" "b" + #1);;
    struct.loadF BoolTest.S "t" "b".

Definition CheckFalse: val :=
  λ: "b",
    struct.storeF BoolTest.S "fc" "b" (struct.loadF BoolTest.S "fc" "b" + #1);;
    struct.loadF BoolTest.S "f" "b".

Definition testShortcircuitAndTF: val :=
  λ: <>,
    let: "b" := struct.new BoolTest.S [
      "t" ::= #true;
      "f" ::= #false;
      "tc" ::= #0;
      "fc" ::= #0
    ] in
    (if: CheckTrue "b" && CheckFalse "b"
    then #false
    else (struct.loadF BoolTest.S "tc" "b" = #1) && (struct.loadF BoolTest.S "fc" "b" = #1)).

Definition testShortcircuitAndFT: val :=
  λ: <>,
    let: "b" := struct.new BoolTest.S [
      "t" ::= #true;
      "f" ::= #false;
      "tc" ::= #0;
      "fc" ::= #0
    ] in
    (if: CheckFalse "b" && CheckTrue "b"
    then #false
    else (struct.loadF BoolTest.S "tc" "b" = #0) && (struct.loadF BoolTest.S "fc" "b" = #1)).

Definition testShortcircuitOrTF: val :=
  λ: <>,
    let: "b" := struct.new BoolTest.S [
      "t" ::= #true;
      "f" ::= #false;
      "tc" ::= #0;
      "fc" ::= #0
    ] in
    (if: CheckTrue "b" ∥ CheckFalse "b"
    then (struct.loadF BoolTest.S "tc" "b" = #1) && (struct.loadF BoolTest.S "fc" "b" = #0)
    else #false).

Definition testShortcircuitOrFT: val :=
  λ: <>,
    let: "b" := struct.new BoolTest.S [
      "t" ::= #true;
      "f" ::= #false;
      "tc" ::= #0;
      "fc" ::= #0
    ] in
    (if: CheckFalse "b" ∥ CheckTrue "b"
    then (struct.loadF BoolTest.S "tc" "b" = #1) && (struct.loadF BoolTest.S "fc" "b" = #1)
    else #false).

(* test integer overflow and underflow *)
Definition testAdd64Equals: val :=
  λ: "x" "y" "z",
    ("x" + "y" = "z").

Definition testMinus64Equals: val :=
  λ: "x" "y" "z",
    ("x" - "y" = "z").

(* test side-effects on array writes from multiple accessors *)
Module ArrayEditor.
  Definition S := struct.decl [
    "s" :: slice.T uint64T;
    "next_val" :: uint64T
  ].
End ArrayEditor.

Definition ArrayEditor__Advance: val :=
  λ: "ae" "arr" "next",
    SliceSet uint64T "arr" #0 (SliceGet uint64T "arr" #0 + #1);;
    SliceSet uint64T (struct.loadF ArrayEditor.S "s" "ae") #0 (struct.loadF ArrayEditor.S "next_val" "ae");;
    struct.storeF ArrayEditor.S "next_val" "ae" "next";;
    struct.storeF ArrayEditor.S "s" "ae" (SliceSkip uint64T (struct.loadF ArrayEditor.S "s" "ae") #1).

Definition testOverwriteArray: val :=
  λ: <>,
    let: "arr" := ref (NewSlice uint64T #4) in
    let: "ae1" := struct.mk ArrayEditor.S [
      "s" ::= SliceSkip uint64T (![slice.T uint64T] "arr") #0;
      "next_val" ::= #1
    ] in
    let: "ae2" := struct.mk ArrayEditor.S [
      "s" ::= SliceSkip uint64T (![slice.T uint64T] "arr") #1;
      "next_val" ::= #102
    ] in
    ArrayEditor__Advance "ae2" (![slice.T uint64T] "arr") #103;;
    ArrayEditor__Advance "ae2" (![slice.T uint64T] "arr") #104;;
    ArrayEditor__Advance "ae2" (![slice.T uint64T] "arr") #105;;
    ArrayEditor__Advance "ae1" (![slice.T uint64T] "arr") #2;;
    ArrayEditor__Advance "ae1" (![slice.T uint64T] "arr") #3;;
    ArrayEditor__Advance "ae1" (![slice.T uint64T] "arr") #4;;
    ArrayEditor__Advance "ae1" (![slice.T uint64T] "arr") #5;;
    (if: SliceGet uint64T (![slice.T uint64T] "arr") #0 + SliceGet uint64T (![slice.T uint64T] "arr") #1 + SliceGet uint64T (![slice.T uint64T] "arr") #2 + SliceGet uint64T (![slice.T uint64T] "arr") #3 ≥ #100
    then #false
    else (SliceGet uint64T (![slice.T uint64T] "arr") #3 = #4) && (SliceGet uint64T (![slice.T uint64T] "arr") #0 = #4)).

(* advances the array editor, and returns the value it wrote, storing "next" in next_val *)
Definition ArrayEditor__AdvanceReturn: val :=
  λ: "ae" "next",
    let: "tmp" := ref (struct.loadF ArrayEditor.S "next_val" "ae") in
    SliceSet uint64T (struct.loadF ArrayEditor.S "s" "ae") #0 (![uint64T] "tmp");;
    struct.storeF ArrayEditor.S "next_val" "ae" "next";;
    struct.storeF ArrayEditor.S "s" "ae" (SliceSkip uint64T (struct.loadF ArrayEditor.S "s" "ae") #1);;
    ![uint64T] "tmp".

(* we call this function with side-effectful function calls as arguments,
   its implementation is unimportant *)
Definition addFour64: val :=
  λ: "a" "b" "c" "d",
    "a" + "b" + "c" + "d".

Module Pair.
  Definition S := struct.decl [
    "x" :: uint64T;
    "y" :: uint64T
  ].
End Pair.

Definition testFunctionOrdering: val :=
  λ: <>,
    let: "arr" := ref (NewSlice uint64T #5) in
    let: "ae1" := struct.mk ArrayEditor.S [
      "s" ::= SliceSkip uint64T (![slice.T uint64T] "arr") #0;
      "next_val" ::= #1
    ] in
    let: "ae2" := struct.mk ArrayEditor.S [
      "s" ::= SliceSkip uint64T (![slice.T uint64T] "arr") #0;
      "next_val" ::= #101
    ] in
    (if: ArrayEditor__AdvanceReturn "ae1" #2 + ArrayEditor__AdvanceReturn "ae2" #102 ≠ #102
    then #false
    else
      (if: SliceGet uint64T (![slice.T uint64T] "arr") #0 ≠ #101
      then #false
      else
        (if: addFour64 (ArrayEditor__AdvanceReturn "ae1" #3) (ArrayEditor__AdvanceReturn "ae2" #103) (ArrayEditor__AdvanceReturn "ae2" #104) (ArrayEditor__AdvanceReturn "ae1" #4) ≠ #210
        then #false
        else
          (if: SliceGet uint64T (![slice.T uint64T] "arr") #1 ≠ #102
          then #false
          else
            (if: SliceGet uint64T (![slice.T uint64T] "arr") #2 ≠ #3
            then #false
            else
              let: "p" := struct.mk Pair.S [
                "x" ::= ArrayEditor__AdvanceReturn "ae1" #5;
                "y" ::= ArrayEditor__AdvanceReturn "ae2" #105
              ] in
              (if: SliceGet uint64T (![slice.T uint64T] "arr") #3 ≠ #104
              then #false
              else
                let: "q" := struct.mk Pair.S [
                  "y" ::= ArrayEditor__AdvanceReturn "ae1" #6;
                  "x" ::= ArrayEditor__AdvanceReturn "ae2" #106
                ] in
                (if: SliceGet uint64T (![slice.T uint64T] "arr") #4 ≠ #105
                then #false
                else (struct.get Pair.S "x" "p" + struct.get Pair.S "x" "q" = #109)))))))).

(* slices.go *)

Definition SliceAlias: ty := slice.T boolT.

Definition sliceOps: val :=
  λ: <>,
    let: "x" := NewSlice uint64T #10 in
    let: "v1" := SliceGet uint64T "x" #2 in
    let: "v2" := SliceSubslice uint64T "x" #2 #3 in
    let: "v3" := SliceTake "x" #3 in
    let: "v4" := SliceRef "x" #2 in
    "v1" + SliceGet uint64T "v2" #0 + SliceGet uint64T "v3" #1 + ![uint64T] "v4".

Definition makeSingletonSlice: val :=
  λ: "x",
    SliceSingleton "x".

Module thing.
  Definition S := struct.decl [
    "x" :: uint64T
  ].
End thing.

Module sliceOfThings.
  Definition S := struct.decl [
    "things" :: slice.T (struct.t thing.S)
  ].
End sliceOfThings.

Definition sliceOfThings__getThingRef: val :=
  λ: "ts" "i",
    SliceRef (struct.get sliceOfThings.S "things" "ts") "i".

Definition makeAlias: val :=
  λ: <>,
    NewSlice boolT #10.

(* spawn.go *)

(* Skip is a placeholder for some impure code *)
Definition Skip: val :=
  λ: <>,
    #().

Definition simpleSpawn: val :=
  λ: <>,
    let: "l" := lock.new #() in
    let: "v" := ref (zero_val uint64T) in
    Fork (lock.acquire "l";;
          let: "x" := ![uint64T] "v" in
          (if: "x" > #0
          then
            Skip #();;
            #()
          else #());;
          lock.release "l");;
    lock.acquire "l";;
    "v" <-[refT uint64T] #1;;
    lock.release "l".

Definition threadCode: val :=
  λ: "tid",
    #().

Definition loopSpawn: val :=
  λ: <>,
    let: "i" := ref #0 in
    (for: (![uint64T] "i" < #10); ("i" <-[uint64T] ![uint64T] "i" + #1) :=
      let: "i" := ![uint64T] "i" in
      Fork (threadCode "i");;
      Continue);;
    let: "dummy" := ref #true in
    (for: (#true); (Skip) :=
      "dummy" <-[boolT] ~ (![boolT] "dummy");;
      Continue).

(* strings.go *)

Definition stringAppend: val :=
  λ: "s" "x",
    #(str"prefix ") + "s" + #(str" ") + uint64_to_string "x".

Definition stringLength: val :=
  λ: "s",
    strLen "s".

(* struct_method.go *)

Module Point.
  Definition S := struct.decl [
    "x" :: uint64T;
    "y" :: uint64T
  ].
End Point.

Definition Point__Add: val :=
  λ: "c" "z",
    struct.get Point.S "x" "c" + struct.get Point.S "y" "c" + "z".

Definition Point__GetField: val :=
  λ: "c",
    let: "x" := struct.get Point.S "x" "c" in
    let: "y" := struct.get Point.S "y" "c" in
    "x" + "y".

Definition UseAdd: val :=
  λ: <>,
    let: "c" := struct.mk Point.S [
      "x" ::= #2;
      "y" ::= #3
    ] in
    let: "r" := Point__Add "c" #4 in
    "r".

Definition UseAddWithLiteral: val :=
  λ: <>,
    let: "r" := Point__Add (struct.mk Point.S [
      "x" ::= #2;
      "y" ::= #3
    ]) #4 in
    "r".

(* struct_pointers.go *)

Module TwoInts.
  Definition S := struct.decl [
    "x" :: uint64T;
    "y" :: uint64T
  ].
End TwoInts.

Module S.
  Definition S := struct.decl [
    "a" :: uint64T;
    "b" :: struct.t TwoInts.S;
    "c" :: boolT
  ].
End S.

Definition NewS: val :=
  λ: <>,
    struct.new S.S [
      "a" ::= #2;
      "b" ::= struct.mk TwoInts.S [
        "x" ::= #1;
        "y" ::= #2
      ];
      "c" ::= #true
    ].

Definition S__readA: val :=
  λ: "s",
    struct.loadF S.S "a" "s".

Definition S__readB: val :=
  λ: "s",
    struct.loadF S.S "b" "s".

Definition S__readBVal: val :=
  λ: "s",
    struct.get S.S "b" "s".

Definition S__writeB: val :=
  λ: "s" "two",
    struct.storeF S.S "b" "s" "two".

Definition S__negateC: val :=
  λ: "s",
    struct.storeF S.S "c" "s" (~ (struct.loadF S.S "c" "s")).

Definition S__refC: val :=
  λ: "s",
    struct.fieldRef S.S "c" "s".

Definition localSRef: val :=
  λ: <>,
    let: "s" := ref (zero_val (struct.t S.S)) in
    struct.fieldRef S.S "b" "s".

Definition setField: val :=
  λ: <>,
    let: "s" := ref (zero_val (struct.t S.S)) in
    struct.storeF S.S "a" "s" #0;;
    struct.storeF S.S "c" "s" #true;;
    ![struct.t S.S] "s".

(* synchronization.go *)

(* DoSomeLocking uses the entire lock API *)
Definition DoSomeLocking: val :=
  λ: "l",
    lock.acquire "l";;
    lock.release "l".

Definition makeLock: val :=
  λ: <>,
    let: "l" := lock.new #() in
    DoSomeLocking "l".

(* type_alias.go *)

Definition u64: ty := uint64T.

Definition Timestamp: ty := uint64T.

Definition UseTypeAbbrev: ty := u64.

Definition UseNamedType: ty := Timestamp.

Definition convertToAlias: val :=
  λ: <>,
    let: "x" := #2 in
    "x".
