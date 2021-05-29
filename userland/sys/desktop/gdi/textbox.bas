
Constructor TextBox()
	this.FontSize = 1
    this._Text=this._Text->Create()
    this.MaxLen=255
    this._TextAlign=0
    Destruct=@TextBox_OnDestroy
    
    
	
    OnRedraw=@TextBox_Redraw
    OnHandleMouse=@TextBox_HandleMouse
    base.OnGotFocus=@TextBox_GotFocus
    OnLostFocus=@TextBox_LostFocus
    base.OnKeyPress=@TextBox_KeyPress
    this.TypeName = TextBoxTypeName
end Constructor

destructor TextBox()
	DestroyObj(_Text)
end destructor

Constructor TextBlock()
	this.FontSize = 1
    this.Destruct=@TextBlock_OnDestroy
    this.OnRedraw=@TextBlock_Redraw
    
    this._Text=this._Text->Create()
    this._fg=&hFF000000
    this.TypeName = TextBlockTypeName
end Constructor

destructor TextBlock()
	DestroyObj(_Text)
end destructor 

property TextBox.TextAlign() as unsigned integer
    return this._textAlign
end property

property TextBox.TextAlign(value as unsigned integer)
    if (this._textAlign<>value) then
        this._textAlign=value
        this.Invalidate()
    end if
end property

sub TextBox_OnDestroy(elem as TextBox ptr)
    elem->destructor()
end sub

sub TextBlock_OnDestroy(elem as TextBlock ptr)
    elem->destructor()
end sub

sub TextBlock_Redraw(txt as TextBlock ptr)
	txt->Clear(&hFFFFFFFF)
	txt->DrawText(txt->_text->Buffer,3,(txt->_height-16)/2,txt->_fg,FontManager.SIMPAGAR,1)

end sub

sub TextBox_Redraw(txt as TextBox ptr)
	txt->FillRectangle(0,0,txt->_width-1,txt->_height-1,&hFFffffff)
	
	txt->DrawTextValue()
	
	if (txt->_HasFocus) then
		txt->DrawRectangle(0,0,txt->_width-1,txt->_height-1,&hFF33B5E5)
		txt->DrawRectangle(1,1,txt->_width-2,txt->_height-2,&hFF33B5E5)
	else
		txt->DrawRectangle(0,0,txt->_width-1,txt->_height-1,&hFFaaaaaa)
	end if
end sub

sub TextBox.DrawTextValue()
    dim ml as integer =(this._width-8)/(this.FontSize*9)
    dim toDraw as unsigned byte ptr = this._text->Buffer
	
	if (this._hasFocus) then
		toDraw = strCat(toDraw,@"_")
	end if
	
    dim x as integer=5
    var l=strlen(toDraw)
    if l>ml then 
        toDraw=substring(toDraw,l-ml,-1)
        l=maxlen
    end if
	
    if (this._textAlign=1) then x=(this.Width-10)-(l*9*this.FontSize)
    dim ty as integer=(this._height-16*this.FontSize)/2
    DrawText(toDraw,x,ty,&hFF000000,FontManager.SIMPAGAR,this.FontSize)
    
end sub

property TextBox.Text(value as unsigned byte ptr)
    this._Text->SetText(value)
    this.Invalidate()
end Property

property TextBox.Text(value as TString ptr)
    this._Text->SetText(value->Buffer)
    this.Invalidate()
end Property

property TextBox.Text() as unsigned byte ptr
    return this._Text->Buffer
end property



property TextBlock.Text(value as unsigned byte ptr)
    this._Text->SetText(value)
    this.Invalidate()
end Property

property TextBlock.Text(value as TString ptr)
    this._Text->SetText(value->Buffer)
    this.Invalidate()
end Property

property TextBlock.Text() as unsigned byte ptr
    return this._Text->Buffer
end property

property TextBlock.ForeColor() as unsigned integer
    return this._fg
end property

property TextBlock.ForeColor(f as unsigned integer)
    this._fg=f
    this.Invalidate()
end property

sub TextBox_GotFocus(obj as TextBox ptr)
    obj->Invalidate()
end sub

sub TextBox_LostFocus(obj as TextBox ptr)
    obj->Invalidate()
end sub

function TextBox_HandleMouse(txt as textbox ptr,_mx as integer,_my as integer, _mb as integer) as integer
    dim oldMouseOver as integer=txt->MouseOver
    dim oldMousePressed as integer=txt->MousePressed
    dim ax as integer=txt->_absoluteLeft
    dim ay as integer=txt->_absoluteTop        
    
    txt->MouseOver= (MouseX>=ax) and (MouseX<ax+txt->_width) and (MouseY>=ay) and (MouseY<ay+txt->_height)
    txt->MousePressed=txt->MouseOver and ((_mb and 1) = 1)
    
    if (not txt->MousePressed) and (oldMousePressed) then
        if (txt->MouseOver) then
            if (not txt->_HasFocus) then
                txt->TakeFocus()
                'TextBox_GotFocus(elem)
            end if
        else
            txt->LostFocusInternal()
        end if
    end if
    return 0
end function

sub TextBox_KeyPress(txt as textbox ptr,char as unsigned byte)
    if (char=8) then
        if (txt->_Text->Len>0) then
            txt->_Text->SubStr(0,txt->_Text->Len-1)
        end if
    elseif (char=13) or (char=27) then
        txt->LostFocusInternal()
    elseif (char=9) then
        txt->LostFocusInternal()
        txt->FocusNext()
    else
        if (txt->_Text->Len<txt->MaxLen) then
            txt->_Text->AppendChar(char)
        end if
    end if
    txt->Invalidate()
end sub