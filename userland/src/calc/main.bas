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

sub MAIN(p as any ptr) 
   
    ISOpComplete = 0
	OP = Operation.NONE
	hasDot = 0
	value = 0
    
	MainWin = GDIWindowCreate(285,225,@"Calculator")
	DisplayTxt = GDITextBoxCreate(MainWin,10,10,265,30)
    
    btnCos = GDIButtonCreate(MainWin,10,45,40,30,@"COS",@btnFuncClick,0)
    btnSin = GDIButtonCreate(MainWin,55,45,40,30,@"SIN",@btnFuncClick,0)
    
    btnNum7	= GDIButtonCreate(MainWin,10,80,40,30,@"7",@BTNNumClick,0)
    btnNum8	= GDIButtonCreate(MainWin,55,80,40,30,@"8",@BTNNumClick,0)    
    btnNum9	= GDIButtonCreate(MainWin,100,80,40,30,@"9",@BTNNumClick,0)
    
    btnNum4	= GDIButtonCreate(MainWin,10,115,40,30,@"4",@BTNNumClick,0)
    btnNum5	= GDIButtonCreate(MainWin,55,115,40,30,@"5",@BTNNumClick,0)
    btnNum6	= GDIButtonCreate(MainWin,100,115,40,30,@"6",@BTNNumClick,0)
    
    btnNum1	= GDIButtonCreate(MainWin,10,150,40,30,@"1",@BTNNumClick,0)
    btnNum2	= GDIButtonCreate(MainWin,55,150,40,30,@"2",@BTNNumClick,0)
    btnNum3	= GDIButtonCreate(MainWin,100,150,40,30,@"3",@BTNNumClick,0)
    
    btnNum0 = GDIButtonCreate(MainWin,10,185,40,30,@"0",@BTNNumClick,0)
    GDIButtonCreate(MainWin,55,185,40,30,@"+/-",@BTNPlusMinusClick,0)
    btnDot	= GDIButtonCreate(MainWin,100,185,40,30,@".",@BTNNumClick,0)
    
    GDIButtonCreate(MainWin,145,80,40,30,@"+",@BTNPlusClick,0)
    GDIButtonCreate(MainWin,145,115,40,30,@"-",@BTNMinusClick,0)
    GDIButtonCreate(MainWin,145,150,40,30,@"*",@BTNMultiplyClick,0)
    GDIButtonCreate(MainWin,145,185,40,30,@"/",@BTNDivideClick,0)
    
    GDIButtonCreate(MainWin,190,80,85,30,@"C",@BTNClearClick,0)
    btnSQRT = GDIButtonCreate(MainWin,190,115,40,30,@"SQRT",@btnFuncClick,0)
    GDIButtonCreate(MainWin,190,150,40,30,@"PI",@BTNPIClick,0)
    btnSQR  = GDIButtonCreate(MainWin,235,115,40,30,@"x^2",@btnFuncClick,0)
    
    
    GDIButtonCreate(MainWin,235,150,40,30,@"%",@BTNPERCENTClick,0)
    GDIButtonCreate(MainWin,190,185,85,30,@"=",@BTNEqualsClick,0)
    WaitForEvent()
	do:loop
end sub




sub DoOperation()
	GDITextBoxGetText(DisplayTxt,txtX)
    valuex = Atof(txtX)
    if (OP <> Operation.None) then
        
        select case OP
            case Operation.Plus
                value = value + valueX
            case Operation.Minus
                value = value - valueX
            case Operation.Multiply
                value = value * valueX
            case Operation.Divide
				if (valueX<>0) then value = value / valueX
			case Operation.Percent
				value = (value * valueX) / 100.0
        end select
	else
		value = valueX
    end if
end sub

sub SetOperation(o as OPERATION)
    DoOperation()
	OP = o
	ftoa(Value,txtX)
    GDITextBoxSetText(displayTxt,@"")
    hasDot = 0
end sub

sub BTNEqualsClick(btn as unsigned integer,parm as unsigned integer)
    DoOperation()
    ftoa(Value,txtX)
    GDITextBoxSetText(displayTxt,txtX)
    'to do : set the textbox to "Value1" string
	value = 0
	OP = OPERATION.NONE
	hasdot = 0
    IsOPComplete = 1
	EndCallBack()
end sub

sub BTNPERCENTClick(btn as unsigned integer,parm as unsigned integer)
	SetOperation(Operation.Percent)
	EndCallBack()
end sub

sub BTNPIClick(btn as unsigned integer,parm as unsigned integer)
    GDITextBoxSetText(displayTxt,@"3.14159265358979323846")
	EndCallBack()
end sub

sub BTNClearClick(btn as unsigned integer,parm as unsigned integer)
    GDITextBoxSetText(displayTxt,@"")
    IsOPComplete = 0
	OP = OPERATION.NONE
	value = 0
	hasdot = 0
	EndCallBack()
end sub

sub BTNPlusClick(btn as unsigned integer,parm as unsigned integer)
    SetOperation(Operation.Plus)
	EndCallBack()
end sub

sub BTNMinusClick(btn as unsigned integer,parm as unsigned integer)
    SetOperation(Operation.Minus)
	EndCallBack()
end sub

sub BTNMultiplyClick(btn as unsigned integer,parm as unsigned integer)
    SetOperation(Operation.Multiply)
	EndCallBack()
end sub

sub BTNDivideClick(btn as unsigned integer,parm as unsigned integer)
    SetOperation(Operation.Divide)
	EndCallBack()
end sub


sub BTNPlusMinusClick(btn as unsigned integer,parm as unsigned integer)

	GDITextBoxGetText(DisplayTxt,txtX)
    valuex = -Atof(txtX)
	
    ftoa(valuex,txtX)
    
    GDITextBoxSetText(displayTxt,txtX)
   
	EndCallBack()
end sub

sub btnFuncClick(btn as unsigned integer,parm as unsigned integer)
	GDITextBoxGetText(DisplayTxt,txtX)
    valuex = Atof(txtX)
	
	if (btn = btnCOS) then
		valuex = fcos(valuex)
    elseif(btn = btnSIN) then 
		valueX = fsin(valuex)
    elseif(btn = btnSQR ) then 
		valueX = valueX*valueX
    elseif(btn = btnSQRT ) then 
		valuex = sqrt(valuex)
	end if
	
	ftoa(valueX,txtX)
	GDITextBoxSetText(displayTxt,txtX)
    
    IsOPComplete = 1
	EndCallBack()
end sub

sub BTNNumClick(btn as unsigned integer,parm as unsigned integer)
    if (IsOPComplete = 1) then GDITextBoxSetText(displayTxt,@""):IsOPComplete=0
	
	if (btn=btnnum0) then 
		GDITextBoxAppendChar(displayTxt,asc("0"))
	elseif (btn=btnnum1) then 
		GDITextBoxAppendChar(displayTxt,asc("1"))
	elseif (btn=btnnum2) then 
		GDITextBoxAppendChar(displayTxt,asc("2"))
	elseif (btn=btnnum3) then 
		GDITextBoxAppendChar(displayTxt,asc("3"))
	elseif (btn=btnnum4) then 
		GDITextBoxAppendChar(displayTxt,asc("4"))
	elseif (btn=btnnum5) then 
		GDITextBoxAppendChar(displayTxt,asc("5"))
	elseif (btn=btnnum6) then 
		GDITextBoxAppendChar(displayTxt,asc("6"))
	elseif (btn=btnnum7) then 
		GDITextBoxAppendChar(displayTxt,asc("7"))
	elseif (btn=btnnum8) then 
		GDITextBoxAppendChar(displayTxt,asc("8"))
	elseif (btn=btnnum9) then 
		GDITextBoxAppendChar(displayTxt,asc("9"))
	elseif (btn=btnDot) then
		if (hasDot=0) then
			GDITextBoxAppendChar(displayTxt,asc("."))
			hasdot=1
		end if
	end if
	EndCallBack()
end sub