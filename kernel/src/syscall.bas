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
        Scheduler.SetThreadReady(th,0)
      
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
        Scheduler.SetThreadReady(th,0)
      
        currentContext->Activate()
      
    end if
end sub


sub XappIRQReceived(intno as unsigned integer,p as IRQ_THREAD_POOL ptr)
    var th = cptr(Thread ptr,IRQ_THREAD_HANDLERS(intno).Owner)
    if (th<>0) then
        if (th->State=ThreadState.Waiting) then
            var proc=th->Owner
            var currentContext = vmm_get_current_context()
            proc->VMM_Context.Activate()
                
            dim st as IRQ_Stack ptr = cptr(IRQ_Stack ptr,th->SavedESP)
            st->EIP = IRQ_THREAD_HANDLERS(intno).EntryPoint
            st->ESP = st->ESP-40
            *cptr(unsigned integer ptr, st->ESP+4)  =intno
            *cptr(unsigned integer ptr, st->ESP+8)  =p->SENDERPROCESS
            *cptr(unsigned integer ptr, st->ESP+12) =p->SENDER
            *cptr(unsigned integer ptr, st->ESP+16) =p->EAX
            *cptr(unsigned integer ptr, st->ESP+20) =p->EBX
            *cptr(unsigned integer ptr, st->ESP+24) =p->ECX
            *cptr(unsigned integer ptr, st->ESP+28) =p->EDX
            *cptr(unsigned integer ptr, st->ESP+32) =p->ESI        
            *cptr(unsigned integer ptr, st->ESP+36) =p->EDI      
            *cptr(unsigned integer ptr, st->ESP+40) =p->EBP
            th->ReplyTo = cptr(Thread ptr,p->Sender)
            if (intno<&h30) then
                Scheduler.SetThreadReadyNow(th)
            else
                Scheduler.SetThreadReady(th,0)
            end if
            currentContext->Activate()
        end if
    end if
end sub