sub MODULES_INIT(mb_info as multiboot_info ptr)
     kernel_context.map_range(mb_info,mb_info,cptr(any ptr,cuint(mb_info)+sizeof(multiboot_info)),VMM_FLAGS_KERNEL_DATA)
     kernel_context.map_range(mb_info->mods_addr,mb_info->mods_addr,cptr(any ptr,cuint(mb_info->mods_addr)+mb_info->mods_count*sizeof(multiboot_module_info)),VMM_FLAGS_KERNEL_DATA)
     
     PMM_STRIPE(cuint(mb_info),cuint(mb_info)+sizeof(multiboot_info))
     PMM_STRIPE(cuint(mb_info->mods_addr),cuint(mb_info->mods_addr)+mb_info->mods_count*sizeof(multiboot_module_info))
     
     var v_mod_table = mb_info->mods_addr
     
     for i as unsigned integer = 0 to mb_info->mods_count-1
        var mod_start   = v_mod_table[i].mod_start
        var mod_end     = v_mod_table[i].mod_end
        
        
        kernel_context.map_range(cptr(any ptr,mod_start),cptr(any ptr,mod_start),cptr(any ptr,mod_end),VMM_FLAGS_KERNEL_DATA)
        kernel_context.map_page(v_mod_table[i].mod_string,v_mod_table[i].mod_string,VMM_FLAGS_KERNEL_DATA)
        PMM_STRIPE(mod_start,mod_end)
        PMM_STRIPE(cuint(v_mod_table[i].mod_string),cuint(v_mod_table[i].mod_string)+strlen(v_mod_table[i].mod_string))
        
        var image = cptr(EXECUTABLE_HEADER ptr,mod_start)
        
		var proc = Process.Create(image,mod_end-mod_start,v_mod_table[i].mod_string,@CONSOLE_PIPE,@CONSOLE_PIPE)
        proc->Parent = 0
    next i
end sub


sub MODULES_PRE_INIT(mb_info as multiboot_info ptr)
    
     
     kernel_context.map_range(mb_info,mb_info,cptr(any ptr,cuint(mb_info)+sizeof(multiboot_info)),VMM_FLAGS_KERNEL_DATA)
     kernel_context.map_range(mb_info->mods_addr,mb_info->mods_addr,cptr(any ptr,cuint(mb_info->mods_addr)+mb_info->mods_count*sizeof(multiboot_module_info)),VMM_FLAGS_KERNEL_DATA)
     
     PMM_STRIPE(cuint(mb_info),cuint(mb_info)+sizeof(multiboot_info))
     PMM_STRIPE(cuint(mb_info->mods_addr),cuint(mb_info->mods_addr)+mb_info->mods_count*sizeof(multiboot_module_info))
     
     var v_mod_table = mb_info->mods_addr
     
     for i as unsigned integer = 0 to mb_info->mods_count-1
        var mod_start   = v_mod_table[i].mod_start
        var mod_end     = v_mod_table[i].mod_end
        
        
        kernel_context.map_range(cptr(any ptr,mod_start),cptr(any ptr,mod_start),cptr(any ptr,mod_end),VMM_FLAGS_KERNEL_DATA)
        kernel_context.map_page(v_mod_table[i].mod_string,v_mod_table[i].mod_string,VMM_FLAGS_KERNEL_DATA)
        PMM_STRIPE(mod_start,mod_end)
        PMM_STRIPE(cuint(v_mod_table[i].mod_string),cuint(v_mod_table[i].mod_string)+strlen(v_mod_table[i].mod_string))
        
       
    next i
end sub