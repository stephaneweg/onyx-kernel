TYPE AddressSpaceEntry field =1
    NextEntry   as AddressSpaceEntry ptr
    PrevEntry   as AddressSpaceEntry ptr
    
    VirtAddr    as unsigned integer
    PagesCount  as unsigned integer
    VMM_Context as VMMContext ptr
    
    declare function SBRK(n as unsigned integer) as any ptr
    declare sub CopyFrom(src as any ptr,size as unsigned integer)
    declare destructor()
end type

