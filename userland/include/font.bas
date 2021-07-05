dim shared FontPath as unsigned byte ptr = @"SYS:/FONTS/"



function LoadFont(fontname as unsigned byte ptr) as FontData ptr
    dim buffer as unsigned byte ptr
    dim fsize as unsigned integer=0
    buffer=VFS_LOAD_FILE(strCat(strcat(@"SYS:/Fonts/",fontname),@".fon"),@fsize)
    if (buffer=0 or fsize=0) then
        return 0
    end if
    dim result  as FontData ptr = CPTR(FontData ptr, MAlloc(sizeof(FontData)))
    result->Buffer = buffer
    result->FLen = fsize
    result->FontHeight = fsize/256
    if (result->FontHeight>16) then result->FontHeight = 16
    return result
end function