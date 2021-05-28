#include once "stdlib.bi"
#include once "system.bi"
#include once "file.bi"
#include once "gdi.bi"
#include once "slab.bi"

#include once "stdlib.bas"
#include once "system.bas"
#include once "file.bas"
#include once "gdi.bas"
#include once "slab.bas"



dim shared mainWin as unsigned integer
dim shared drawable as unsigned integer
dim shared scrollViewOuter as unsigned integer
dim shared buttonContainer as unsigned integer
dim shared DirEntries as VFSDirectoryEntry ptr
dim shared executablePath(0 to 512) as unsigned byte
dim shared scrollViewHeight as integer
dim shared scrollContentHeight as integer
dim shared scrollOffset as integer
dim shared maxScrollOffset as integer

dim shared btnScrollUp as unsigned integer
dim shared btnScrollDown as unsigned integer
dim shared btnHeight as integer
dim shared btnSpace as integer
declare sub AppButtonClick(btn as unsigned integer,num as unsigned integer)
declare sub btnScrollClick(btn as unsigned integer,num as unsigned integer)

sub MAIN(p as any ptr) 
    SlabINIT()
    scrollViewHeight = 310
    btnHeight = 140
    btnSpace = 10
    dim txtArrow(0 to 3) as unsigned byte
    txtArrow(0) = 30
    txtArrow(1) = 0
    txtArrow(2) = 31
    txtArrow(3) = 0
    
	MainWin = GDIWindowCreate(490,scrollViewHeight+5,@"Applications")
    drawable = GDICreate(MainWin,0,0,490,scrollViewHeight)
    
    scrollViewOuter = gdiCreate(drawable,1,1,458,scrollViewHeight-2)
    
	
    DirEntries = cptr(VFSDirectoryEntry ptr,MAlloc(sizeof(VFSDirectoryEntry)*512))
    dim cpt as unsigned integer = VFSListDir(@"SYS:/APPS",1,0,512,DirEntries)
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
    
    buttonContainer = GDICreate(scrollViewOuter,0,0,458,scrollContentHeight-2)
    GDIClear(buttonContainer,&hFFFFFFFF)
    
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
            
            end if
    next
    
    
    btnScrollUp     = GDIButtonCreate(drawable,460,0,30,30,@txtArrow(0),@btnScrollClick,1)
    btnScrollDown   = GDIButtonCreate(drawable,460,scrollViewHeight-30,30,30,@txtArrow(2),@btnScrollClick,2)
    
    
    gdiClear(drawable,&hFFFFFFFF)
    gdiDrawRectangle(drawable,0,0,489,scrollViewHeight-1,&hFFAAAAAA)
	WaitForEvent()
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
        gdiClear(drawable,&hFFFFFFFF)
        gdiDrawRectangle(drawable,0,0,489,scrollViewHeight-1,&hFFAAAAAA)
        GDISetPosition(buttonContainer,0,-scrollOffset)
    end if
    EndCallBack()
end sub

sub AppButtonClick(btn as unsigned integer,num as unsigned integer)
    strcpy(@executablePath(0),strcat(@"SYS:/APPS/",@(DirEntries[num].FileName(0))))
    strcpy(@executablePath(0),strcat(@executablePath(0),@"/main.bin"))
    
    ExecApp(@executablePath(0))
    EndCallBack()
end sub
