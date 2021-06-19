


sub IRQ_Stack.Dump()
    ConsoleWriteLine(@"----------")
    ConsoleWrite(@"  EAX : 0x"):ConsoleWriteNumber(eax,16):ConsoleNewLine()
    ConsoleWrite(@"  EBX : 0x"):ConsoleWriteNumber(ebx,16):ConsoleNewLine()
    ConsoleWrite(@"  ECX : 0x"):ConsoleWriteNumber(ecx,16):ConsoleNewLine()
    ConsoleWrite(@"  EDX : 0x"):ConsoleWriteNumber(edx,16):ConsoleNewLine()
    ConsoleWrite(@"  EDI : 0x"):ConsoleWriteNumber(edi,16):ConsoleNewLine()
    ConsoleWrite(@"  ESI : 0x"):ConsoleWriteNumber(esi,16):ConsoleNewLine()
    ConsoleWrite(@"  EBP : 0x"):ConsoleWriteNumber(ebp,16):ConsoleNewLine()
    ConsoleWrite(@"  ESP : 0x"):ConsoleWriteNumber(esp,16):ConsoleNewLine()
    ConsoleWrite(@"  CS : 0x"):ConsoleWriteNumber(cs,16):ConsoleNewLine()
    ConsoleWrite(@"  DS : 0x"):ConsoleWriteNumber(ds,16):ConsoleNewLine()
    ConsoleWrite(@"  ES : 0x"):ConsoleWriteNumber(es,16):ConsoleNewLine()
    ConsoleWrite(@"  FS : 0x"):ConsoleWriteNumber(fs,16):ConsoleNewLine()
    ConsoleWrite(@"  GS : 0x"):ConsoleWriteNumber(gs,16):ConsoleNewLine()
    ConsoleWrite(@"  EFLAGS : 0x"):ConsoleWriteNumber(eflags,16):ConsoleNewLine()
end sub


sub InterruptsManager_Init()
    ConsoleWrite(@"Setup Interrupt manager")
	dim i as unsigned integer
	for i=0 to &h2f
		set_idt(i,cptr(unsigned integer ptr, @interrupt_tab)[i],&h8E)'_ring0_int_gate equ 10001110b 
        IRQ_ATTACH_HANDLER(i,@DefaultIrqHandler)
	next
	
	for i=&h30 to &h40
		set_idt(i,cptr(unsigned integer ptr, @interrupt_tab)[i],&hEE)'_ring3_int_gate equ 11101110b 
		IRQ_ATTACH_HANDLER(i,@DefaultIrqHandler)
	next
	
	IDT_POINTER.IDT_BASE = cast(unsigned integer , @IDT_SEGMENT(0))
	IDT_POINTER.IDT_LIMIT = (sizeof(IDT_ENTRY) * &h41) -1
	IDT_POINTER.ALWAYS0 = &h0
	
	ASM lidt [IDT_POINTER]

	pic_init()
	ConsolePrintOK()
    ConsoleNewLine()
end sub


sub set_idt(intno as unsigned integer, irqhandler as unsigned integer,flag as unsigned byte)
	IDT_SEGMENT(intno).BASE_LO = (irqhandler and &hFFFF)
	IDT_SEGMENT(intno).BASE_HI = ((irqhandler shr 16) and &hFFFF)
	IDT_SEGMENT(intno).SEL = &h8
	IDT_SEGMENT(intno).ALWAYS0 = &h0
	IDT_SEGMENT(intno).FLAGS =  flag' 10001110b ;_ring0_int_gate
	
end sub


function int_handler(stack as irq_stack ptr) as irq_stack ptr
    dim returnStack as IRQ_Stack ptr =stack
	dim intno as unsigned integer = returnStack->intno
	
    
    var endPoint = IPCEndPoint.FindBYId(intno)
    if (endPoint<>0) then
        
        var ipcSendResult = IPCSend(intno,Scheduler.CurrentRuningThread,stack->EAX,stack->EBX,stack->ECX,stack->EDX,stack->ESI,stack->EDI,stack->EBP,stack->ESP)
       
        if (ipcSendResult<>0) then
            'caller must wait
            if (endPoint->Synchronous = 1) then
                stack->EAX = &hFF
                Scheduler.CurrentRuningThread->State=ThreadState.WaitingReply
                Scheduler.CurrentRuningThread->ReplyFrom=endPoint->Owner
                returnStack = Scheduler.Switch(stack,Scheduler.Schedule()) 
            elseif (ipcSendResult = 2) then 'received is waked up
                returnStack = Scheduler.Switch(stack,Scheduler.Schedule()) 
            end if
        end if
   
        
    else
    
        dim handler as function(stack as irq_stack ptr) as irq_stack ptr
        dim tid as unsigned integer
        handler=IRQ_HANDLERS(intno)
        if (handler <>@DefaultIrqHandler) then
            returnStack = handler(stack)
            
        else
            select case intno
            case &h0
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    ConsoleWrite(@"Killing process due to Divide by zero")
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWriteLIne(@"Divide by zero")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    ConsoleWriteTextAndHex(@"   Current Thread : ",Cuint(SCheduler.CurrentRuningThread),true)
                    do:loop
                'end if
            case &h1
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Debug exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"DEBUG")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h2
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to NON Maskable interupt exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"NON Maskable interupt")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h3
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Break point exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Break point")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h4
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to OverFlow exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"OverFlow")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h5
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Bound range exceeded exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Bound range exceeded")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h6
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Invalid IPCode exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    'kernel_context.ACTIVATE()
                    '
                    'VMM_EXIT()
                   ' VesaResetScreen()
                    'VMM_INIT_Local()
                    ''var nstack = cptr(IRQ_STACK ptr,kernel_context.resolve(stack))
                    'ConsoleSetBackGround(4)
                    'ConsoleSetForeground(15)
                    'ConsoleClear()
                    ConsoleWrite(@"Invalid IPCode")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    'ConsoleWriteTextAndDec(@"Code : ",stack->errCode,true)
                    'ConsoleWriteTextAndHex(@"Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    'stack->DUMP()
                    'KERNEL_ERROR(@"INVALID OPCODE",0)
                    do:loop
                'end if
            case &h7
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Device not available exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Device not available")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h8
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Double fault exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Double fault")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &hA
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Invalid TSS exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Invalid TSS")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    asm cli
                    do:loop
                'end if
            case &hB
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Segment not present exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Segment not present")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &hC
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Stack segment fault exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Stack segment fault")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &hD
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to General Protection fault exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"General Protection fault")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &hE
                'var pc = Scheduler.CurrentRuningThread->Owner
                 dim acr2 as unsigned integer
                'if (pc<>0) then
                '    asm cli
                '    asm
                '        mov ebx,cr2
                '        mov [acr2],ebx
                '    end asm
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Page fault exception")
                '    ConsoleWriteTextAndDec(@"   Code : ",stack->errCode,true)                        
                '    ConsoleWriteTextAndHex(@"   CR2 : ",acr2,true)                      
                '    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                '    ConsoleWriteTextAndHex(@"   PHYS : ",cuint(current_context->RESOLVE(cptr(any ptr,acr2 ))),true)
                '    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                '    stack->DUMP
                '    asm sti
                'else
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
                'end if
            case &h10
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Floating point exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Floating point exception")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h11
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Alignment check exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Alignment check")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h12
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Machine check exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Machine check")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h13
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to SIMD Floating-point exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"SIMD Floating-point exception")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h14
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Virtualization exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Virtualization exception")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            case &h1E
                'var pc = Scheduler.CurrentRuningThread->Owner
                'if (pc<>0) then
                '    Process.RequestTerminateProcess(pc)
                '    returnStack = Scheduler.Switch(stack, Scheduler.Schedule())
                '    ConsoleWrite(@"Killing process due to Security exception")
                'else
                    asm cli
                    VMM_EXIT()
                    CurrentConsole = @SysConsole
                    VesaResetScreen()
                    SysConsole.VIRT = cptr(any ptr,&hB8000)
                    ConsoleWrite(@"Security exception")
                    ConsoleWriteTextAndHex(@"   EIP : ",stack->EIP,true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    do:loop
                'end if
            end select
        end if
    end if
	IRQ_SEND_ACK(intno)
    
    return returnStack
end function

function DefaultIrqHandler(stack as irq_stack ptr) as irq_stack ptr
    return stack
end function




sub IRQ_ENABLE(irq as unsigned byte)
	dim port as ushort
	dim b as unsigned byte
	if (irq < 8) then
		port = MASTER_DATA
	else
		port = SLAVE_DATA
		irq -= 8
	end if
    inb([port],[b])
	b = b and (not (1 shl irq))
    outb([port],[b])
end sub

sub IRQ_DISABLE(irq as unsigned byte)
	dim port as ushort
	dim b as unsigned byte
    
    if (irq < 8) then
		port = MASTER_DATA
	else
		port = SLAVE_DATA
		irq -= 8
	end if
    inb([port],[b])
    b = b or (1 shl irq)
    outb([port],[b])
end sub

sub IRQ_Attach_Handler(intno as unsigned integer,handler as function(stack as irq_stack ptr) as irq_stack ptr)
	IRQ_HANDLERS(intno)=handler
end sub


sub IRQ_Detach_Handler(intno as unsigned integer)
    IRQ_HANDLERS(intno)=@DefaultIrqHandler
end sub

sub IRQ_SEND_ACK(intno as unsigned integer)
    ASM
	mov ebx,[intno]
	cmp ebx,40
	jb int_handler.noout
		mov al,0x20
		out 0xa0,al
	int_handler.noout:
		mov al,0x20
		out 0x20,al

	END ASM
end sub



sub IRQ_THREAD_TERMINATED(t as unsigned integer)
    var th = cptr(Thread ptr,t)
    
    var ep = FirstIPCEndPoint
    while ep<>0
        var n = ep->NextEndPoint
        if ep->Owner->ReplyTo = th then
            ep->Owner->ReplyTo = 0
        end if
        
        if (ep->Owner = th) then
            ep->destructor()
            KFree(ep)
        end if
        ep=n
    wend
    
end sub