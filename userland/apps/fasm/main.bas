

#include once "stdlib.bi"
#include once "stdlib.bas"

#include once "system.bi"
#include once "console.bi"
#include once "gdi.bi"
#include once "file.bi"
#include once "slab.bi"
#include once "tobject.bi"
#include once "font.bi"
#include once "fontmanager.bi"
#include once "gimage.bi"

#include once "system.bas"
#include once "console.bas"
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
dim shared txtInputFile as unsigned integer
dim shared txtOutputFile as unsigned integer
dim shared txtArguments as unsigned integer

declare sub btnClick(btn as unsigned integer,parm as unsigned integer)
sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
	SlabInit()
    FontManager.Init()
    
	MainWin = GDIWindowCreate(645,550,@"FASM Front end")
	GDISetVisible(MainWin,0)
	
    GDITextBlockCreate(MainWin,0,7,@"Input file : ",&hFF000000)
	txtInputFile = GDITextBoxCreate(MainWin,140,0,190,30)
    
    GDITextBlockCreate(MainWin,0,42,@"Output file : ",&hFF000000)
	txtOutputFile = GDITextBoxCreate(MainWin,140,35,190,30)
    
    GDITextBlockCreate(MainWin,0,77,@"Arguments : ",&hFF000000)
	txtArguments = GDITextBoxCreate(MainWin,140,70,190,30)
    
	GDIButtonCreate(MainWin,0,107,100,30,@"Assemble",@btnClick,0)
	GDIButtonCreate(MainWin,205,107,100,30,@"Run",@btnClick,1)
	
	XConsoleCREATE(mainWin,0,140,645,405)
	
	
	GDISetVisible(MainWin,1)
	ConsoleWrite(@"Console Ready")
    ConsolePrintOK()
    ConsoleNewLine()
	WaitForEvent()
end sub


sub btnClick(btn as unsigned integer,parm as unsigned integer)
    
    dim tmpString as unsigned byte ptr = malloc(1024)
    if (parm=0) then
        dim args as unsigned byte ptr = tmpString
        
        GDITextBoxGetText(txtInputFile,tmpString)
        tmpString = tmpString+strlen(tmpString)
        tmpString[0] = 32
        tmpString+=1
        
        GDITextBoxGetText(txtOutputFile,tmpString)
        tmpString = tmpString+strlen(tmpString)
        tmpString[0] = 32
        tmpString+=1
        
        GDITextBoxGetText(txtArguments,tmpString)
        
        'MessageBoxShow(args,@"arguments")
        ExecApp(@"SYS:/BIN/FASM.BIN",args)
		tmpString = args
	elseif parm=1 then
        GDITextBoxGetText(txtOutputFile,tmpString)
        ExecApp(tmpString,0)
    end if
    Free(tmpString)
	EndCallBack()
end sub
