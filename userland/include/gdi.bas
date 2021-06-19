
function GDICreate(_parent as unsigned integer,x as  integer,y as  integer,w as unsigned integer,h as unsigned  integer) as unsigned integer
    return IPCSend(&h35,&h01,_parent,cuint(w)*cuint(65536)+cuint(h),cuint(x)*cuint(65536)+cuint(y),0,0,0,0,0,0)
end function

function GDIWindowCreate(w as unsigned integer,h as unsigned integer, t as any ptr) as unsigned integer 
    return IPCSend(&h35,&h2,cuint(w)*cuint(65536)+cuint(h),cuint(t),0,0,0,0,0,0,0)
   
end function

function GDIButtonCreate(_parent as unsigned integer,x as integer,y as integer,w as unsigned integer,h as unsigned integer,t as any ptr,c as any ptr, parm as unsigned integer) as unsigned integer
    return IPCSend(&h35,&h3,_parent,cuint(w)*cuint(65536)+cuint(h),cuint(x)*65536+cuint(y),cuint(t),cuint(c),cuint(parm),0,0,0)
  
'    asm
'		push ebp
'        mov eax,&h03
'        mov ebx,[_parent]
'        mov ecx,[w]
'        shl ecx,16
'        or ecx,[h]
'        mov edx,[x]
'        shl edx,16
'        or edx,[y]
'        mov esi,[t]
'        mov edi,[c]
'		push [parm]
'		pop ebp
'        int 0x35
'		pop ebp
'        mov [function],eax
'    end asm
end function

function GDITextBoxCreate(_parent as unsigned integer,x as integer,y as integer,w as unsigned integer,h as unsigned integer) as unsigned integer
    asm
        mov eax,&h04
        mov ebx,[_parent]
        mov ecx,[w]
        shl ecx,16
        or ecx,[h]
        mov edx,[x]
        shl edx,16
        or edx,[y]
        int 0x35
        mov [function],eax
    end asm
end function

function GDITextBlockCreate(_p as unsigned integer,x as integer,y as integer,t as unsigned byte ptr,c as unsigned integer) as unsigned integer
    asm
        mov eax,&h05
        mov ebx,[_p]
        mov ecx,[x]
        shl ecx,16
        or ecx,[y]
        mov edx,[c]
        mov esi,[t]
        int 0x35
        mov [function],eax
    end asm
end function

function GDIConsoleCreate(_p as unsigned integer,x as unsigned integer,y as unsigned integer,w as unsigned integer,h as unsigned integer) as unsigned integer

	asm
		mov eax,&h06
		mov ebx,[_p]
		mov ecx,[w]
		shl ecx,16
		add ecx,[h]
		mov edx,[x]
		shl edx,16
		add edx,[y]
		int 0x35
		mov [function],eax
	end asm
end function

sub GDIClear(_gd as unsigned integer,c as unsigned integer)
    asm
        mov eax,&h07
        mov ebx,[_gd]
        mov ecx,[c]
        int 0x35
    end asm
end sub

sub GDIDrawLine(_gd as unsigned integer,x1 as  integer,y1 as  integer,x2 as  integer,y2 as  integer,c as unsigned integer)
     asm
        mov eax,&h08
        mov ebx,[_gd]
        mov ecx,[x1]
        shl ecx,16
        or ecx,[y1]
        mov edx,[x2]
        shl edx,16
        or edx,[y2]
        mov esi,[c]
        int 0x35
    end asm
end sub

sub GDIDrawRectangle(_gd as unsigned integer,x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
     asm
        mov eax,&h09
        mov ebx,[_gd]
        mov ecx,[x1]
        shl ecx,16
        or ecx,[y1]
        mov edx,[x2]
        shl edx,16
        or edx,[y2]
        mov esi,[c]
        int 0x35
    end asm
end sub

sub GDIFillRectangle(_gd as unsigned integer,x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
     asm
        mov eax,&h0A
        mov ebx,[_gd]
        mov ecx,[x1]
        shl ecx,16
        or ecx,[y1]
        mov edx,[x2]
        shl edx,16
        or edx,[y2]
        mov esi,[c]
        int 0x35
    end asm
end sub

sub GDIDrawText(_gd as unsigned integer,txt as unsigned byte ptr,x as integer,y as integer,c as unsigned integer)
    asm
        mov eax,&h0B
        mov ebx,[_gd]
        mov ecx,[x]
        shl ecx,16
        or ecx,[y]
        mov edx,[c]
        mov esi,[txt]
        int 0x35
    end asm
end sub

sub GDIDrawChar(_gd as unsigned integer,cara as unsigned byte,x as integer,y as integer,c as unsigned integer)
    asm
        mov eax,&h0C
        mov ebx,[_gd]
        mov ecx,[x]
        shl ecx,16
        or ecx,[y]
        mov edx,[c]
        mov esi,[cara]
        int 0x35
    end asm
end sub

sub GDIPutImage(_gd as unsigned integer,_x as unsigned integer,_y as unsigned integer,_width as unsigned integer,_height as unsigned integer,bpp as unsigned integer,_buffer as unsigned integer)
    asm
        mov eax,&h0D
        mov ebx,[_width]
        shl ebx,16
        add ebx,[_height]
        mov ecx,[_x]
        shl ecx,16
        add ecx,[_y]
        mov edx,[bpp]
        mov esi,[_buffer]
        mov edi,[_gd]
        int 0x35
    end asm
end sub

sub GDIBringToFront(_gd as unsigned integer)
    asm
        mov eax,&h1F
        mov ebx,[_gd]
        int 0x35
    end asm
end sub

function GDIGetBuffer(_gdi as unsigned integer,w as unsigned integer ptr,h as unsigned integer ptr) as unsigned integer ptr
    dim _w as unsigned integer
    dim _h as unsigned integer
    dim _result as unsigned integer ptr
    asm
        mov eax,&h20
        mov ebx,[_gdi]
        int 0x35
        mov [_result],eax
        mov [_w],ebx
        mov [_h],ecx
    end asm
    *w = _w
    *h = _h
    return _result
end function

sub GDISetPosition(_gd as unsigned integer,x as integer,y as integer)
	asm
		mov eax,&h0E
		mov ebx,[_gd]
		mov ecx,[x]
		mov edx,[y]
		int 0x35
	end asm
end sub

sub GDISetForegroundColor(g as unsigned integer,c as unsigned integer)
    asm
        mov eax,&h0F
        mov ebx,[g]
        mov ecx,[c]
        int 0x35
    end asm
end sub

sub GDISetTransparent(_gdi as unsigned integer,transparent as unsigned integer)
    asm
        mov eax,&h10
        mov ebx,[_gdi]
        mov ecx,[transparent]
        int 0x35
    end asm
end sub

sub GDISetVisible(_gdi as unsigned integer,visible as unsigned integer)
    asm
        mov eax,&h11
        mov ebx,[_gdi]
        mov ecx,[visible]
        int 0x35
    end asm
end sub


sub GDIButtonSetSkin(_btn as unsigned integer,skin as unsigned byte ptr)
    asm
        mov eax,&h12
        mov ebx,[_btn]
        mov ecx,[skin]
        int 0x35
    end asm
end sub

sub GDIButtonSetIcon(_btn as unsigned integer,icon as unsigned byte ptr,big as unsigned integer)
    asm
        mov eax,&h13
        mov ebx,[_btn]
        mov ecx,[icon]
        mov edx,[big]
        int 0x35
    end asm
end sub

sub GDITextBoxGetText(_tb as unsigned integer,dst  as unsigned byte ptr)

    asm
        mov eax,&h14
        mov ebx,[_tb]
		mov edi,[dst]
        int 0x35
    end asm
end sub

sub GDITextBoxSetText(_tb as unsigned integer,text as unsigned byte ptr)
    asm
        mov eax,&h15
        mov ebx,[_tb]
        mov esi,[text]
        int 0x35
    end asm
end sub

sub GDITextBoxAppendChar(_tb as unsigned integer,c as unsigned byte)
    asm
        mov eax,&h16
        mov ebx,[_tb]
        mov ecx,[c]
        int 0x35
    end asm
end sub

sub GDIConsoleWrite(_console as unsigned integer,txt as unsigned byte ptr)
	asm
		mov eax,&h17
		mov ebx,[_console]
		mov ecx,[txt]
		int 0x35
	end asm
end sub

sub GDIConsoleWriteLine(_console as unsigned integer,txt as unsigned byte ptr)
	asm
		mov eax,&h18
		mov ebx,[_console]
		mov ecx,[txt]
		int 0x35
	end asm
end sub

sub GDIConsolePutChar(_console as unsigned integer,c as unsigned byte)
	asm
		mov eax,&h19
		mov ebx,[_console]
		mov ecx,[c]
		int 0x35
	end asm
end sub

sub GDIConsoleNewLine(_console as unsigned integer)
	asm
		mov eax,&h1A
		mov ebx,[_console]
		int 0x35
	end asm
end sub

sub GDIButtonSetSkinColor(_btn as unsigned integer,c as unsigned integer)
    asm
        mov eax,&h1B
        mov ebx,[_btn]
        mov ecx,[c]
        int 0x35
    end asm
end sub

sub GDISetShadow(_gdi as unsigned integer,c as unsigned integer)
    asm
        mov eax,&h1C
        mov ebx,[_gdi]
        mov ecx,[c]
        int 0x35
    end asm
end sub

sub GDIOnKeyPress(_elem as unsigned integer,callback as any ptr)
    asm
        mov eax,&h60
        mov ebx,[_elem]
        mov ecx,[callback]
        int 0x35
    end asm
end sub

sub GDIOnMouseClick(_elem as unsigned integer,callback as any ptr)
    asm
        mov eax,&h61
        mov ebx,[_elem]
        mov ecx,[callback]
        int 0x35
    end asm
end sub

function MessageBoxShow(text as any ptr,title as any ptr) as integer
    asm
        mov eax,&h70
        mov ebx,[text]
        mov ecx,[title]
        int 0x35
        mov [function],eax
    end asm
end function

function MessageConfirmShow(text as any ptr,title as any ptr) as integer
    asm
        mov eax,&h71
        mov ebx,[text]
        mov ecx,[title]
        int 0x35
        mov [function],eax
    end asm
end function

sub GetScreenRes(byref x as unsigned integer,byref y as unsigned integer )
    asm
        mov eax, &hFF
        int 0x35
        mov edi,[x]
        mov [edi],eax
        mov edi,[y]
        mov [edi],ebx
    end asm
end sub

sub GDIInvalidate(_elem as unsigned integer)
    asm
        mov eax,&hFE
        mov ebx,[_elem]
        int 0x35
    end asm
end sub

sub ConvertBuffer24TO32(dst as any ptr,src as any ptr,pixelcount as unsigned integer)
    
    asm
        mov     ecx, [pixelcount]
        shr     ecx, 2              '// 4 pixels at once
        jz      SHORT ConvRGB24ToRGB32_$2
        mov     esi, [src]
        mov     edi, [dst]
        push    ebp
ConvRGB24ToRGB32_$1:
        mov     ebx, [esi + 4]      '// sb
        mov     edx, ebx            '// copy sb
        mov     eax, [esi + 0]      '// sa
        mov     ebp, eax            '// copy sa
        and     ebx, &h0ffff         '// sb & 0xffff
        shl     ebx, 8              '// (sb & 0xffff) << 8
        and     eax, &h0ffffff       '// sa & 0xffffff
        mov     [edi + 0], eax      '// Dst[0]
        shr     ebp, 24             '// sa >> 24
        or      ebx, ebp            '// (sa >> 24) | ((sb & 0xffff) << 8)
        mov     [edi + 4], ebx      '// Dst[1]
        shr     edx, 16             '// sb >> 16
        mov     eax, [esi + 8]      '// sc
        add     esi, 12             '// Src += 12 (ASAP)
        mov     ebx, eax            '// copy sc
        and     eax, &h0ff           '// sc & 0xff
        shl     eax, 16             '// (sc & 0xff) << 16
        or      eax, edx            '// (sb >> 16) | ((sc & 0xff) << 16)
        mov     [edi + 8], eax      '// Dst[2]
        shr     ebx, 8              '// sc >> 8
        mov     [edi + 12], ebx     '// Dst[3]
        add     edi, 16             '// Dst += 16
        dec     ecx
        jnz     ConvRGB24ToRGB32_$1
        pop     ebp
ConvRGB24ToRGB32_$2:
end asm
end sub