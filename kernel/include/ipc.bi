Type IPCMessageBody field = 1
	REG0            as unsigned integer    'eax
    REG1            as unsigned integer    'ebx
    REG2            as unsigned integer    'ecx
    REG3            as unsigned integer    'edx
    REG4            as unsigned integer    'esi
    REG5            as unsigned integer    'edi
    REG6            as unsigned integer    'ebp
    REG7            as unsigned integer    'ebp
end type

Type IPCMessage field = 1
    SENDER          as thread ptr
    SENDERPROCESS   as process ptr
    Body			as IPCMessageBody
    NextMessage     as IPCMessage ptr
    
    declare destructor()
end type

type IPCEndPoint    field = 1
    MAGIC           as unsigned integer
    ID              as unsigned integer
    IPCName         as unsigned byte ptr
    Owner           as thread ptr
    OwnerProcess    as process ptr
    Synchronous     as unsigned integer
    EntryPoint      as unsigned integer
    Counter         as unsigned integer
    FirstMessage    as IPCMessage ptr
    LastMessage     as IPCMessage ptr
    
    NextEndPoint    as IPCEndPoint ptr
    PrevEndPoint    as IPCEndPoint ptr
    
    declare static function NewID() as unsigned integer
    declare static function CreateID(id as unsigned integer,th as thread ptr,entry as unsigned integer,sync as unsigned integer) as IPCEndPoint ptr
    declare static function CreateName(N as unsigned byte ptr,th as thread ptr,entry as unsigned integer,sync as unsigned integer) as IPCEndPoint ptr
    declare static sub CreateCommon(ep as IPCendPoint ptr,th as thread ptr,entry as unsigned integer,sync as unsigned integer)
    declare static function FindById(id as unsigned integer) as IPCEndPoint ptr
    declare static function FindByName(n as unsigned byte ptr) as IPCEndPoint ptr
    
    declare sub Enqueue(p as IPCMessage ptr)
    declare function Dequeue() as IPCMessage ptr
    declare function ProcessReceive() as unsigned integer
    declare destructor()

end type

dim shared FirstIPCEndPoint as IPCEndPoint ptr
dim shared LastIPCEndPoint as IPCEndPoint ptr
dim shared IPCIds as unsigned integer

declare function IPCSendBody(_
    id as unsigned integer,th as Thread ptr,_
    body as IPCMessageBody ptr) as unsigned integer
    
declare function IPCSend(_
    id as unsigned integer,th as Thread ptr,_
    r0 as unsigned integer,r1 as unsigned integer,r2 as unsigned integer,r3 as unsigned integer,_
    r4 as unsigned integer,r5 as unsigned integer,r6 as unsigned integer,r7 as unsigned integer) as unsigned integer
    
    
declare sub IPC_INIT()