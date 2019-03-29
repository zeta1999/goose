From RecoveryRefinement.Goose Require Import base.

Module partialFile.
  Record t {model:GoModel} := mk {
    off: uint64;
    data: slice.t byte;
  }.
  Arguments mk {model}.
  Global Instance t_zero {model:GoModel} : HasGoZero t := mk (zeroValue _) (zeroValue _).
End partialFile.

Definition getUserDir {model:GoModel} (user:uint64) : proc string :=
  Ret ("user" ++ uint64_to_string user).

Definition readMessage {model:GoModel} (userDir:string) (name:string) : proc (slice.t byte) :=
  f <- FS.open userDir name;
  fileContents <- Data.newPtr (slice.t byte);
  _ <- Loop (fun pf =>
        buf <- FS.readAt f pf.(partialFile.off) 4096;
        newData <- Data.sliceAppendSlice pf.(partialFile.data) buf;
        if compare_to (slice.length buf) 4096 Lt
        then
          _ <- Data.writePtr fileContents newData;
          LoopRet tt
        else
          Continue {| partialFile.off := pf.(partialFile.off);
                      partialFile.data := newData; |}) {| partialFile.off := 0;
           partialFile.data := slice.nil _; |};
  fileData <- Data.readPtr fileContents;
  Ret fileData.

(* Pickup reads all stored messages *)
Definition Pickup {model:GoModel} (user:uint64) : proc (slice.t (slice.t byte)) :=
  userDir <- getUserDir user;
  names <- FS.list userDir;
  messages <- Data.newPtr (slice.t (slice.t byte));
  initMessages <- Data.newSlice (slice.t byte) 0;
  _ <- Data.writePtr messages initMessages;
  _ <- Loop (fun i =>
        if i == slice.length names
        then LoopRet tt
        else
          name <- Data.sliceRead names i;
          msg <- readMessage userDir name;
          oldMessages <- Data.readPtr messages;
          newMessages <- Data.sliceAppend oldMessages msg;
          _ <- Data.writePtr messages newMessages;
          Continue (i + 1)) 0;
  msgs <- Data.readPtr messages;
  Ret msgs.

Definition createTmp {model:GoModel} : proc (File * string) :=
  initID <- Data.randomUint64;
  finalFile <- Data.newPtr File;
  finalName <- Data.newPtr string;
  _ <- Loop (fun id =>
        let fname := uint64_to_string id in
        let! (f, ok) <- FS.create "tmp" fname;
        if ok
        then
          _ <- Data.writePtr finalFile f;
          _ <- Data.writePtr finalName fname;
          LoopRet tt
        else
          newID <- Data.randomUint64;
          Continue newID) initID;
  f <- Data.readPtr finalFile;
  name <- Data.readPtr finalName;
  Ret (f, name).

Definition writeTmp {model:GoModel} (data:slice.t byte) : proc string :=
  let! (f, name) <- createTmp;
  _ <- Loop (fun buf =>
        if compare_to (slice.length buf) 4096 Lt
        then
          _ <- FS.append f buf;
          LoopRet tt
        else
          _ <- FS.append f (slice.take 4096 buf);
          Continue (slice.skip 4096 buf)) data;
  _ <- FS.close f;
  Ret name.

(* Deliver stores a new message *)
Definition Deliver {model:GoModel} (user:uint64) (msg:slice.t byte) : proc unit :=
  userDir <- getUserDir user;
  tmpName <- writeTmp msg;
  initID <- Data.randomUint64;
  _ <- Loop (fun id =>
        ok <- FS.link "spool" tmpName userDir ("msg" ++ uint64_to_string id);
        if ok
        then LoopRet tt
        else
          newID <- Data.randomUint64;
          Continue newID) initID;
  FS.delete "spool" tmpName.

Definition Recover {model:GoModel} : proc unit :=
  Ret tt.