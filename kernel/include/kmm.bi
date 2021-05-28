#define MAlloc(s) KAlloc(s)
#define MFree(s) KFree(s)
declare function PageAlloc(count as unsigned integer) as any ptr
declare sub PageFree(addr as any ptr)
declare function KAlloc(size as unsigned integer) as any ptr
declare sub KFree(addr as any ptr)