constructor ThreadQueue()
    this.FirstThread = 0
    this.LastThread = 0
end constructor


'enqueue at the begining of the queue
sub ThreadQueue.EnqueueHead(t as Thread ptr)
    t->NextThreadQueue = this.FirstThread
    t->PrevThreadQueue = 0
    t->Queue = @this
    if (this.FirstThread<>0) then this.FirstThread->PrevThreadQueue = t
    
    if (this.LastThread=0) then
        this.LastThread = t
    end if
    
    this.FirstThread = t
end sub

'enqueue at the end of the queue
sub ThreadQueue.EnqueueTail(t as Thread ptr)
    t->NextThreadQueue = 0
    t->PrevThreadQueue = this.LastThread
    t->Queue = @this
    
    if (this.LastThread<>0) then this.LastThread->NextThreadQueue = t
    
    if (this.FirstThread=0) then
        this.FirstThread = t
    end if
    
    this.LastThread = t
end sub

function ThreadQueue.Dequeue() as Thread ptr
    dim t as Thread ptr =  this.FirstThread
    
    if (t<>0) then
        this.FirstThread = t->NextThreadQueue
        if (this.FirstThread = 0) then this.LastThread = 0
        t->NextThreadQueue = 0
        t->PrevThreadQueue = 0
        t->Queue = 0
    end if
    return t
end function


function ThreadQueue.RTCDequeue() as Thread ptr
    dim t as Thread ptr =  this.FirstThread
    dim selected as Thread ptr = 0
    while (t<>0)
        if (t->RTCDelay<TotalEllapsed) then
            this.Remove(t)
            return t
            exit while
        end if
        t=t->NextThreadQueue
    wend
    return 0
end function

sub ThreadQueue.Remove(t as Thread ptr)
    if (t->Queue = @this) then
        if (t->PrevThreadQueue<>0) then t->PrevThreadQueue->NextThreadQueue = t->NextThreadQueue
        if (t->NextThreadQueue<>0) then t->NextThreadQueue->PrevThreadQueue = t->PrevThreadQueue
        if (this.FirstThread = t) then this.FirstThread = t->NextThreadQueue
        if (this.LastThread = t) then this.LastThread = t->PrevThreadQueue
        t->NextThreadQueue = 0
        t->PrevThreadQueue = 0
        t->Queue = 0
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
	RemovedThread = 0
	CurrentRuningThread  = newThread

	CurrentRuningThread->State = ThreadState.Runing
    
	nstack =cptr(irq_stack ptr,CurrentRuningThread->SavedESP)
		
    KTSS_SET(CurrentRuningThread->SavedESP + sizeof(irq_stack),&h8,&h10,&h3202)
    CurrentRuningThread->VMM_Context->Activate()
   
	return nstack
end function


sub ThreadScheduler.SetThreadRealTime(t as Thread ptr,delay as unsigned integer)
    if (t->State=ThreadState.Ready) then exit sub
    if (delay=0) then 
        SetThreadReady(t)
        exit sub
    end if
    t->State=ThreadState.Ready
    t->RTCDelay = TotalEllapsed+delay
    RTCQueue.EnqueueTail(t)
end sub



sub ThreadScheduler.SetThreadReadyNow(t as Thread ptr)
    if (t->State=ThreadState.Ready) then exit sub
    t->State=ThreadState.Ready
    NormalQueue.EnqueueHead(t)
end sub

sub ThreadScheduler.SetThreadReady(t as Thread ptr)
    if (t->State=ThreadState.Ready) then exit sub
    t->State=ThreadState.Ready
    NormalQueue.EnqueueTail(t)
end sub



function ThreadScheduler.Schedule() as Thread ptr
    dim i as unsigned integer
    dim j as unsigned integer
    dim th as Thread ptr  = 0
    
    if (CurrentRuningThread<>0) then
        if (CurrentRuningThread->InCritical = 1) and (CurrentRuningThread<> RemovedThread) then
            return CurrentRuningThread
        end if
    end if
	
    if (CurrentRuningThread <> RemovedThread) then
        if (CurrentRuningThread<>0)  and (CurrentRuningThread<>IDLE_Thread) then
            if (CurrentRuningThread->State = ThreadState.Runing) then
                SetThreadReady(CurrentRuningThread)
            end if
        end if
    end if
	
    th = RTCQueue.RTCDequeue()
        
    if (th=0) then 
        th=NormalQueue.Dequeue()
    end if
	
    if (th=0) then
        th = IDLE_Thread
        IDLE_ThreadRunCount+=1
    end if
    return th
end function




