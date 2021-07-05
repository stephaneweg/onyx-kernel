#include once "stdlib.bi"
#include once "stdlib.bas"


#include once "system.bi"
#include once "console.bi"
#include once "slab.bi"
#include once "file.bi"
#include once "system.bas"
#include once "console.bas"
#include once "slab.bas"
#include once "file.bas"


sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    if (argc>0) then
		var f = FileOpen(argv[0])
		if (f<>0) then
			dim b as unsigned byte
			while FileEOF(f)=0
				FileRead(f,1,@b)
				STDIO_WRITE_BYTE(0,b)
				
				WAITN(20)
				STDIO_READ(0) 'if user enter ctrl+C it will end the app
			wend
		end if
    end if
    ExitApp()
end sub
