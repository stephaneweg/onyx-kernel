#include once "kernel.bi"
#include once "pmm.bi"
#include once "console.bi"

dim shared PageBitmap(0 to &hFFFFF) as unsigned integer
function PMM_GET_FREEPAGES_COUNT() as unsigned integer
    return TotalPagesCount
end function

sub PMM_INIT(mb_info as multiboot_info ptr)
    ConsoleWrite(@"Physical pages allocator initializing ...")
    MemoryEnd = cptr(any ptr,mb_info->mem_upper * 1024)
    FirstPage = (cuint(KEND) shr 12)+1
    LastPage = (mb_info->mem_upper shr 2)
    for i as unsigned integer = 0 to &hFFFFF
        PageBitmap(i)=0
    next i
    
    PMM_STRIPE(0,cuint(KEND))
    PMM_STRIPE(mb_info->mem_upper shl 10,&hFFFFFFFF)
    
    TotalPagesCount = 0
    for i as unsigned integer = 0 to &hFFFFF
        if (PageBitmap(i)=0) then TotalPagesCount+=1
    next i
    ConsolePrintOK()
    ConsoleNewLine()
    
    ConsoleWriteTextAndSize(@"UPER MEMORY      :",(mb_info->mem_upper)*1024,true)
    ConsoleWriteTextAndDec(@"Availables free page",TotalPagesCount,true)
end sub

sub PMM_STRIPE(start_addr as unsigned integer,end_addr as unsigned integer)
    dim startPage as unsigned integer = start_addr shr 12
    dim endPage as unsigned integer = end_addr shr 12
    
    for i as unsigned integer = startPage to endPage
        PageBitmap(i) = &hFFFFFFFF
        TotalPagesCount-=1
    next
end sub

'allocate a contigous number of pages
'it will mark the bitmap cells as used, and put the count in the first cell
'so it can free all pages when freeing the pages
function PMM_ALLOCPAGE(pagesCount as unsigned integer) as any ptr
   
    dim i as unsigned integer
    dim obase as unsigned integer = FirstPage
    dim cptFree as unsigned integer = 0
    for i = FirstPage to LastPage
        if (PageBitmap(i)= 0) then 
            cptFree+=1
            if (cptFree=pagesCount) then
                for i = obase to obase+pagesCount-1
                    PageBitmap(i) = 1
                next i
                PageBitmap(obase) = pagesCount
                TotalPagesCount-=pagesCount
                return cptr(any ptr,obase shl 12)
            end if
        else
            cptFree=0
            obase = i+1
        end if
    next i
    KERNEL_ERROR(@"Cannot find enought free page",0)
    return 0
end function


'it will fre the pages at this address
'the parameter is the address of the first page
'in the bitmap , the value is the count of contigous pages allocated
function PMM_FREEPAGE(addr as any ptr) as unsigned integer
    dim obase as unsigned integer = cast(unsigned integer,addr) shr 12
    dim pagesCount as unsigned integer = PageBitmap(obase)
    
	if (pagesCount>0) then
		dim i as unsigned integer
		for i = obase to obase+pagesCount-1
			if (PageBitmap(i)=0) then
				KERNEL_ERROR(@"Page is already free",0)
			end if
			PageBitmap(i) = 0
		next i
        TotalPagesCount+=pagesCount
        return pagesCount
	else
		KERNEL_ERROR(@"Cannot free aloready freed page",0)
	end if
    return 0
end function