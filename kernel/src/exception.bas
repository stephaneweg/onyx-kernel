function PanicException(msg as unsigned byte ptr,stack as IRQ_Stack ptr) as IRQ_Stack ptr
    
   
    
    if ( Scheduler.CurrentRuningThread<>0) then
        var pc = Scheduler.CurrentRuningThread->Owner
        if (pc<>0) then
            ConsoleWrite(msg)
            ConsoleWriteLine(@" : killing process")
            Process.RequestTerminate(pc)
            Scheduler.CurrentRuningThread=0
            return Scheduler.Switch(stack, Scheduler.Schedule())
        end if
    end if
    
    
    
    asm cli
    VMM_EXIT()
    CurrentConsole = @SysConsole
    VesaResetScreen()
    SysConsole.VIRT = cptr(any ptr,&hB8000)
    stack=current_context->Resolve(stack)
    var th = cptr(Thread ptr,current_context->Resolve(SCheduler.CurrentRuningThread))
    ConsoleWriteLine(msg)
    'if (Scheduler.CurrentRuningThread<>0) then
        ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
        ConsoleWriteTextAndHex(@"   Current Thread ID : ",th->ID,true)
        'ConsoleWriteTextAndHex(@"   Current Thread : ",Cuint(SCheduler.CurrentRuningThread),true)
        'ConsoleWriteTextAndHex(@"   IDLE Thread : ",Cuint(IDLE_Thread),true)
        'ConsoleWriteTextAndHex(@"   KERNEL_IDLE : ",cuint(@KERNEL_IDLE),true)
    'else
    '    ConsoleWriteLine(@"No runing thread")
    'end if
    do:loop
    return stack
end function

function ExceptionHandler(stack as IRQ_STACK ptr) as IRQ_Stack ptr
    dim intno as unsigned integer = stack->intno
    var pc = Scheduler.CurrentRuningThread->Owner
    
    select case intno
        case &h0
            return PanicException(@"Divide by zero",stack)
        case &h1
            return PanicException(@"Debug",stack)
        case &h2
            return PanicException(@"NON Maskable interupt",stack)
        case &h3
            return PanicException(@"Break point",stack)
        case &h4
            return PanicException(@"OverFlow",stack)
        case &h5
            return PanicException(@"Bound range exceeded",stack)
        case &h6
            return PanicException(@"Invalid IPCode",stack)
        case &h7
            return PanicException(@"Device not available",stack)
        case &h8
            return PanicException(@"Double fault",stack)
        case &hA
            return PanicException(@"Invalid TSS",stack)
        case &hB
            return PanicException(@"Segment not present",stack)
        case &hC
            return PanicException(@"Stack segment fault",stack)
        case &hD
            return PanicException(@"General Protection fault",stack)
        case &hE
            if (pc<>0) then
                IRQ_DISABLE(0)
                ConsoleWriteLine(@"Page fault : killing process")
                Process.RequestTerminate(pc)
                Scheduler.CurrentRuningThread=0
                IRQ_ENABLE(0)
                return Scheduler.Switch(stack, Scheduler.Schedule())
            else
                dim acr2 as unsigned integer
                asm cli
                asm
                    mov ebx,cr2
                    mov [acr2],ebx
                end asm
                VMM_EXIT()
                CurrentConsole = @SysConsole
                VesaResetScreen()
                SysConsole.VIRT = cptr(any ptr,&hB8000)
                ConsoleSetBackGround(4)
                ConsoleSetForeground(15)
                ConsoleClear()
                
                ConsoleWriteLine(@"Page fault")                       
                ConsoleWriteTextAndDec(@"   Code : ",stack->errCode,true)                        
                ConsoleWriteTextAndHex(@"   CR2 : ",acr2,true)                      
                ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                ConsoleWriteTextAndHex(@"   PHYS : ",cuint(current_context->RESOLVE(cptr(any ptr,acr2 ))),true)
                ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                do:loop
            end if
        case &h10
            return PanicException(@"Floating point exception",stack)
        case &h11
            return PanicException(@"Alignment check",stack)
        case &h12
            return PanicException(@"Machine check",stack)
        case &h13
            return PanicException(@"SIMD Floating-point exception",stack)
        case &h14
            return PanicException(@"Virtualization exception",stack)
        case &h1E
            return PanicException(@"Security exception",stack)
    end select
    return stack
end function