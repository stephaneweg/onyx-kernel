#include once "stdlib.bi"
#include once "system.bi"
#include once "slab.bi"
#include once "file.bi"
#include once "gdi.bi"
#include once "console.bi"


#include once "stdlib.bas"
#include once "system.bas"
#include once "slab.bas"
#include once "file.bas"
#include once "gdi.bas"


dim shared DirEntries as VFSDirectoryEntry ptr
dim shared Path as unsigned byte ptr
dim shared MainWin as unsigned integer
dim shared btnScrollUp as unsigned integer
dim shared btnScrollDown as unsigned integer
dim shared drawable as unsigned integer
dim shared scrollViewOuter as unsigned integer
dim shared buttonContainer as unsigned integer


dim shared scrollViewHeight as integer
dim shared scrollContentHeight as integer
dim shared scrollOffset as integer
dim shared maxScrollOffset as integer
dim shared btnHeight as integer
dim shared btnSpace as integer

declare sub btnScrollClick(btn as unsigned integer,num as unsigned integer)
declare sub ButtonClick(btn as unsigned integer,num as unsigned integer)
declare sub ButtonAppClick(btn as unsigned integer,num as unsigned integer)
declare sub MergePath(fname as unsigned byte ptr)
dim shared TmpPath(0 to 1024) as unsigned byte
sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
	SlabInit()
    scrollViewHeight = 310
    btnHeight = 140
    btnSpace = 10
    dim txtArrow(0 to 3) as unsigned byte
    txtArrow(0) = 30
    txtArrow(1) = 0
    txtArrow(2) = 31
    txtArrow(3) = 0
	
	if (argc=0) then 
		Path=@"SYS:/"
	else
		Path=argv[0]
	end if
	
	MainWin = GDIWindowCreate(490,scrollViewHeight+5,Path)
    drawable = GDICreate(MainWin,0,0,490,scrollViewHeight)
    gdiClear(drawable,&hFFFFFFFF)
	
    scrollViewOuter = gdiCreate(drawable,1,1,458,scrollViewHeight-2)
    gdiClear(scrollViewOuter,&hFFFFFFFF)
	
    DirEntries = cptr(VFSDirectoryEntry ptr,MAlloc(sizeof(VFSDirectoryEntry)*512))
    dim cpt as unsigned integer = VFSListDir(Path,0,0,512,DirEntries)
	dim i as integer
	dim num as integer
	dim row as unsigned integer
	dim col as unsigned integer
	for i= 0 to cpt-1
		var fname = @(DirEntries[i].FileName(0))
		if (strcmp(fname,@"..")<>0) and (strcmp(fname,@".")<>0) then
			col = num mod 3
			row = num \3
			num+=1
		end if
	next i
	scrollContentHeight = row*(btnHeight+btnSpace)+(btnHeight+2*btnSpace)
	scrollOffset = 0
    maxScrollOffset = 0
	if (scrollContentHeight>(scrollViewHeight-2)) then maxScrollOffset = scrollContentHeight-(scrollViewHeight-2)
    buttonContainer = GDICreate(scrollViewOuter,0,0,458,scrollContentHeight-2)
    GDIClear(buttonContainer,&hFFFFFFFF)
	
	num=0    
    for i = 0 to cpt-1
		var fname = @(DirEntries[i].FileName(0))
		if (strcmp(fname,@"..")<>0) and (strcmp(fname,@".")<>0) then
			col = num mod 3
			row = num \ 3
			num+=1
			
			var isApp = strendswith(fname,@".APP")
			var callback = @ButtonClick
			if (isApp) then callback=@ButtonAppClick
			
			
			var btn = GDIButtonCreate(buttonContainer,_
				col * (btnHeight+btnSpace)+btnSpace,_
				row*(btnHeight+btnSpace)+btnSpace,btnHeight,_
				btnHeight,_
				@(DirEntries[i].FileName(0)),_
				callback,i)
			if  isApp then
				MergePath(@(DirEntries[i].FileName(0)))
                strcpy(@TmpPath(0),strcat(@TmpPath(0),@"/app.bmp"))
                GDIButtonSetIcon(btn,@TmpPath(0),1)
            end if
		end if
	next
	
	
    btnScrollUp     = GDIButtonCreate(drawable,460,0,30,30,@txtArrow(0),@btnScrollClick,1)
    btnScrollDown   = GDIButtonCreate(drawable,460,scrollViewHeight-30,30,30,@txtArrow(2),@btnScrollClick,2)
    
    
    gdiClear(drawable,&hFFFFFFFF)
    gdiDrawRectangle(drawable,0,0,489,scrollViewHeight-1,&hFFAAAAAA)
    
    GDIInvalidate(buttonContainer)
    GDIInvalidate(scrollViewOuter)
    GDIInvalidate(drawable)
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

sub ButtonAppClick(btn as unsigned integer,num as unsigned integer)
    
	dim tpath as unsigned byte ptr = @TmpPath(0)
	dim entry as VFSDirectoryEntry ptr = @DirEntries[num]
	MergePath(@entry->FileName(0))
	strcpy(tpath,strcat(tpath,@"/main.bin"))
    ExecApp(tpath,0)
    EndCallBack()
end sub

sub ButtonClick(btn as unsigned integer,num as unsigned integer)
	dim entry as VFSDirectoryEntry ptr = @DirEntries[num]
	dim tpath as unsigned byte ptr = @TmpPath(0)
	
	if (entry->EntryType=1) then
		MergePath(@entry->FileName(0))
		ExecApp(@"SYS:/SYS/FILEMAN.BIN",tpath)
	elseif(entry->EntryType=2) then
		MergePath(@entry->FileName(0))
		MessageBoxShow(tpath, @"Select file")
	end if
    'strcpy(@executablePath(0),strcat(@"SYS:/APPS/",@(DirEntries[num].FileName(0))))
    'strcpy(@executablePath(0),strcat(@executablePath(0),@"/main.bin"))
    
    'ExecApp(@executablePath(0))
    EndCallBack()
end sub

sub MergePath(fname as unsigned byte ptr)
	dim tpath as unsigned byte ptr = @TmpPath(0)
	MemSet(tpath,0,1024)
	strcpy(tpath,Path)
	if (tpath[strlen(tpath)-1]<>asc("/")) then
		tpath[strlen(tpath)]=asc("/")
	end if
	strcpy(cptr(unsigned byte ptr,cuint(tpath)+strlen(tpath)),fname)
end sub

