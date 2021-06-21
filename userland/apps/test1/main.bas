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



sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    SlabInit()
    argsCount = argc
	argsValues = argv
    
	MainWin = GDIWindowCreate(285,225,@"Test application")
    GDIButtonCreate(MainWin,10,45,40,30,@"TEST",@btnClick,0)
    WaitForEvent()
	do:loop
end sub

sub btnClick(btn as unsigned integer,parm as unsigned integer)
	dim a as unsigned integer = 4
	dim b as unsigned integer = 0
	dim c as unsigned integer = 99
	
	c = a\b
    MessageBoxShow(IntToStr(c,10),@"Result")
	EndCallBack()
    do:loop
end sub




