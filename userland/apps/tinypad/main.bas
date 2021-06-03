
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


dim shared mainWin as unsigned integer
dim shared txtFileName as unsigned integer
dim shared drawable as GImage ptr
dim shared TextBuffer as unsigned byte ptr
dim shared TextSize as unsigned integer
dim shared CursorPos as  integer
dim shared CursorX as  integer
dim shared CursorY as  integer
dim shared ScrollY as integer
dim shared ScrollX as integer
dim shared MaxY as integer
dim shared MaxX as integer
declare sub CursorCoordToCursorPos()
declare sub OnKeyPress(elem as unsigned integer,k as unsigned integer)
declare sub InsertCharacter(k as unsigned byte)
declare sub RemoveCharacterPrev()
declare sub btnOpenClick(btn as unsigned integer,parm as unsigned integer)
declare sub btnSaveClick(btn as unsigned integer,parm as unsigned integer)
declare sub drawOnMouseClick(elem as unsigned integer,param as unsigned integer)
declare sub NewFile()
declare sub RedrawText()
declare sub CheckScroll()
sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    SlabINIT()
    FontManager.Init()
    TextBuffer = MAlloc(1024*1024*5)
	MainWin = GDIWindowCreate(600,440,@"Simple Text Editor")
	GDISetVisible(MainWin,0)
    drawable = cptr(GImage ptr,MAlloc(sizeof(GImage)))
    drawable->Constructor(MainWin,0,0,600,400)
    MaxY = ((400-4)/16)-1
    MaxX = (600-16)/9
    txtFileName = GDITextBoxCreate(MainWin,0,405,390,30)
	GDIButtonCreate(MainWin,395,405,100,30,@"Open",@btnOpenClick,3)
	GDIButtonCreate(MainWin,500,405,100,30,@"Save",@btnSaveClick,3)
	
    GDIOnKeyPress(MainWin,@OnKeyPress)
    Drawable->OnMouseClick(@drawOnMouseClick)
    NewFile()
    
	GDISetVisible(MainWin,1)
	WaitForEvent()
end sub


dim shared strline as unsigned byte ptr = @"                                                   "
sub drawOnMouseClick(elem as unsigned integer,param as unsigned integer)
    dim mx as short =cast(short, param shr 16)
    dim my as short =cast(short, param and &hFFFFFF)
    
    CursorX = ((cast(integer,mx)-8)/9)-cast(integer,ScrollX)
    CursorY = ((cast(integer,my)-2)/16)-cast(integer,ScrollY)
    CursorCoordToCursorPos()
    
	RedrawText()
	EndCallBack()
end sub     
sub btnOpenClick(btn as unsigned integer,parm as unsigned integer)

    GDITextBoxGetText(txtFileName,strline)
    if (strlen(strLine)>0) then
        var f = FileOpen(strline)
        if (f<>0) then
            CursorPos = 0
            ScrollY = 0
            ScrollX = 0
            CursorX = 0
            CursorY = 0
        
            TextSize = FileSize(f)
            if (TextSize>0) then
                FileRead(f,TextSize,TextBuffer)
            end if
            FileClose(f,0)
        else
            MessageBoxShow(@"File not found",@"Open error")
        end if
        RedrawText()
    end if
	EndCallBack()
end sub     

sub btnSaveClick(btn as unsigned integer,parm as unsigned integer)
    GDITextBoxGetText(txtFileName,strline)
    if (strlen(strLine)>0) then
        var f = FileCreate(strLine)
        FileWrite(f,TextSize,TextBuffer)
        FileClose(f,1)
    end if
	EndCallBack()
end sub          


sub NewFile()
    ScrollY = 0
    ScrollX = 0
    CursorX = 0
    CursorY = 0
    CursorPos = 0
    TextBuffer[0]=0
    TextSize=0
	RedrawText()
end sub

sub OnKeyPress(elem as unsigned integer,k as unsigned integer)
    select case k
        case (50 or 128)
            CursorY+=1
            CursorCoordToCursorPos()
        case (56 or 128)
            if (CursorY>0) then
                CursorY-=1
                CursorCoordToCursorPos()
            end if
        case (52 or 128)
            if (CursorPos>0) then 
                CursorPos-=1
            end if
        case (54 or 128)
            if (CursorPos<TextSize) then 
                CursorPos+=1
            end if
        Case 10
            CursorPos=CursorPos
        case 8
            RemoveCharacterPrev()
        case 13
            InsertCharacter(10)
        case else
            InsertCharacter(cast(unsigned byte,k))
    end select
    CheckScroll()
	RedrawText()
	EndCallBack()
end sub

sub RemoveCharacterPrev()
    if CursorPos>0 then
        asm
            mov esi,[TextBuffer]
            add esi,[CursorPos]
            mov edi,esi
            dec edi
            mov ecx,[TextSize]
            sub ecx,[CursorPos]
            cld
            rep movsb
        end asm
        CursorPos-=1
        TextSize-=1
    end if
end sub

sub InsertCharacter(k as unsigned byte)
    dim i as integer
    for i=TextSize to CursorPos step -1
        TextBuffer[i+1]=TextBuffer[i]
    next
    TextBuffer[CursorPos] = k
    CursorPos+=1
    TextSize+=1
end sub

sub RedrawText()
    Drawable->Clear(&hFFEEEEEE)
    
    dim i as  integer
    dim last as integer=TextSize
    last = last-1
    dim tx as integer = 0
    dim ty as integer = 0
    dim cx as integer = 0
    dim cy as integer = 0
    dim cursorDraw as unsigned integer = 0
    for i = 0 to last
        var c = TextBuffer[i]
        
        if (i=CursorPos and cursorDraw=0) then
            cursorDraw=1
            
            CursorX = tx
            CursorY = ty
        end if
        
        select case c
            case 0:
                tx=tx
            case 9:
                tx+= (4 - (tx Mod 4))
            case 10:
                tx=0
                ty+=1
            case 13:
                tx=tx
            case else:
                drawable->DrawChar(c,2+tx*9,2+(ty+ScrollY)*16,&hFF000000,FontManager.ML,1)
                tx=tx+1
        end select
    next i
    
    if (cursorDraw=0) then
        CursorX = tx
        CursorY = ty
    end if
    Drawable->FillRectangle(1+(CursorX+1)*9,2+(CursorY+ScrollY)*16,3+(CursorX+1)*9,2+(CursorY+ScrollY+1)*16,&hAAFF0000)
    Drawable->Flush()
end sub

sub CursorCoordToCursorPos()
     dim i as  integer
    dim last as integer=TextSize
    last = last-1
    dim tx as integer = 0
    dim ty as integer = 0
    dim cursorDraw as unsigned integer = 0
    for i = 0 to last
        
      
        var c = TextBuffer[i]
		if (c<>13) then
			if (tx=CursorX and ty=CursorY) then 
				CursorPos = i
				cursorDraw=1
				exit for
			end if
			if (ty=CursorY and tx>cursorX) then
				CursorPos = i
				cursorDraw=1
				exit for
			end if
        end if
        
        select case c
            case 0:
                tx=tx
            case 9:
                tx+=(4 - (tx Mod 4))
            case 10:
                tx=0
                if (cursorY = ty) then
                    if (i>0) then
                        cursorPos = i
                    else
                        cursorPos = 0
                    end if
                    cursorDraw=1
                    exit for
                end if
                ty+=1
            case 13:
                tx=tx
            case else:
                tx=tx+1
        end select
    next i
    
    if (cursorDraw=0) then
        CursorPos = TextSize
    end if
end sub

sub CheckScroll()
    if (CursorY+ScrollY<0) then
        ScrollY =0-CursorY
    end if
    if (CursorY+ScrollY>MaxY-1) then
        ScrollY = (MaxY-CursorY)-1
    end if
end sub
