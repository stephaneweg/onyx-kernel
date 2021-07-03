#include once "stdlib.bi"
#include once "system.bi"
#include once "gdi.bi"
#include once "slab.bi"
#include once "file.bi"
#include once "tobject.bi"
#include once "font.bi"
#include once "fontmanager.bi"
#include once "gimage.bi"

#include once "stdlib.bas"
#include once "system.bas"
#include once "gdi.bas"
#include once "slab.bas"
#include once "file.bas"
#include once "tobject.bas"
#include once "font.bas"
#include once "fontmanager.bas"
#include once "gimage.bas"

type rgb24
    b as unsigned byte
    g as unsigned byte
    r as unsigned byte
end type

dim shared mainWin as unsigned integer
dim shared drawable as GImage ptr
dim shared buff as rgb24 ptr
dim shared btnColor as unsigned integer
dim shared fireScreen as unsigned integer ptr
dim shared fcolor as unsigned integer


dim shared FPS as unsigned integer
dim shared PrevTime as unsigned integer
dim shared FrameCount as unsigned integer
declare sub btnClick(btn as unsigned integer,parm as unsigned integer)
declare sub FireThread()
declare sub FPSCounter()
declare function BCDToSeconds(b as unsigned integer) as unsigned integer

dim shared fpm as unsigned integer

dim shared totalPages as unsigned integer
dim shared freepages as unsigned integer
dim shared slabCount as unsigned integer
dim shared IDLECount as unsigned integer

sub btnClick(btn as unsigned integer,parm as unsigned integer)
    fcolor = (fcolor+1) mod 3  
    EndCallBack()
end sub

sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    SlabINIT()
    FPM = 900/60
    FontManager.Init()
    FrameCount = 0
    FPS=0
	fcolor = 1
	MainWin = GDIWindowCreate(320,240,@"Fire demo")
	GDISetVisible(MainWin,0)
    drawable = cptr(GImage ptr,MAlloc(sizeof(GImage)))
    
    drawable->Constructor(MainWin,0,0,320,200)
    
    
    GDIButtonCreate(MainWin,0,205,80,30,@"Color",@btnClick,0)
    
    
    drawable->Clear(&hFF000000)
    drawable->Flush()
    CreateThread(@FPSCounter,3)
    CreateThread(@FireThread,3)
	GDISetVisible(MainWin,1)
    WaitForEvent()
end sub



sub FPSCounter()

   
    do
        GetMemInfo(@totalPages,@freepages,@slabCount)
        FPS = FrameCount
		FrameCount = 0
        IDLECount = IDLE_COUNT()
        WaitN(1000)
    loop
end sub

function BCDToSeconds(b as unsigned integer) as unsigned integer
    var sec1 = b and   &h0000000F
    var sec2 = b and  (&h000000F0 shr 4) * 10
    var min1 = b and  (&h00000F00 shr 8) * 60
    var min2 = b and  (&h0000F000 shr 12) * 600
    var hour1 = b and (&h000F0000 shr 16) * 3600
    var hour2 = b and (&h00F00000 shr 20) * 36000
    
    return sec1 + sec2 + min1+min2 + hour1+hour2
end function

sub FireThread()
	buff = malloc(sizeof(unsigned integer)*320*200)
    fireScreen = cptr(unsigned integer ptr,malloc(&h100000))
    dim FireSeed as unsigned integer = &h1234
    dim firetype as unsigned integer = 0
    dim firedelay as unsigned integer = 1
    dim firecalc as unsigned integer = 0
   
    dim firescreenLimit as unsigned integer=cast(unsigned integer,fireScreen)+&h2000
    
    dim tbegin as unsigned longint
    dim tend as unsigned longint
    dim tdiff as unsigned longint
    
    do
        tbegin = GetTimer()
        asm
        
        
        mov  esi, [FireScreen]
        add  esi, 0x2300
        sub  esi, 80
        mov  ecx, 80
        xor  edx, edx
       
      NEWLINE:
       
        mov  eax,dword [FireSeed]                '; New number
        mov  edx, 0x8405
        mul  edx
        inc  eax
        mov  dword [FireSeed], eax               '; Store seed
       
        mov  [esi], dl
        inc  esi
        dec  ecx
        jnz  NEWLINE
       
        mov  ecx, 0x2300
        sub  ecx, 80
        mov  esi, [fireScreen]
        add  esi, 80
       
      FIRELOOP:
       
        xor  eax,eax
        mov ebx,[firetype]
        cmp  ebx,0
        jnz  notype1
        mov  al, [esi]
        add  al, [esi + 2]
        adc  ah, 0
        add  al, [esi + 1]
        adc  ah, 0
        add  al, [esi + 81]
        adc  ah, 0
      notype1:
       
        cmp  ebx, 1
        jnz  notype2
        mov  al, [esi]
        add  al, [esi - 1]
        adc  ah, 0
        add  al, [esi - 1]
        adc  ah, 0
        add  al, [esi + 79]
        adc  ah,0
      notype2:
       
        cmp  ebx, 2
        jnz  notype3
        mov  al, [esi]
        add  al, [esi - 1]
        adc  ah,0
        add  al, [esi + 1]
        adc  ah, 0
        add  al, [esi + 81]
        adc  ah,0
      notype3:
       
        shr  eax, 2
        jz   ZERO
        dec  eax
       
      ZERO:
       
        mov byte [esi - 80], al
        inc  esi
        dec  ecx
        jnz  FIRELOOP
       
        pusha
   
        
        mov  eax, [firecalc]
        inc  eax
        mov  [firecalc],al
        cmp  al, 2
        jz   pdraw
       
        jmp  nodrw
        
      pdraw:
        xor eax,eax    
        mov  [firecalc],eax
        
        cld
        mov  edi,[buff]
        xor eax,eax
        mov  ecx,320*200*3
        rep  stosb
        
        
        mov  edi,[buff]
        add  edi,[fcolor]
        mov  esi,[fireScreen]
        xor  edx,edx
       
      newc:
        
        xor   eax,eax
        mov   al,byte [esi]
        mov   ebx,eax
        mov   ecx,eax
        shl   ax,8
        shr   bx,1
        mov   al,bl
        add   ecx,eax
        shl   ax,8
        mov   ch,ah
       
        mov  [edi+0],cx
        mov  [edi+3],cx
        mov  [edi+6],cx
        mov  [edi+9],cx
        mov  [edi+0+320*3],cx
        mov  [edi+3+320*3],cx
        mov  [edi+6+320*3],cx
        mov  [edi+9+320*3],cx
       
        add  edi,12
        inc  edx
        cmp  edx,80
        jnz  nnl
        xor  edx,edx
        add  edi,320*3
      nnl:
        inc  esi
        cmp  esi,[firescreenLimit]
        jnz  newc
    end asm
    frameCount+=1
    
    ConvertBuffer24TO32(drawable->_buffer,buff,drawable->_width*drawable->_height)
    
    drawable->DrawText(@"FPS : ",5,5,&hFFFFFF,FontManager.ML,1)
    drawable->DrawText(IntToStr(fps,10),60,5,&hFFFFFF,FontManager.ML,1)

    drawable->DrawText(@"Total pages : ",5,25,&hFFFFFF,FontManager.ML,1)
    drawable->DrawText(IntToStr(totalPages,10),150,25,&hFFFFFF,FontManager.ML,1)
    
    drawable->DrawText(@"Free pages : ",5,45,&hFFFFFF,FontManager.ML,1)
    drawable->DrawText(IntToStr(FreePages,10),150,45,&hFFFFFF,FontManager.ML,1)
    
    drawable->DrawText(@"IDLE : ",5,65,&hFFFFFF,FontManager.ML,1)
    drawable->DrawText(IntToStr(IDLECount,10),150,65,&hFFFFFF,FontManager.ML,1)
    drawable->Flush()
    'ThreadYield()
    
    tend = GetTimer()
    tdiff = tend-tbegin
    if (tdiff<fpm) then
        WaitN(fpm-tdiff)
    end if
    asm
      nodrw:
        popa
    end asm
    loop
    
end sub