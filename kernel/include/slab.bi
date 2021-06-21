#define minSlabPower 5
#define maxSlabPower 9

declare function GetSmallestPowerOfTwoo(value as unsigned integer) as unsigned integer
type SlabEntry field = 1
    NextEntry as SlabEntry ptr
end type

type Slab field =1
    NextSlab as Slab ptr
    PrevSlab as Slab ptr
    FreeList as SlabEntry ptr
    SlabStart as unsigned integer
    ItemSize as unsigned short
    IsFull as unsigned byte
    IsEmpty as unsigned byte
    ItemsCount as unsigned integer
    
    declare destructor()
    declare sub Init(isize as unsigned short)
    declare function Alloc(isize as unsigned integer) as any ptr
    declare function Free(addr as any ptr) as unsigned byte
    declare function IsValidAddr(addr as any ptr) as unsigned integer
end type

type SlabMetaData  field=1
    SlabEntry as Slab
    SlabCount as unsigned integer
    FirstSlab as Slab ptr
    declare function KAlloc(s as unsigned integer) as any ptr
    declare sub KFree(addr as any ptr)
    declare function IsValidAddr(addr as any ptr) as unsigned integer
end type 
dim shared SlabMeta as SlabMetaData
declare sub SlabINIT()
