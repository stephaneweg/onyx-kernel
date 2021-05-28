constructor Semaphore()
    value  = 0
    ThreadQueue = 0
    nextSem = 0
    If (Semaphores=0) then
        Semaphores=@this
    else
        this.NextSem = Semaphores
        Semaphores = @this
    end if
end constructor

destructor Semaphore()
    dim s as Semaphore ptr = Semaphores
    
    if (s=@this) then
        Semaphores = this.NextSem
    else
        while s<>0
            if (s->NextSem = @this) then
                s->NextSem = this.NextSem
                exit while
            end if
            s = s->NextSem
        wend
    end if
    
end destructor

function Semaphore.SemLock(th as thread ptr) as unsigned integer
    
    if (CurrentThread=th) then return 1
    
    Value+=1
    if (Value=1) then
        CurrentThread = th
        CurrentThread->Priority = 1
        return 1
    
    else
        th->State = WaitingSemaphore
        if (this.ThreadQueue = 0) then
            this.ThreadQueue = th
        else
            var t = this.ThreadQueue
            while t->NextThreadQueue<>0
                t = t->NextThreadQueue
            wend
            t->NextThreadQueue = th
        end if
        th->NextThreadQueue = 0
        return 0
    end if
end function

sub Semaphore.SemUnlock(th as Thread ptr)
    if (CurrentThread=th) then
        if (value>0) then
            CurrentThread->Priority = CurrentThread->BasePriority
            Value-=1
            
            CurrentThread = this.ThreadQueue
            if (CurrentThread<>0) then
                this.ThreadQueue = CurrentThread->NextThreadQueue
                Scheduler.SetThreadReady(CurrentThread,1)
            end if
        end if
    end if
end sub
    