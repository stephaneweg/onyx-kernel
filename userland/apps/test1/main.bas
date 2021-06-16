declare sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 


#include once "stdlib.bi"
#include once "system.bi"
#include once "gdi.bi"
#include once "slab.bi"
#include once "stdlib.bas"


#include once "system.bas"
#include once "slab.bas"
#include once "gdi.bas"



dim shared mainWin as unsigned integer



dim shared argsCount as unsigned integer
dim shared argsValues as unsigned byte ptr ptr
declare sub btnClick(btn as unsigned integer,parm as unsigned integer)

#include once "console.bi"
#include once "console.bas"
#include once "ipc.bi"
#include once "ipc.bas"

type XReply field = 1
    code as Unsigned Integer
end type

type XMessage field = 1
    op as unsigned integer
end type

type XWindowMessage extends XMessage field=1
    WindowWidth as unsigned integer
    WindowHeight as unsigned integer
    WindowTitle(0 to 255) as unsigned byte
end type


sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    SlabInit()
    argsCount = argc
	argsValues = argv
    
	MainWin = GDIWindowCreate(285,225,@"Test application")
    GDIButtonCreate(MainWin,10,45,40,30,@"TEST",@btnClick,0)
	IPInitClient(@"DESKTOP")
    MessageBoxShow(intToStr(ClientMailBoxId,10),@"Client mailbox")
    WaitForEvent()
	do:loop
end sub

sub btnClick(btn as unsigned integer,parm as unsigned integer)
    var msg = cptr(XWindowMessage ptr,Malloc(sizeof(XWIndowMessage)))
    msg->OP = 1
    msg->WindowWidth = 500
    msg->WindowHeight = 200
    
    var r = IPCSendReceive(sizeof(XWindowMessage),msg)
    if (r<>0) then
        var reply = cptr(XReply ptr,cuint(r)+sizeof(IPCMessage))
        MessageBoxShow(intToStr(reply->Code,10),@"Received result code")
        MessageBoxShow(intToStr(ClientMailBoxId,10),@"My Client mailbox")
        delete r
    end if
    
    delete msg
    
	EndCallBack()
    do:loop
end sub




