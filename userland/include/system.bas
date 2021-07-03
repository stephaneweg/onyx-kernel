

function CreateProcess(img as any ptr,fsize as unsigned integer,args as unsigned byte ptr) as unsigned integer
    asm
        mov eax,&h01
        mov ebx,[img]
        mov ecx,[fsize]
        mov esi,[args]
        int 0x30
        mov [function],eax
    end asm
end function

function  CreateThread(fn as any ptr,prio as unsigned integer) as unsigned integer
    asm
        mov eax,&h02
        mov ebx,[fn]
        mov ecx,[prio]
        int 0x30
        mov [function],eax
    end asm
end function


sub ThreadYield()
    asm
        mov eax,&h03
        int 0x30
    end asm
end sub

sub WaitForEvent()
	asm
		mov eax,0x04
		int 0x30
	end asm
    do:loop
end sub

sub ExitApp()
    asm
        mov eax,&h05
        int 0x30
    end asm
end sub

sub ThreadWakeUP(th as unsigned integer,p1 as unsigned integer,p2 as unsigned integer)
    asm
        mov eax,&h06
        mov ebx,[th]
        mov ecx,[p1]
        mov edx,[p2]
        int 0x30
    end asm
end sub

sub UDevCreate(n as unsigned byte ptr,descriptor as unsigned integer,entry as sub(descr as unsigned integer,sender as unsigned integer,param1 as unsigned integer,param2 as unsigned integer,param3 as unsigned integer,param4 as unsigned integer))
    asm
        mov eax,&h07
        mov ebx,[n]
        mov ecx,[descriptor]
        mov edx,[entry]
        int 0x30
    end asm
end sub

function UDevFind(n as unsigned byte ptr) as unsigned integer
    asm
        mov eax,&h08
        mov ebx,[n]
        int 0x30
        mov [function],eax
    end asm
end function
 
function UDevInvoke(d as unsigned integer,p1 as unsigned integer,p2 as unsigned integer,p3 as unsigned integer,p4 as unsigned integer) as unsigned integer
    asm
        mov eax,&h09
        mov ebx,[d]
        mov ecx,[p1]
        mov edx,[p2]
        mov esi,[p3]
        mov edi,[p4]
        int 0x30
        mov [function],eax
    end asm
end function
        



sub IRQ_ENABLE(intno as unsigned integer)
    asm
        mov eax,&h0C
        mov ebx,[intno]
        int 0x30
    end asm
end sub

sub XappSignal2Parameters(th as unsigned integer,callback as unsigned integer,p1 as unsigned integer, p2 as unsigned integer)
    asm
        mov eax,&h0E
        mov ebx,[th]
        mov ecx,[callback]
        mov esi,[p1]
        mov edi,[p2]
        int 0x30
    end asm
end sub

sub KillProcess(pc as unsigned integer)
    asm
        mov eax,&h0F
        mov ebx,[pc]
        int 0x30
    end asm
end sub

function PAlloc(cnt as unsigned integer) as any ptr
    asm
        mov eax,&hD0
        mov ebx,[cnt]
        int 0x30
        mov [function],eax
    end asm
end function

sub PFree(addr as any ptr)
    asm
        mov eax,&hD1
        mov ebx,[addr]
        int 0x30
    end asm
end sub

function GetStringFromCaller(dst as unsigned byte ptr,src as unsigned integer) as unsigned integer
    asm
        mov eax,&h10
        mov esi,[src]
        mov edi,[dst]
        int 0x30
        mov [function],eax
    end asm
end function

sub SetStringToCaller(dst as unsigned integer,src as unsigned byte ptr)
     asm
        mov eax,&h11
        mov esi,[src]
        mov edi,[dst]
        int 0x30
    end asm
end sub

function MapBufferFromCaller(src as any ptr,size as unsigned integer) as any ptr
    asm
        mov eax,&h12
        mov esi,[src]
        mov ecx,[size]
        int 0x30
        mov [function],eax
    end asm
end function

sub UnMapBuffer(addr as any ptr,size as unsigned integer)
    asm
        mov eax,&h13
        mov ebx,[addr]
        mov ecx,[size]
        int 0x30
    end asm
end sub


function MapBufferToCaller(src as any ptr,size as unsigned integer) as any ptr
    asm
        mov eax,&h14
        mov esi,[src]
        mov ecx,[size]
        int 0x30
        mov [function],eax
    end asm
end function

function GetParentProcess(p as unsigned integer) as unsigned integer
    asm
        mov eax,&h15
        mov ebx,[p]
        int 0x30
        mov [function],eax
    end asm
end function

sub WaitN(delay as unsigned integer)
    asm
        mov eax,&hE0
        mov ebx,[delay]
        int 0x30
    end asm
end sub


sub SysEnterCritical()
	asm
		mov eax ,&hE1
		int 0x30
	end asm
end sub

sub SysExitCritical()
	asm
		mov eax,&hE2
		int 0x30
	end asm
end sub


function SemaphoreCreate() as unsigned integer
    asm 
        mov eax,&hE3
        int 0x30
        mov [function],eax
    end asm
end function


sub SemaphoreLock(s as unsigned integer)
    asm
        mov eax,&hE4
        mov ebx,[s]
        int 0x30
    end asm
end sub

sub SemaphoreUnlock(s as unsigned integer)
    asm
        mov eax,&hE5
        mov ebx,[s]
        int 0x30
    end asm
end sub

function SignalCreate() as unsigned integer
    asm 
        mov eax,&hE6
        int 0x30
        mov [function],eax
    end asm
end function


sub SignalWait(s as unsigned integer)
    asm
        mov eax,&hE7
        mov ebx,[s]
        int 0x30
    end asm
end sub

sub SignalSet(s as unsigned integer)
    asm
        mov eax,&hE8
        mov ebx,[s]
        int 0x30
    end asm
end sub


function GetTimer() as unsigned longint
     dim u1 as unsigned longint = 1
     asm
         mov eax,&hE9
         int 0x30
         mov [u1],eax
         mov [u1+4],ebx
     end asm
     return u1
end function

function NextRandomNumber(_min as unsigned integer,_max as unsigned integer) as unsigned integer
    asm
        mov eax,&hF0
        mov ebx,[_min]
        mov ecx,[_max]
        int 0x30
        mov [function],eax
    end asm
end function

function GetTimeBCD() as unsigned integer
    asm
        mov eax,&hF1
        int 0x30
        mov [function],eax
    end asm
end function

sub GetScreenInfo(_xres as unsigned integer ptr,_yres as unsigned integer ptr,_bpp as unsigned integer ptr,_lfb as unsigned integer ptr, _lfbsize as unsigned integer ptr)
	dim resolution as unsigned integer
	dim _abpp as unsigned integer
	dim _alfb as unsigned integer
	dim _alfbsize as unsigned integer
	asm
		mov eax,&hF3
		int 0x30
		mov [resolution],eax
		mov [_abpp],ebx
		mov [_alfbsize],ecx
		mov [_alfb],edi
	end asm
	*_lfb = _alfb
	*_lfbsize = _alfbsize
	*_bpp = _abpp
	*_xres = (resolution shr 16) and &hFFFF
	*_yres = (resolution) and &hFFFF
end sub

sub GetMemInfo(totalPages as unsigned integer ptr,freePages as unsigned integer ptr,slabCount as unsigned integer ptr)
        dim tp as unsigned integer
        dim fp as unsigned integer
        dim sc as unsigned integer
        asm
            mov eax,&hF4
            int 0x30
            mov [tp],eax
            mov [fp],ebx
            mov [sc],ecx
        end asm
        *totalPages = tp
        *freePages  = fp
        *slabCount  = sc
end sub

function IDLE_COUNT() as unsigned integer
    asm
        mov eax ,&hF5
        int 0x30
        mov [function],eax
    end asm
end function

sub SetPriority(p as unsigned integer)
    asm
        mov eax,&hFFFF
        mov ebx,[p]
        int 0x30
    end asm
end sub


sub DefineIPCHandler(id as unsigned integer,c as sub(_intno as unsigned integer,_senderproc as unsigned integer,_sender as unsigned integer,_eax as unsigned integer,_ebx as unsigned integer,_ecx as unsigned integer,_edx as unsigned integer,_esi as unsigned integer,_edi as unsigned integer,_ebp as unsigned integer,_esp as unsigned integer),synchronous as unsigned integer)
    asm
        mov eax,&hC0
        mov ebx,[id]
        mov ecx,[c]
        mov edx,[synchronous]
        int 0x30
    end asm
end sub


function IPCSend(id as unsigned integer,r0 as unsigned integer,r1 as unsigned integer,r2 as unsigned integer,r3 as unsigned integer,r4 as unsigned integer,r5 as unsigned integer,r6 as unsigned integer,r7 as unsigned integer,result2 as unsigned integer ptr,result3 as unsigned integer ptr) as unsigned integer
    dim res1 as unsigned integer
    dim res2 as unsigned integer
    dim res3 as unsigned integer
    dim body as IPCMessageBody
    body.REG0 = r0
    body.REG1 = r1
    body.REG2 = r2
    body.REG3 = r3
    body.REG4 = r4
    body.REG5 = r5
    body.REG6 = r6
    body.REG7 = r7
    var b= @body
    asm
        mov eax,&hC2
        mov ebx,[id]
        mov ecx,[b]
        int 0x30
        mov [res1],eax
        mov [res2],ebx
        mov [res3],ecx
    end asm
    if (result2<>0) then *result2 = res2
    if (result3<>0) then *result3 = res3
    return res1
end function