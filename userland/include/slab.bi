#define minSlabPower = 5
#define maxSlabPower = 9

#define minSize 64

#define MALLOC(n) SlabMeta.Alloc(n)
#define MFree(a) SlabMeta.Free(a)
    
type SlabEntry field = 1
    NextEntry as SlabEntry ptr
end type

type SlabPageEntry field=1
    PageAddr as any ptr
    PagesCount as unsigned integer
    IsFree as unsigned integer
    NextPage as SlabPageEntry ptr
end type

type Slab field =1
    NextSlab as Slab ptr
    FreeList as SlabEntry ptr
    SlabStart as unsigned integer
    ItemSize as unsigned integer
    IsFull as unsigned byte
    
    declare sub Init(isize as unsigned integer)
    declare function Alloc(isize as unsigned integer) as any ptr
    declare function Free(addr as any ptr) as unsigned byte
end type

type SlabMetaData  field=1
    SlabEntry as Slab
    SlabPagesEntries as SlabPageEntry ptr
    FirstSlab as Slab ptr
    declare function Alloc(s as unsigned integer) as any ptr
    declare sub Free(addr as any ptr)
    
    declare function SlabAllocPage(count as unsigned integer) as any ptr
    declare sub SlabFreePage(addr as any ptr)
end type 
dim shared SlabMeta as SlabMetaData
declare sub SlabINIT()
