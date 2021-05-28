
dim shared keymapPtr as unsigned integer ptr
dim shared KEYMAP as unsigned byte ptr
dim shared KEYMAP_ALT as unsigned byte ptr
dim shared KEYMAP_SHIFT as unsigned byte ptr

dim shared NextArrow as unsigned byte

sub loadKeys()
    dim kmapsize as unsigned integer
    ConsoleWrite(@" Loading Keymap ... ")
    keymapPtr =cptr(unsigned integer ptr, VFS_LOAD_FILE(@"SYS:/KEYS/FR.MAP",@kmapsize))
    
    if (kmapsize=0 or keymapPtr = 0) then
        ConsoleWrite(@"Failed")
    else
        var kmapBase = cast(unsigned integer,keymapPtr)
        KEYMAP = cptr(unsigned byte ptr, keymapPtr[0] + kmapBase)
        KEYMAP_ALT = cptr(unsigned byte ptr, keymapPtr[1] + kmapBase)
        KEYMAP_SHIFT = cptr(unsigned byte ptr, keymapPtr[2] + kmapBase)
        
        KBD_CTRL=0
        KBD_ALT=0
        KBD_SHIFT=0
        KBD_CIRC=0
        KBD_GUILLEMETS=0
        KEYBOARD_Loaded = 1
        ConsoleWrite(@"OK")
    end if
end sub

sub INIT_KBD()
    ConsoleWrite(@"Keyboard Driver starting ...")
    loadKeys()
    dim akey as unsigned byte = 0
    do
        inb(&h60,[akey])
    loop while akey = 0
	
	IRQ_ATTACH_HANDLER(&h21,@KBD_INT_HANDLER)
    ConsolePrintOK()
    ConsoleNewLine()
    
end sub

function KBD_INT_HANDLER(stack as IRQ_Stack ptr) as IRQ_Stack ptr
    'ConsoleWriteLine(@"Key pressed")
    dim akey as unsigned byte
	inb(&h60,[akey])
    KBD_HANDLER(akey)
    if (GuiThread<>0) then
        if (GuiThread->State = ThreadState.waiting) then Scheduler.SetThreadReady(GuiThread,0)
    end if
	return stack
end function

sub KBD_PutChar(char as unsigned byte)
    if (KBD_BUFFERPOS<255) then
        KBD_BUFFER(KBD_BUFFERPOS) = char
        KBD_BUFFERPOS+=1
    end if
end sub

sub KBD_FLUSH()
	KBD_BUFFERPOS=0
end sub

function KBD_GetChar() as unsigned byte
    if (KBD_BUFFERPOS>0) then
        dim k as unsigned byte = KBD_BUFFER(0)
		KBD_BUFFERPOS-=1
		dim i as integer
		for i = 0 to KBD_BUFFERPOS
			KBD_BUFFER(i)=KBD_BUFFER(i+1)
		next
'        MemCpy(@KBD_BUFFER(0),@KBD_BUFFER(1),255)
        return k
    end if
    return 0
end function



sub KBD_HANDLER(akey as unsigned byte)
    if (akey=224) then
        NextArrow = 128
    else
        select case akey
            case KEY_CTRL:
                KBD_CTRL=1
            case KEY_CTRL+128:
                KBD_CTRL=0
            case KEY_ALT:
                KBD_ALT=1
            case KEY_ALT+128:
                KBD_ALT=0
            case KEY_SHIFT1:
                KBD_SHIFT=1
            case KEY_SHIFT2:
                KBD_SHIFT=2
            case KEY_SHIFT1+128:
                KBD_SHIFT=KBD_SHIFT AND 2
            case KEY_SHIFT2+128:
                KBD_SHIFT=KBD_SHIFT AND 1
            case else:
                if akey<128 then
                    
                    dim k as unsigned byte=0
                    if KBD_SHIFT>0 then 
                        k=KEYMAP_SHIFT[akey]
                    elseif KBD_ALT>0 then
                        k=KEYMAP_ALT[akey]
                    else
                        k=KEYMAP[akey]
                    end if
                    
                    
                    if k=94 then
                        KBD_CIRC=1
                        k=0
                    elseif k=249 then
                        KBD_GUILLEMETS=1
                        k=0
                    else
                        if KBD_CIRC=1 then
                            select case k
                            case 97: k=131 'â
                            case 101:k=136 'ê
                            case 105:k=140 'î
                            case 111:k=147 'ô
                            case 117:k=150 'û
                            end select
                        elseif KBD_GUILLEMETS=1 then
                            select case k
                            case 97: k=132 'ä
                            case 101:k=137 'ë
                            case 105:k=139 'ï
                            case 111:k=148 'ö
                            case 117:k=129 'ü
                            end select
                        end if
                        KBD_CIRC=0
                        KBD_GUILLEMETS=0
                    end if
                    
                    
                    if (k<>0) then 
                        'ConsolePutChar(k)
                        KBD_PutChar(k or NextArrow)
                    end if
                end if
        end select
        NextArrow = 0
    end if
end sub