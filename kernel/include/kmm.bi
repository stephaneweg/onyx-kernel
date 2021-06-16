declare function KMM_ALLOCPAGE() as any ptr
declare sub KMM_FREEPAGE(addr as any ptr)
declare function KAlloc(size as unsigned integer) as any ptr
declare sub KFree(addr as any ptr)
declare sub KMM_INIT()