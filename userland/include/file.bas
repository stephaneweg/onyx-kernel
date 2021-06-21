#include once "console.bi"
#include once "console.bas"
function ExecApp(path as unsigned byte ptr,args as unsigned byte ptr) as unsigned integer
	dim fsize as unsigned integer = 0
	dim img as unsigned byte ptr = VFS_LOAD_FILE(path,@fsize)
	if (img<>0 and fsize<>0) then
		dim retval as unsigned integer= CreateProcess(img,fsize,args)
        Free(img)
        return retval
	else
		return 0
	end if
end function

function FileOpen(p as unsigned byte ptr) as unsigned integer
    
	asm 
		mov eax,0x03
		mov esi,[p]
		int 0x33
		mov [function],eax
	end asm
end function

function FileCreate(p as unsigned byte ptr) as unsigned integer
	asm
		mov eax,0x04
		mov esi,[p]
		int 0x33
		mov [function],eax
	end asm
end function

function FileRead(f as unsigned integer, count as unsigned integer,dest as any ptr) as unsigned integer
	asm
		mov eax,0x05
		mov ebx,[f]
		mov ecx,[count]
		mov edi,[dest]
		int 0x33
		mov [function],eax
	end asm
end function

sub FileWrite(f as unsigned integer,count as unsigned integer,src as any ptr)
	asm
		mov eax,0x06
		mov ebx,[f]
		mov ecx,[count]
		mov esi,[src]
		int 0x33
	end asm
end sub

sub FileClose(f as unsigned integer,doFlush as integer)
	asm
		mov eax,0x07
		mov ebx,[f]
        mov ecx,[doFlush]
		int 0x33
	end asm
end sub

function FileSize(f as unsigned integer) as unsigned integer
	asm
		mov eax,0x08
		mov ebx,[f]
		int 0x33
		mov [function],eax
	end asm
end function

function FileSeek(f as unsigned integer,count as unsigned integer,mode as unsigned integer) as unsigned integer
	asm
		mov eax,0x09
		mov ebx,[f]
		mov ecx,[count]
		mov edx,[mode]
		int 0x33
		mov [function],eax
	end asm
end function

function FileReadLine(f as unsigned integer,dst as any ptr) as unsigned integer
	asm
		mov eax,0x0a
		mov ebx,[f]
		mov edi,[dst]
		int 0x33
		mov [function],eax
	end asm
end function
		
function FileEOF(f as unsigned integer) as unsigned integer
	asm
		mov eax,0x0b
		mov ebx,[f]
		int 0x33
		mov [function],eax
	end asm
end function

function VFSListDir(path as unsigned byte ptr,attrib as unsigned integer,skip as unsigned integer,count as unsigned integer,dst as VFSDirectoryEntry ptr) as unsigned integer
    asm
        mov eax,0x0c
        mov ebx,[attrib]
        mov ecx,[count]
        mov edx,[skip]
        mov esi,[path]
        mov edi,[dst]
        int 0x33
        mov [function],eax
    end asm
end function



function VFS_Load_File(fname as unsigned byte ptr,fsize as unsigned integer ptr) as unsigned byte ptr
	*fsize = 0
    dim buffer as unsigned byte ptr = 0
    var f = FileOpen(fname)
    if (f<>0) then
        *fsize = FileSize(f)
        if (*fsize)>0 then
            buffer = MAlloc(*fsize)
            if (buffer<>0) then
                FileRead(f,*fsize,buffer)
            end if
        end if
        FileClose(f,0)
    end if
	return buffer
end function
