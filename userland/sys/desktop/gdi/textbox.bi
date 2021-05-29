TYPE TextBox extends GDIBase FIELD=1
    _text as TString ptr
	FontSize as unsigned integer
	MaxLen as unsigned integer
    MouseOver as integer
    MousePressed as integer
    _textAlign as unsigned integer
	
    declare constructor()
	declare destructor()
    
    declare property TextAlign() as unsigned integer
    declare property TextAlign(value as unsigned integer)
    
    declare sub DrawTextValue()
    declare Property Text() as unsigned byte ptr
    declare Property Text(value as unsigned byte ptr)
    declare Property Text(value as TString ptr)
	
end type

TYPE TextBlock extends GDIBase FIELD=1
    _text as TString ptr
	FontSize as unsigned integer
    _fg as unsigned integer
    BorderColor as unsigned integer
    Padding as integer
    declare constructor()
	declare destructor()
    
    declare Property Text() as unsigned byte ptr
    declare Property Text(value as unsigned byte ptr)
    declare Property Text(value as TString ptr)
    
    declare Property ForeColor() as unsigned integer
    declare property ForeColor(f as unsigned integer)
	
end type
declare sub TextBlock_OnDestroy(elem as TextBlock ptr)
declare sub TextBlock_Redraw(txt as TextBlock ptr)

declare sub TextBox_OnDestroy(elem as TextBox ptr)
declare sub TextBox_Redraw(txt as textbox ptr)
declare sub TextBox_Resized(txt as textbox ptr)
declare function TextBox_HandleMouse(txt as textbox ptr,_mx as integer,_my as integer, _mb as integer) as integer
declare sub TextBox_GotFocus(obj as TextBox ptr)
declare sub TextBox_LostFocus(obj as TextBox ptr)
declare sub TextBox_KeyPress(obj as textbox ptr,char as unsigned byte)

dim shared TextBoxTypeName as unsigned byte ptr=@"TextBox"
dim shared TextBlockTypeName as unsigned byte ptr=@"TextBlock"