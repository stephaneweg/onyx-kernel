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
    var vfs = UDevFind(@"VFS")
    while (vfs=0)
        threadYield()
        vfs = UDevFind(@"VFS")
    wend
    
    
    ConsoleWriteLine(@"INIT starting")
    dim f as unsigned integer = FileOpen(@"SYS:/ETC/INIT.CFG")
    if (f<>0) then
        
        while not FileEOF(f)
            FileReadLine(f,@fline(0))
            
            if strlen(@fline(0))>0 then
                ExecApp(@fline(0))
                'ConsoleWrite(@"Process to execute : ")
                'ConsoleWriteLine(@fline(0))
            end if
        wend
        FileClose(f,0)
    else
        ConsoleSetForeground(12)
        ConsoleWrite(@"Could not open INIT.CFG")
        ConsoleSetForeground(7)
    end if
    ExitApp()
end sub
