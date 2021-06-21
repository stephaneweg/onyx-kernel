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
    
    VIRT_CONSOLE as VirtConsole ptr
    
    ServerChannels as any ptr
    ClientChannels as any ptr
    
    AddressSpace as AddressSpaceEntry ptr
    
    CodeAddressSpace as AddressSpaceEntry ptr
    StackAddressSpace as AddressSpaceEntry ptr
    
    declare function CreateAddressSpace(virt as unsigned integer) as AddressSpaceEntry ptr
    declare function FindAddressSpace(virt as unsigned integer)  as AddressSpaceEntry ptr
    declare sub RemoveAddressSpace(virt as unsigned integer)
    
    declare static sub InitEngine()
    declare static function Create(image as EXECUTABLE_HEADER ptr,size as unsigned integer,args as unsigned byte ptr) as Process ptr
    
    declare static sub Terminate(app as Process ptr)
    declare static sub RequestTerminate(app as Process ptr)
    
    declare constructor()
    declare destructor()
    declare sub AddThread(t as any ptr)
    declare sub DoLoad()
    declare function DoLoadFlat() as unsigned integer
    declare function DoLoadElf() as unsigned integer
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
dim shared ProcessToTerminate as Process ptr
