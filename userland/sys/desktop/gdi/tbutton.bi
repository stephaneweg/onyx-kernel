type TButton extends GDIBase field=1
    OnClick as any ptr
    _Text as TString ptr
    _Skin as Skin ptr
    AppCallBack as unsigned integer
	AppCallBackParameter as unsigned integer
    px as integer
    py as integer
    CanMove as integer
    SmallIcon as GImage ptr
    BIGIcon as GImage ptr
    declare constructor()
	declare destructor()
	
	
    declare Property Text() as unsigned byte ptr
    declare Property Text(value as unsigned byte ptr)
    declare Property Text(value as TString ptr)
end Type

declare sub TButtonDestroy(elem as TButton ptr)
declare sub TButton_Draw(elem as TButton ptr)
declare function TButton_HandleMouse(elem as TButton ptr,_mx as integer,_my as integer,_mb as integer) as integer
declare function TButton_MouseExit(elem as TButton ptr) as integer
dim shared ButtonSkin as Skin ptr
dim shared TButtonTypeName as unsigned byte ptr=@"TButton"