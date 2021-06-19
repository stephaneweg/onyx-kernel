enum ThreadState
    created = 0
    ready = 1
    runing = 2
    waiting = 3
    waitingIRQ = 4
    waitingForMessage = 5
    WaitingSemaphore = 6
    WaitingDialog = 7
    WaitingReply = 8
    WaitingSendChannel = 9
    Terminating = 127
end enum

type Thread field=1
    IsSys as integer
	InCritical as integer
    StackAddr as unsigned integer
    ID as unsigned integer
    Owner as Process ptr
    VMM_Context as VMMContext ptr
    RTCDelay as unsigned long
    State as ThreadState
    
    NextThreadQueue as Thread ptr
    NextThreadProc as Thread ptr
    
    SavedESP as unsigned integer
    KernelStackBase as unsigned integer
    KernelStackLimit as unsigned integer
	
    'when a process do a software interrupt that is handled by another process, or it do an invoke process
    'the ReplyFrom of caller is set to the called thread addr, and ReplyTO of the called thread is set to the caller thread
    'so, the kernel known between who it should map memory when they ask to map memory to/from caller or want to read data from the caller process
    ReplyTo as Thread ptr
    ReplyFrom as Thread ptr
    declare sub AddToList()
	declare destructor()
    
    declare static sub InitManager()
    declare static sub Ready()
    declare static function CreateSys(entryPoint as sub(p as any ptr)) as thread ptr
    declare static function Create(proc as Process ptr,entryPoint as unsigned integer) as Thread ptr
    declare function DoWait(stack as IRQ_Stack ptr) as IRQ_Stack ptr
end type

declare sub PROCESS_MANAGER(p as any ptr)
declare sub KERNEL_IDLE(p as any ptr) 

declare sub EnterCritical()
declare sub ExitCritical()
declare sub ThreadSleep()

declare function int20Handler(stack as irq_stack ptr) as irq_stack ptr

dim shared TerminatedProcess as unsigned integer
dim shared IDLE_THREAD as Thread ptr
dim shared IDLE_THREADRunCount as unsigned integer
dim shared TotalEllapsed as unsigned long

