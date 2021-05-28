function SysCall31Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr
    dim CurrentThread as Thread ptr = Scheduler.CurrentRuningThread
    select case stack->EAX
        case 1
            ConsoleWrite(cptr(unsigned byte ptr,stack->EBX))
        case 2
             ConsoleWriteLine(cptr(unsigned byte ptr,stack->EBX))
        case 3
            ConsoleWriteNumber(stack->EBX,stack->ECX)
        case 4
            ConsoleNewLine()
        case 5
            ConsolePrintOK()
        case 6
            ConsoleBackSpace()
        case 7
            ConsoleSetForeground(stack->EBX)
        case 8
            ConsolePutChar(cast(unsigned byte ,stack->EBX))
    end select
    return stack
end function