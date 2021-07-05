function STD_PIPE.Read() as unsigned byte
    if (ReadMethod<>0) then
        'while (END_OF_FILE<>0):wend
        
        return ReadMethod(@this)
    end if
    return 0
end function

sub STD_PIPE.Write(b as unsigned byte)
    if (WriteMethod<>0) then
        WriteMethod(@this,b)
    end if
end sub

function VIRT_STDIO_CREATE() as VIRT_STDIO ptr
    dim std as VIRT_STDIO ptr = cptr(VIRT_STDIO ptr, KAlloc(sizeof(VIRT_STDIO)))
    
    std->MAGIC          = STD_PIPE_MAGIC
    std->BUFFER         = KMM_ALLOCPAGE()
    std->FPOS           = 0
    std->WriteMethod    = cptr(any ptr, @VIRT_IO_WRITE)
    std->ReadMethod     = cptr(any ptr,@VIRT_IO_READ)
    std->END_OF_FILE    = 1
    return std
end function

sub VIRT_IO_WRITE(std as VIRT_STDIO ptr,b as unsigned byte)
    if (std->FPOS < 4096) then
        std->BUFFER[std->FPOS] = b
        std->FPOS+=1
        std->END_OF_FILE = 0
    end if
end sub

function VIRT_IO_READ(std as VIRT_STDIO ptr) as unsigned byte
    dim b as unsigned byte  = 0
    if (STD->FPOS>0) then
        b=STD->BUFFER[0]
        STD->FPOS-=1
        if (STD->FPOS>0) then
            memcpy(STD->BUFFER,STD->BUFFER+1,STD->FPOS)
        end if
        if (std->FPOS = 0) then
            std->END_OF_FILE = 1
        end if
    end if
    return b
end function

sub INIT_STD_PIPE()
    CONSOLE_PIPE.MAGIC          = STD_PIPE_MAGIC
    CONSOLE_PIPE.WriteMethod    = @STD_WRITE
    CONSOLE_PIPE.ReadMethod     = @STD_READ
    CONSOLE_PIPE.END_OF_FILE    = 0
end sub

sub STD_WRITE(std as STD_PIPE ptr,b as unsigned byte)
    ConsolePutChar(b)
end sub

function STD_READ(std as STD_PIPE ptr) as unsigned byte
    return 0
end function

