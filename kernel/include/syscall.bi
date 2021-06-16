declare function SysCall30Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr 'system
declare function SysCall31Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr 'console
declare function SysCall33Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr 'Files
declare sub XappSignal2Parameters(th as Thread ptr,callback as unsigned integer,p1 as unsigned integer, p2 as unsigned integer)
declare sub XappSignal6Parameters(th as Thread ptr,callback as unsigned integer,p1 as unsigned integer, p2 as unsigned integer,p3 as unsigned integer,p4 as unsigned integer,p5 as unsigned integer,p6 as unsigned integer)
