type TConsole extends GDIBase field = 1
    _twidth as unsigned integer
    _theight as unsigned integer
    
    _cursorX as unsigned integer
    _cursorY as unsigned integer
    
    
    declare constructor()
    declare destructor()

    declare sub WriteLine(s as unsigned byte ptr)
    declare sub Write(s as unsigned byte ptr)
    declare sub PutChar(c as unsigned byte)
    declare sub NewLine()
    declare sub ClearConsole()
    declare sub Scroll()
end type



declare sub TConsoleSizeChanged(elem as TConsole ptr)
declare sub TConsoleDestroy(elem as TConsole ptr) 
dim shared TConsoleTypeName as unsigned byte ptr=@"TConsole"