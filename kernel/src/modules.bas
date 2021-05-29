sub MODULES_INIT(mb_info as multiboot_info ptr)
    ConsoleWrite(@"There is "):ConsoleWriteNumber(mb_info->mods_count,10):ConsoleWriteLine(@" modules to load")
    
     for i as unsigned integer = 0 to mb_info->mods_count-1
        var mod_start   = mb_info->mods_addr[i].mod_start
        var mod_end     = mb_info->mods_addr[i].mod_end
        ConsoleWriteTextAndHex(@"Module start",mod_start,true)
        ConsoleWriteTextAndHex(@"Module end",mod_end,true)
        ConsoleWriteTextAndDec(@"Module size",mod_end-mod_start,true)
        var image = cptr(EXECUTABLE_HEADER ptr,KAlloc(mod_end-mod_start))
        MemCpy(cptr(any ptr,image),cptr(any ptr,mod_start),mod_end-mod_start)
        ConsoleWriteTextAndHex(@"Magic",image->Magic,true)
        
        Process.RequestLoadMem(image,mod_end-mod_start,0,1)
    next i
end sub
