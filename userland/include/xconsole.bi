declare sub XConsoleCREATE(parent as unsigned integer,_x as unsigned integer,_y as unsigned integer,_width as unsigned integer,_height as unsigned integer)
declare sub XConsoleOnKeyPress(elem as unsigned integer,k as unsigned integer)
declare sub XConsoleThread()
declare sub XCONSOLEPUTCHAR(b as unsigned byte)
declare sub XCONSOLESCROLL()
declare sub XCONSOLENEWLINE()
declare sub XConsoleBackSpace()

dim shared xConsoleDrawable as GImage ptr

dim shared xConsoleCursorX as  integer
dim shared xConsoleCursorY as  integer

dim shared xConsoleMaxX as unsigned integer
dim shared xConsoleMaxY as unsigned integer
dim shared xConsoleSTD_OUT as unsigned integer
dim shared xConsoleSTD_IN as unsigned integer