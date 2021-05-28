

sub INIT_MOUSE()
	ConsoleWrite(@"Installing Mouse driver ... ")
    MouseMaxX = 640
    MouseMaxY = 480
	MouseUpdated = 0
	IRQ_ENABLE(&hc)
	IRQ_ENABLE(&h2C)
    MOUSE_INSTALL()
	IRQ_ATTACH_HANDLER(&h2C,@MOUSE_INT_HANDLER)
    
    ConsoleWriteLine(@"installed")
    COnsolePrintOK()
    ConsoleNewLine()
end sub

function MOUSE_INT_HANDLER(stack as IRQ_STACK ptr) as IRQ_STACK ptr
	MOUSE_DATA_ARIVED(Mouse_READ())
	return stack
end function

sub SET_MOUSE_LIMIT(x as integer,y as integer)
    MouseMaxX = x
    MouseMaxY = y
    if (MouseX<0) then MouseX = 0
    if (MouseX>=MouseMaxX) then MouseX = MouseMaxX
    if (MouseY<0) then MouseY = 0
    if (MouseY>=MouseMaxY) then MouseY = MouseMaxY
end sub

sub MOUSE_INSTALL()
	dim Mouse_STATUS as byte
    Mouse_CYCLE = 0
	
	'disable keyboard
	MOUSE_WAIT(1)
	outb(&h64,&had)
	MOUSE_READ()
	
	'enable ps aux
	MOUSE_WAIT(1)
	outb(&h64,&hA8)
	
	'ennable irq (and disable mouse clock)
	MOUSE_WAIT(1)
	outb(&h64,&h20)
	MOUSE_WAIT(1)
	inb(&h60,[MOUSE_STATUS])
	MOUSE_STATUS=(MOUSE_STATUS OR 2)
	MOUSE_WAIT(1)
	outb(&h64,&h60)
	MOUSE_WAIT(1)
	outb(&h60,[MOUSE_STATUS])
	
	'set to defaults
	MOUSE_WRITE(&hF6)
	MOUSE_READ()
	
	'set to stream mode
	MOUSE_WRITE(&hF4)
	MOUSE_READ()
	
	'enable keyboard
	MOUSE_WAIT(1)
	outb(&h64,&hae)
	MOUSE_READ()
end sub



sub MOUSE_WAIT(a_type as integer)
	dim counter as integer
	counter=_time_out
	dim b as unsigned byte
	if(a_type=0) then
		do
			inb(&h64,[b])
			counter-=1
		loop until (b and 1 = 1) or counter=0
		
		'do:loop until (inb(&h64) and 1)=1 
		'exit sub
	end if
	if (a_type=1) then
		do
			inb(&h64,[b])
			counter-=1
		loop until (b and 2 = 0) or counter=0
	end if
END sub


sub MOUSE_WRITE(b as byte)
	MOUSE_WAIT(1)
	outb(&h64,&hd4)
	MOUSE_WAIT(1)
	outb(&h60,[b])
end SUB

function MOUSE_READ() as byte
	MOUSE_WAIT(0)
	inb(&h60,[function])
	'return inb(&h60)
end function

sub MOUSE_DATA_ARIVED(b as byte)
	select case MOUSE_CYCLE
        case (0)
			MOUSE_BYTE(0) = b
			if ((MOUSE_BYTE(0) AND &h08)=&h08) then MOUSE_CYCLE = MOUSE_CYCLE+1
		case (1)
			MOUSE_BYTE(1) = b
			MOUSE_CYCLE = MOUSE_CYCLE+1
		case (2)
			MOUSE_BYTE(2) = b
			MOUSE_CYCLE = MOUSE_CYCLE+1
			MOUSE_SET_DATA()
	end select
	MOUSE_CYCLE = MOUSE_CYCLE mod 3
end sub

sub MOUSE_SET_DATA()
	OldMouseB=MouseB
	OldMouseX=MouseX
	OldMouseY=MouseY
	
	
	dim rel_x as integer
	dim rel_y as integer
	
	MouseB=mouse_byte(0) AND 7
	if (mouse_byte(1)<>0) then
		rel_x=(mouse_byte(1))
		if ((mouse_byte(0) AND &h10)=&h10) then rel_x=rel_x or &hFFFFFF00
		MouseX =MouseX+ rel_x
		if (mousex<0) then MouseX=0
		if (mousex>=MouseMaxX) then MouseX=MouseMaxX
	end if
	if (mouse_byte(2)<>0) then
		rel_y = (mouse_byte(2))
		if ((mouse_byte(0) AND &h20)=&h20) then rel_y=rel_y or &hFFFFFF00
		MouseY =MouseY - rel_y
		if (mousey<0) then MouseY=0
		if (mousey>=MouseMaxY) then MouseY=MouseMaxY
	end if
    MouseUpdated = 1
    if (GuiThread<>0) then
        if (GuiThread->State = ThreadState.waiting) then Scheduler.SetThreadReady(GuiThread,0)
    end if
end sub