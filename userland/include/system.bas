

function ExecApp(path as unsigned byte ptr) as unsigned integer
    asm
        mov eax,&h01
        mov ebx,[path]
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

sub DefineIRQHandler(intNO as unsigned integer,c as sub(_intno as unsigned integer,_sender as unsigned integer,_eax as unsigned integer,_ebx as unsigned integer,_ecx as unsigned integer,_edx as unsigned integer,_esi as unsigned integer,_edi as unsigned integer,_ebp as unsigned integer),synchronous as unsigned integer)
    asm
        mov eax,&h0B
        mov ebx,[intNO]
        mov ecx,[c]
        mov edx,[synchronous]
        int 0x30
    end asm
end sub


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

sub KillProcess(th as unsigned integer)
    asm
        mov eax,&h0F
        mov ebx,[th]
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

sub WaitN(delay as unsigned integer)
    asm
        mov eax,&hE0
        mov ebx,[delay]
        int 0x30
    end asm
end sub


sub EnterCritical()
	asm
		mov eax ,&hE1
		int 0x30
	end asm
end sub

sub ExitCritical()
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

function GetTimer() as unsigned long
     dim u1 as unsigned long = 1
     asm
         mov eax,&hE6
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



sub SetPriority(p as unsigned integer)
    asm
        mov eax,&hFFFF
        mov ebx,[p]
        int 0x30
    end asm
end sub