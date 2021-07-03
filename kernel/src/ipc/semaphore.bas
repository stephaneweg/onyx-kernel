constructor Semaphore()
    value  = 0
    ThreadQueue = 0
    nextSem = Semaphores
    Semaphores = @this
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
    
    'semaphore is not locked
    if (value=0) then
        'increment level
        CurrentThread = th
        Value+=1
        return 1
    
    
    'semaphore is already locked by this thread
    elseif (CurrentThread=th) then
        'increment level
        Value+=1
        return 1
        
    'semaphore is aloready locked by another thread
    else
        ConsoleWriteLine(@"Lock on semaphore")
        'block this thread
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
    end if
    return 0
end function

sub Semaphore.SemUnlock(th as Thread ptr)
    'semaphore must be loocked by this thread
    if (CurrentThread=th) and (value>0) then
        'decrement level
        Value-=1
        
        'semaphore is not locked anymore
        if (value=0) then
            CurrentThread = this.ThreadQueue
            
            'if there is a pending thread, unblock the first
            if (CurrentThread<>0) then
                ConsoleWriteLine(@"Unlock on semaphore")
                'increment level
                Value+=1
                'make therad read
                this.ThreadQueue = CurrentThread->NextThreadQueue
                Scheduler.SetThreadReadyNow(CurrentThread)
            end if
        end if
    end if
end sub
    