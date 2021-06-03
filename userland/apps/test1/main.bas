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
	dim drivename(0 to 20) as unsigned byte
	dim fsname(0 to 20) as unsigned byte
	if (argsCount>0) then
		for i as unsigned integer=0 to argsCount-1
			if (strncmp(argsValues[i],@"sys=",4)=0) then
				MessageBoxShow(@"found sys Mount point",@"argument")
				dim parm as unsigned byte ptr = cptr(unsigned byte ptr,cuint(argsValues[i])+4)
				MessageBoxShow(parm,@"argument")
				var dd  = strindexof(parm,@":")
				if (dd>0 and dd<20) then
					memcpy(@drivename(0),parm,dd)
					drivename(dd)=0
					MessageBoxShow(@drivename(0),@"drivename")
					memcpy(@fsname(0),parm+dd+1,(strlen(parm)-dd)-1)
					fsname((strlen(parm)-dd)-1)=0
					MessageBoxShow(@fsname(0),@"fsname")
					
				end if
			end if
		next i
	else
	end if
	EndCallBack()
    do:loop
end sub




