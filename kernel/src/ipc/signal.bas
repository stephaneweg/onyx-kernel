

constructor Signal()
    value = 0
    ThreadQueue = 0
    nextSignal = Signals
    Signals = @this
end constructor

destructor Signal()
    dim s as Signal ptr = Signals
    if (s=@this) then
        Signals = this.NextSignal
    else
        while s<>0
            if (s->NextSignal = @this) then
                s->NextSignal = this.NextSignal
                exit while
            end if
            s=s->NextSignal
        wend
    end if
end destructor


function Signal.Wait(th as Thread ptr) as unsigned integer
    if (value = 1) then 
        value = 0
        return 1
    else
        th->State = WaitingSignal
        
        th->NextThreadQueue = this.ThreadQueue
        this.ThreadQueue = th
    end if
    return 0
end function

sub Signal.Set()
    if (Value = 0) then
        value = 1
        var t = this.ThreadQueue
        this.ThreadQueue = 0
        
        while (t<>0)
            var n = t->NextThreadQueue
            t->NextThreadQueue = 0
            t->PrevThreadQueue = 0
            Scheduler.SetThreadReadyNow(t)
            t = n
        wend
    end if
end sub