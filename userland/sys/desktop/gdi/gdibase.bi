#Macro GDIForeach(c,p) 
    var c = p.FirstChild
    while c<>0
#EndMacro
#Macro GDIForeachRev(c,p)
    var c = p.LastChild
    while c<>0
#EndMacro
#Macro GDIEndForeach(c)
    c = c->NextChild
    wend
#ENdMacro
#Macro GDIEndForeachRev(c)
    c = c->PrevChild
    wend
#EndMacro


Type GDIBase extends GImage field = 1
    Draging as integer
    Collapsed as integer
    Shadow as integer
    
    
    MouseOver as integer
    MousePressed as integer
	FGColor as unsigned integer
	
    _left as  integer
    _top as  integer
    _absoluteLeft as integer
    _absoluteTop as integer
    
    _paddingLeft as integer
    _paddingTop as integer
	_paddingRight as integer
	_paddingBottom as integer
    
	_hasFocus as unsigned integer
    
    _isScreen as unsigned integer
    _lfb as unsigned integer
    _lfbBack as any ptr
    _lfbBytesPerPixel as unsigned integer
    _transparent as integer
    _visible as integer
    
    ChildCount as unsigned integer
    Parent as GDIBase ptr
    FirstChild as GDIBase ptr
    NextChild as GDIBase ptr
    PrevChild as GDIBase ptr
    LastChild as GDIBase ptr
	PrevHandledChild as GDIBase ptr
    IsValid as unsigned integer
    CanManage as unsigned integer
    declare sub addChild(elem as GDIBase ptr)
    declare sub removeChild(elem as GDIBase ptr)
    declare sub ChildRemoved()
    declare sub BringToFront()
    declare sub Invalidate()
    declare sub UpdateAbsolutePosition()
    
    OnRedraw as any ptr
    OnRedrawFront as any ptr
    OnHandleMouse as any ptr
    OnMouseExit as any ptr
	
	OnGotFocus as any ptr
	OnLostFocus as any ptr
	OnKeyPress as any ptr
	
    
	_onUserKeyDown as unsigned integer
	_onUserClick as unsigned integer
	Owner as unsigned integer
	OwnerThread as unsigned integer
    declare constructor()
    declare destructor()
    
    declare sub DestroyChildren()
    
    
    declare property Left() as  integer
    declare property Left(l as  integer)
    declare property Top() as  integer
    declare property Top(t as  integer)
    declare sub SetPosition(l as  integer,t as integer)
    
	declare property Visible() as integer
	declare property Visible(v as integer)
    
    declare sub BindToScreen(_buff as unsigned integer,_w as unsigned integer,_h as unsigned integer,_bpp as unsigned integer)
    declare sub Convert32To24(dst as any ptr,src as any ptr,count as unsigned integer)
    
    declare sub syncScreen()
    declare sub Redraw()
    declare sub RedrawChildren()
    
	declare sub TakeFocus()
	declare sub TakeFocusInternal()
	declare sub LostFocusInternal()
	declare sub FocusNext()
    
	declare Function HandleMouse(_mx as integer,_my as integer, _mb as integer) as integer	
	
end type

declare sub GDIBaseDestroy(elem as GDIBase ptr)
declare sub GDIBaseSizeChanged(elem as GDIBase ptr)
dim shared GDI_FocusedElement as GDIBase ptr
declare function GDIBase_HandleMouse(elem as GDIBase ptr,_mx as integer,_my as integer,_mb as integer) as integer
declare function GDIBase_MouseExit(elem as GDIBase ptr) as integer
dim shared GDIBaseTypeName as unsigned byte ptr=@"GDIBase"