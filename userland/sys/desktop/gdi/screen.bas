sub ScreenInit()
	GDI_FocusedElement = 0
    
    GUI_LOCK    = SemaphoreCreate()
    
	LoadMouseCursor()
	
	AssignNewObj(RootScreen,GDIBase)
	RootScreen->BindToScreen(LFB,XRes,YRes,BytesPerPixel)
    rootScreen->OnRedraw      = @ScreenDrawBack
    rootScreen->OnRedrawFront = @ScreenDrawFront
	AssignNewObj(ScreenBGR,GImage)
    ScreenBGR->SetSize(XRes,YRes)
	'beos blue &h3060a0
    ScreenBGR->Clear(&hFF3060A0)'&hFF224488)
    'GenBackground()
	
   
    
	'MouseX = XRes shr 1
	'MouseY = YRes shr 1
end sub


sub LoadMouseCursor()
    MouseCursor.Constructor()
    MouseCursor.SetSize(12,19)
    
    dim fmousebuff as unsigned byte ptr
    dim fbmousesize as unsigned integer = 0
    fmousebuff=VFS_LOAD_FILE(@"SYS:/RES/mousecur.bin",@fbmousesize)
    if (fmousebuff<>0 and fbmousesize<>0) then
        dim i as integer
        dim fcar as unsigned byte
        for i=0 to fbmousesize-1
            fcar=fmousebuff[i]
            select case fcar
                case 1
                    MouseCursor._buffer[i]=&hFFFFFFFF
                case 2
                    MouseCursor._buffer[i]=&hFF000000          
                case else
                    MouseCursor._buffer[i]=0
                end select
        next i
        Free(fmousebuff)
    end if
    MouseCursor.IsValid=1
end sub

sub ScreenDrawBack(elem as GDIBase ptr)
    memcpy32(elem->_buffer, ScreenBGR->_Buffer,elem->_bufferSize)
end sub

sub ScreenDrawFront(elem as GDIBase ptr)
    elem->PutOther(@MouseCursor,mousex,mousey,1)
end sub


sub ScreenLoop()
    SemaphoreLock(GUI_LOCK)
    dim c as unsigned byte
    c=KBD_GetChar()
	if (c<>0) then
        var kbdHandled = 0
		if GDI_FocusedElement<>0 then
            dim canHandle as integer = GDI_FocusedElement->OnKeyPress<>0
            
            if (GDI_FocusedElement->OwnerThread<>0) then
                'if (cptr(thread ptr,GDI_FocusedElement->OwnerThread)->HasModalVisible) then
                '    if (GDI_FocusedElement->CanManage = 0) then canHandle= 0
                'end if
            end if
            
			if canHandle then
				cptr(sub(p as any ptr,k as unsigned byte),GDI_FocusedElement->OnKeyPress)(GDI_FocusedElement,c)
                kbdHandled = 1
			end if
        end if
        
        if (kbdHandled=0) then
            var child=RootScreen->LastChild
            while child<>0
                if (child->_onUserKeyDown<>0 and child->OwnerThread<>0) then
                    XAppKeyPress(child,c)
                    exit while
                end if
                child=child->PrevChild
            wend
		end if
	end if
	RootScreen->HandleMouse(mousex,mousey,mouseb)
    RootScreen->Redraw()
    SemaphoreUnLock(GUI_LOCK)
end sub

sub GenBackground()
        dim adiv as integer=2
        
        dim mx as unsigned integer
        dim my as unsigned integer
        mx=ScreenBGR->_width \adiv
        my=ScreenBGR->_height \adiv
        dim i as unsigned integer
        dim j as unsigned integer
        dim m as integer=8
        dim ptArray as unsigned integer ptr=MAlloc(sizeof(unsigned integer)*(m*2))
        for i=0 to m-1
            ptArray[i*2]=NextRandomNumber(0,mx)
            ptArray[i*2+1]=NextRandomNumber(0,my)
        next i
        
       
        dim xsquare as integer
        dim ysquare as integer
        dim sum as unsigned integer
        
        dim minDistance as unsigned integer
        dim result as unsigned integer
        
        dim x as unsigned integer
        dim y as unsigned integer
      
        for y=0 to my-1
            
            for x=0 to mx-1
                
                minDistance=-1
                for i=0 to m-1
                
                    if (x>ptArray[i*2]) then 
                        xsquare=(x-ptArray[i*2])
                    else
                        xsquare=(ptArray[i*2]-x)
                    end if
                    xsquare=(xsquare*256)/mx
                    if (xsquare>128) then xsquare=256-xsquare
                    
                    if (y>y-ptArray[i*2+1]) then
                        ysquare=y-ptArray[i*2+1]
                    else
                        ysquare=ptArray[i*2+1]-y
                    end if
                    ysquare=(ysquare*256)/my
                    if (ysquare>128) then ysquare=256-ysquare
                    
                    sum=sqrt(xsquare*xsquare+ysquare*ysquare) 'shr 1
                    if (sum>255) then sum=255
                    if (sum<minDistance) then minDistance=sum
                next i
                result=minDistance
                var ccc=computeColor(&h00AA00,result and 255)
                
				for i= 0 to adiv -1
					for j=0 to adiv-1
						dim _yy as unsigned integer = (y+(my*j))
						dim _xx as unsigned integer = (x+(mx*i))
						if (_yy>=0 and _xx >=0 and _yy<ScreenBGR->_height and _xx<ScreenBGR->_width) then
							ScreenBGR->_buffer[_yy*ScreenBGR->_width+_xx]=ccc
						end if
					next j
				next i
            next x
        next y
        
        
       
        Free(ptArray)
end sub

function ComputeColor(c as unsigned integer,chanel as unsigned integer) as unsigned integer
    var minchanel=16
    var ratio=255/(255-minchanel)
    var cc=minchanel+(chanel/ratio)
    
    if cc>255 then cc=255
    var red=(((c and &hFF0000) shr 16)*cc) shr 8
    var green=(((c and &hFF00) shr 8)*cc) shr 8
    var blue=(((c and &hff)*cc)) shr 8
    return &hFF000000 or ((red and &hFF) shl 16) or ((green and &hFF) shl 8) or (blue and &hFF)
end function