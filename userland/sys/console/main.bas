
#include once "stdlib.bi"
#include once "system.bi"
#include once "slab.bi"
#include once "console.bi"

#include once "stdlib.bas"
#include once "system.bas"
#include once "slab.bas"
#include once "console.bas"

#include once "vconsole.bi"
dim shared TmpString as unsigned byte ptr

#include once "vconsole.bas"

declare sub int31Handler(_intno as unsigned integer,_senderproc as unsigned integer,_sender as unsigned integer,_eax as unsigned integer,_ebx as unsigned integer,_ecx as unsigned integer,_edx as unsigned integer,_esi as unsigned integer,_edi as unsigned integer,_ebp as unsigned integer)

sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    SlabInit()
    Consoles = 0
    TmpString = MAlloc(2048)
    MemSet(TmpString,0,2048)
    SysConsole = VirtConsole.CreateDisplay()
    
    DefineIRQHandler(&h31,@int31Handler,1)
    
    WaitForEvent()
    Do:loop
end sub

sub int31Handler(_intno as unsigned integer,_senderproc as unsigned integer,_sender as unsigned integer,_eax as unsigned integer,_ebx as unsigned integer,_ecx as unsigned integer,_edx as unsigned integer,_esi as unsigned integer,_edi as unsigned integer,_ebp as unsigned integer)
    var con = Virtconsole.Find(_senderproc)
    if (con=0) then 
        EndIRQHandlerAndSignal()
    end if
        
    '
    select case _EAX
        case 0
            con->PutChar(cast(unsigned byte ,_EBX))
        case 1
            GetStringFromCaller(TmpString,_EBX)
            con->Write(TmpString)
        case 2
            GetStringFromCaller(TmpString,_EBX)
            con->WriteLine(TmpString)
        case 3
            con->Write(IntToStr(_EBX,_ECX))
        case 4
            con->NewLine()
        case 5
            con->PrintOK()
        case 6
            con->BackSpace()
        case 7
            con->Foreground = _EBX
        case 8
            con->BackGround = _EBX
        case &hF
            con->Clear()
        case &hFF
            con = VirtConsole.Create(80,25)
            con->Owner = _senderProc
            _eax =cuint( MapBufferToCaller(con->Buffer,con->ConsoleWidth*con->ConsoleHeight*2))
    end select
    EndIRQHandlerAndSignal()
        
end sub