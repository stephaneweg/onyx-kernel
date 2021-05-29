#include once "stdlib.bi"
#include once "system.bi"
#include once "console.bi"
#include once "slab.bi"


#include once "stdlib.bas"
#include once "system.bas"
#include once "console.bas"
#include once "slab.bas"

sub MAIN(p as any ptr) 
	'SlabInit()
	ConsoleWrite(@"Starting usermode hard disk driver")
	
	ConsolePrintOK()
    do:loop
	WaitForEvent()
end sub