TYPE VMMContext field =1
    p_dir as unsigned integer ptr
    v_dir as unsigned integer ptr
    version as unsigned integer
    declare destructor()
    
    declare sub Initialize()
    
    declare sub sync()
    declare function get_pagetable (index as unsigned integer) as unsigned integer ptr
    declare sub free_pagetable(table as unsigned integer ptr)
    declare function find_free_pages (pages as unsigned integer, lower_limit as unsigned integer, upper_limit as unsigned integer) as unsigned integer
    declare function automap (p_start as any ptr, size as unsigned integer, lowerLimit as unsigned integer, upperLimit as unsigned integer, flags as unsigned integer) as any ptr
    declare function MAP_PAGE(virt as any ptr,phys as any ptr, flags as unsigned integer)  as boolean
    declare function map_range (v_addr as any ptr, p_start as any ptr, p_end as any ptr, flags as uinteger) as boolean
    declare sub unmap_page (v_addr as any ptr)
    declare sub unmap_range (v_addr as any ptr, pages as uinteger)
    declare function Resolve (vaddr as any ptr) as any ptr
    declare sub Activate()
end TYPE

#define VMM_PAGETABLES_VIRT_START &h3FC00000
#define VMM_FLAG_PRESENT    &h1
#define VMM_FLAG_WRITEABLE  &h2
#define VMM_FLAG_USER       &h4
#define VMM_FLAG_GLOBAL     &h100
#define VMM_PAGE_MASK (&hFFFFF000)
#define VMM_FLAGS_KERNEL_DATA  (VMM_FLAG_PRESENT or VMM_FLAG_WRITEABLE or VMM_FLAG_GLOBAL)
#define VMM_FLAGS_USER_DATA    (VMM_FLAG_PRESENT or VMM_FLAG_WRITEABLE or VMM_FLAG_USER)

#define VMM_IDENTITY_MEMORY_END 1024*1024*32
declare sub VMM_INIT()
declare sub vmm_init_local ()
declare sub VMM_EXIT()
declare function vmm_get_current_context () as VMMContext ptr
declare function vmm_kernel_automap (p_start as any ptr, size as unsigned integer, flags as unsigned integer) as any ptr
declare sub vmm_kernel_unmap (v_start as any ptr, size as uinteger)

dim shared FirstVMMPage as unsigned integer
dim shared kernel_context as VMMContext
dim shared current_context as VMMContext ptr
dim shared latest_context as VMMContext ptr
dim shared paging_active as unsigned integer