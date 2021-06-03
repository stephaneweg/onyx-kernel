

declare function VFS_LOAD_FILE(p as unsigned byte ptr,s as unsigned integer ptr) as unsigned byte ptr
declare sub VFS_WRITE_FILE(p as unsigned byte ptr,s as unsigned integer,src as unsigned byte ptr)

function VFS_LOAD_FILE(p as unsigned byte ptr,s as unsigned integer ptr) as unsigned byte ptr
    dim fic as unsigned integer = freefile
    dim buffer as unsigned byte ptr = 0
    open _byteStrToString(p) for binary as fic
        *s = lof(fic)
        buffer = malloc((*s)+1)
        memset(buffer,0,(*s)+1)
        dim b as unsigned byte
        for i as unsigned integer = 0 to *s
            get #fic,,b
            buffer[i]=b
        next
        buffer[*s]=0
    close fic
    return buffer
end function

sub VFS_WRITE_FILE(p as unsigned byte ptr,s as unsigned integer,src as unsigned byte ptr)
end sub