
constructor TWindow()
    _Title = _Title->Create()
	AssignNewObj(this.CloseButton,TButton)
	
    this.Destruct = @TWindowDestroy
    this.OnRedraw = @TWindowRedraw
    
    this.OnHandleMouse =@TWindowHandleMouse
    this.OnMouseExit = @TWindowMouseExit
    
    this._paddingLeft = WindowSkin->LeftWidth+2
    this._paddingTop = WindowSkin->TopHeight+2
    this._paddingRight = WindowSkin->RightWidth+2
    this._paddingBottom = WindowSkin->BottomHeight-2
    this.Shadow  = 0
    this.CanMove = -1
	
	this.OnSizeChanged = @TWindowSizeChanged
	this.CloseButton->OnRedraw = @TWindowCloseBtnRedraw
	this.CloseButton->OnClick = @TWIndowCLoseBtnClick
	CloseButton->SetSize(24,24)
	this.AddChild(CloseButton)
    BackgroundColor = &hFFFFFFFF
    this.TypeName = TWindowTypeName
end constructor


destructor TWindow()
    DestroyObj(_Title)
	this.RemoveChild(CloseButton)
	DestroyObj(CloseButton)
end destructor

sub TWindowDestroy(elem as TWindow ptr)
    elem->destructor()
end sub

sub TWindowSizeChanged(elem as TWindow ptr)
	GDIBaseSizeChanged(elem)
    
	elem->CloseButton->SetPosition(elem->_Width-24-elem->_paddingLeft-elem->_paddingRight,-elem->_paddingTop+4)
end sub

sub TWindowCloseBtnRedraw(elem as TButton ptr)
	dim i as unsigned integer=0
	if (elem->MouseOver) then i=1
    if (elem->MousePressed) then i=2
	elem->PutOtherPart(WindowCloseBtn,0,0,i*24,0,24,24,0)
end sub

sub TWIndowCLoseBtnClick(elem as TButton ptr)
	dim win as TWindow ptr =cptr(TWindow ptr ptr, elem->Parent)
	if (win->OwnerThread<>0 and win->Collapsed=0) then
        ThreadToTerminate = win->OwnerThread
	end if
end sub


sub TWindowRedraw(elem as TWindow ptr)
    WindowSkin->DrawOn(elem,0,0,0,elem->_Width ,elem->_Height,elem->BackgroundColor,0)
    
    if (elem->Title<>0) then
        if (elem->_Title->Len>0) then
            var ty = (elem->_paddingTop - FontManager.ML->FontHeight) shr 1
            elem->DrawText(elem->_Title->Buffer,elem->_paddingLeft,ty+2,&hFFFFFFFF,FontManager.ML,1)
            
            'elem->DrawText(IntToStr(cptr(Thread ptr,elem->OwnerThread)->Priority,10),elem->_paddingLeft,ty+2,&hFFFFFFFF,FontManager.ML,1)
        end if
    end if
    return
    'dim c1 as unsigned integer = &hFF29349C
    'dim c2 as unsigned integer = &hFF4A55BD
    'dim c3 as unsigned integer = &hFF00005A
    
    'elem->Clear(c1)
    'elem->DrawRectangle(0,0,elem->_width-1,elem->_height-1,&hFF000000)
    'elem->DrawRectangle(5,5,elem->_width-6,elem->_height-6,&hFF000000)
    'if (not elem->Collapsed) then
    '    elem->DrawLine(5,35,elem->_width-6,35,&hFF000000)
    '    elem->FillRectangle(6,36,elem->_width-7,elem->_height-7,&hFFFFFFFF)
    'end if
    
    
end sub


   
property TWindow.Title(value as unsigned byte ptr)
    this._Title->SetText(value)
    this.Invalidate()
end Property

property TWindow.Title(value as TString ptr)
    this._Title->SetText(value->Buffer)
    this.Invalidate()
end Property

property TWindow.Title() as unsigned byte ptr
    return this._Title->Buffer
end property

function TWindowHandleMouse(elem as TWindow ptr,_mx as integer,_my as integer,_mb as integer) as integer
    if (mouseb  = 1 ) then
        if (not elem->Draging) then
            if (_my<35 and _my>=0 and _mx<elem->CloseButton->_left) then
                elem->Draging = elem->CanMove
                elem->px=mousex
                elem->py=mousey
            end if            
            if (elem->Parent<>0 and elem->Parent->LastChild<>elem) then
                elem->BringToFront()
            end if
        else
            elem->SetPosition(elem->_left + mousex-elem->px,elem->_top+mousey-elem->py)
            elem->px=mousex
            elem->py=mousey
        end if
    else
        elem->Draging = 0
        if (mouseb  = 0 and elem->oldMouseB=2 and _my<35) then
            if (not elem->Collapsed) then
                elem->Collapsed = -1
                elem->SavedWidth  = elem->_Width
                elem->SavedHeight = elem->_Height
                elem->SetSize(elem->_Width,elem->_paddingTop+elem->_paddingBottom)
            else
                elem->Collapsed = 0
                elem->SetSize(elem->SavedWidth,elem->SavedHeight)
            end if
        end if
    end if
    elem->oldMouseB=mouseb
    return elem->Draging or (_mx>=0 and _my>=0 and _mx<=elem->_width and _my<=elem->_height) 
end function

function TWindowMouseExit(elem as TWindow ptr) as integer
    if (elem->Draging) then
        elem->SetPosition(elem->_left + mousex-elem->px,elem->_top+mousey-elem->py)
        elem->px=mousex
        elem->py=mousey
        return -1
    end if
    return 0
end function