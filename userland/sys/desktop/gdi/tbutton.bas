constructor TButton()
    MouseOver = 0
    MousePressed = 0
    _Skin = ButtonSkin
    _Text = _Text->Create()
    OnRedraw = @TButton_Draw
    OnHandleMouse = @TButton_HandleMouse
    OnMouseExit = @TButton_MouseExit
    OnClick = 0
    AppCallBack = 0
	AppCallBackParameter = 0
    SmallIcon = 0
    BigIcon = 0
	Destruct = @TButtonDestroy
    this.TypeName = TButtonTypeName
end constructor

destructor TButton()
    DestroyObj(_Text)
    if (_Skin<>0 and _Skin<>ButtonSkin) then DestroyObj(_Skin)
    if (SmallIcon<>0) then DestroyObj(SmallIcon)
    if (BIgIcon<>0) then DestroyObj(BigIcon)
end destructor



sub TButtonDestroy(elem as TButton ptr)
	elem->Destructor()
end sub


   
property TButton.Text(value as unsigned byte ptr)
    this._Text->SetText(value)
    this.Invalidate()
end Property

property TButton.Text(value as TString ptr)
    this._Text->SetText(value->Buffer)
    this.Invalidate()
end Property

property TButton.Text() as unsigned byte ptr
    return this._Text->Buffer
end property



function TButton_HandleMouse(elem as TButton ptr,_mx as integer,_my as integer,_mb as integer) as integer
    if (elem->Parent<>0 and elem->Parent->Collapsed=-1) then return 0
    var op = elem->MousePressed
    var oo = elem->MouseOver
    
    elem->MouseOver = _mx>=0 and _my>=0 and _mx<=elem->_width and _my<=elem->_height
    elem->MousePressed =  (_mb = 1) and elem->MouseOver
    if (elem->MousePressed and not op) then elem->TakeFocus()
    if (op<>elem->MousePressed or oo<>elem->MouseOver) then elem->Invalidate()
    if (not elem->MousePressed) and (op) and (elem->MouseOver) then
        if (elem->OnClick<>0) then
            cptr(sub(e as TButton ptr),elem->OnClick)(elem)
        end if
    end if
    return elem->MouseOver
end function

function TButton_MouseExit(elem as TButton ptr) as integer
    var op = elem->MousePressed
    var oo = elem->MouseOver
    elem->MousePressed =  0
    elem->MouseOver = 0
    if (op<>elem->MousePressed or oo<>elem->MouseOver) then elem->Invalidate()
    return 0
end function

sub TButton_Draw(elem as TButton ptr)
    'dim c1 as unsigned integer = &hFFAAAAAA
    'dim c2 as unsigned integer = &hFFEEEEEE
    'dim c3 as unsigned integer = &hFF777777
    
    'if (elem->MouseOver) then c1 = &hFFBBBBBB
    'if (elem->MousePressed) then
    '    c2 = &hFF777777
    '    c3 = &hFFEEEEEE
    'end if
    
    'elem->Clear(c1)
    'elem->DrawRectangle(0,0,elem->_width-1,elem->_height-1,&hFF000000)
    'elem->DrawLine(1,1,elem->_Width-2,1,c2)
    'elem->DrawLine(1,1,1,elem->_Height-2,c2)
    'elem->DrawLine(elem->_Width-2,1,elem->_Width-2,elem->_Height-2,c3)
    'elem->DrawLine(1,elem->_Height-2,elem->_Width-2,elem->_height-2,c3)
	
	dim cb as unsigned integer = &hF6F6F6
	dim num as unsigned integer = 0
	if (elem->MouseOver) then 
		num=1
		cb = &hFFFFFF
	end if
	if (elem->MousePressed) then 
		num = 2
		cb = &hF6F6F6
	end if
	elem->Clear(0)
    if (elem->BigIcon=0) then
        elem->_Skin->DrawOn(elem,num,0,0,elem->_width ,elem->_height,cb,1)
    else
        if (elem->MouseOver) then
            elem->Clear(&h88FFFFDD) 
            if (elem->MousePressed) then
                elem->DrawRectangle(0,0,elem->_width-1,elem->_height-1,&hFFAAAAAA)
            end if
        else
            elem->Clear(&hFFFFFFFF)
        end if
    end if
	var l = elem->_Text->Len
    var tw = l*9
    var th = (FontManager.M->FontHeight-4)
    
    if (elem->SmallIcon<>0) then
        tw+=elem->SmallIcon->_width +5
    end if
    
    if (elem->BigIcon<>0) then
        th+=elem->BigIcon->_height+5
    end if
    
    var tx = (elem->_width -tw) shr 1
    var ty = (elem->_height -th) shr 1
    var iy=0
    if (elem->MousePressed) then
        iy=1
    end if
    if (elem->SmallIcon<>0) then
        elem->PutOther(elem->SmallIcon,tx,((elem->_height-elem->SmallIcon->_height) shr 1)+iy,1)
        tx+=elem->SmallIcon->_width +5
    end if
    if (elem->BigIcon<>0) then
        elem->PutOther(elem->BigIcon,((elem->_width - elem->BigIcon->_width) shr 1),ty+iy,1)
        ty+=elem->BigIcon->_height +5
    end if
    
	if (l>0) then
		elem->DrawText(elem->_Text->Buffer,tx,ty+iy,elem->FGColor,FontManager.M,1)
	end if
end sub