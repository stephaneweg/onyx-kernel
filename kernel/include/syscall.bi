
declare function SysCall30Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr 'system
declare function SysCall31Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr 'console
declare function SysCall33Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr 'Files
declare sub XappIRQReceived(intno as unsigned integer,p as IRQ_THREAD_POOL ptr)
declare sub XappSignal2Parameters(th as Thread ptr,callback as unsigned integer,p1 as unsigned integer, p2 as unsigned integer)