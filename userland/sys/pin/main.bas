
#include once "stdlib.bi"
#include once "system.bi"
#include once "gdi.bi"
#include once "slab.bi"

#include once "stdlib.bas"
#include once "system.bas"
#include once "gdi.bas"
#include once "slab.bas"


type app field=1
    Text as unsigned byte ptr
    Path as unsigned byte ptr
end type

dim shared apps(0 to 10) as app

dim shared xres as unsigned integer
dim shared yres as unsigned integer
dim shared minXPos as integer
dim shared xPos as integer
dim shared yPos as integer
dim shared panel as unsigned integer
dim shared panelHeight as unsigned integer
dim shared panelWidth as unsigned integer
dim shared buttonHeight as unsigned integer
dim shared Collapsed as integer

dim shared nbrApps as integer = 3
declare sub btnClick(btn as unsigned integer,parm as unsigned integer)
declare sub btnCollapseClick(btn as unsigned integer,parm as unsigned integer)
sub Main(p as any ptr) 
    dim buttonWidth as integer = 150
    
    SlabINIT()
    GetScreenRes(xres,yres)
    panelHeight= 36
    buttonHeight = panelHeight-4
    panelWidth = buttonWidth*3 + panelHeight
    
    yPos = yres-30-panelHeight
    minXPos = -3*buttonWidth
    xPos = 0
    
    panel = GDICreate(0,xPos,yPos,panelWidth,panelHeight)
	GDIClear(panel,&h00000000)
    GDISetTransparent(panel,-1)
    GDISetPosition(panel, xPos,yPos)
    Collapsed = 0
    'GDISetPosition(panel, minXPos,yPos)
    'Collapsed = 1
    
    var b1 = GDIButtonCreate(panel,0*buttonWidth,(panelHeight-buttonHeight) shr 1,buttonWidth,buttonHeight,@"Applications",@btnClick,1)
    var b2 = GDIButtonCreate(panel,1*buttonWidth,(panelHeight-buttonHeight) shr 1,buttonWidth,buttonHeight,@"Settings",@btnClick,2)
    var b3 = GDIButtonCreate(panel,2*buttonWidth,(panelHeight-buttonHeight) shr 1,buttonWidth,buttonHeight,@"Documents",@btnClick,3)
    var b4 = GDIButtonCreate(panel,3*buttonWidth,0,panelHeight,panelHeight,@"",@btnCollapseClick,4)
    GDIButtonSetSkin(b1,@"SYS:/RES/PINBTN1.BMP")
    GDIButtonSetIcon(b1,@"SYS:/ICONS/APPS2.BMP",0)
    
    GDIButtonSetSkin(b2,@"SYS:/RES/PINBTN1.BMP")
    GDIButtonSetIcon(b2,@"SYS:/ICONS/CONTROL.BMP",0)
    
    
    GDIButtonSetSkin(b3,@"SYS:/RES/PINBTN1.BMP")
    GDIButtonSetIcon(b3,@"SYS:/ICONS/DOCS2.BMP",0)
    
    GDIButtonSetSkin(b4,@"SYS:/RES/STRIP.BMP")
    
    GDIButtonSetSkinColor(b1,1)
    GDIButtonSetSkinColor(b2,1)
    GDIButtonSetSkinColor(b3,1)
    GDIButtonSetSkinColor(b4,1)
	
	GDISetForegroundColor(b1,&hFFFFFFFF)
	GDISetForegroundColor(b2,&hFFFFFFFF)
	GDISetForegroundColor(b3,&hFFFFFFFF)
	GDISetForegroundColor(b4,&hFFFFFFFF)
    
	WaitForEvent()
end sub

sub btnClick(btn as unsigned integer,parm as unsigned integer)

	if (parm=1) then
		ExecApp(@"SYS:/SYS/APPS.BIN")
	end if
	EndCallBack()
end sub

sub btnCollapseClick(btn as unsigned integer,parm as unsigned integer)

    dim x as integer
    dim i as unsigned integer
    dim diff as integer = xPos -minXPos
	if (Collapsed = 0) then
        for x = xPos to minXPos step -4
            GDISetPosition(panel, x,yPos)
            for i=0 to 100000:next
            'ThreadYield()
            
        next x
        Collapsed = 1
    else
        for x = minXPos to xPos step 4
            GDISetPosition(panel, x,yPos)
            for i=0 to 100000:next
            'ThreadYield()
        next x
        Collapsed = 0
    end if
	EndCallBack()
end sub
