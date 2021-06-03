


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
	
    
    if (IRQ_THREAD_HANDLERS(intno).Owner<>0) then
        
        var th =cptr(Thread ptr, IRQ_THREAD_HANDLERS(intno).Owner)
        
        
        var pool = cptr(IRQ_THREAD_POOL ptr,KAlloc(sizeof(IRQ_THREAD_POOL)))
        pool->SENDER = cuint(Scheduler.CurrentRuningThread)
        pool->SENDERPROCESS = cuint(Scheduler.CurrentRuningThread->Owner)
        pool->EAX = stack->EAX
        pool->EBX = stack->EBX
        pool->ECX = stack->ECX
        pool->EDX = stack->EDX
        pool->ESI = stack->ESI
        pool->EDI = stack->EDI
        pool->EBP = stack->EBP
        IRQ_THREAD_HANDLERS(intno).Enqueue(pool)
        
        if (th->State=THreadState.Waiting) then
            var pool = IRQ_THREAD_HANDLERS(intno).Dequeue()
            if (pool<>0) then
                XappIRQReceived(intno,pool)
                KFree(pool)
            end if
        end if
        
        'if its a synchronous interrupt, make the caller "waiting for reply from "
        if (IRQ_THREAD_HANDLERS(intno).Synchronous = 1) then
            stack->EAX = &hFF
            Scheduler.CurrentRuningThread->State=ThreadState.WaitingReply
            Scheduler.CurrentRuningThread->ReplyFrom=th
            returnStack = Scheduler.Switch(stack,Scheduler.Schedule()) 
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
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Divide by zero")
                    asm cli
                    do:loop
            case &h1
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"DEBUG")
                    asm cli
                    do:loop
            case &h2
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"NON Maskable interupt")
                    asm cli
                    do:loop
            case &h3
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Break point")
                    asm cli
                    do:loop
            case &h4
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"OverFlow")
                    asm cli
                    do:loop
            case &h5
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Bound range exceeded")
                    asm cli
                    do:loop
            case &h6
                    'kernel_context.ACTIVATE()
                    '
                    VMM_EXIT()
                    VesaResetScreen()
                    'VMM_INIT_Local()
                    ''var nstack = cptr(IRQ_STACK ptr,kernel_context.resolve(stack))
                    'ConsoleSetBackGround(4)
                    'ConsoleSetForeground(15)
                    'ConsoleClear()
                    ConsoleWrite(@"Invalid IPCode")
                    'ConsoleWriteTextAndDec(@"Code : ",stack->errCode,true)
                    'ConsoleWriteTextAndHex(@"Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    'stack->DUMP()
                    'KERNEL_ERROR(@"INVALID OPCODE",0)
                    asm cli
                    do:loop
            case &h7
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Device not available")
                    asm cli
                    do:loop
            case &h8
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Double fault")
                    asm cli
                    do:loop
            case &hA
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Invalid TSS")
                    asm cli
                    do:loop
            case &hB
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Segment not present")
                    asm cli
                    do:loop
            case &hC
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Stack segment fault")
                    asm cli
                    do:loop
            case &hD
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"General Protection fault")
                    asm cli
                    do:loop
            case &hE
                    dim acr2 as unsigned integer
                    asm
                        mov ebx,cr2
                        mov [acr2],ebx
                    end asm
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleSetBackGround(4)
                    ConsoleSetForeground(15)
                    ConsoleClear()
                    
                    ConsoleWriteLine(@"Page fault")                       
                    ConsoleWriteTextAndDec(@"   Code : ",stack->errCode,true)                        
                    ConsoleWriteTextAndHex(@"   CR2 : ",acr2,true)
                    ConsoleWriteTextAndHex(@"   PHYS : ",cuint(current_context->RESOLVE(cptr(any ptr,acr2 ))),true)
                    ConsoleWriteTextAndHex(@"   Current Thread ID : ",SCheduler.CurrentRuningThread->ID,true)
                    asm cli
                    do:loop
            case &h10
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Floating point exception")
                    asm cli
                    do:loop
            case &h11
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Alignment check")
                    asm cli
                    do:loop
            case &h12
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Machine check")
                    asm cli
                    do:loop
            case &h13
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"SIMD Floating-point exception")
                    asm cli
                    do:loop
            case &h14
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Virtualization exception")
                    asm cli
                    do:loop
            case &h1E
                    VMM_EXIT()
                    VesaResetScreen()
                    ConsoleWrite(@"Security exception")
                    asm cli
                    do:loop
            end select
        end if
    end if
	ReceivedInt=intno
	IRQ_SEND_ACK(intno)
    return returnStack
end function

function DefaultIrqHandler(stack as irq_stack ptr) as irq_stack ptr
    return stack
end function

sub Irq_Wait(intno as unsigned integer)
	ASM STI
	do
	loop while ReceivedInt<> intno
	ASM CLI
	ReceivedInt=-1
end sub



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

sub IRQ_SET_THREAD_HANDLER(intno as unsigned integer,th as any ptr,e as unsigned integer,isSynchronous as unsigned integer)
    if (IRQ_THREAD_HANDLERS(intno).Owner = 0) then
        IRQ_THREAD_HANDLERS(intno).Owner = th
        IRQ_THREAD_HANDLERS(intno).Synchronous = isSynchronous
        IRQ_THREAD_HANDLERS(intno).EntryPoint = e
        IRQ_THREAD_HANDLERS(intno).Counter = 0
        'IRQ_THREAD_HANDLERS(intno).FirstPool = 0
        'IRQ_THREAD_HANDLERS(intno).LastPool = 0
    end if
end sub

sub IRQ_THREAD_HANDLER.Enqueue(p as IRQ_THREAD_POOL ptr)
    this.Counter += 1
    if (this.LastPool<>0)  then
        this.LastPool->NextPool = p
    else
        this.FirstPool = p
    end if
    this.LastPool = p
    p->NextPool = 0
end sub

function IRQ_THREAD_HANDLER.Dequeue() as IRQ_THREAD_POOL ptr
    if (this.FirstPool<>0) then
        var ret = this.FirstPool
        this.FirstPool = this.FirstPool->NextPool
        if (this.FirstPool=0) then this.LastPool = 0
        return ret
    end if
    return 0
end function


sub IRQ_THREAD_TERMINATED(t as unsigned integer)
    var th = cptr(Thread ptr,t)
    for i as unsigned integer = 0 to &h40
        if IRQ_THREAD_HANDLERS(i).Owner<>0 then
            var p = IRQ_THREAD_HANDLERS(i).FirstPool
            while p<>0
                if (p->Sender = t) then
                    var n = p->NextPool
                    IRQ_THREAD_HANDLERS(i).FirstPool = n
                    KFree(p)
                    p = n
                else
                    exit while
                end if
            wend
            
            
            while p<>0
                var pnext = p->NextPool
                if (pnext<>0) then
                    if (pnext->Sender = t) then
                        p->NextPool = pnext->NextPool
                        KFree(pnext)
                    end if
                end if
                p = p->NextPool
            wend
            if (IRQ_THREAD_HANDLERS(i).FirstPool=0) then IRQ_THREAD_HANDLERS(i).LastPool = 0
            if cptr(Thread ptr,IRQ_THREAD_HANDLERS(i).Owner)->ReplyTo = th then
                cptr(Thread ptr,IRQ_THREAD_HANDLERS(i).Owner)->ReplyTo = 0
            end if
        end if
    next i
end sub