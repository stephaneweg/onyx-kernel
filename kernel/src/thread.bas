
dim shared TotalThreadCount as unsigned integer
dim shared ThreadIDS as unsigned integer
dim shared CriticalCount as unsigned integer

sub EnterCritical()
    if (Scheduler.CurrentRuningThread<>0) then
        Scheduler.CurrentRuningThread->InCritical = 1 
    end if
end sub

sub ExitCritical()
    if (Scheduler.CurrentRuningThread<>0) then
        Scheduler.CurrentRuningThread->InCritical = 0 
    end if
end sub

sub ThreadSleep()
    asm
        mov eax,&h04 '&hE2
        int 0x30
    end asm
end sub



sub Thread.InitManager()
        TotalEllapsed = 0
        CriticalCount = 0
        TotalThreadCount = 0
        ThreadIDS = 0
        IDLE_THREADRunCount = 0
        Scheduler.Constructor()
    
    
        IDLE_Thread = Thread.CreateSys(@KERNEL_IDLE)
        PROCESS_MANAGER_THREAD = Thread.CreateSys(@PROCESS_MANAGER)
end sub

sub Thread.Ready()
   
    IRQ_ATTACH_HANDLER(&h20,@Int20Handler)
    set_timer_freq(500)
    IRQ_ENABLE(0)
    
end sub


sub PROCESS_MANAGER(p as any ptr)
    do
        if (ProcessesToTerminate<>0) then
            while (ProcessesToTerminate<>0)
                var proc = ProcessesToTerminate
                ProcessesToTerminate = proc->NextProcess
                Process.Terminate(proc,0)
            wend
        end if
        
        if (ProcessesToTerminate=0) then
            ThreadSleep()
        end if
    loop
end sub



sub KERNEL_IDLE(p as any ptr) 
    do
        asm hlt
    loop
end sub

function int20Handler(stack as irq_stack ptr) as irq_stack ptr
	TotalEllapsed+=2
    dim nextThread as Thread ptr = 0
     nextThread = Scheduler.Schedule()
    
    if (nextThread<>0) then
        return Scheduler.Switch(stack,nextThread)
    else
        KERNEL_ERROR(@"Could not find a thread to activate",0)
    end if
	return stack
end function

destructor Thread()
	if (IsSys=1) then KMM_FREEPAGE(cptr(any ptr,stackAddr))
    ReplyTo = 0
	IsSys = 0
	StackAddr = 0
	ID = 0
	InCritical =0
	Owner = 0
    VMM_Context = 0
	State = 0
	NextThreadQueue = 0
	NextThreadProc = 0
	SavedESP = 0
    KMM_FREEPAGE(cptr(any ptr,KernelStackBase))
	
	KernelStackBase = 0
	KernelStackLimit = 0
    
	TotalThreadCount-=1
end destructor

function Thread.CreateSys(entryPoint as sub(p as any ptr)) as Thread ptr
    dim th as Thread ptr = cptr(Thread ptr,KAlloc(sizeof(Thread)))
    
    TotalThreadCount+=1
    ThreadIDS+=1    
    
    th->IsSys = 1
    th->ReplyTo = 0
	th->InCritical = 0
    th->RTCDelay = 0
    th->StackAddr = cuint(KMM_ALLOCPAGE())
    th->ID = ThreadIDS
    th->Owner = 0
    th->VMM_Context = @kernel_context
    th->State = ThreadState.created
    th->NextThreadQueue = 0
    th->NextThreadProc = 0
    
    th->KernelStackBase = cuint(KMM_ALLOCPAGE())
    th->KernelStackLimit = th->KernelStackBase + (1 shl 12)-4
    th->SavedESP = th->KernelStackLimit - sizeof(irq_stack)
    
    th->RTCDelay = 0
    
    'configure the process's context
    var st = cptr(irq_stack ptr,th->SavedESP)
    st->EAX = 0
    st->EBX = 0
    st->ECX = 0
    st->EDX = 0
    st->ESI = 0
    st->EDI = 0
    st->EIP = cuint(entryPoint)
    st->cs = &h8 
    st->ds = &h10 
    st->es = &h10 
    st->ss = &h10
    st->fs = &h10
    st->gs = &h10
    st->ESP = (th->StackAddr + (1 shl 12)) -4
    st->eflags = &h3202
    
    
    th->AddToList()
    Scheduler.SetThreadReady(th)
    return th
end function

function Thread.Create(proc as Process ptr,entryPoint as unsigned integer) as Thread ptr
    dim th as Thread ptr = cptr(Thread ptr,KAlloc(sizeof(Thread)))
    
    TotalThreadCount+=1
    ThreadIDS+=1    
    
    th->IsSys = 0
    th->ReplyTo = 0
	th->InCritical = 0
    th->StackAddr = 0
    th->ID = ThreadIDS
    th->Owner = proc
    th->VMM_Context = @proc->VMM_Context
    th->State = ThreadState.created
    th->NextThreadQueue = 0
    th->NextThreadProc = 0
    
    th->KernelStackBase = cuint(KMM_ALLOCPAGE())
    th->KernelStackLimit = th->KernelStackBase + (1 shl 12)-4
    th->SavedESP = th->KernelStackLimit - sizeof(irq_stack) 
    
    
    'configure the process's context
    var st = cptr(irq_stack ptr,th->SavedESP)
    st->EAX = 0
    st->EBX = 0
    st->ECX = 0
    st->EDX = 0
    st->ESI = 0
    st->EDI = 0
    st->EIP = entrypoint
    st->cs = &h18 or &h03
    st->ds = &h20 or &h03
    st->es = &h20 or &h03
    st->ss = &h20 or &h03
    st->fs = &h20 or &h03
    st->gs = &h20 or &h03
    st->ESP = cuint(proc->StackAddressSpace->SBRK(1)) + PAGE_SIZE - 8
    st->eflags = &h3202
    
    
    th->AddToList()
    return th
end function

sub Thread.AddToList()
    
    
    if (this.Owner<>0) then
        this.Owner->AddThread(@this)
    end if
end sub

function Thread.DoWait(stack as IRQ_Stack ptr) as IRQ_Stack ptr
    this.State=ThreadState.waiting
    
    var ep = FirstIPCEndPoint
    while ep<>0
        if (ep->Owner = @this) then
            ep->ProcessReceive()
        end if
        ep=ep->NextEndPoint
    wend
    
    
    
    return Scheduler.Switch(stack,Scheduler.Schedule()) 
end function