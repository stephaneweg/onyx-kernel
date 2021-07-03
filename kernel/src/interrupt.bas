sub InterruptsManager_Init()
    ConsoleWrite(@"Setup Interrupt manager")
	dim i as unsigned integer
	for i=0 to &h2f
		set_idt(i,cptr(unsigned integer ptr, @interrupt_tab)[i],&h8E)'_ring0_int_gate equ 10001110b 
        IRQ_ATTACH_HANDLER(i,0)
	next
	
	for i=&h30 to &hFF
		set_idt(i,cptr(unsigned integer ptr, @interrupt_tab)[i],&hEE)'_ring3_int_gate equ 11101110b 
		IRQ_ATTACH_HANDLER(i,0)
	next
	
	IDT_POINTER.IDT_BASE = cast(unsigned integer , @IDT_SEGMENT(0))
	IDT_POINTER.IDT_LIMIT = (sizeof(IDT_ENTRY) * &h100) -1
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


function int_handler (stack as irq_stack ptr) as irq_stack ptr
    dim returnStack as IRQ_Stack ptr =stack
	dim intno as unsigned integer = returnStack->intno
	
    select case intNo
        case &h0 to &hC
            returnStack = ExceptionHandler(stack)
        case &hD
            returnStack = ExceptionHandler(stack)
        case &hE to &h1E
            returnStack = ExceptionHandler(stack)
            
        case else
            dim handler as function(stack as irq_stack ptr) as irq_stack ptr
            dim tid as unsigned integer
            handler=IRQ_HANDLERS(intno)
            if (handler <> 0) then
                returnStack = handler(stack)
            else
                var endPoint = IPCEndPoint.FindBYId(intno)
                if (endPoint<>0) then
                    dim ipcSendResult as unsigned integer
                    if (intno>=&h30) then
                        ipcSendResult = IPCSend(intno,Scheduler.CurrentRuningThread,stack->EAX,stack->EBX,stack->ECX,stack->EDX,stack->ESI,stack->EDI,stack->EBP,stack->ESP)
                    else
                        ipcSendResult = IPCSend(intno,0,0,0,0,0,0,0,0,0)
                    end if
                    
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
                end if
               
            end if
    end select
    
	IRQ_SEND_ACK(intno)
    
    return returnStack
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
    IRQ_HANDLERS(intno)=0
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