declare sub MAIN (p as any ptr)


#include once "stdlib.bi"
#include once "system.bi"
#include once "gdi.bi"
#include once "slab.bi"
#include once "stdlib.bas"


#include once "system.bas"
#include once "slab.bas"
#include once "gdi.bas"



dim shared mainWin as unsigned integer




declare sub btnClick(btn as unsigned integer,parm as unsigned integer)
sub MAIN(p as any ptr) 
   SlabInit()
    
    
	MainWin = GDIWindowCreate(285,225,@"Test application")
    GDIButtonCreate(MainWin,10,45,40,30,@"TEST",@btnClick,0)
	
    WaitForEvent()
	do:loop
end sub

sub btnClick(btn as unsigned integer,parm as unsigned integer)
	var descr= UdevFind(@"HDA1")
	while descr=0
		threadYield()
		descr= UdevFind(@"HDA1")
	wend
	MessageBoxShow(intToStr(descr,16),@"UDev descriptor")
	dim b as unsigned byte ptr = MALLOC(512)
	for i as unsigned integer = 0 to 10
		UdevInvoke(descr,0,i,1,cuint(b))
		MessageBoxShow(b,@"UDev (hd)Read")
	next
	EndCallBack()
    do:loop
end sub




