
#define NewObj(v,t) var v = cptr(t ptr,MAlloc(sizeof(t))) : v->constructor()
#define AssignNewObj(v,t) v = cptr(t ptr,MAlloc(sizeof(t))) : v->constructor()
#define DeleteObj(o) MFree(o)

type TObject field = 1
    Destruct as any ptr
    TypeName as unsigned byte ptr
    declare constructor()
    declare destructor()
end Type

declare sub DestroyObj(o as TObject ptr)
declare sub TObjectDestroy(elem as TObject ptr)
dim shared TObjectTypeName as unsigned byte ptr = @"TObject"

