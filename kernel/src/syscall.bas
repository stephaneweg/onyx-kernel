#include once "syscalls/syscall30.bas"
#include once "syscalls/syscall31.bas"
'#include once "syscalls/syscall32.bas"
#include once "syscalls/syscall33.bas"

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

sub XappIRQReceived(intno as unsigned integer,p as IRQ_THREAD_POOL ptr)
    var th = cptr(Thread ptr,IRQ_THREAD_HANDLERS(intno).Owner)
    if (th<>0) then
        if (th->State=ThreadState.Waiting) then
            var proc=th->Owner
            var currentContext = vmm_get_current_context()
            proc->VMM_Context.Activate()
                
            dim st as IRQ_Stack ptr = cptr(IRQ_Stack ptr,th->SavedESP)
            st->EIP = IRQ_THREAD_HANDLERS(intno).EntryPoint
            st->ESP = st->ESP-36
            *cptr(unsigned integer ptr, st->ESP+4)  =intno
            *cptr(unsigned integer ptr, st->ESP+8)  =p->SENDER
            *cptr(unsigned integer ptr, st->ESP+12) =p->EAX
            *cptr(unsigned integer ptr, st->ESP+16) =p->EBX
            *cptr(unsigned integer ptr, st->ESP+20) =p->ECX
            *cptr(unsigned integer ptr, st->ESP+24) =p->EDX
            *cptr(unsigned integer ptr, st->ESP+28) =p->ESI        
            *cptr(unsigned integer ptr, st->ESP+32) =p->EDI      
            *cptr(unsigned integer ptr, st->ESP+36) =p->EBP
            th->ReplyTo = cptr(Thread ptr,p->Sender)
            Scheduler.SetThreadReady(th,0)
                
            currentContext->Activate()
        end if
    end if
end sub