dim shared Colors16(0 to 15) as unsigned integer

constructor TConsole()
    this.Destruct = @TConsoleDestroy
    this.OnRedraw = @TConsoleRedraw
    
    this.OnHandleMouse = 0
    this.OnMouseExit = 0
    this._twidth = 0
    this._theight = 0
	
	this.OnSizeChanged = @TConsoleSizeChanged
    this.TypeName = TConsoleTypeName
    
    Colors16(0) = &hFF000000
    Colors16(1) = &hFF000088
    Colors16(2) = &hFF008800
    Colors16(3) = &hFF008888
    Colors16(4) = &hFF880000
    Colors16(5) = &hFF880088
    Colors16(6) = &hFF888800
    Colors16(7) = &hFFdddddd
    Colors16(8) = &hFF888888
    Colors16(9) = &hFF0000FF
    Colors16(10) = &hFF00FF00
    Colors16(11) = &hFF00FFFF
    Colors16(12) = &hFFFF0000
    Colors16(13) = &hFFFF00FF
    Colors16(14) = &hFFFFFF00
    Colors16(15) = &hFFFFFFFF
end constructor


destructor TConsole()
    
end destructor



sub TConsoleRedraw(elem as TConsole ptr)
    dim src as unsigned short ptr = cptr(unsigned short ptr,&HB8000)
    
    dim i as unsigned integer
    dim xx as unsigned integer
    dim yy as unsigned integer
    dim cx as unsigned integer
    dim cy as unsigned integer
    i=0
    yy = 0
    xx = 0
    for cy as integer = 0 to 79
        xx = 0
        for cx = 0 to 27
            dim b as unsigned byte = src[i] and &hFF
            dim c as unsigned byte = (src[i] shr 8) and &hFF
            dim fg as unsigned byte = c and &hF
            dim bg as unsigned byte = (c shr 4) and &hF
            
            if (xx>=0 and yy>=0 and xx+8<elem->_width and yy+15<elem->_height) then
                elem->FillRectangle(xx,yy,xx+8,yy+15,Colors16(bg))
                elem->DrawChar(b,xx,yy,Colors16(fg),FontManager.ML,1)
            end if
            i+=1
            xx+=9
        next
        yy+=16
    next
end sub

sub TConsoleDestroy(elem as TConsole ptr)
    elem->destructor()
end sub

sub TConsoleSizeChanged(elem as TConsole ptr)
    elem->_twidth = elem->_width / 9
    elem->_theight = elem->_height / 16
    
end sub


sub TConsole.WriteLine(src as unsigned byte ptr)

end sub

sub TConsole.Write(src as unsigned byte ptr)

end sub

sub TConsole.PutChar (c as unsigned byte)  

end sub

sub TConsole.NewLine()

end sub

sub TConsole.ClearConsole()

end sub

sub TConsole.Scroll()

end sub

        
    


