
declare function _byteStrToString(b as unsigned byte ptr) as string
declare function VFS_LOAD_FILE(p as unsigned byte ptr,s as unsigned integer ptr) as unsigned byte ptr
declare sub VFS_WRITE_FILE(p as unsigned byte ptr,s as unsigned integer,src as unsigned byte ptr)

declare sub ConsoleWrite(p as unsigned byte ptr) 
declare sub ConsoleNewLine()

#define free(a) deallocate(a)
#define malloc(s) allocate(s)


function _byteStrToString(b as unsigned byte ptr) as string
    
    dim instring as unsigned integer = 0
    dim result as string = ""
    dim i as integer
    while b[i] <>0
        if (b[i]) = 34 and instring = 0 then
            instring = 1
        elseif (b[i]) = 34 and instring = 1 then
            instring = 0
        else
            result = result+ chr(b[i])
        end if
        i+=1
    wend
    return result
end function

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


sub ConsoleWrite(p as unsigned byte ptr) 
    dim result as string = ""
    var l = strlen(p)
    for i as unsigned integer= 0 to l-1
        print chr(p[i]);
    next i
end sub

sub ConsoleNewLine()
    print
end sub