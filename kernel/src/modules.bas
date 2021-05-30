sub MODULES_INIT(mb_info as multiboot_info ptr)
     for i as unsigned integer = 0 to mb_info->mods_count-1
        var mod_start   = mb_info->mods_addr[i].mod_start
        var mod_end     = mb_info->mods_addr[i].mod_end
        ConsoleWriteTextAndHex(@"Load module from",mod_start,true)
        var image = cptr(EXECUTABLE_HEADER ptr,KAlloc(mod_end-mod_start))
        MemCpy(cptr(any ptr,image),cptr(any ptr,mod_start),mod_end-mod_start)
        Process.RequestLoadMem(image,mod_end-mod_start,0,1)
    next i
end sub
