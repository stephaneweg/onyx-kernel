type STD_PIPE field = 1
    MAGIC       as unsigned integer
    END_OF_FILE as unsigned integer
    
    ReadMethod  as function(std as STD_PIPE ptr) as unsigned byte
    WriteMethod as sub(std as STD_PIPE ptr,b as unsigned byte)
    
    declare function Read() as unsigned byte
    declare sub Write(b as unsigned byte)
end type

type VIRT_STDIO extends STD_PIPE field = 1
    FPOS    as unsigned integer
    buffer as unsigned byte ptr
end type

#define STD_PIPE_MAGIC &hEEFFEEFF
dim shared CONSOLE_PIPE as STD_PIPE
declare sub INIT_STD_PIPE()
declare sub STD_WRITE(std as STD_PIPE ptr,b as unsigned byte)
declare function STD_READ(std as STD_PIPE ptr) as unsigned byte


declare sub VIRT_IO_WRITE(std as VIRT_STDIO ptr,b as unsigned byte)
declare function VIRT_IO_READ(std as VIRT_STDIO ptr) as unsigned byte
declare function VIRT_STDIO_CREATE() as VIRT_STDIO ptr