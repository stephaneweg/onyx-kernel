constructor GDIBase()
    this._left = 0
    this._top = 0
    this.Shadow = 0
    this._isScreen = 0
    this._lfb = 0
    this._lfbBack = 0
    this.FGColor = &hFF000000
    this.FirstChild = 0
    this.NextChild = 0
    this.PrevChild = 0
    this.Parent = 0
    this.LastChild = 0
	this.PrevHandledChild = 0
    this.ChildCount = 0
    this._transparent = 0
	
    this.OnRedraw = 0
    this.OnRedrawFront = 0
    this.OnHandleMouse = @GDIBase_HandleMouse
    this.OnMouseExit = @GDIBase_MouseExit
	
	this.OnGotFocus  = 0 
	this.OnLostFocus = 0
	this.OnKeyPress = 0
	
    this.Collapsed = 0
    this._paddingLeft = 0
    this._paddingTop = 0	
    this._paddingRight = 0
    this._paddingBottom = 0
	this._hasFocus = 0
    this.IsValid = 0
	this.Owner = 0
    this.OwnerThread = 0
    this.Draging = 0
    this.CanManage = 0
	this.Visible = -1
    this.Destruct = @GDIBaseDestroy
    this.OnSizeChanged = @GDIBaseSizeChanged
    this._onUserKeyDown = 0
    this.TypeName = GDIBaseTypeName
end constructor


destructor GDIBase()
	this.DestroyChildren()
    if (this._lfbBack<>0) then
        MFree(this._lfbBack)
        this._lfbBack=0
    end if
    this._left = 0
    this._top = 0
    this._bufferSize = 0
    this._isScreen = 0
    this._lfb = 0    
    
    this.FirstChild = 0
    this.NextChild = 0
    this.PrevChild = 0
    this.Parent = 0
    this.LastChild = 0
    this.ChildCount = 0
    this.IsValid = 0
end destructor

sub GDIBaseDestroy(elem as GDIBase ptr)
    elem->destructor()
end sub

function GDIBase_HandleMouse(elem as GDIBase ptr,_mx as integer,_my as integer,_mb as integer) as integer
    var op = elem->MousePressed
    var oo = elem->MouseOver
    
    elem->MouseOver = _mx>=0 and _my>=0 and _mx<=elem->_width and _my<=elem->_height
    elem->MousePressed =  (_mb = 1) and elem->MouseOver
    if (elem->MousePressed and not op) then elem->TakeFocus()
    if (op<>elem->MousePressed or oo<>elem->MouseOver) then elem->Invalidate()
    if (not elem->MousePressed) and (op) and (elem->MouseOver) then
        if elem->_onUserClick<>0 and elem->OwnerThread<>0 then
			XAppMouseClick(elem,_mx,_my)
		end if
    end if
    return 0
end function


function GDIBase_MouseExit(elem as GDIBase ptr) as integer
    var op = elem->MousePressed
    var oo = elem->MouseOver
    elem->MousePressed =  0
    elem->MouseOver = 0
    
    var child = elem->FirstChild
	while child<>0
		var n = child->NextChild
		if (child->OnMouseExit<>0) then
            cptr(sub(e as GDIBase ptr),child->OnMouseExit)(child)
        end if
		child=n
	wend
    
    if (op<>elem->MousePressed or oo<>elem->MouseOver) then elem->Invalidate()
    return 0
end function

sub GDIBase.DestroyChildren()
	var child = this.FirstChild
	while child<>0
		var n = child->NextChild
		child->DestroyChildren()
		RemoveChild(child)
		DestroyObj(child)
		child=n
	wend
end sub

sub GDIBaseSizeChanged(elem as GDIBase ptr)
    elem->Invalidate()
end sub

sub GDIBase.Invalidate()
    this.IsValid = 0
    if (this.Parent<>0) then this.Parent->Invalidate()
    if (this._isScreen) then
        SpinLock()
        GDI_UPDATED = 1
        SpinUnLock()
        'ThreadWakeUp(GUIThread,0,0)
        'if (GuiThread->State = ThreadState.waiting) then Scheduler.SetThreadReady(GuiThread,0)
    end if
end sub

sub GDIBase.UpdateAbsolutePosition()
    this._absoluteLeft = this._left
    this._absoluteTop = this._top
    if (this.Parent<>0) then
        this._absoluteLeft += this.Parent->_absoluteLeft + this.Parent->_paddingLeft
        this._absoluteTop += this.Parent->_absoluteTop+ this.Parent->_paddingTop
    end if
    
    GDIForeach(child,this)
        child->UpdateAbsolutePosition()
    GDIEndForeach(child)
end sub


sub GDIBase.AddChild(child as GDIBase ptr)
    if (child->parent = 0) then
        child->NextChild = 0
        child->PrevChild = this.LastChild
        
        if (this.LastChild = 0) then
            this.FirstChild = child
        else
            this.LastChild->NextChild = child
            
        end if
        this.LastChild = child
        child->Parent = @this
        this.ChildCount+=1
        child->UpdateAbsolutePosition()
        this.Invalidate()
    end if
end sub

sub GDIBase.RemoveChild(child as GDIBase ptr)
    if (child->Parent=@this) then
        if (child->PrevChild=0) then
            this.FirstChild = child->NextChild
        else
            child->PrevChild->NextChild =child->NextChild
        end if
        if (child->NextChild=0) then
            this.LastChild = child->PrevChild
        else
            child->NextChild->PrevChild = child->PrevChild
        end if
        this.ChildCount-=1 
        child->Parent=0
        this.Invalidate()
        ChildRemoved()
    end if
end sub

sub GDIBase.ChildRemoved()
        PrevHandledChild = 0
        if (Parent<>0) then parent->ChildRemoved()
end sub

sub GDIBase.BringToFront()
    if (Parent<>0) then
        if (Parent->LastChild<>@this) then
            var p = Parent
            Parent->RemoveChild(@this)
            p->AddChild(@this)
        end if
    end if
end sub


property GDIBase.Left() as integer
    return this._left
end property

property GDIBase.Left(l as integer)
    if (l<> this._left) then this.SetPosition(l,this._top)
end property

property GDIBase.Top() as integer
    return this._top
end property

property GDIBase.Top(t as integer)
    if (t<> this._top) then this.SetPosition(this._left,t)
end property

sub GDIBase.SetPosition(l as  integer,t as integer)
    if (this._left<>l or this._top<>t) then
        this._left = l
        this._top = t
        this.UpdateAbsolutePosition()
        if (this.Parent<>0) then this.Parent->Invalidate()
    end if
end sub

property GDIBase.Visible() as integer
	return this._visible
end property

property GDIBase.Visible(v as integer)
	if (v<>this._visible) then
		this._visible = v
		this.Invalidate()
	end if
end property


sub GDIBase.BindToScreen(_buff as unsigned integer,_w as unsigned integer,_h as unsigned integer,_bpp as unsigned integer)
    this.SetSize(_w,_h)
    this._lfb = _buff
    this._lfbBytesPerPixel = _bpp
    this._isScreen = -1
    this._lfbBack = MAlloc(this._width*this._height*_bpp)
end sub


sub GDIBase.Convert32To24(dst as any ptr,src as any ptr,count as unsigned integer)
    asm
        push    eax
        push    ebx
        push    ecx
        push    esi
        push    edi
        
        mov     ecx, [count]
        shr     ecx, 2              '// 4 pixels at once
        jz      ConvRGB32ToRGB24_$2
        mov     esi, [src]
        mov     edi, [dst]
ConvRGB32ToRGB24_$1:
        mov     ebx, [esi + 4]      '// sb
        and     ebx, 0x00ffffff       '// sb & 0xffffff
        mov     eax, [esi + 0]      '// sa
        and     eax, 0x00ffffff       '// sa & 0xffffff
        mov     edx, ebx            '// copy sb
        shl     ebx, 24             '// sb << 24
        or      eax, ebx            '// sa | (sb << 24)
        mov     [edi + 0], eax      '// Dst[0]
        shr     edx, 8              '// sb >> 8
        mov     eax, [esi + 8]      '// sc
        and     eax, 0x00ffffff       '// sc & 0xffffff
        mov     ebx, eax            '// copy sc
        shl     eax, 16             '// sc << 16
        or      eax, edx            '// (sb >> 8) | (sc << 16)
        mov     [edi + 4], eax      '// Dst[1]
        shr     ebx, 16             '// sc >> 16
        mov     eax, [esi + 12]     '// sd
        add     esi, 16             '// Src += 4 (ASAP)
        shl     eax, 8              '// sd << 8
        or      eax, ebx            '// (sc >> 16) | (sd << 8)
        mov     [edi + 8], eax      '// Dst[2]
        add     edi, 12             '// Dst += 3
        dec     ecx
        jnz     SHORT ConvRGB32ToRGB24_$1
ConvRGB32ToRGB24_$2:

        pop edi
        pop esi
        pop ecx
        pop ebx
        pop eax
    end asm
end sub

sub GDIBase.RedrawChildren()
    GDIForeach(child,this)
		if (child->_visible) then
			var tx = child->_left + this._paddingLeft
			var ty = child->_top+this._paddingTop
			
			if (child->Shadow) then
				this.FillRectangleAlpha(tx+child->_width,ty+2,tx+1+child->_width,ty+1+child->_height,&h88000000)
				this.FillRectangleAlpha(tx+2,ty+child->_height,tx+child->_width-1,ty+1+child->_height,&h88000000)
			end if
			child->Redraw()
			this.PutOther(child,tx,ty,child->_transparent)
		end if
    GDIEndForeach(child)
end sub

sub GDIBase.Redraw()
    if (this.isValid = 0) then
        if (this.OnRedraw<>0) then
            cptr(sub(elem as any ptr), this.OnRedraw)(@this)
        end if
		if (not this.Collapsed) then this.RedrawChildren()
        if (this.OnRedrawFront<>0) then
            cptr(sub(elem as any ptr),this.OnRedrawFront)(@this)
        end if
        
        if (this._isScreen) then
            syncScreen()
        end if
        this.isValid = 1
    
    end if
end sub

sub GDIBase.syncScreen()
    if (this._isScreen) then
            
            dim dst as any ptr = cptr(any ptr,this._lfb)
            dim src as any ptr= cptr(any ptr,this._lfbBack)
            dim cpt as unsigned integer = this._width*this._height*this._lfbBytesPerPixel
            
            if (this._lfbBytesPerPixel=3) then            
                Convert32To24(this._lfbBack,this._buffer,this._width*this._height)
                memcpy512(dst,src,cpt shr 6)
            else
                src = cptr(any ptr,this._buffer)
                memcpy512(dst,src,cpt shr 6)
            end if
    end if
end sub


Function GDIBase.HandleMouse(_mx as integer,_my as integer, _mb as integer) as integer
    
    dim handled as integer = 0
    
    if (this.OwnerThread<>0) then
        'if (cptr(thread ptr,this.OwnerThread)->HasModalVisible) then
        '    if (this.CanManage = 0) then return 0
        'end if
    end if
    
    if (PrevHandledChild<>0) then
        if (PrevHandledChild->Draging<>0 and PrevHandledChild->_visible) then
            if (MouseX>=this._absoluteLeft and _
                MouseX<=this._absoluteLeft+this._width and _
                MouseY>=this._absoluteTop and _
                MouseY<=this._absoluteTop + this._height) then
                    handled = PrevHandledChild->HandleMouse(MouseX-PrevHandledChild->_absoluteLeft,MouseY-PrevHandledChild->_absoluteTop,_mb)
           end if
       end if
    end if
    
	dim ExitedFrom as GDIBase ptr = 0
	if (this.Draging = 0) then
		GDIForeachRev(child,this)
			if (child->_visible) then
				if (handled<>0) then exit while
				if (MouseX>=child->_absoluteLeft and _
					MouseX<=child->_absoluteLeft+child->_width and _
					MouseY>=child->_absoluteTop and _
					MouseY<=child->_absoluteTop + child->_height) then
					handled = child->HandleMouse(MouseX-child->_absoluteLeft,MouseY-child->_absoluteTop,_mb)
					if (handled) then
						if (child<>PrevHandledChild and PrevHandledChild<>0) then
							ExitedFrom = PrevHandledChild
						end if
						PrevHandledChild = child
					end if
				end if 
			end if
		GDIEndForeachRev(child)
	end if
    
    
    if (not handled) then
        if (PrevHandledCHild<>0) then
            ExitedFrom = PrevHandledChild
            PrevHandledChild = 0
        end if
        
        if (OnHandleMouse<>0 and visible) then
            handled = cptr(function(elem as GDIBase ptr,_mx as integer,_my as integer,_mb as integer) as integer,OnHandleMouse)(@this,MouseX-this._absoluteLeft,MouseY-this._absoluteTop,_mb)
        end if
    end if
    
    if (ExitedFrom<>0) then
        if (ExitedFrom->OnMouseExit<>0) then
            cptr(sub(p as GDIBase ptr),ExitedFrom->OnMouseExit)(ExitedFrom)
        end if
    end if
    return handled
    
end function

sub GDIBase.TakeFocus()
	if (GDI_FocusedElement<>@this) then
		if (GDI_FocusedElement<>0) then
			GDI_FocusedElement->LostFocusInternal()
		end if
		
		this.TakeFocusInternal()
		
		GDI_FocusedElement = @this
		if (GDI_FocusedElement->OnGotFocus<>0) then
			cptr(sub(e as any ptr),GDI_FocusedElement->OnGotFocus)(GDI_FocusedElement)
		end if
	end if
end sub

sub GDIBase.LostFocusInternal()
	this._hasFocus = 0
	if (OnLostFocus<>0) then
		cptr(sub(e as any ptr),OnLostFocus)(@this)
	end if
	
	GDIForeach(child,this)
		child->LostFocusInternal()
	GDIEndForeach(child)
	
	if (GDI_FocusedElement=@this) then GDI_FocusedElement = 0
end sub

sub GDIBase.TakeFocusInternal()
	this._HasFocus = 1
	if (this.Parent<>0) then this.Parent->TakeFocusInternal()
end sub

sub GDIBase.FocusNext()
	if (this.Parent<>0) then
		if (this.NextChild<>0) then
			this.NextChild->TakeFocus()
		else
			this.Parent->FirstChild->TakeFocus()
		end if
	end if
end sub
