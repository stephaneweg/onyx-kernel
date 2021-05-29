constructor GImage()
    this._width  = 0
    this._height = 0
    this._buffer = 0
    this._bufferSize = 0
    
    this.Destruct = @GImageDestroy
    this.OnSizeChanged = 0
    this.TypeName = GImageTypeName
end constructor

destructor GImage()
    if (this._buffer<>0) then
        MFree(this._buffer)
        this._buffer = 0
        this._bufferSize=0
    end if
    this._width = 0
    this._height = 0
end destructor

sub GImageDestroy(elem as GImage ptr)
      elem->destructor()
end sub

function GImage.LoadFromRaw(path as unsigned byte ptr,_w as unsigned integer,_h as unsigned integer) as GImage ptr
	dim fsize as integer
    dim fbuff as RGBType ptr = cptr(RGBType ptr,VFS_LOAD_FILE(path,@fsize))
    if (fbuff<>0 and fsize<>0) then
        dim result as GImage Ptr = cptr(GImage ptr,MAlloc(sizeof(GImage)))
        result->Constructor()
        result->SetSize(_w,_h)
        
        dim i as integer
        dim c as unsigned integer
        dim nb as unsigned integer = result->_width*result->_height
        for i = 0 to nb -1
            c = cptr(unsigned integer ptr,@fbuff[i])[0]
			if (c and &hFFFFFF) = &hFF00FF then 
				c = &h0
			else
				c = c or &hFF000000
			end if
            result->_buffer[i] =  c
        next i
        MFree(fbuff)
        return result
    end if
	
	return 0
end function

Function GImage.LoadFromBitmap(path as unsigned byte ptr) as GImage ptr
    dim fsize as integer
    dim header as BMPHeader ptr = cptr(BMPHeader ptr,VFS_LOAD_FILE(path,@fsize))
    if (header<>0 and fsize<>0) then
        dim buff as RGBType ptr = cptr(RGBType ptr,cast(unsigned integer,header)+header->dataOffset)
        dim buff32 as unsigned integer ptr = cptr(unsigned integer ptr,cast(unsigned integer,header)+header->dataOffset)
        dim result as GImage Ptr = cptr(GImage ptr,MAlloc(sizeof(GImage)))
        result->Constructor()
        result->SetSize(header->PixelWidth,header->PixelHeight)
        
        dim i as unsigned integer
        dim c as unsigned integer
        
        dim tx as integer
        dim ty as integer
        i = 0
        for ty = header->PixelHeight-1 to 0 step -1
            for tx = 0 to header->PixelWidth-1
                if (header->bitsPerPixel=24) then
                    c = cptr(unsigned integer ptr,@buff[i])[0]
                elseif(header->bitsPerPixel=32) then
                    c = buff32[i]
                end if
                if (c and &hFFFFFF) = &hFF00FF then 
                    c = &h0
                else
                    c = c or &hFF000000
                end if
                result->_buffer[(ty*header->PixelWidth)+tx] =  c
                i+=1
            next tx
        next ty
        
    
        MFree(header)
        return result
    end if
	
	return 0
end function

property GImage.Width() as unsigned integer
    return this._width
end property

property GImage.Width(w as unsigned integer)
    if (w<>this._width) then this.SetSize(w,this._height)
end property

property GImage.Height() as unsigned integer
    return this._height
end property

property GImage.Height(h as unsigned integer)
    if (h<>this._height) then this.SetSize(this._width,this._height)
end property

sub GImage.SetSize(w as unsigned integer,h as unsigned integer)
    if (w<>this._width or h<>this._height) then
        this._width     = w
        this._height    = h
        this.CreateBuffer()
        if (this.OnSizeChanged<>0) then
            cptr(sub(p as any ptr),this.OnSizeChanged)(@this)
        end if
    end if
end sub


sub GImage.CreateBuffer()

	dim newsize as unsigned integer = this._width*this._height
	if (newsize>this._bufferSize) then
		if (this._buffer<>0) then
			MFree(this._buffer)
			this._buffer = 0
            this._bufferSize = 0
		end if
		if (this._width>0 and this._height>0) then
			this._bufferSize = newsize
			this._buffer =cast(unsigned integer ptr, MAlloc(newsize*sizeof(unsigned integer)))
		end if
	end if
end sub


sub GImage.Clear(c as unsigned integer)
    if (this._buffer<>0) then
        dim addr as any ptr = this._buffer
        dim cpt as unsigned integer = this._width*this._height
        asm
            push eax
            push ecx
            push edi
            
            mov eax,[c]
            mov ecx,[cpt]
            mov edi,[addr]
            cld
            rep stosd
            
            pop edi
            pop ecx
            pop eax
        end asm
    end if
end sub

sub GImage.SetPixel(_x as integer,_y as integer,c as unsigned integer)
    if (_x>=0 and _y>=0 and _x<this._width and _y<this._height) then
        this._buffer[_y*this._width+_x] = c
    end if
end sub

sub GImage.DrawLine(x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
    	
        dim x as integer
        dim y as integer
        
        dim fx as integer
        dim fy as integer
        dim lx as integer
        dim ly as integer
        dim addr as unsigned integer
        dim bpl as unsigned integer=this._width*4
        dim cpt as unsigned integer
        fx=x1:	lx=x2:	fy=y1:	ly=y2
        
        'vertical line
        if (fx=lx) then
            if (fy>ly) then fy=y2: ly=y1
            if (fy<0) then fy=0
            if (ly>=this._height) then ly = this._height-1
            addr = cast(unsigned integer,this._buffer) + ((fy*this._width+fx)*4)
            cpt = (ly-fy)+1
            asm
                 
                 push edi
                 push eax
                 push ecx
                 cld
                 mov edi,[addr]
                 mov eax,[c]
                 mov ecx,[cpt]
                .boucle:                    
                    mov [edi],eax
                    add edi,[bpl]
                 loop .boucle
                 pop ecx
                 pop eax
                 pop edi                 
            end asm
            exit sub
        end if
        
        'horizontal line
        if (fy=ly) then
            if (fy>=0 and fy<this._height) then
                if (fx>lx) then fx=x2: lx=x1                
                if (fx<0) then fx=0
                if (lx>=this._width) then lx=this._width-1
                addr = cast(unsigned integer,this._buffer) + ((fy*this._width+fx)*4)
                cpt = (lx-fx)+1
                asm
                    push eax
                    push ecx
                    
                    mov eax,[c]
                    mov edi,[addr]
                    mov ecx,[cpt]
                    rep stosd
                    
                    pop ecx
                    pop eax
                end asm
            end if
            exit sub
        end if
    
        'oblique line
        dim dx as integer=0
        dim sx as integer
        if (x1>x2) then dx=x1-x2
        if (x2>x1) then dx=x2-x1
        if x1<x2 then 
            sx=1
        else
            sx=-1
        end if
        
        dim dy as integer=0
        dim sy as integer
        if (y1>y2) then dy=y1-y2
        if (y2>y1) then dy=y2-y1
        if y1<y2 then 
            sy=1
        else
            sy=-1
        end if
        
        dim aerr as integer
        if (dx>dy) then
            aerr=dx
        else
            aerr=-dy
        end if
        aerr=aerr\2
        dim e2 as integer
        do
            if (x1=0 and y1>=0 and x1<this._width and y1<this._height) then
                addr = cast(unsigned integer,this._buffer) + ((y1 * this._width+x1)*4)
                asm
                    push edi
                    mov edi,[addr]
                    push [c]
                    pop [edi]
                    pop edi
                end asm
            end if
            'SetPixel(x1,y1,c)
            
            if (x1=x2 and y1=y2) then exit do
            e2=aerr
            if (e2>-dx) then
                aerr=aerr-dy
                x1=x1+sx
            end if
            if (e2<dy) then
                aerr=aerr+dx
                y1=y1+sy
            end if
        loop
        
end sub

sub GImage.DrawRectangle(x1 as integer,y1 as integer,x2 as integer,y2 as integer, c as unsigned integer)
   DrawLine(x1,y1,x2,y1,c)
   DrawLine(x1,y1,x1,y2,c)
   DrawLine(x2,y1,x2,y2,c)
   DrawLine(x1,y2,x2,y2,c)
end sub

sub GImage.FillRectangleAlphaHalf(x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
      
        dim r as unsigned integer = (c and &hFF0000) shr 16
        dim g as unsigned integer = (c and &h00FF00) shr 8
        dim b as unsigned integer = (c and &h0000FF)
        for _y as integer=y1 to y2
            
            for _x as integer = x1 to x2
                if _x>=0 and _x<this._width and _y>=0 and _y<this._height then
                    
                    dim o as unsigned integer = _y * this._width + _x
                    if ((this._buffer[o] and &hFFFFFF) <> &hFF00FF ) then
                        dim l as unsigned integer= this._buffer[o] and &h000000FF
                        dim rr as unsigned integer = ((r*l) \ 255) and &hFF  
                        dim gg as unsigned integer = ((g*l) \ 255) and &hFF
                        dim bb as unsigned integer = ((b*l)\255) and &hFF
                        this._buffer[o] = (this._buffer[o] and &hFF000000) or (rr shl 16) or (gg shl 8) or (bb)
                    end if
                end if
            next
        next
end sub

sub GImage.FillRectangleAlpha(x1 as integer,y1 as integer,x2 as integer,y2 as integer, c as unsigned integer)
    dim sx1 as integer
    dim sy1 as integer
    dim sw as integer
    dim sh as integer
    dim dx as integer
    dim dy as integer
    
    if (x1>=this._width or y1>=this._height or x2<0 or y2<0) then exit sub
    
    dx = x1
    dy = y1
    sw = (x2-x1)+1
    sh = (y2-y1)+1
    
    sx1 = 0
    sy1 = 0
    
    if (x1<0) then
        sx1 = -x1
        dx = 0
        sw = sw+x1
    end if
    
    if (y1<0) then 
        sy1 = -y1
        dy = 0
        sh = sh+y1
    end if
    
    if (dx + sw>= this._width) then
        sw = this._width-dx
    end if
    if (dy + sh>=this._height) then
        sh = this._height-dy
    end if
    
    dim doffset as integer
    doffset = dy * this._width + dx
    sh -=1
    sw -=1
    dim nx as integer
    dim ny as integer
    dim dstwidth as unsigned integer=this._width
    dim addr as unsigned integer = cast(unsigned integer,this._buffer)+doffset*4
    dim bpl as unsigned integer = this._width*4
    sh+=1
    sw+=1
    asm
        mov eax,[c]
        shr eax,24
        pxor mm5,mm5
        movd mm7,eax
        pshufw mm7,mm7,0
        neg eax
        add eax,256
        movd mm6,eax
        pshufw mm6,mm6,0
        
        
        cld
        push ecx
        push edi
        push eax
        
        mov ecx,[sh] 'nbr of rows
        mov edi,[addr] 'first offset
        mov eax,[c]  'set the color
        .boucleFillRectAlpha:
            push edi
            push ecx
            
            mov ecx,[sw] 'width
            .boucleFillRectAlphaPixel:
                movd mm0,[edi] 'couleur source
                movd mm1,eax 'couleur rectangle
                punpcklbw	mm0, mm5
                punpcklbw	mm1, mm5
                pmullw		mm0, mm6
                pmullw		mm1, mm7
                paddusw		mm0, mm1
                psrlw		mm0, 8
                packuswb	mm0, mm0
                movd		[edi], mm0
            add edi,4
            loop .boucleFillRectAlphaPixel
            
            pop ecx
            pop edi
            add edi,[bpl] 'increment by scanline
        loop .boucleFillRectAlpha
        
        pop eax
        pop edi
        pop ecx
    end asm
end sub

sub GImage.FillRectangle(x1 as integer,y1 as integer,x2 as integer,y2 as integer, c as unsigned integer)
    dim sx1 as integer
    dim sy1 as integer
    dim sw as integer
    dim sh as integer
    dim dx as integer
    dim dy as integer
    
    if (x1>=this._width or y1>=this._height or x2<0 or y2<0) then exit sub
    
    dx = x1
    dy = y1
    sw = (x2-x1)+1
    sh = (y2-y1)+1
    
    sx1 = 0
    sy1 = 0
    
    if (x1<0) then
        sx1 = -x1
        dx = 0
        sw = sw+x1
    end if
    
    if (y1<0) then 
        sy1 = -y1
        dy = 0
        sh = sh+y1
    end if
    
    if (dx + sw>= this._width) then
        sw = this._width-dx
    end if
    if (dy + sh>=this._height) then
        sh = this._height-dy
    end if
    
    dim doffset as integer
    doffset = dy * this._width + dx
    sh -=1
    sw -=1
    dim nx as integer
    dim ny as integer
    dim dstwidth as unsigned integer=this._width
    dim addr as unsigned integer = cast(unsigned integer,this._buffer)+doffset*4
    dim bpl as unsigned integer = this._width*4
    sh+=1
    sw+=1
    asm
        cld
        push ecx
        push edi
        push eax
        
        mov ecx,[sh] 'nbr of rows
        mov edi,[addr] 'first offset
        mov eax,[c]  'set the color
        .boucleFillRect:
            push edi
            push ecx
            cld
            mov ecx,[sw] 'width
            rep stosd
            
            pop ecx
            pop edi
            add edi,[bpl] 'increment by scanline
        loop .boucleFillRect
        
        pop eax
        pop edi
        pop ecx
    end asm
end sub

sub GImage.PutOtherRaw(src as unsigned integer ptr,_w as integer,_h as integer,x as integer,y as integer)

    dim sx1 as integer
    dim sy1 as integer
    dim sw as integer
    dim sh as integer
    dim dx as integer
    dim dy as integer
    
    dim thiswidth as integer = cast(integer,this._width)
    dim thisheight as integer = cast(integer,this._height)
    
    dx = x
    dy = y
    sw = _w
    sh = _h
    
    if (x>=thiswidth or y>=thisheight or x+sw<=0 or y+sh<=0) then exit sub
    
    sx1 = 0
    sy1 = 0
    
    if (x<0) then
        sx1 = -x
        dx = 0
        sw = sw+x
    end if
    
    if (y<0) then 
        sy1 = -y
        dy = 0
        sh = sh+y
    end if
    
    if (dx + sw>= this._width) then
        sw = thiswidth-dx
    end if
    if (dy + sh>=this._height) then
        sh = thisheight-dy
    end if
    
    dim soffset as integer 
    dim doffset as integer
    soffset = sy1 * _w + sx1
    doffset = dy * this._width + dx
    sh -=1
    sw -=1
    dim nx as integer
    dim ny as integer
    
    dim srcwidth as unsigned integer=_w*4
    dim dstwidth as unsigned integer=this._width*4
    
    dim srcAddr as unsigned integer =  cast(unsigned integer,src)+(soffset*4)
    dim dstAddr as unsigned integer = cast(unsigned integer,this._buffer)+(doffset*4)
    sh+=1
    sw+=1
  
	
    asm
        cld
        push ecx
        push edi
        push esi
        push eax
        
        mov ecx,[sh] 'nbr of rows
        mov edi,[dstAddr] 'first offset of destination
        mov esi,[srcAddr] 'last offset of destination
        
        .bouclePutOtherRaw:
            push esi
            push edi
            push ecx
            
            cld
            mov ecx,[sw] 'width
            rep movsd
            
            pop ecx
            pop edi
            pop esi
            add edi,[dstWidth] 'increment by scanline
            add esi,[srcWidth]
        loop .bouclePutOtherRaw
        
        pop eax
        pop esi
        pop edi
        pop ecx
    end asm
end sub

sub GImage.PutOther(src as GImage ptr,x as integer,y as integer,transparent as integer)
    dim sx1 as integer
    dim sy1 as integer
    dim sw as integer
    dim sh as integer
    dim dx as integer
    dim dy as integer
    
    dim thiswidth as integer = cast(integer,this._width)
    dim thisheight as integer = cast(integer,this._height)
    
    dx = x
    dy = y
    sw = src->_width
    sh = src->_height
    
    if (x>=thiswidth or y>=thisheight or x+sw<=0 or y+sh<=0) then exit sub
    
    sx1 = 0
    sy1 = 0
    
    if (x<0) then
        sx1 = -x
        dx = 0
        sw = sw+x
    end if
    
    if (y<0) then 
        sy1 = -y
        dy = 0
        sh = sh+y
    end if
    
    if (dx + sw>= this._width) then
        sw = thiswidth-dx
    end if
    if (dy + sh>=this._height) then
        sh = thisheight-dy
    end if
    
    dim soffset as integer 
    dim doffset as integer
    soffset = sy1 * src->_width + sx1
    doffset = dy * this._width + dx
    sh -=1
    sw -=1
    dim nx as integer
    dim ny as integer
    
    dim srcwidth as unsigned integer=src->_width*4
    dim dstwidth as unsigned integer=this._width*4
    
    dim srcAddr as unsigned integer =  cast(unsigned integer,src->_buffer)+(soffset*4)
    dim dstAddr as unsigned integer = cast(unsigned integer,this._buffer)+(doffset*4)
    sh+=1
    sw+=1
    if transparent then
	asm
        cld
        push ecx
        push edi
        push esi
        push eax
        
        mov ecx,[sh] 'nbr of rows
        mov edi,[dstAddr] 'first offset of destination
        mov esi,[srcAddr] 'last offset of destination
        
        .bouclePutOtherTrans:
            push esi
            push edi
            push ecx
            
            
            mov ecx,[sw] 'width
            .bouclePutOtherTransPixel:
            mov eax,[esi]
            and eax,0xFF000000
            test eax,eax
            jz .noSetPixel
            push [esi]
            pop  [edi]
            .noSetPixel:
            add edi,4
            add esi,4
            loop .bouclePutOtherTransPixel
            
            pop ecx
            pop edi
            pop esi
            add edi,[dstWidth] 'increment by scanline
            add esi,[srcWidth]
        loop .bouclePutOtherTrans
        
        pop eax
        pop esi
        pop edi
        pop ecx
    end asm
    else
	
    asm
        cld
        push ecx
        push edi
        push esi
        push eax
        
        mov ecx,[sh] 'nbr of rows
        mov edi,[dstAddr] 'first offset of destination
        mov esi,[srcAddr] 'last offset of destination
        
        .bouclePutOther:
            push esi
            push edi
            push ecx
            
            cld
            mov ecx,[sw] 'width
            'shr ecx,1
            '.b1:
            '    movq mm0,[esi]
            '    movq [edi],mm0
            '    add esi,8
            '    add edi,8
            'loop .b1
            rep movsd
            
            pop ecx
            pop edi
            pop esi
            add edi,[dstWidth] 'increment by scanline
            add esi,[srcWidth]
        loop .bouclePutOther
        
        pop eax
        pop esi
        pop edi
        pop ecx
    end asm
    end if
    
    'if (transparent) then
    '    for ny = 0 to sh
    '        for nx = 0 to sw
    '            this._buffer[doffset + nx] =AlphaPixel(this._buffer[doffset + nx] , src->_buffer[soffset+nx])
    '        next
    '        soffset+=src->_width
    '        doffset+=this._width
    '    next 
    'else
     '   for ny = 0 to sh
     '       BufferToBuffer(this._buffer+(doffset*4),src->_buffer+(soffset*4),sw+1,4,4)
            'for nx = 0 to sw
            '    this._buffer[doffset + nx] = src->_buffer[soffset+nx]
            'next
     '       soffset+=src->_width
     '       doffset+=this._width
     '   next 
    'end if
end sub



sub GImage.PutOtherPart(src as GImage ptr,x as integer,y as integer,sourceX as integer,sourceY as integer,sourceWidth as integer,sourceHeight as integer, transparent as integer)
    dim sx1 as integer
    dim sy1 as integer
    dim sw as integer
    dim sh as integer
    dim dx as integer
    dim dy as integer
    
    dim thiswidth as integer = cast(integer,this._width)
    dim thisheight as integer = cast(integer,this._height)
    
    dx = x
    dy = y
    sw = sourceWidth
    sh = sourceHeight
 
    sx1 = sourceX
    sy1 = sourceY
    
    if (sx1+sw)>src->_Width     then sw = src->_Width-sx1
    if (sy1+sh)>src->_Height    then sh = src->_height-sy1
    
    if (x>=thiswidth or y>=thisheight or x+sw<=0 or y+sh<=0) then exit sub
    
    
    if (x<0) then
        sx1 = sx1-x
        dx = 0
        sw = sw+x
    end if
    
    if (y<0) then 
        sy1 = sy1-y
        dy = 0
        sh = sh+y
    end if
    
    if (dx + sw >= this._width) then
        sw = thiswidth-dx
    end if
    if (dy + sh>=this._height) then
        sh = thisheight-dy
    end if
    
    dim soffset as integer 
    dim doffset as integer
    soffset = sy1 * src->_width + sx1
    doffset = dy * this._width + dx
    sh -=1
    sw -=1
    dim nx as integer
    dim ny as integer
    
    dim srcwidth as unsigned integer=src->_width*4
    dim dstwidth as unsigned integer=this._width*4
    
    dim srcAddr as unsigned integer =  cast(unsigned integer,src->_buffer)+(soffset*4)
    dim dstAddr as unsigned integer = cast(unsigned integer,this._buffer)+(doffset*4)
    sh+=1
    sw+=1
    if transparent then
    asm
        cld
        push ecx
        push edi
        push esi
        push eax
        
        mov ecx,[sh] 'nbr of rows
        mov edi,[dstAddr] 'first offset of destination
        mov esi,[srcAddr] 'last offset of destination
        
        .bouclePutOtherPartTrans:
            push esi
            push edi
            push ecx
            
            
            mov ecx,[sw] 'width
            .bouclePutOtherPartTransPixel:
            mov eax,[esi]
            and eax,0xFF000000
            test eax,eax
            jz .noSetPixelPart
            push [esi]
            pop  [edi]
            .noSetPixelPart:
            add edi,4
            add esi,4
            loop .bouclePutOtherPartTransPixel
            
            pop ecx
            pop edi
            pop esi
            add edi,[dstWidth] 'increment by scanline
            add esi,[srcWidth]
        loop .bouclePutOtherPartTrans
        
        pop eax
        pop esi
        pop edi
        pop ecx
    end asm
    else
    asm
        cld
        push ecx
        push edi
        push esi
        push eax
        
        mov ecx,[sh] 'nbr of rows
        mov edi,[dstAddr] 'first offset of destination
        mov esi,[srcAddr] 'last offset of destination
        
        .bouclePutOtherPart:
            push esi
            push edi
            push ecx
            
            cld
            mov ecx,[sw] 'width
            'shr ecx,1
            '.b2:
            '    movq mm0,[esi]
            '    movq [edi],mm0
            '    add esi,8
            '    add edi,8
            'loop .b2
            rep movsd
            
            pop ecx
            pop edi
            pop esi
            add edi,[dstWidth] 'increment by scanline
            add esi,[srcWidth]
        loop .bouclePutOtherPart
        
        pop eax
        pop esi
        pop edi
        pop ecx
    end asm
    end if
end sub

sub GImage.DrawTextMultiLine(s as unsigned byte ptr,x1 as integer,y1 as integer,c as integer,fdata as FontData ptr,ratio as integer,w as integer,textAlign as HorizontalAlignment)
    if (fdata=0) then exit sub
    if (s=0) then exit sub
    
    dim tx as integer = x1
    dim tlen as integer
    tlen=strlen(s)
    if tlen>0 then
        dim fontHeight as integer=fdata->FLEN/256  
        dim fontWidth as integer=8
        dim maxTextLen as integer=w/(fontWidth*ratio)
        if tlen>maxTextLen then
            tlen = maxTextLen     
            dim cpt as integer
            dim tlenNext as integer=tlen
            for cpt=tlen-1 to 0 step-1
                if s[cpt]=asc(" ") then
                    tlen=cpt
                    tlenNext = tlen+1
                    exit for
                end if
            next
            
            dim rowNum as integer
            dim colNum as integer
            dim bData as unsigned byte
            dim asciicode as integer
            
            dim x as integer
            dim y as integer
            
            select case textAlign
                case HorizontalAlignment.Center
                    tx = x1+(w - ( tlen*fontWidth*Ratio))/2
                case HorizontalAlignment.Right
                    tx = x1+(w - ( tlen*fontWidth*Ratio))
            end select
            
            for cpt=0 to tlen
                asciicode=s[cpt]
                for rowNum=0 to fontHeight-1
                    bdata=fdata->Buffer[asciicode * fontHeight + rowNum+1]
                    for colNum=0 to fontWidth -1
                        if ((bData shr colNum) and &h1)=&h1 then
                                
                                if (ratio=1) then
                                    x=tx+(cpt*(fontWidth+1) )+((fontWidth -1)-colNum)
                                    y=rowNum+y1
                                    this.SetPixel(x,y,c)
                                else
                                    x=tx+((cpt*fontWidth )+((fontWidth -1)-colNum))*ratio+cpt
                                    y=rowNum*ratio+y1
                                    this.FillRectangle(x,y,x+ratio-1,y+ratio-1,c)
                                end if
                        end if
                    next
                next
            next
            
            DrawTextMultiLine(s+tlenNext,x1,y1+fontHeight*ratio,c,fdata,ratio,w,textAlign)
        else
            select case textAlign
                case HorizontalAlignment.Center
                    tx = x1+(w-( tlen*fontWidth*Ratio))/2
                case HorizontalAlignment.Right
                    tx = x1+(w - ( tlen*fontWidth*Ratio))
            end select
            DrawText(s,tx,y1,c,fdata,ratio)
        end if
        
    end if
end sub

sub GImage.DrawText(txt as unsigned byte ptr,x1 as integer,y1 as integer,c as integer,fdata as FontData ptr,ratio as integer)
    if (fdata=0) then exit sub
    if (txt=0) then exit sub
    dim tlen as integer
    tlen=strlen(txt)
    if tlen>0 then
        tlen=tlen-1
        
        
        dim fontHeight as integer=fdata->FLEN/256  
        dim fontWidth as integer=8
            
            
            
        dim cpt as integer
        dim rowNum as integer
        dim colNum as integer
        dim bData as unsigned byte
        dim asciicode as integer
        
        dim x as integer
        dim y as integer
        

        for cpt=0 to tlen
            asciicode=txt[cpt]
            for rowNum=0 to fontHeight-1
                bdata=fdata->Buffer[asciicode * fontHeight + rowNum+1]
                for colNum=0 to fontWidth -1
                    if ((bData shr colNum) and &h1)=&h1 then
                            
                            if (ratio=1) then
                                x=x1+(cpt*(fontWidth+1) )+((fontWidth -1)-colNum)
                                y=rowNum+y1
                                this.SetPixel(x,y,c)
                            else
                                x=x1+((cpt*fontWidth )+((fontWidth -1)-colNum))*ratio+cpt
                                y=rowNum*ratio+y1
                                this.FillRectangle(x,y,x+ratio-1,y+ratio-1,c)
                            end if
                    end if
                next
            next
        next
    end if
end sub


sub GImage.DrawChar(asciicode as unsigned byte,x1 as integer,y1 as integer,c as integer,fdata as FontData ptr,ratio as integer)
    if (fdata=0) then exit sub
    if (c=0) then exit sub
    
    dim fontHeight as integer=fdata->FLEN/256  
    dim fontWidth as integer=8
        
    dim rowNum as integer
    dim colNum as integer
    dim bData as unsigned byte
    
    dim x as integer
    dim y as integer
    

    for rowNum=0 to fontHeight-1
        bdata=fdata->Buffer[asciicode * fontHeight + rowNum+1]
        for colNum=0 to fontWidth -1
            if ((bData shr colNum) and &h1)=&h1 then
                    
                    if (ratio=1) then
                        x=x1+((fontWidth+1) )+((fontWidth -1)-colNum)
                        y=rowNum+y1
                        this.SetPixel(x,y,c)
                    else
                        x=x1+((fontWidth )+((fontWidth -1)-colNum))*ratio
                        y=rowNum*ratio+y1
                        this.FillRectangle(x,y,x+ratio-1,y+ratio-1,c)
                    end if
            end if
        next
    next
end sub
