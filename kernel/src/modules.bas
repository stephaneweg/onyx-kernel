sub MODULES_INIT(mb_info as multiboot_info ptr)
     for i as unsigned integer = 0 to mb_info->mods_count-1
        var mod_start   = mb_info->mods_addr[i].mod_start
        var mod_end     = mb_info->mods_addr[i].mod_end
        var image = cptr(EXECUTABLE_HEADER ptr,KAlloc(mod_end-mod_start))
        MemCpy(cptr(any ptr,image),cptr(any ptr,mod_start),mod_end-mod_start)
		
		Process.RequestLoadMem(image,mod_end-mod_start,1,mb_info->mods_addr[i].mod_string)
        ConsoleWrite(mb_info->mods_addr[i].mod_string)
        ConsoleWrite(@" - Magic : 0x"):ConsoleWriteUNumber(image->Magic,16):ConsoleNewLine()
    next i
end sub
