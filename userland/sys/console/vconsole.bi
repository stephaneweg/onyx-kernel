Type VirtConsole
    CursorX     as integer
    CursorY     as integer
    Foreground  as byte
    Background  as byte
    ConsoleWidth as integer
    ConsoleHeight as integer
    
    Buffer      as byte ptr
    Owner       as unsigned integer
    NextConsole as VirtConsole ptr
    
    declare sub PutChar (c as byte)  
    declare sub PrintOK()
    declare sub PrintFAIL()
    declare sub BackSpace()
    declare sub Write(src as unsigned byte ptr)
    declare sub WriteLine(src as unsigned byte ptr)
    declare sub NewLine()
    declare sub Scroll()
    declare sub Clear()
    
    declare constructor()
    declare destructor()
    declare sub SetSize(w as integer,h as integer)
    declare static function CreateDisplay() as VirtConsole ptr
    declare static function Create(w as integer,h as integer) as VirtConsole ptr
    declare static function Find(o as unsigned integer) as VirtConsole ptr
end type


dim shared SysConsole as VirtConsole ptr
dim shared Consoles as VirtConsole ptr
