#include once "syscalls/syscall30.bas"
#include once "syscalls/syscall31.bas"

sub XappSignal2Parameters(th as Thread ptr,callback as unsigned integer,p1 as unsigned integer, p2 as unsigned integer)
    var proc = cptr(Process ptr,th->Owner)
    if (th->State = ThreadState.Waiting) then
        var currentContext = vmm_get_current_context()
        proc->VMM_Context.Activate()
        
        dim st as IRQ_Stack ptr = cptr(IRQ_Stack ptr,th->SavedESP)
        st->EIP = callback
        st->ESP = st->ESP-8
        *cptr(unsigned integer ptr, st->ESP+4) =cast(unsigned integer, p1)
        *cptr(unsigned integer ptr, st->ESP+8) =cast(unsigned integer, p2)
        'Scheduler.SetThreadReady(th,0)
        Scheduler.SetThreadReadyNow(th)
            
        currentContext->Activate()
      
    end if
end sub

sub XappSignal6Parameters(th as Thread ptr,callback as unsigned integer,p1 as unsigned integer, p2 as unsigned integer,p3 as unsigned integer,p4 as unsigned integer,p5 as unsigned integer,p6 as unsigned integer)
    var proc = cptr(Process ptr,th->Owner)
    if (th->State = ThreadState.Waiting) then
        var currentContext = vmm_get_current_context()
        proc->VMM_Context.Activate()
        
        dim st as IRQ_Stack ptr = cptr(IRQ_Stack ptr,th->SavedESP)
        st->EIP = callback
        st->ESP = st->ESP-24
        *cptr(unsigned integer ptr, st->ESP+4) =cast(unsigned integer, p1)
        *cptr(unsigned integer ptr, st->ESP+8) =cast(unsigned integer, p2)
        *cptr(unsigned integer ptr, st->ESP+12) =cast(unsigned integer, p3)
        *cptr(unsigned integer ptr, st->ESP+16) =cast(unsigned integer, p4)
        *cptr(unsigned integer ptr, st->ESP+20) =cast(unsigned integer, p5)
        *cptr(unsigned integer ptr, st->ESP+24) =cast(unsigned integer, p6)
        'force the thread to be sheduled next time because it's used by UDEV
        'Scheduler.SetThreadReady(th,0)
        Scheduler.SetThreadReadyNow(th)
            
        currentContext->Activate()
      
    end if
end sub

