#include once "stdlib.bi"
#include once "stdlib.bas"


#include once "system.bi"
#include once "console.bi"
#include once "system.bas"
#include once "console.bas"


sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    if (argc>0) then
        ConsoleWriteLine(argv[0])
    end if
    ExitApp()
end sub
