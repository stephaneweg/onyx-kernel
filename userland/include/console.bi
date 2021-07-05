
declare sub ConsolePutChar(c as unsigned byte)
declare sub ConsoleWrite(txt as unsigned byte ptr)
declare sub ConsoleWriteLine(txt as unsigned byte ptr)
declare sub ConsoleWriteNumber(n as unsigned integer,b as unsigned integer)
declare sub ConsoleNewLine()
declare sub ConsolePrintOK()
declare sub ConsoleBackSpace()
declare sub ConsoleSetForeground(c as unsigned integer)
declare sub ConsoleSetBackground(c as unsigned integer)
declare sub ConsoleClear()

declare function STDIO_CREATE() as unsigned integer
declare function STDIO_SET_IN(fd as unsigned integer) as unsigned integer
declare function STDIO_SET_OUT(fd as unsigned integer) as unsigned integer
declare function STDIO_READ(fd as unsigned integer) as unsigned byte
declare sub STDIO_WRITE_BYTE(fd as unsigned integer,b as unsigned byte)
declare sub STDIO_WRITE(fd as unsigned integer,b as unsigned byte ptr)
declare sub STDIO_WRITE_LINE(fd as unsigned integer,b as unsigned byte ptr)

#define STD_KEY_CTRL 29
dim shared STDIO_ERR_NUM as unsigned integer
    