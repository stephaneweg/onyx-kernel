type multiboot_module_info  FIELD=1
    mod_start as unsigned integer
    mod_end as unsigned integer
    mod_string as unsigned integer
    reserved as unsigned integer
end type

type multiboot_info  FIELD=1
    flags as unsigned integer
    
    'memoire
    mem_lower as unsigned integer
    mem_upper as unsigned integer
    
    'partition root
    boot_device as unsigned integer
    
    'cmdline
    cmdline as byte ptr
    
    'boot modules list
    mods_count as unsigned integer
    mods_addr as multiboot_module_info ptr
    
    syms(0 to 4) as unsigned integer
    
    mmap_length as unsigned integer
    mmap_addr as unsigned integer
    
    drives_length as unsigned integer
    drives_addr as unsigned integer
    
    config_table as unsigned integer
    
    boot_loader_name as byte ptr
    
    apm_table as unsigned integer
    
    VBE_CONTROL_INFO as unsigned integer
    VBE_MODE_INFO as unsigned integer
    
    VBE_MODE      as unsigned short
    VBE_INTERFACE_SEG as unsigned short
    VBE_INTERFACE_OFF as unsigned short
    VBE_INTERFACE_LEN as unsigned short
end type