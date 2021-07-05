function SysCall31Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr
    dim CurrentThread as Thread ptr = Scheduler.CurrentRuningThread
    select case stack->EAX
        case 0
            dim pip as STD_PIPE ptr = CurrentThread->Owner->GET_OUT(0)
            if (pip<>0) then
                pip->Write(stack->EBX)
            end if
            'ConsolePutChar(cast(unsigned byte ,stack->EBX))
        case 1
            dim pip as STD_PIPE ptr = CurrentThread->Owner->GET_OUT(0)
            if (pip<>0) then
                dim s as unsigned byte ptr = cptr(unsigned byte ptr,stack->EBX)
                while s[0]<>0
                    pip->Write(s[0])
                    s+=1
                wend
            end if
            'ConsoleWrite(cptr(unsigned byte ptr,stack->EBX))
        case 2
            dim pip as STD_PIPE ptr = CurrentThread->Owner->GET_OUT(0)
            if (pip<>0) then
                dim s as unsigned byte ptr = cptr(unsigned byte ptr,stack->EBX)
                while s[0]<>0
                    pip->Write(s[0])
                    s+=1
                wend
                pip->Write(10)
            end if
             'ConsoleWriteLine(cptr(unsigned byte ptr,stack->EBX))
        case 3
            dim pip as STD_PIPE ptr = CurrentThread->Owner->GET_OUT(0)
            if (pip<>0) then
                dim s as unsigned byte ptr = intToStr(stack->EBX,stack->ECX)
                while s[0]<>0
                    pip->Write(s[0])
                    s+=1
                wend
            end if
            'ConsoleWriteNumber(stack->EBX,stack->ECX)
        case 4
            dim pip as STD_PIPE ptr = CurrentThread->Owner->GET_OUT(0)
            if (pip<>0) then
                pip->Write(10)
            end if
            'ConsoleNewLine()
        case 5
            'ConsolePrintOK()
        case 6
            
            dim pip as STD_PIPE ptr = CurrentThread->Owner->GET_OUT(0)
            if (pip<>0) then
                pip->Write(8)
            end if
            'ConsoleBackSpace()
        case 7
            'ConsoleSetForeground(stack->EBX)
        case 8
            'ConsoleSetBackground(stack->EBX)
        case &hF
            'ConsoleClear()
        case &hFF
            'CurrentThread->Owner->CreateConsole()
        case &h100 'STD_CREATE
            stack->EAX =cuint( VIRT_STDIO_CREATE())
        case &h101 'SET IN
            var pip = cptr(STD_PIPE ptr,stack->EBX)
            if (pip = 0) then
                if (CurrentThread->Owner->Parent<>0) then
                    pip = CurrentThread->Owner->Parent->STD_IN
                else
                    pip = @CONSOLE_PIPE
                end if
            end if
            
            if (pip<>0) then
                if (pip->MAGIC = STD_PIPE_MAGIC) then
                    CurrentThread->Owner->STD_IN = pip
                end if
            end if
            stack->EAX = cuint(pip)
        case &h102 'SET OUT
            var pip = cptr(STD_PIPE ptr,stack->EBX)
            if (pip = 0) then
                if (CurrentThread->Owner->Parent<>0) then
                    pip = CurrentThread->Owner->Parent->STD_OUT
                else
                    pip = @CONSOLE_PIPE
                end if
            end if
            
            if (pip<>0) then
                if (pip->MAGIC = STD_PIPE_MAGIC) then
                    CurrentThread->Owner->STD_OUT = pip
                end if
            end if
            stack->EAX = cuint(pip)
            
        case &h103 'STD IN
            dim pip as STD_PIPE ptr = CurrentThread->Owner->GET_IN(  cptr(STD_PIPE ptr,stack->EBX))
            
            if (pip<>0) then
                if (pip->END_OF_FILE=0) then
                    stack->EAX =  pip->Read()
                    stack->EBX = 0
                else
                    STACK->EAX = 0
                    stack->EBX = 26 'end of file
                end if
            else
                stack->EAX = 0
                stack->EBX = 1'no stdin
            end if
            
        case &h104 'std out
            dim pip as STD_PIPE ptr = CurrentThread->Owner->GET_OUT(  cptr(STD_PIPE ptr,stack->EBX))
            if (pip<>0) then
                pip->Write(stack->ECX)
            end if
        
        case &h105 'std out string
            dim pip as STD_PIPE ptr = CurrentThread->Owner->GET_OUT(  cptr(STD_PIPE ptr,stack->EBX))
            if (pip<>0) then
                dim s as unsigned byte ptr = cptr(unsigned byte ptr,stack->ESI)
                while s[0]<>0
                    pip->Write(s[0])
                    s+=1
                wend
            end if
    end select
    return stack
end function