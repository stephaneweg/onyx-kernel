constructor SKIN()
    Destruct = @SkinDestroy
    Image = 0
    this.TypeName = SKINTypeName
end constructor

destructor SKIN()
    if (Image<>0) then DestroyObj(Image)
end destructor

sub SkinDestroy(sk as skin ptr)
    sk->destructor
end sub

function Skin.Create(path as unsigned byte ptr,count as unsigned integer,lw as integer,rw as integer,th as integer, bh as integer) as Skin ptr
    dim img as GImage ptr = GImage.LoadFromBitmap(path)
    
    if img<>0 then
        dim result as Skin Ptr = cptr(Skin ptr,MAlloc(sizeof(Skin)))
        if result<>0 then
                
            result->Constructor()
            result->Image = img
            
            result->leftWidth = lw
            result->rightWidth = rw
            result->topHeight=th
            result->bottomHeight=bh
            result->SkinWidth = img->_width
            result->SkinHeight = img->_height/count
            result->partCount = count
            
            return result
        end if
    end if
    return 0
end function

sub Skin.ApplyColor(c as unsigned integer,all as unsigned integer)
    if (all=0) then
        for i as unsigned integer = 0 to this.partCount-1
            var _minY = this.SkinHeight * i
            var _maxY =  _minY+this.SkinHeight -1
            
            this.Image->FillRectangleAlphaHalf(0,_minY,this.LeftWidth-1,_maxY,c)
            this.Image->FillRectangleAlphaHalf(this.SkinWidth-this.RightWidth+1,_minY,this.SkinWidth-1,_maxY,c)
            this.Image->FillRectangleAlphaHalf(this.LeftWidth,_minY,this.SkinWidth-this.RightWidth,_minY+this.TopHeight,c)
            this.Image->FillRectangleAlphaHalf(this.LeftWidth,_maxY-this.bottomHeight+1,this.SkinWidth-this.RightWidth,_maxY,c)
        next i
    else
        this.Image->FillRectangleAlphaHalf(0,0,this.Image->_width-1,this.Image->_height-1,c)
    end if
end sub
    
sub Skin.DrawOn(target as GImage ptr,num as unsigned integer,x as integer,y as integer,w as integer,h as integer,c as unsigned integer,transparent as integer)
    dim i as integer
    dim middleWidth as integer = cast(integer,this.SkinWidth) - this.leftWidth - this.rightWidth
    dim middleHeight as integer = cast(integer,this.SkinHeight) - this.topHeight - this.bottomHeight
    dim oWidth as integer = w - this.leftWidth - this.rightWidth
    dim oHeight as integer = h - this.topHeight - this.bottomHeight
    
    
    
    dim sourceY  as integer = this.SkinHeight * (num mod this.partCount)
    
    
    if (w = skinWidth and h=skinHeight) then
        target->PutOtherPart(this.Image,x,y,0,sourceY,this.SkinWidth,this.SkinHeight,transparent)
        exit sub
    end if
    
    if (oHeight>0 and oWidth>0) then
        var p = ((sourceY+(SkinHeight shr 1)) * skinWidth)+(skinWidth shr 1)
        target->FillRectangle(x+this.LeftWidth,y+this.TopHeight,x+w-this.RightWidth-1,y+h-this.BottomHeight-1,this.Image->_buffer[p] )
    end if
    
    if ((middleWidth>0) and (oWidth>0)) then
        dim cptx as integer = oWidth  / middleWidth
        for i = 0 to cptx
            dim tx as integer = i*middleWidth + x+ this.leftWidth
            target->PutOtherPart(this.Image,tx,y               ,this.LeftWidth,sourceY               ,middleWidth,this.TopHeight,transparent)
            if (middleHeight>0 and middleWidth>0) then
            target->PutOtherPart(this.Image,tx,y+this.TopHeight,this.LeftWidth,sourceY+this.TopHeight,middleWidth,middleHeight,transparent)
            end if
            target->PutOtherPart(this.Image,tx,y+h-this.BottomHeight,this.LeftWidth,this.SkinHeight+sourceY-this.BottomHeight,middleWidth,this.BottomHeight,transparent)
        next i
    end if

    if ((middleHeight>0) and (oHeight>0)) then
        dim cpty as integer = oHeight/middleHeight
        for i = 0 to cpty
            dim ty as integer = i*middleHeight +y + this.topHeight
            target->PutOtherPart(this.Image,x,ty,0,sourceY+this.TopHeight,this.LeftWidth,middleHeight,transparent)
            target->PutOtherPart(this.Image,x+w-this.RightWidth,ty,this.SkinWidth-this.RightWidth,sourceY+this.TopHeight,this.LeftWidth,middleHeight,transparent)
        next i
    end if
    
	if (this.LeftWidth >0 and this.TopHeight>0) then
		target->PutOtherPart(this.Image,x                    ,y                      ,0                          ,sourceY                              ,this.LeftWidth,this.TopHeight,transparent)
	end if
	
	if (this.RightWidth>0 and this.TopHeight>0) then
		target->PutOtherPart(this.Image,x+w-this.RightWidth  ,y                      ,this.SkinWidth-this.RightWidth,sourceY                              ,this.RightWidth,this.TopHeight,  transparent)
    end if
	
	if (this.LeftWidth>0 and this.BottomHeight>0) then
		target->PutOtherPart(this.Image,x                    ,y+h-this.BottomHeight  ,0                          ,sourceY+this.SkinHeight-this.BottomHeight ,this.LeftWidth,this.BottomHeight,transparent)
    end if
	
	if (this.RightWidth>0 and this.BottomHeight>0) then
		target->PutOtherPart(this.Image,x+w-this.RightWidth  ,y+h-this.BottomHeight  ,this.SkinWidth-this.RightWidth,sourceY+this.SkinHeight-this.BottomHeight ,this.RIghtWidth,this.BottomHeight,transparent)
	end if
	
end sub