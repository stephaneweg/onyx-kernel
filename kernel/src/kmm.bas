

'allocate a #count number of physical page, and map them in a contigous number of pages
function KMM_ALLOCPAGE() as any ptr
    var paddr = PMM_ALLOCPAGE()
    if (paddr<>0) then
        return vmm_kernel_automap(paddr, PAGE_SIZE,VMM_FLAGS_KERNEL_DATA)
    end if
    return 0
end function

sub KMM_FREEPAGE(vaddr as any ptr)
    var paddrx = current_context->Resolve(cptr(any ptr,vaddr))
    if (paddrx<>0) then
            current_context->unmap_page(cptr(any ptr,vaddr))
            PMM_FREEPAGE(paddrx)
    else
        KERNEL_ERROR(@"The page is not used",cuint(vaddr))
    end if
end sub
    

function KAlloc(size as unsigned integer) as any ptr
    return SlabMeta.KAlloc(size)
end function

sub KFree(addr as any ptr)
    SlabMeta.KFree(addr)
end sub