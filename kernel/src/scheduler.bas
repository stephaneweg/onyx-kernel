constructor ThreadQueue()
    this.FirstThread = 0
    this.LastThread = 0
    this.count = 0
end constructor


'enqueue at the begining of the queue
sub ThreadQueue.EnqueueHead(t as Thread ptr)
    t->NextThreadQueue = this.FirstThread
    this.FirstThread = t
    if (this.LastThread=0) then
        this.LastThread = t
    end if
    this.Count += 1
end sub

'enqueue at the end of the queue
sub ThreadQueue.EnqueueTail(t as Thread ptr)
    if (this.FirstThread<>0) then
        this.LastThread->NextThreadQueue = t
    else
        this.FirstThread = t
    end if
    this.LastThread = t
    this.Count += 1
    t->NextThreadQueue = 0
end sub

function ThreadQueue.Dequeue() as Thread ptr
    dim t as Thread ptr =  this.FirstThread
    if (t<>0) then
        this.FirstThread = t->NextThreadQueue
        if (this.FirstThread = 0) then this.LastThread = 0
        t->NextThreadQueue = 0
		this.Count-=1
    end if
    return t
end function


function ThreadQueue.RTCDequeue() as Thread ptr
    dim t as Thread ptr =  this.FirstThread
    dim selected as Thread ptr = 0
    while (t<>0)
            if (t->RTCDelay<TotalEllapsed) then
                selected = t
                exit while
            end if
            t=t->NextThreadQueue
    wend
    if (selected<>0) then this.Remove(selected)
    return selected
end function

sub ThreadQueue.Remove(t as Thread ptr)
    var removed = 0
    if (t = this.FirstThread) then
        this.FirstThread = t->NextThreadQueue
        removed = 1
    else
        dim th as Thread ptr =  this.FirstThread 
        while th<>0
            if (th->NextThreadQueue = t) then
                th->NextThreadQueue = t->NextThreadQueue
                if (th->NextThreadQueue=0) then this.LastThread = th
                removed = 1
                exit while
            end if
            th=>th->NextThreadQueue
        wend
    end if
    if (removed=1) then
        this.Count-=1
        if (this.FirstThread =0) then this.LastThread = 0
        t->NextThreadQueue = 0
    end if
end sub

constructor ThreadScheduler()
    NormalQueue.Constructor()
    RTCQueue.Constructor()
    CurrentRuningThread = 0
	RemovedThread = 0
end constructor


sub ThreadScheduler.RemoveThread(t as Thread ptr)
    NormalQueue.Remove(t)
    RTCQueue.Remove(t)
	if (CurrentRuningThread=t) then
		RemovedThread = t
	end if
end sub


function ThreadScheduler.Switch(_stack as IRQ_Stack ptr,newThread as Thread ptr) as IRQ_Stack ptr
    
    dim nStack as IRQ_Stack ptr = _stack
    
	if (CurrentRuningThread<>0 and CurrentRuningThread<>RemovedThread) then
		CurrentRuningThread->SavedESP = cast(unsigned integer,_stack) 
	end if
	
	CurrentRuningThread  = newThread

	CurrentRuningThread->State = ThreadState.Runing
	'consoleWrite(@"LDT index : 0x")
	'consoleWriteNumber(localldt,16)
	nstack =cptr(irq_stack ptr,CurrentRuningThread->SavedESP)
		
	KTSS.esp0 = CurrentRuningThread->SavedESP + sizeof(irq_stack)
	KTSS.SS0 = &h10
	KTSS.ds = &h10
	KTSS.es = &h10
	KTSS.fs = &h10
	KTSS.gs = &h10
	KTSS.cs = &h8
	KTSS.eflags = &h3202
    
    CurrentRuningThread->VMM_Context->Activate()
    if (CurrentRuningThread->Owner<>0) then
        CurrentRuningThread->Owner->VIRT_CONSOLE->Activate()
    else
        SysConsole.Activate()
    end if
    
	return nstack
end function


sub ThreadScheduler.SetThreadRealTime(t as Thread ptr,delay as unsigned integer)
    if (t->State=ThreadState.Ready) then exit sub
    if (delay=0) then 
        SetThreadReady(t)
        exit sub
    end if
    t->RTCDelay = TotalEllapsed+delay
    RTCQueue.EnqueueTail(t)
    t->State=ThreadState.Ready
end sub



sub ThreadScheduler.SetThreadReadyNow(t as Thread ptr)
    if (t->State=ThreadState.Ready) then exit sub
    NormalQueue.EnqueueHead(t)
    t->State=ThreadState.Ready
end sub

sub ThreadScheduler.SetThreadReady(t as Thread ptr)
    if (t->State=ThreadState.Ready) then exit sub
    NormalQueue.EnqueueTail(t)
    t->State=ThreadState.Ready
end sub


function ThreadScheduler.ThreadCount() as unsigned integer
    return NormalQueue.Count+RTCQueue.Count
end function



function ThreadScheduler.Schedule() as Thread ptr

    dim i as unsigned integer
    dim j as unsigned integer
    dim th as Thread ptr  = 0
    
    if (CurrentRuningThread<>0) then
        if (CurrentRuningThread->InCritical = 1 and CurrentRuningThread<> RemovedThread) then
            return CurrentRuningThread
        end if
    end if
	
    if (CurrentRuningThread<> RemovedThread) then
			if (CurrentRuningThread<>0 and CurrentRuningThread<>IDLE_Thread) then
				if (CurrentRuningThread->State = ThreadState.Runing) then
					SetThreadReady(CurrentRuningThread)
				end if
			end if
    else
        RemovedThread = 0
    end if
	
    th = RTCQueue.RTCDequeue()
    if (th=0) then 
        th=NormalQueue.Dequeue()
    end if
    
	
	
    if (th=0) then
        th = IDLE_Thread
        IDLE_ThreadRunCount+=1
    else
        IDLE_ThreadRunCount=0
    end if
    return th
end function




