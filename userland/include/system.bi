
declare function SemaphoreCreate() as unsigned integer
declare sub SemaphoreLock(s as unsigned integer)
declare sub SemaphoreUnlock(s as unsigned integer)
declare sub EnterCritical()
declare sub ExitCritical()
declare function CreateThread(fn as any ptr,prio as unsigned integer) as unsigned integer
declare sub ThreadYield()
declare sub KillProcess(th as unsigned integer)
declare sub ThreadWakeUP(th as unsigned integer,p1 as unsigned integer,p2 as unsigned integer)

declare sub UDevCreate(n as unsigned byte ptr,descriptor as unsigned integer,entry as sub(descr as unsigned integer,sender as unsigned integer,param1 as unsigned integer,param2 as unsigned integer,param3 as unsigned integer,param4 as unsigned integer))
declare function UDevFind(n as unsigned byte ptr) as unsigned integer
declare function UDevInvoke(d as unsigned integer,p1 as unsigned integer,p2 as unsigned integer,p3 as unsigned integer,p4 as unsigned integer)  as unsigned integer


declare function PAlloc(cnt as unsigned integer) as any ptr
declare function GetStringFromCaller(dst as unsigned byte ptr,src as unsigned integer) as unsigned integer
declare sub SetStringToCaller(dst as unsigned integer,src as unsigned byte ptr)

declare function MapBufferFromCaller(src as any ptr,size as unsigned integer) as any ptr
declare sub UnMapBuffer(addr as any ptr,size as unsigned integer)

declare sub XappSignal2Parameters(th as unsigned integer,callback as unsigned integer,p1 as unsigned integer, p2 as unsigned integer)

declare sub WaitForEvent()
declare sub IRQ_ENABLE(intno as unsigned integer)
declare sub DefineIRQHandler(intNO as unsigned integer,c as sub(_intno as unsigned integer,_senderproc as unsigned integer,_sender as unsigned integer,_eax as unsigned integer,_ebx as unsigned integer,_ecx as unsigned integer,_edx as unsigned integer,_esi as unsigned integer,_edi as unsigned integer,_ebp as unsigned integer),synchronous as unsigned integer)
declare sub WaitN(delay as unsigned integer)
declare function GetTimer() as unsigned long
declare function NextRandomNumber(_min as unsigned integer,_max as unsigned integer) as unsigned integer
declare function GetTimeBCD() as unsigned integer
declare sub GetScreenInfo(_xres as unsigned integer ptr,_yres as unsigned integer ptr,_bpp as unsigned integer ptr,_lfb as unsigned integer ptr, _lfbsize as unsigned integer ptr)


declare sub SetPriority(p as unsigned integer)
#macro EndCallBack()
	asm
		mov esp,ebp
		add esp,12 'remove parameters (sender+args) and return addr to the stack
		mov eax,0x04
		int 0x30
	end asm
	do:loop
#endmacro

#macro EndIRQHandler()
asm
    mov esp,ebp
    add esp,44
    mov eax,0x04
    int 0x30
end asm
do:loop
#endmacro


#macro EndIRQHandlerAndSignal()
asm
    mov eax,0x0D
    int 0x30
end asm
do:loop
#endmacro


#macro UDevEndInvoke(r)
asm
    mov eax,&h0A
    mov ebx,[r]
    int 0x30
end asm
do:loop
#endmacro