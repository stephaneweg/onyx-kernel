constructor TConsole()
	
    this.Destruct = @TConsoleDestroy
    this.OnRedraw = 0
    
    this.OnHandleMouse = 0
    this.OnMouseExit = 0
    this._twidth = 0
    this._theight = 0
	
	this.OnSizeChanged = @TConsoleSizeChanged
    this.TypeName = TConsoleTypeName
end constructor


destructor TConsole()
end destructor

sub TConsoleDestroy(elem as TConsole ptr)
    elem->destructor()
end sub

sub TConsoleSizeChanged(elem as TConsole ptr)
    elem->_twidth = elem->_width / 9
    elem->_theight = elem->_height / 16
    
end sub


sub TConsole.WriteLine(src as unsigned byte ptr)
    this.Write(src)
    this.NewLine()
end sub

sub TConsole.Write(src as unsigned byte ptr)
    dim cpt as integer
    dim dst as byte ptr
    cpt=0
    WHILE src[cpt] <> 0
        this.PutChar(src[cpt])
        cpt=cpt+1
    WEND
end sub

sub TConsole.PutChar (c as unsigned byte)  
    if (c=13) then return
    if (c=10) then
        this.NewLine()
        return
    end if
    if (c=8) then
    '    ConsoleBackSpace()
        return
    end if
    if (c=9) then
        _cursorX=_cursorX+5
        if (_cursorX>=_twidth) then this.NewLine()
    else
        this.DrawChar(c,_cursorX*9,_cursorY*16,&hFFFFFFFF,FontManager.ML,1)
        _cursorX=_cursorX+1
    end if
    if (_cursorX>=this._twidth) then this.NewLine()
end sub

sub TConsole.NewLine()
    _cursorX=0
    _cursorY=_cursorY+1
    if (_cursorY>=_tHeight) then this.Scroll()
end sub

sub TConsole.ClearConsole()
    this.Clear(&hFF000000)
    this._cursorX = 0
    this._cursorY = 0
end sub

sub TConsole.Scroll()
    dim _y as unsigned integer
    this._cursorY-=1
    for _y = 0 to this._cursorY
        this.FillRectangle(0,_y*16,this._width-1,(_y+1)*16-1,&hFF000000)
        this.PutOtherPart(@this,0,_y*16,0,(_y+1)*16,this._width,16,0)
    next
    this.FillRectangle(0,_y*16,this._width-1,(_y+1)*16-1,&hFF000000)
end sub
    
    


