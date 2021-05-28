

function PageAlloc(count as unsigned integer) as any ptr
    'var addr = find_free_pages(@kernel_context,1,cuint(KEND),VMM_PAGETABLES_VIRT_START)
    'if (addr=0) then
    '    KERNEL_ERROR(@"Cannot allocate page",0)
    'end if
    var paddr = PMM_ALLOCPAGE(count)
    'if its above the identity mapping: map and return the virtual address
    'if (cuint(paddr)>=VMM_IDENTITY_MEMORY_END) then
    '    return vmm_kernel_automap(paddr,PAGE_SIZE*count,VMM_FLAGS_KERNEL_DATA)
    'else
    'map to kernel address space
    '
        return paddr
    'end if
end function

sub PageFree(addr as any ptr)
    'if it's above the identity mapping
    'resolve, free and unmap
    'if (cuint(addr)>=VMM_IDENTITY_MEMORY_END) then
    '    var paddr = current_context->resolve(addr)
    '    var count = PMM_FREE(paddr)
     '   vmm_kernel_unmap(addr,PAGE_SIZE*count)
    'else
        PMM_FREEPAGE(addr)
    'end if
end sub


function KAlloc(size as unsigned integer) as any ptr
    return SlabMeta.KAlloc(size)
end function

sub KFree(addr as any ptr)
    SlabMeta.KFree(addr)
end sub