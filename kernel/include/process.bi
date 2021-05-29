TYPE EXECUTABLE_Header field =1
    Magic as unsigned integer
    Init as sub(arg as any ptr)
    Update as sub(arg as any ptr)
    Clean as sub(arg as any ptr)
    ImageEnd as unsigned integer
end type



TYPE Process field =1
    
    Image as EXECUTABLE_Header ptr
    ImageSize as unsigned integer
    NextProcess as Process ptr
    
    Threads as any ptr
    
    PagesCount as integer
    
    VMM_Context as VMMContext
    ShouldFreeMem as unsigned integer
    
    declare static sub InitEngine()
    declare static function RequestLoadMem(image as EXECUTABLE_HEADER ptr,size as unsigned integer,args as any ptr,shouldFree as unsigned integer) as Process ptr
    declare static function RequestLoad(path as unsigned byte ptr,args as any ptr) as Process ptr
    
    declare static sub TerminateNow(app as Process ptr)
    declare static sub RequestTerminateProcess(app as Process ptr)
    declare static sub Terminate(app as Process ptr,args as any ptr)
    
    declare constructor()
    declare destructor()
    declare function SBRK(pagesToAdd as unsigned integer) as unsigned integer
    declare sub AddThread(t as any ptr)
    declare sub DoLoad()
    
end type

'the address where the service  process can map a buffer from a client
#define ProcessMapAddress &hA0000000
'the address where the process are loaded
#define ProcessAddress &h40000000
dim shared FirstProcess as Process ptr
dim shared ProcessesToTerminate as Process ptr
dim shared ProcessesToLoad as Process ptr
