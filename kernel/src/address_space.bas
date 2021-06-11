function AddressSpaceEntry.SBRK(n as unsigned integer) as any ptr
    var retval = this.PagesCount
    if (n>0) then
        for i as unsigned integer=0 to n-1
            var paddr = PMM_ALLOCPAGE(1)
            var vaddr = this.VirtAddr+(this.PagesCount shl 12)
            
            'if unable to allocate
            if (paddr = 0) then 
                'free allocated pages
                if (i>0) then
                    for j as unsigned integer = 0 to i-1
                        var vaddrx = this.VirtAddr+((retval+j) shl 12)
                        var paddrx = this.VMM_CONTEXT->Resolve(cptr(any ptr,vaddrx))
                        if (paddrx<>0) then
                            PMM_FREEPAGE(paddrx)
                        end if
                    next j
                end if
                this.PagesCount = 0
                return 0
            end if
            this.VMM_Context->MAP_PAGE(cptr(any ptr,vaddr),cptr(any ptr,paddr),VMM_FLAGS_USER_DATA)
            this.PagesCount+=1
        next i
    end if
    return cptr(any ptr, this.VirtAddr + ( retval shl 12))
end function

destructor AddressSpaceEntry()
    if (this.NextEntry<>0) then
        this.NextEntry->Destructor()
        KFree(this.NextEntry)
        this.NextEntry = 0
    end if
    
    if (this.PagesCount>0) then
        for i as unsigned integer = 0 to this.PagesCount -1
            var vaddrx = this.VirtAddr+(i shl 12)
            var paddrx = this.VMM_CONTEXT->Resolve(cptr(any ptr,vaddrx))
            if (paddrx<>0) then
                PMM_FREEPAGE(paddrx)
            end if
        next i
    end if
    this.PagesCount     = 0
    this.VirtAddr       = 0
    this.VMM_CONTEXT    = 0
end destructor

sub AddressSpaceEntry.CopyFrom(_src as any ptr,size as unsigned integer)
    
	dim remaining as unsigned integer = size
    dim addr as unsigned integer = this.VirtAddr
    dim src as unsigned integer = cuint(_src)
    while remaining>0
        dim chunkSize as unsigned integer = iif(remaining>PAGE_SIZE,PAGE_SIZE,remaining)
        dim phys as any ptr = this.VMM_CONTEXT->Resolve(cptr(any ptr,addr))
        
        dim dst as any ptr = VMM_KERNEL_AUTOMAP(phys,PAGE_SIZE,VMM_FLAGS_KERNEL_DATA)
        memcpy(dst,cptr(any ptr,src),chunkSize)
        VMM_KERNEL_UNMAP(dst,PAGE_SIZE)
        
        addr+=chunkSize
        src+=chunkSize
        remaining-=chunkSize
    wend
end sub