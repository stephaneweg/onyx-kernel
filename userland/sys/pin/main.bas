


#include once "stdlib.bi"
#include once "system.bi"
#include once "slab.bi"
#include once "file.bi"
#include once "gdi.bi"

#include once "stdlib.bas"
#include once "system.bas"
#include once "slab.bas"
#include once "file.bas"
#include once "gdi.bas"


#include once "tobject.bi"
#include once "font.bi"
#include once "fontmanager.bi"
#include once "gimage.bi"
#include once "tobject.bas"
#include once "font.bas"
#include once "fontmanager.bas"
#include once "gimage.bas"
type app field=1
    Text as unsigned byte ptr
    Path as unsigned byte ptr
end type


dim shared panelApps as unsigned integer
dim shared scrollViewOuter as unsigned integer
dim shared buttonContainer as unsigned integer
dim shared DirEntries as VFSDirectoryEntry ptr
dim shared executablePath(0 to 512) as unsigned byte
dim shared scrollViewHeight as integer
dim shared scrollContentHeight as integer
dim shared scrollOffset as integer
dim shared maxScrollOffset as integer

dim shared currentPanelXPos as integer
dim shared minPanelXPos as integer
dim shared maxPanelXPos as integer
dim shared panelYPos as integer

dim shared btnScrollUp as unsigned integer
dim shared btnScrollDown as unsigned integer
dim shared btnHeight as integer
dim shared btnSpace as integer
declare sub AppButtonClick(btn as unsigned integer,num as unsigned integer)
declare sub btnScrollClick(btn as unsigned integer,num as unsigned integer)

dim shared panel as unsigned integer
dim shared xres as integer
dim shared yres as integer
dim shared xpos as integer
dim shared ypos as integer
dim shared panelWidth as integer
dim shared panelHeight as integer
dim shared buttonSize as integer 
dim shared buttonCount as integer 

dim shared nbrApps as integer = 3
dim shared Collapsed as integer = 0
declare sub CreateAppPanel()
declare sub Collapse()
declare sub UnCollapse()
declare sub btnClick(btn as unsigned integer,parm as unsigned integer)
declare sub btnCollapseClick(btn as unsigned integer,parm as unsigned integer)


sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
	buttonSize= 64
	buttonCount = 7
    Collapsed = 1
    SlabINIT()
    
    GetScreenRes(xres,yres)
    panelHeight= buttonSize*buttonCount
    panelWidth = buttonSize
    
    yPos =  (yRes-panelHeight) /2
	xPos = 0
    
    panel = GDICreate(0,xPos,yPos,panelWidth,panelHeight)
    GDISetShadow(panel,-1)
	GDISetVisible(panel,0)
	GDIClear(panel,&hFF000000)
    GDISetTransparent(panel,-1)
    GDISetPosition(panel, xPos,yPos)
	
    dim panelBTNSkinSize as unsigned integer = 0
    var panelBTNSkin =VFS_LOAD_FILE(@"SYS:/RES/PANELBTN.BMP",@panelBTNSkinSize)
	for i as unsigned integer = 0 to buttonCount-1
		dim callback as any ptr = @btnClick
		if (i=buttonCount-1) then callback=@btnCollapseClick
		var btn = GDIButtonCreate(panel,0,i*buttonSize,buttonSize,buttonSize,@"",callback,i)
        select case i
            case 0
                GDIButtonSetSkin(btn,@"SYS:/RES/CFGBTN.BMP")
            case 1
                GDIButtonSetSkin(btn,@"SYS:/RES/VOLBTN.BMP")
            case else
                if (panelBTNSkinSize<>0 and panelBTNSkin<>0) then
                    GDIButtonSetSkinFromBUffer(btn,panelBTNSkin,panelBTNSkinSize)
                end if
        end select
        
        if i = 1 then
              GDIButtonSetIcon(btn,@"SYS:/ICONS/FILEMAN.BMP",0)
        elseif i = buttonCount-1 then
              GDIButtonSetIcon(btn,@"SYS:/ICONS/APPSX.BMP",0)
        end if
	next i
    
    
	GDISetVisible(panel,1)
    
    CreateAppPanel()
    Free(panelBTNSkin)
	WaitForEvent()
end sub

sub CreateAppPanel()

    dim appBTNSkinSize as unsigned integer = 0
    var appBTNSkin =VFS_LOAD_FILE(@"SYS:/RES/APPBTN.BMP",@appBTNSkinSize)
    
    dim txtArrow(0 to 3) as unsigned byte
    txtArrow(0) = 30
    txtArrow(1) = 0
    txtArrow(2) = 31
    txtArrow(3) = 0
	scrollViewHeight = 310
	btnHeight = 140
    btnSpace = 10
	
	maxPanelXPos = buttonSize-1
	minPanelXPos = buttonSize-491
	panelYPos = (yres-scrollViewHeight)/2
    currentPanelXPos = minPanelXPos
	
    panelApps = GDICreate(0,currentPanelXPos,panelYPos,490,scrollViewHeight)
    GDISetShadow(panelApps,-1)
	GDISetVisible(panelApps,0)
    GDIClear(panelApps,&hFF141D24)
    
    
    scrollViewOuter = GDICreate(panelApps,0,0,470,scrollViewHeight)
    DirEntries = cptr(VFSDirectoryEntry ptr,MAlloc(sizeof(VFSDirectoryEntry)*512))
    dim cpt as integer = VFSListDir(@"SYS:/APPS",1,0,512,DirEntries)
    dim i as integer
    dim num as integer = 0
    dim row as unsigned integer
    dim col as unsigned integer
    for i = 0 to cpt-1
        if (strendswith(@(DirEntries[i].FileName(0)),@".APP")) then
            col= num mod 3
            row = num \ 3
            num+=1
        end if
    next
    scrollContentHeight = row*(btnHeight+btnSpace)+(btnHeight+2*btnSpace)
    scrollOffset = 0
    maxScrollOffset = 0
    if (scrollContentHeight>(scrollViewHeight-2)) then maxScrollOffset = scrollContentHeight-(scrollViewHeight-2)
    
    buttonContainer = GDICreate(scrollViewOuter,0,0,470,scrollContentHeight)
    
    GDIClear(buttonContainer,&hFF141D24)
    
    num=0    
	for i = 0 to cpt-1
            if (strendswith(@(DirEntries[i].FileName(0)),@".APP")) then
                col = num mod 3
                row = num \ 3
                num+=1
                var btn = GDIButtonCreate(buttonContainer, col * (btnHeight+btnSpace)+btnSpace,row*(btnHeight+btnSpace)+btnSpace,btnHeight,btnHeight,@(DirEntries[i].FileName(0)),@AppButtonClick,i)
                strcpy(@executablePath(0),strcat(@"SYS:/APPS/",@(DirEntries[i].FileName(0))))
                strcpy(@executablePath(0),strcat(@executablePath(0),@"/app.bmp"))
                GDIButtonSetIcon(btn,@executablePath(0),1)
                
                if (appBTNSkinSize<>0 and appBTNSkin<>0) then
                    GDIButtonSetSkinFromBUffer(btn,appBTNSkin,appBTNSkinSize)
                end if
				'GDIButtonSetSkin(btn,@"SYS:/RES/APPBTN.BMP")
				GDISetForegroundColor(btn,&hFFFFFFFF)
            end if
    next
    
    
    btnScrollUp     = GDIButtonCreate(panelApps,470,0,20,20,@txtArrow(0),@btnScrollClick,1)
    btnScrollDown   = GDIButtonCreate(panelApps,470,scrollViewHeight-20,20,20,@txtArrow(2),@btnScrollClick,2)
    
    
    
    GDIInvalidate(buttonContainer)
    GDIInvalidate(scrollViewOuter)
    GDIInvalidate(panelApps)
	Free(appBTNSkin)
end sub


sub btnScrollClick(btn as unsigned integer,num as unsigned integer)
    
    var newScroll = scrollOffset
    if (num=2) then
        newScroll+=((btnHeight+btnSpace)\2)
    elseif (num=1) then
        newScroll-=((btnHeight+btnSpace)\2)
    end if
            
    if (newScroll>=maxScrollOffset) then newScroll=maxScrollOffset
    if (newScroll<=0) then newScroll = 0
    
    if (newScroll<>scrollOffset) then
        scrollOffset = newScroll
        GDISetPosition(buttonContainer,0,-scrollOffset)
    end if
    EndCallBack()
end sub

sub AppButtonClick(btn as unsigned integer,num as unsigned integer)
    strcpy(@executablePath(0),strcat(@"SYS:/APPS/",@(DirEntries[num].FileName(0))))
    strcpy(@executablePath(0),strcat(@executablePath(0),@"/main.bin"))
    
    Collapse()
    ExecApp(@executablePath(0),@"module /sys/vfs.bin sys=HDA1:FATFS")
    EndCallBack()
end sub

sub btnClick(btn as unsigned integer,parm as unsigned integer)
	if (parm=1) then
		ExecApp(@"SYS:/SYS/fileman.bin",0)
	end if
	EndCallBack()
end sub

sub btnCollapseClick(btn as unsigned integer,parm as unsigned integer)
	if (Collapsed=1)  then
        UnCollapse()
    else
        Collapse()
    end if
    EndCallBack()
end sub

sub Collapse()
    dim tStart as unsigned long
    dim tEnd as unsigned long
    dim tDiff as unsigned long
	'dim x as integer
    'dim i as unsigned integer
	'for x = currentPanelXPos to minPanelXPos step -4
    '    if (collapsing<>-1) then exit sub
    '    tStart = GetTimer()
    '	GDISetPosition(panelApps, x,panelYPos)
    '      currentPanelXPos = x
	'	tEnd = GetTimer()
    '    tDiff = tEnd-tStart
    '    if (tDiff <3) then
    '        WaitN(3-tDiff)
    '    end if
	'next x
    currentPanelXPos=minPanelXPos
    GDISetPosition(panelApps, minPanelXPos,panelYPos)
    Collapsed=1
end sub

sub UnCollapse()
    dim tStart as unsigned long
    dim tEnd as unsigned long
    dim tDiff as unsigned long
	GDISetVisible(panelApps,0)
	GDIBringToFront(panelApps)
	GDIBringToFront(panel)
	GDISetVisible(panelApps,1)
	'dim x as integer
    'dim i as unsigned integer
	'for x = currentPanelXPos to maxPanelXPos step 4
    '        if (collapsing<>1) then exit sub
    '        tStart = GetTimer()
    '        GDISetPosition(panelApps, x,panelYPos)
    '        currentPanelXPos = x
    '        tEnd = GetTimer()
    '        tDiff = tEnd-tStart
    '        if (tDiff <3) then
    '            WaitN(3-tDiff)
    '        end if
	'next x
    currentPanelXPos=maxPanelXPos
    GDISetPosition(panelApps, maxPanelXPos,panelYPos)
    Collapsed=0
end sub
