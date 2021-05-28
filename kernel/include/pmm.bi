declare sub PMM_INIT(mb_info as multiboot_info ptr)
declare sub PMM_STRIPE(start_addr as unsigned integer,end_addr as unsigned integer)
declare function PMM_ALLOCPAGE(pagesCount as unsigned integer) as any ptr
declare function PMM_FREEPAGE(addr as any ptr) as unsigned integer
declare function PMM_GET_FREEPAGES_COUNT() as unsigned integer
dim shared MemoryEnd as any ptr

dim shared FirstPage as unsigned integer
dim shared LastPage as unsigned integer
dim shared TotalPagesCount as unsigned integer