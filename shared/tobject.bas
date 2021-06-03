constructor TObject
    this.Destruct = @TObjectDestroy
    this.TypeName = TObjectTypeName
end constructor

destructor TObject
    this.Destruct = 0
end destructor

sub TObjectDestroy(elem as TObject ptr)
    elem->destructor()
end sub

sub DestroyObj(o as TObject ptr)
    if (o->Destruct<>0) then
        cptr(sub(o as TObject ptr),o->Destruct)(o)
        Free(o)
    end if
end sub