

sub int35Handler(_intno as unsigned integer,_senderproc as unsigned integer,_sender as unsigned integer,_eax as unsigned integer,_ebx as unsigned integer,_ecx as unsigned integer,_edx as unsigned integer,_esi as unsigned integer,_edi as unsigned integer,_ebp as unsigned integer,_esp as unsigned integer)
    dim signalSender as boolean = true
    select case _EAX
        case &h01 'create generic ui element
            dim _parent as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            
            dim _w as unsigned integer = _ECX shr 16
            dim _h as unsigned integer = _ECX and &hFFFF
            dim _x as unsigned integer = _EDX shr 16
            dim _y as unsigned integer = _EDX and &hFFFF
            
            NewObj(gd,GDIBase)
            gd->SetSize(_w,_h)
            gd->SetPosition(_x,_y)
            gd->Owner = _senderproc
            gd->OwnerThread = _sender
            if (_parent<>&hFFFFFFFF) then
                if (_parent<>0) then
                    _parent->AddChild(gd)
                else
                    rootScreen->AddChild(gd)
                end if
            end if
            _eax = cast(unsigned integer,gd)
        case &h02 'window create
            dim _w as unsigned integer =_EBX shr 16
            dim _h as unsigned integer = _EBX and &hFFFF
            
           
			GetStringFromCaller(TmpString,_ECX)
           
            NewObj(win,TWindow)
            win->SetSize(_w + win->_paddingLeft + win->_paddingRight,_h+win->_paddingTop+win->_paddingBottom)
            dim _x as integer = NextRandomNumber(0,(XRES-win->_width)-60)+30' (XRES - _w) shr 1
            dim _y as integer = NextRandomNumber(0,(YRes-win->_height)-60)+30' (YRES - _h) shr 1
            win->SetPosition(_x,_y)
            win->Owner = _senderproc
            win->OwnerThread = _sender
            win->Title = TmpString
            rootScreen->AddChild(win)
            
            ProcessRegister(_senderProc,_sender)
            ProcessSetTitle(_senderProc,win->Title)
            ProcessActivate(_senderProc)
            _EAX = cast(unsigned integer,win)
            
        case &h03 'button create
            dim _parent as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            dim _w as unsigned integer = _ECX shr 16
            dim _h as unsigned integer = _ECX and &hFFFF
            dim _x as unsigned integer = _EDX shr 16
            dim _y as unsigned integer = _EDX and &hFFFF
			GetStringFromCaller(TmpString,_ESI)
            dim _c as unsigned integer = _EDI
            dim _p as unsigned integer  = _EBP
            NewObj(btn,TButton)
            btn->SetSize(_w,_h)
            btn->SetPosition(_x,_y)
            btn->Owner = _senderproc
            btn->OwnerThread = _sender
            btn->Text = TmpString
            btn->OnClick = @XAppButtonClick
            btn->AppCallBack = _c
			btn->AppCallBackParameter = _p
            
            _parent->AddChild(btn)
            _EAX = cast(unsigned integer,btn)
            
            
        case &h04 'textbox create
            dim _parent as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            dim _w as unsigned integer = _ECX shr 16
            dim _h as unsigned integer = _ECX and &hFFFF
            dim _x as unsigned integer = _EDX shr 16
            dim _y as unsigned integer = _EDX and &hFFFF
            
            NewObj(txt,TextBox)
            txt->SetSize(_w,_h)
            txt->SetPosition(_x,_y)
            txt->Owner = _senderproc
            txt->OwnerThread = _sender
            
            _parent->AddChild(txt)
            _EAX = cast(unsigned integer,txt)
        
        case &h05'textblock create
            dim _parent as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            dim _x as unsigned integer = _ECX shr 16
            dim _y as unsigned integer = _ECX and &hFFFF
            dim _c as unsigned integer = _ECX
			GetStringFromCaller(TmpString,_ESI)
            NewObj(tb,TextBlock)
            tb->SetSize(strlen(TmpString)*9,16)
            tb->SetPosition(_x,_y)
            tb->Text = TmpString
            tb->ForeColor = _c
            tb->Owner = _senderproc
            tb->OwnerThread = _sender
			
            
            if (_parent<>0) then
                _parent->AddChild(tb)
            else
                rootScreen->AddChild(tb)
            end if
            _EAX = cast(unsigned integer,tb)
            
        
        case &h06 'create console
            dim _parent as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            dim _w as unsigned integer = _ECX shr 16
            dim _h as unsigned integer = _ECX and &hFFFF
            dim _x as unsigned integer = _EDX shr 16
            dim _y as unsigned integer = _EDX and &hFFFF
            
            
            NewObj(console,TConsole)
            console->SetSize(_w,_h)
            console->SetPosition(_x,_y)
			console->Clear(&hFF000000)
            console->Owner = _senderproc
            console->OwnerThread = _sender
            if (_parent<>0) then
                _parent->AddChild(console)
            else
                rootScreen->AddChild(console)
            end if
            
            _EAX = cast(unsigned integer,console)
            
        case &h07'GDI clear
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,_EBX)
			dim c as unsigned integer = _EcX
            _gd->Clear(c)
            
        case &h08 'draw line
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            dim _x1 as unsigned integer = _ECX shr 16
            dim _y1 as unsigned integer = _ECX and &hFFFF
            dim _x2 as unsigned integer = _EDX shr 16
            dim _y2 as unsigned integer = _EDX and &hFFFF
            dim _c as unsigned integer = _ESI
            if (_gd<>0) then _gd->DrawLine(_x1,_y1,_x2,_y2,_c)
            if (_gd->Parent<>0) then 
               ' _gd->Parent->Invalidate()
               ' RootScreen->Redraw()
            end if
        
        case &h09 'drawRectangle
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            dim _x1 as unsigned integer = _ECX shr 16
            dim _y1 as unsigned integer = _ECX and &hFFFF
            dim _x2 as unsigned integer = _EDX shr 16
            dim _y2 as unsigned integer = _EDX and &hFFFF
            dim _c as unsigned integer = _ESI
            if (_gd<>0) then _gd->DrawRectangle(_x1,_y1,_x2,_y2,_c)
            if (_gd->Parent<>0) then 
               ' _gd->Parent->Invalidate()
               ' RootScreen->Redraw()
            end if
            
            
        case &h0A 'fillRectangle
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            dim _x1 as unsigned integer = _ECX shr 16
            dim _y1 as unsigned integer = _ECX and &hFFFF
            dim _x2 as unsigned integer = _EDX shr 16
            dim _y2 as unsigned integer = _EDX and &hFFFF
            dim _c as unsigned integer = _ESI
            dim _a as unsigned integer = _c shr 24
            
            if (_gd<>0) then 
                if (_a = 0 or _a = 255) then
                    _gd->FillRectangle(_x1,_y1,_x2,_y2,_c)
                else
                    _gd->FillRectangleAlpha(_x1,_y1,_x2,_y2,_c)
                end if
            end if
            if (_gd->Parent<>0) then
              '  _gd->Parent->Invalidate()
              '  RootScreen->Redraw()
            end if
        
        
		case &h0B 'draw text
		
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,_EBX)
			GetStringFromCaller(TmpString,_ESI)
			dim _x as unsigned integer = _ECX shr 16
            dim _y as unsigned integer = _ECX and &hFFFF
			dim c as unsigned integer = _EDX
			_gd->DrawText(TmpString,_x,_y,c,FontManager.ML,1)
            if (_gd->Parent<>0) then
               ' _gd->Parent->Invalidate()
            end if
            
        
        
        case &h0C 'draw char
		
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,_EBX)
			dim cara as unsigned byte = _ESI
			dim _x as unsigned integer = _ECX shr 16
            dim _y as unsigned integer = _ECX and &hFFFF
			dim c as unsigned integer = _EDX
			_gd->DrawChar(cara,_x,_y,c,FontManager.ML,1)
            if (_gd->Parent<>0) then
                '_gd->Parent->Invalidate()
            end if
            
        
        case &h0D 'put buffer
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,_EDI)
            dim _w as unsigned integer = _EBX shr 16
            dim _h as unsigned integer = _EBX and &hFFFF
            dim _x as unsigned integer = _ECX shr 16
            dim _y as unsigned integer = _ECX and &hFFFF
            var size = _w*_h * _edx
            dim src as unsigned integer ptr = MapBufferFromCaller(cptr(any ptr,_esi),size)
            
                
            if (_EDX = 3) then
                dim src32 as unsigned integer ptr = Malloc(sizeof(unsigned integer)*_w*_h)
                dim src24 as unsigned byte ptr = cptr(unsigned byte ptr,src)
                dim n as unsigned integer = (_w*_h)-1
                dim i as unsigned integer
                for i = 0 to n
                    var b = src24[i*3]
                    var g = src24[i*3+1]
                    var r = src24[i*3+2]
                    src32[i] = (r shl 16) or (g shl 8) or (b) or &hFF000000 
                next i
                _gd->PutOtherRaw(src32,_w,_h,_x,_y)
                Free(src32)
            else
                _gd->PutOtherRaw(src,_w,_h,_x,_y)
            end if
            if (_gd->Parent<>0) then
                '_gd->Parent->Invalidate()
            end if
            UnMapBuffer(src,size)
        case &h0E 'GDISetPosition
            dim g as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            g->SetPosition(cast(integer,_ECX),cast(integer,_EDX))
            
        case &h0F 'GDISetFGColor
            dim g as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            g->FGColor = _ECX
            g->Invalidate()
            
        case &h10'GDISetTransparent
            dim g as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            g->_transparent = _ECX
            g->Invalidate()
            
        case &h11 'GDIElem Set visibility
            dim g as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            if (_ECX = 1) then
                g->Visible = -1
            else
                g->Visible = 0
            end if
            g->Invalidate
            
        case &h12 'ButtonSetSkin
            dim btn as TButton ptr = cptr(TButton ptr,_EBX)
            if (btn->TypeName=TButtonTypeName) then
                
                GetStringFromCaller(TmpString,_ECX)
                var sk = Skin.Create(TmpString,3,12,12,12,12)
                if (sk<>0) then
                    btn->_Skin = sk
                    btn->Invalidate()
                end if
            end if
            
        case &h13'ButtonSetIcon
            dim btn as TButton ptr = cptr(TButton ptr,_EBX)
            if (btn->TypeName=TButtonTypeName) then
                GetStringFromCaller(TmpString,_ECX)
                if (_edx=0) then
                    btn->SmallIcon = GImage.LoadFromBitmap(TmpString)
                elseif(_edx=1) then
                    btn->BigIcon = GImage.LoadFromBitmap(TmpString)
                end if
                btn->Invalidate()
            end if  
            
        case &h14 'Textbox get text
            dim txt as TextBox ptr = cptr(TextBox ptr,_EBX)
            if (txt->TypeName = TextBoxTypeName) then
				SetStringToCaller(_EDI,txt->_Text->Buffer)
            end if
            
        case &h15 'textbox set text
            dim txt as TextBox ptr = cptr(TextBox ptr,_EBX)
            if (txt->TypeName = TextBoxTypeName) then
				if (GetStringFromCaller(TmpString,_ESI)=1) then
					txt->Text = TmpString
				else
					txt->Text = @"ERROR"
				end if
            end if
            
        case &h16'textbox append char
            dim txt as TextBox ptr = cptr(TextBox ptr,_EBX)
            if (txt->TypeName = TextBoxTypeName) then
                dim c as unsigned byte = cast(unsigned byte,_ECX)
                txt->_Text->AppendChar(c)
                txt->Invalidate()
            end if
            
        
        case &h17 'console write
            dim console as TConsole ptr = cptr(TConsole ptr,_EBX)
            if (console->TypeName=TConsoleTypeName) then
				GetStringFromCaller(TmpString,_Ecx)
                console->Write(TmpString)
                console->parent->invalidate()
            end if
            
        case &h18 'console write line
            dim console as TConsole ptr = cptr(TConsole ptr,_EBX)
            if (console->TypeName=TConsoleTypeName) then
				GetStringFromCaller(TmpString,_Ecx)
                console->WriteLine(TmpString)
                console->parent->invalidate()
            end if
        case &h19 'console put char
            dim console as TConsole ptr = cptr(TConsole ptr,_EBX)
            if (console->TypeName=TConsoleTypeName) then
                console->PutChar(cast(unsigned byte,_ECX))
                console->parent->invalidate()
            end if
            
        case &h1A 'console new line
            dim console as TConsole ptr = cptr(TConsole ptr,_EBX)
            if (console->TypeName=TConsoleTypeName) then
                console->NewLine()
            end if
        
        case &h1B'button set skin color
            dim btn as TButton ptr=cptr(TButton ptr,_EBX)
            if (btn->TypeName=TButtonTypeName) then
                if (btn->_Skin<>0 and btn->_Skin<>ButtonSkin) then
                    var c = _ecx
                    if (c=1) then c=WinColor
                    btn->_Skin->ApplyColor(c,1)
                end if
            end if
            
        case &h1C'set shadow
            dim g as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            g->Shadow = (_ECX<>0)
            
        case  &h1F 'bring to front
            dim gd as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            gd->BringToFront()
            
        case  &h20 'get buffer
            if (_ebx=0) then
                var virt = MapBufferToCaller(ScreenBGR->_buffer,ScreenBGR->_width*ScreenBGR->_height*4)
                _eax = cuint(virt)
                _ebx = ScreenBGR->_width
                _ecx =ScreenBGR->_height
            else
                dim gd as GDIBase ptr = cptr(GDIBase ptr,_EBX)
                var virt = MapBufferToCaller(gd->_buffer,gd->_width*gd->_height*4)
                _eax = cuint(virt)
                _ebx = gd->_width
                _ecx = gd->_height
            end if
        case &h60 'OnKeyPress
            dim _g as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            _g->_onUserKeyDown = _ECX
        case &h61 'OnMouseClick
            dim _g as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            _g->_onUserClick = _ECX
            
        
        case &h70
		
			GetStringFromCaller(TmpString,_EBX)
			GetStringFromCaller(TmpString2,_ECX)
            MessageBox.Show( TmpString, TmpString2,DIALOGButton.OKOnly,_sender)
            signalSender = false
            'currentThread->State=ThreadState.WaitingDialog
            'return  Scheduler.Switch(stack,Scheduler.Schedule()) 
        case &h71
			GetStringFromCaller(TmpString,_EBX)
			GetStringFromCaller(TmpString2,_ECX)
            MessageBox.Show( TmpString, TmpString2,DIALOGButton.NoYes,_sender)
            signalSender = false
            'currentThread->State=ThreadState.WaitingDialog
            'return  Scheduler.Switch(stack,Scheduler.Schedule()) 
        
        case &hFE
            dim _g as GDIBase ptr = cptr(GDIBase ptr,_EBX)
            _g->Invalidate()
        case &hFF
            _EAX = XRES
            _EBX = YRES
		case &hFFFFFF 'process terminated
			TerminatedProc = _ebx
    end select
    if (signalSender) then
        EndIPCHandlerAndSignal()
    else
        EndIPCHandler()
    end if
    do:loop
end sub