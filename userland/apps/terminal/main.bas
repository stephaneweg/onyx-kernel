
#include once "stdlib.bi"
#include once "system.bi"
#include once "gdi.bi"
#include once "slab.bi"
#include once "file.bi"
#include once "tobject.bi"
#include once "font.bi"
#include once "fontmanager.bi"
#include once "gimage.bi"

#include once "stdlib.bas"
#include once "system.bas"
#include once "gdi.bas"
#include once "slab.bas"
#include once "file.bas"
#include once "tobject.bas"
#include once "font.bas"
#include once "fontmanager.bas"
#include once "gimage.bas"

#include once "xconsole.bi"
#include once "xconsole.bas"

dim shared mainWin as unsigned integer


sub SHELLThread()
	ExecAppAndWait(@"SYS:/BIN/SHELL.BIN",0)
    ExitApp()
end sub

sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    SlabINIT()
    FontManager.Init()
    
	MainWin = GDIWindowCreate(500,355,@"TEMINAL")
	GDISetVisible(MainWin,0)
	XConsoleCREATE(mainWin,0,0,500,350)
	GDISetVisible(MainWin,1)
    
	CreateThread(@SHELLThread,3)
	WaitForEvent()
end sub




