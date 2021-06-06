Type VirtConsole
    CursorX as integer
    CursorY as integer
    Foreground as byte
    Background as byte
    PHYS as byte ptr
    VIRT as byte ptr
    declare sub PutChar (c as byte)  
    declare sub PrintOK()
    declare sub PrintFAIL()
    declare sub BackSpace()
    declare sub Write(src as unsigned byte ptr)
    declare sub NewLine()
    declare sub Scroll()
    declare sub Clear()
    
    declare destructor()
    
    declare sub Activate()
end type

declare sub ConsoleInit()
DECLARE sub ConsoleClear()
declare sub ConsoleSetBackground(c as byte)
declare sub ConsoleSetForeground(c as byte)



declare sub ConsoleWriteTextAndHex(src as unsigned byte ptr,n as unsigned integer,newline as boolean)
declare sub ConsoleWriteTextAndSize(src as unsigned byte ptr,s as unsigned integer,newline as boolean)
declare sub ConsoleWriteTextAndDec(src as unsigned byte ptr,n as unsigned integer,newline as boolean)
declare sub ConsoleWrite(src as unsigned byte ptr)
declare sub ConsoleWriteLine(src as unsigned byte ptr)
declare sub ConsoleWriteNumber(number as integer,abase as unsigned integer)
declare sub ConsoleWriteUNumber(number as unsigned integer,abase as unsigned integer)
declare sub ConsoleWriteSigned(number as integer)
declare sub ConsoleNewLine()
declare sub ConsoleScroll()
declare sub ConsoleBackSpace()
declare sub ConsoleUpdateCursor()
declare sub ConsolePrintOK()
declare sub ConsolePrintFAIL()
declare sub ConsolePutChar (c as byte)
dim shared CurrentConsole as VirtConsole ptr
dim shared SYSCONSOLE as VirtConsole
dim shared VIRT_CONSOLE_MEM as unsigned byte ptr
dim shared PHYS_CONSOLE_MEM as unsigned byte ptr