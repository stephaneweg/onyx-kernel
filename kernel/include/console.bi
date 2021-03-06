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
dim shared CONSOLE_MEM     as unsigned byte ptr
dim shared consoleWidth         as integer
dim shared consoleHeight        as integer
dim shared consoleCursorX       as integer
dim shared consoleCursorY       as integer
dim shared consoleLineOffset    as integer
dim shared consoleBackground    as unsigned byte
dim shared consoleForeground    as unsigned byte