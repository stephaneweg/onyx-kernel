constructor Mutex()
    value  = 0
    ThreadQueue = 0
    NextMutex = Mutexes
    Mutexes = @this
end constructor


destructor Mutex()
    dim s as Mutex ptr = Mutexes
    
    if (s=@this) then
        Mutexes = this.NextMutex
    else
        while s<>0
            if (s->NextMutex = @this) then
                s->NextMutex = this.NextMutex
                exit while
            end if
            s = s->NextMutex
        wend
    end if
    
end destructor


            
function Mutex.Acquire(th as thread ptr) as unsigned integer
    
    'mutex is not locked
    if (value=0) then
        'increment level
        CurrentThread = th
        Value+=1
        return 1
    
    
    'mutex is already locked by this thread
    elseif (CurrentThread=th) then
        'increment level
        Value+=1
        return 1
        
    'mutex is aloready locked by another thread
    else
        ConsoleWriteLine(@"Lock on Mutex")
        'block this thread
        th->State = WaitingMutex
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

sub Mutex.Release(th as Thread ptr)
    'mutex must be loocked by this thread
    if (CurrentThread=th) and (value>0) then
        'decrement level
        Value-=1
        
        'mutex is not locked anymore
        if (value=0) then
            CurrentThread = this.ThreadQueue
            
            'if there is a pending thread, unblock the first
            if (CurrentThread<>0) then
                ConsoleWriteLine(@"Unlock on mutex")
                'increment level
                Value+=1
                'make therad read
                this.ThreadQueue = CurrentThread->NextThreadQueue
                Scheduler.SetThreadReadyNow(CurrentThread)
            end if
        end if
    end if
end sub
    