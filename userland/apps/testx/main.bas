#include once "stdlib.bi"
#include once "stdlib.bas"


#include once "system.bi"
#include once "slab.bi"
#include once "console.bi"
#include once "file.bi"
#include once "system.bas"
#include once "console.bas"
#include once "slab.bas"
#include once "file.bas"

dim shared fline(0 to 255) as unsigned byte

dim shared entries(0 to 50) as VFSDirectoryEntry
sub MAIN(p as any ptr) 
	SlabInit()
    ConsoleWriteLine(@"Test from userland")
    ExitApp()
end sub
