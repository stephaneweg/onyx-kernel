TYPE EXECUTABLE_Header field =1
    Magic as unsigned integer
    Init  as unsigned integer
    ArgsCount as unsigned integer
    ArgsValues as unsigned byte ptr ptr
    ImageEnd as unsigned integer
end type



TYPE Process field =1
    
    Image as EXECUTABLE_Header ptr
    ImageSize as unsigned integer
    PrevProcessList as Process ptr
    NextProcessList as Process ptr
    Parent as Process ptr
    NextProcess as Process ptr
    
    Threads as any ptr
    
    VMM_Context as VMMContext
    TmpArgs as unsigned byte ptr
    ShouldFreeMem as integer
    
    VIRT_CONSOLE as VirtConsole ptr
    
    
    AddressSpace as AddressSpaceEntry ptr
    
    CodeAddressSpace as AddressSpaceEntry ptr
    HeapAddressSpace as AddressSpaceEntry ptr
    StackAddressSpace as AddressSpaceEntry ptr
    
    declare function CreateAddressSpace(virt as unsigned integer) as AddressSpaceEntry ptr
    
    declare static sub InitEngine()
    declare static function RequestLoadMem(image as EXECUTABLE_HEADER ptr,size as unsigned integer,shouldFree as unsigned integer,args as unsigned byte ptr) as Process ptr
    declare static function RequestLoadUser(mem as EXECUTABLE_HEADER ptr,fsize as unsigned integer,args as unsigned byte ptr) as Process ptr
    
    declare static sub TerminateNow(app as Process ptr)
    declare static sub RequestTerminateProcess(app as Process ptr)
    declare static sub Terminate(app as Process ptr,args as any ptr)
    
    declare constructor()
    declare destructor()
    declare sub AddThread(t as any ptr)
    declare sub DoLoad()
    declare sub DoLoadFlat()
    declare sub DoLoadElf()
    declare sub ParseArguments()
    
    declare sub FreeConsole()
    declare sub CreateConsole()
end type

'the address where the service  process can map a buffer from a client
#define ProcessMapAddress &hA0001000
#define ProcessConsoleAddress &hA0000000
'the address where the process are loaded
#define ProcessAddress      &h40000000
#define ProcessHeapAddress  &h50000000
#define ProcessStackAddress &h60000000
dim shared FirstProcessList as Process ptr
dim shared LastProcessList as Process ptr
dim shared ProcessesToTerminate as Process ptr
dim shared ProcessesToLoad as Process ptr
