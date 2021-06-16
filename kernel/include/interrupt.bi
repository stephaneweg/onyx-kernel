TYPE IDT_ENTRY FIELD=1
	BASE_LO as UNSIGNED SHORT
	SEL as UNSIGNED SHORT		'/* Our kernel segment goes here! */
    ALWAYS0 as BYTE				'/* This will ALWAYS be set to 0! */
    FLAGS as UNSIGNED BYTE				'/* Set using the above table! */
    BASE_HI as UNSIGNED SHORT
END TYPE

TYPE IDT_PTR FIELD=1
	IDT_LIMIT as UNSIGNED SHORT
	IDT_BASE as UNSIGNED INTEGER
	ALWAYS0 as unsigned short
END TYPE

type IRQ_Stack field = 1
    ebp as unsigned integer     '+24
    edi as unsigned integer     '+16
    esi as unsigned integer     '+20
    edx as unsigned integer     '+28
    ecx as unsigned integer     '+32  
    ebx as unsigned integer     '+32
    eax as unsigned integer     '+36  
    
    gs as unsigned integer
    fs as unsigned integer
    es as unsigned integer
    ds as unsigned integer
    
    
    intno as unsigned integer '+48
    errCode as unsigned integer
    
    eip as unsigned integer     '+52
    cs as unsigned integer
    eflags as unsigned integer
    esp as unsigned integer
    ss as unsigned integer
    declare sub Dump()
end type



declare sub InterruptsManager_Init()
declare sub set_idt(intno as unsigned integer, irqhandler as unsigned integer,flag as unsigned byte)
 
declare function int_handler(stack as irq_stack ptr) as irq_stack ptr
declare function DefaultIrqHandler(stack as irq_stack ptr) as irq_stack ptr



declare sub IRQ_ENABLE(numirq as unsigned byte)
declare sub IRQ_DISABLE(numirq as unsigned byte)
declare sub IRQ_Attach_Handler(intno as unsigned integer,handler as function(stack as irq_stack ptr) as irq_stack ptr)
declare sub IRQ_Detach_Handler(intno as unsigned integer)
declare sub IRQ_SEND_ACK(intno as unsigned integer)


dim shared IDT_POINTER as IDT_PTR
dim shared IDT_SEGMENT(0 to &h8F) as IDT_ENTRY
dim shared IRQ_HANDLERS(0 to &h8F) as function(stack as irq_stack ptr) as irq_stack ptr


declare sub interrupt_tab()

declare sub IRQ_THREAD_TERMINATED(t as unsigned integer)