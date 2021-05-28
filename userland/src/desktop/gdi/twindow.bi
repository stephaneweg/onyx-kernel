type TWindow extends GDIBase field=1
    _Title as TString ptr
    
    BackgroundColor as unsigned integer
    px as integer
    py as integer
    CanMove as integer
    savedWidth as integer
    savedHeight as integer
    oldMouseB as integer
    
	CloseButton as TButton ptr
    declare constructor()
    declare destructor()
    
    
    declare Property Title() as unsigned byte ptr
    declare Property Title(value as unsigned byte ptr)
    declare Property Title(value as TString ptr)
end type

declare sub TWindowDestroy(elem as TWindow ptr)
declare sub TWindowRedraw(elem as TWindow ptr)
declare function TWindowHandleMouse(elem as TWindow ptr,_mx as integer,_my as integer,_mb as integer) as integer
declare function TWindowMouseExit(elem as TWindow ptr) as integer
declare sub TWindowCloseBtnRedraw(elem as TButton ptr)
declare sub TWindowSizeChanged(elem as TWindow ptr)
declare sub TWIndowCLoseBtnClick(elem as TButton ptr)
dim shared WindowSkin as Skin ptr
dim shared WindowCloseBtn as GImage ptr
dim shared TWindowTypeName as unsigned byte ptr=@"TWindow"
