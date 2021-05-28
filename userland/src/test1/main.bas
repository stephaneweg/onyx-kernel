declare sub MAIN (p as any ptr)


#include once "stdlib.bi"
#include once "stdlib.bas"


#include once "system.bi"
#include once "system.bas"
#include once "gdi.bi"
#include once "gdi.bas"

declare sub BTNPlusClick(btn as unsigned integer,parm as unsigned integer)
declare sub BTNMinusClick(btn as unsigned integer,parm as unsigned integer)
declare sub BTNMultiplyClick(btn as unsigned integer,parm as unsigned integer)
declare sub BTNDivideClick(btn as unsigned integer,parm as unsigned integer)
declare sub BTNPlusMinusClick(btn as unsigned integer,parm as unsigned integer)
declare sub BTNClearClick(btn as unsigned integer,parm as unsigned integer)
declare sub BTNPIClick(btn as unsigned integer,parm as unsigned integer)
declare sub BTNPERCENTClick(btn as unsigned integer,parm as unsigned integer)
declare sub BTNEqualsClick(btn as unsigned integer,parm as unsigned integer)
declare sub BtnFuncClick(btn as unsigned integer,parm as unsigned integer)
declare sub BtnNumClick(btn as unsigned integer,parm as unsigned integer)

enum Operation
    None
    Plus
    Minus
    Multiply
    Divide
	Percent
end enum
declare sub DoOperation()
declare sub SetOperation(o as OPERATION)


dim shared mainWin as unsigned integer
dim shared displayTxt as unsigned integer
dim shared hasDot as unsigned integer
dim shared Value as Double
dim shared IsOPComplete as integer

dim shared OP as Operation

dim shared txtX as unsigned byte ptr = @"                                                  "
dim shared valueX as double


dim shared btnNum0 as unsigned integer
dim shared btnNum1 as unsigned integer
dim shared btnNum2 as unsigned integer
dim shared btnNum3 as unsigned integer
dim shared btnNum4 as unsigned integer
dim shared btnNum5 as unsigned integer
dim shared btnnum6 as unsigned integer
dim shared btnnum7 as unsigned integer
dim shared btnNum8 as unsigned integer
dim shared btnNum9 as unsigned integer
dim shared btnDot as unsigned integer

dim shared btnSQR as unsigned integer
dim shared btnSQRT as unsigned integer
dim shared btnSIN as unsigned integer
dim shared btnCOS as unsigned integer

declare sub btnClick(btn as unsigned integer,parm as unsigned integer)
sub MAIN(p as any ptr) 
   
    ISOpComplete = 0
	OP = Operation.NONE
	hasDot = 0
	value = 0
    
	MainWin = GDIWindowCreate(285,225,@"Calculator")
    GDIButtonCreate(MainWin,10,45,40,30,@"COS",@btnClick,0)
	
    WaitForEvent()
	do:loop
end sub

sub btnClick(btn as unsigned integer,parm as unsigned integer)
    if (MessageConfirmShow(@"Do you want to continue",@"Question")) then
        MessageBoxShow(@"You clicked on yes",@"Info")
    else
        MessageBoxShow(@"You clicked on no",@"info")
    end if
	EndCallBack()
    do:loop
end sub




