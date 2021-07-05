#include once "vmm.bi"
#include once "kernel.bi"


#define PAGE_SIZE 4096
#define PAGE_SIZE_DWORD 1024
#define GET_PAGEDIR_INDEX(x) ((cuint(x) shr 22) and &h3FF)
#define GET_PAGETABLE_INDEX(x) ((cuint(x) shr 12) and &h3FF)
#define num_pages(n) (((n + &hFFF) and (&hFFFFF000)) shr 12)


sub VMM_INIT()
    ConsoleWrite(@"Initializing Virtual Memory Management")
    paging_active = 0
    kernel_context.p_dir = PMM_ALLOCPAGE()
    memset32(kernel_context.p_dir,0,PAGE_SIZE_DWORD)
    kernel_context.v_dir = kernel_context.p_dir
    current_context = @kernel_context
    
    kernel_context.p_dir[VMM_PAGETABLES_VIRT_START shr 22] = cuint(kernel_context.p_dir) or VMM_FLAG_PRESENT or VMM_FLAG_WRITEABLE
    
    'map from 0 to memory end 
    kernel_context.map_range(KSTART, KSTART, KEND, VMM_FLAGS_KERNEL_DATA)
    
  
    'map text video memory
    kernel_context.map_page(CONSOLE_MEM,CONSOLE_MEM, VMM_FLAGS_USER_DATA)
	
	'map the page tables 
    kernel_context.v_dir = cptr(uinteger ptr, (VMM_PAGETABLES_VIRT_START shr 22)*4096*1024 + (VMM_PAGETABLES_VIRT_START shr 22)*4096)
    
    'map real mode module 1:1
    kernel_context.map_page(cptr(any ptr, RealModeAddr), cptr(any ptr, RealModeAddr), VMM_FLAGS_KERNEL_DATA)
    
    
    kernel_context.version = 1
	latest_context = @kernel_context
    ConsolePrintOK()
    ConsoleNewLine()
end sub


sub VMM_EXIT()
    
    asm
        mov ebx,cr4
        and ebx, &hFFFFFF7F
        mov cr4,ebx
        
        mov ebx,cr0
        and ebx, &h7FFFFFFF
        mov cr0,ebx
    end asm
    paging_active = 0
    
end sub

function vmm_get_current_context () as VMMContext ptr
	return current_context
end function


function vmm_kernel_automap (p_start as any ptr, size as unsigned integer, flags as unsigned integer ) as any ptr
	return vmm_get_current_context()->automap(p_start, size, ((cuint(KEND) shr 12) +1) shl 12, ProcessAddress, flags)
end function


sub vmm_kernel_unmap (v_start as any ptr, size as uinteger)
	vmm_get_current_context()->unmap_range(v_start, num_pages(size))
end sub

'' loads the pagedir into cr3 and activates paging
sub vmm_init_local ()
	dim pagedir as uinteger ptr = kernel_context.p_dir
	asm
		'' load the page directory address
		mov ebx, [pagedir]
		mov cr3, ebx

		'' set the paging bit
		mov ebx, cr0
		or ebx, &h80000000
		mov cr0, ebx

		'' set the PGE (page global enable) bit
		mov ebx, cr4
		or ebx, &h80
		mov cr4, ebx
	end asm
	KTSS_SET_CR3(cuint(pagedir))
	paging_active = 1
end sub

destructor VMMContext()
    for i as unsigned integer = 256 to 1023
        if (( this.v_dir[i] and VMM_PAGE_MASK) <> 0) then
            PMM_FREEPAGE(cptr(any ptr,(cuint(this.v_dir[i]) and VMM_PAGE_MASK)))
        end if
    next i
    current_context->unmap_page(this.v_dir)
    PMM_FREEPAGE(this.P_dir)
end destructor

'' create_context () creates and clears space for a page-directory
sub VMMContext.Initialize ()
    this.version    = 0
    FirstVMMPage = ((cuint(KEND) shr 22)+1) shl 22
	this.p_dir  = PMM_ALLOCPAGE()
	this.v_dir  = vmm_kernel_automap(this.p_dir, PAGE_SIZE,VMM_FLAGS_KERNEL_DATA)
	memset32(this.v_dir, 0, PAGE_SIZE_DWORD)
    
    'map the LFB
	if (LFB<>0 and LFBSize<>0) then
		var lfbEND =LFB+(((LFBSize shr 12) +1) shl 12)
		map_range(cptr(any ptr,LFB),cptr(any ptr, LFB),cptr(any ptr, lfbEND), VMM_FLAGS_USER_DATA)
	end if
	'' copy the kernel address space
	this.sync()

	'' pagetables need to be accessible
	this.v_dir[VMM_PAGETABLES_VIRT_START shr 22] = cuint(this.p_dir) or VMM_FLAG_PRESENT or VMM_FLAG_WRITEABLE
end sub


sub VMMContext.Sync()
	if (this.version < latest_context->version) then
		memcpy32(this.v_dir, latest_context->v_dir, &hff)'3FC bytes (1020) = 255 dword
        this.version = latest_context->version
	end if
	latest_context = @this
end sub



sub VMMContext.Activate()
    if (current_context<>@this) then
        this.Sync()
        current_context = @this
    
        dim pagedir as uinteger ptr = this.p_dir
        asm
            mov ebx, [pagedir]
            mov cr3, ebx
        end asm
		
		KTSS_SET_CR3(cuint(pagedir))
    end if
end sub


function VMMContext.get_pagetable (index as unsigned integer) as unsigned integer ptr
	dim pdir as unsigned integer ptr =  this.v_dir
    if (paging_active=0) then pdir = this.p_dir

	'' is there no pagetable?
	if ((pdir[index] and VMM_FLAG_PRESENT) = 0) then return 0

	if (@this = current_context) then
		'' the pdir is currently active
		if (paging_active=1) then
			return cast(unsigned integer ptr, VMM_PAGETABLES_VIRT_START + 4096*index)
		else
			return cast(unsigned integer ptr, pdir[index] and VMM_PAGE_MASK)
		end if
	else
		return vmm_kernel_automap(cptr(any ptr, (pdir[index] and VMM_PAGE_MASK)), PAGE_SIZE,VMM_FLAGS_KERNEL_DATA)
	end if
end function


sub VMMContext.free_pagetable (table as unsigned integer ptr)
	if (@this <> current_context) then
		current_context->unmap_page(table)
	end if
end sub

function VMMContext.find_free_pages (pages as unsigned integer, lower_limit as unsigned integer, upper_limit as unsigned integer) as unsigned integer
	
    dim pdir as unsigned integer ptr = this.v_dir
	dim free_pages_found as unsigned integer = 0

	dim cur_page_table as unsigned integer = lower_limit shr 22
	dim cur_page as unsigned integer = (lower_limit shr 12) mod 1024

	while ((free_pages_found < pages) and ((cur_page_table shl 22) < upper_limit))
		if (pdir[cur_page_table] and VMM_FLAG_PRESENT) then
            
			'' ok, there is a page table, search the entries
			dim ptable as unsigned integer ptr = this.get_pagetable(cur_page_table)
			while (cur_page < 1024)
				''is the entry free?
				if ((ptable[cur_page] and VMM_FLAG_PRESENT) = 0) then
                   
					free_pages_found += 1
					if (free_pages_found >= pages) then exit while
				else
					free_pages_found = 0
					lower_limit = (cur_page_table shl 22) or ((cur_page+1) shl 12)
				end if
				cur_page += 1
			wend

			this.free_pagetable(ptable)
		else
			'' the whole table is free
			free_pages_found += 1024
		end if

		cur_page = 0
		cur_page_table += 1
	wend

	if ((free_pages_found >= pages) and (lower_limit + pages * PAGE_SIZE <= upper_limit)) then
		return lower_limit
	else
		return 0
	end if
end function


function VMMContext.automap (p_start as any ptr, size as unsigned integer, lowerLimit as unsigned integer, upperLimit as unsigned integer, flags as unsigned integer) as any ptr
	if (size=0) then return 0

	dim aligned_addr as unsigned integer = cuint(p_start) and VMM_PAGE_MASK
	dim aligned_bytes as unsigned integer = size + (cuint(p_start) - aligned_addr)

	'' search for free pages
	dim vaddr as unsigned integer = this.find_free_pages(num_pages(aligned_bytes), lowerLimit, upperLimit)

	'' not enough free pages found?
	if (vaddr = 0) then 
        KERNEL_ERROR(@"No free pages found",0)
        return 0
    end if
    
	'' map the pages
	this.map_range(cast(any ptr, vaddr), cast(any ptr, aligned_addr), cast(any ptr, aligned_addr+aligned_bytes), flags)

	'' return the virtual address
	return vaddr + (p_start - aligned_addr)
end function


function VMMContext.MAP_PAGE(virt as any ptr,phys as any ptr, flags as unsigned integer) as boolean
    dim clear_page as boolean = false
    
    dim pdir_entry as unsigned integer ptr =  @(this.v_dir[GET_PAGEDIR_INDEX(virt)])
    if (paging_active=0) then pdir_entry = @(this.p_dir[GET_PAGEDIR_INDEX(virt)])
   
   if ((*pdir_entry and VMM_FLAG_PRESENT) <> VMM_FLAG_PRESENT) then
       
       'if the page dir is not present, and if we want to unmap, it is not necessary to create a new pagetable
       if (phys=0) then return true
       
		'' reserve memory
		dim pagetable as any ptr = PMM_ALLOCPAGE()

		'' insert the new pagetable into the pagedir
		*pdir_entry = cuint(pagetable) or (VMM_FLAG_PRESENT or VMM_FLAG_WRITEABLE or VMM_FLAG_USER)

		'' set the clear flag because the table is new, we cannot clear it now because it's not mapped
		clear_page = true
        
        if (virt < ProcessAddress) then
			this.version = latest_context->version+1
			latest_context = @this
		end if
	end if
    
    '' fetch page-table address from page directory
	dim page_table as unsigned integer ptr = this.get_pagetable(GET_PAGEDIR_INDEX(virt))
    
    if (clear_page) then
		'' if the table needs to be cleared we clear it now because it is now mapped
		memset32(page_table, 0, PAGE_SIZE_DWORD)
	end if
	'' set address and flags
	page_table[GET_PAGETABLE_INDEX(virt)] = (cuint(phys) or flags)
    
    'if we unmap, check if there is still content
    'if not, we can free the pagetable
    if (phys=0) then
        dim hasContent as unsigned integer = 0
        for i as unsigned integer = 0 to 1023
            if ((page_table[i] and VMM_FLAG_PRESENT ) = VMM_FLAG_PRESENT) then
                hasContent = 1
                exit for
            end if
        next i
        if (hasContent=0) then
            var pagetable = this.Resolve(page_table)
            PMM_FREEPAGE(pageTable)
            *pdir_entry = 0
        end if
    end if
	'' invalidate virtual address
	asm
		mov ebx, dword ptr [virt]
		invlpg [ebx]
	end asm

	'' don't forget to free the pagetable
	this.free_pagetable(page_table)
    
    return true
end function



function VMMContext.map_range (v_addr as any ptr, p_start as any ptr, p_end as any ptr, flags as uinteger) as boolean
	dim v_dest as uinteger = cuint(v_addr) and VMM_PAGE_MASK
	dim p_src as uinteger = cuint(p_start) and VMM_PAGE_MASK


	'' FIXME: first check if the area is free, and map only then

	while (p_src < p_end)
		if ((this.map_page(cast(any ptr, v_dest), cast(any ptr, p_src), flags)=0)) then
			return false
		end if
		p_src += PAGE_SIZE
		v_dest += PAGE_SIZE
	wend

	return true
end function



sub VMMContext.unmap_page (v_addr as any ptr)
	this.map_page(v_addr, 0, 0)
end sub


sub VMMContext.unmap_range (v_addr as any ptr, pages as uinteger)
	for counter as uinteger = 0 to pages-1
		this.unmap_page(v_addr+counter*PAGE_SIZE)
	next
end sub


function VMMContext.Resolve (vaddr as any ptr) as any ptr
	dim pagetable_virt as uinteger ptr
	dim result as uinteger

	'' get the pagetable
	pagetable_virt = this.get_pagetable(GET_PAGEDIR_INDEX(cuint(vaddr)))

	'' pagetable not present?
	if (pagetable_virt = 0) then return 0

	'' get the entry of the page
	result = pagetable_virt[GET_PAGETABLE_INDEX(cuint(vaddr))]

	if (result and VMM_FLAG_PRESENT) then
		'' page present
		result = (result and VMM_PAGE_MASK) or (cuint(vaddr) and &hFFF)
	else
		'' page not present
		result = 0
	end if

	'' free the pagetable
	this.free_pagetable(pagetable_virt)

	return cast(any ptr, result)
end function