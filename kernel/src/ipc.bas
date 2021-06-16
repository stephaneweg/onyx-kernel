sub IPC_INIT()
    ConsoleWrite(@"Initializing IPC subsystem ...")
    FirstIPCEndPoint    = 0
    LastIPCEndPoint     = 0
    IPCIds              = 0
    ConsolePrintOK()
    ConsoleNewLine()
end sub


function IPCEndPoint.FindById(id as unsigned integer) as IPCEndPoint ptr
    dim ep as IPCEndPoint ptr = FirstIPCEndPoint
    while ep<>0
        if (ep->ID = id) then
            if (ep->Magic=&hFFEEFFEE) then return ep
            return 0
        end if
        ep=ep->NextEndPoint
    wend
    return 0
end function

function IPCEndPoint.FindByName(n as unsigned byte ptr) as IPCEndPoint ptr
    dim ep as IPCEndPoint ptr = FirstIPCEndPoint
    while ep<>0
        if strcmp(ep->IPCName,n)=0 then
            if (ep->Magic=&hFFEEFFEE) then return ep
            return 0
        end if
        ep=ep->NextEndPoint
    wend
    return 0
end function

function IPCEndPoint.NewID() as unsigned integer
    IPCIds+=1
    while IPCEndPoint.FindById(IPCIds)<>0
        IPCIds+=1
    wend
    return IPCIds
end function

function IPCEndPoint.CreateName(N as unsigned byte ptr,th as thread ptr,entry as unsigned integer,sync as unsigned integer) as IPCEndPoint ptr
    'if name is already used return 0
    if (IPCEndPoint.FindByName(n)<>0) then return 0
    
    dim ep as IPCEndPoint ptr = KAlloc(sizeof(IPCEndPoint))
    ep->IPCName         = KAlloc(strlen(N)+1)
    strcpy(ep->IPCName,N)
    ep->ID              = IPCEndPoint.NewID()
    
    IPCEndPoint.CreateCommon(ep,th,entry,sync)
    return ep
end function

function IPCEndPoint.CreateID(id as unsigned integer,th as thread ptr,entry as unsigned integer,sync as unsigned integer) as IPCEndPoint ptr
    if (id>=&h30 and id<=&h31) then return 0 'reserved for kernel Interrupt
    if (IPCEndPoint.FindBYId(id)<>0) then return 0'already used
    
    dim ep as IPCEndPoint ptr = KAlloc(sizeof(IPCEndPoint))
    ep->IPCName=KAlloc(5)
    strcpy(ep->IPCName,@"$$$$")
    ep->ID = id
    
    IPCEndPoint.CreateCommon(ep,th,entry,sync)
    return ep
end function

sub IPCEndPoint.CreateCommon(ep as IPCendPoint ptr,th as thread ptr,entry as unsigned integer,sync as unsigned integer)
    ep->Magic           = &hFFEEFFEE
    ep->Owner           = th
    ep->OwnerProcess    = th->Owner
    ep->Synchronous = sync
    ep->EntryPoint  = entry
    ep->Counter     = 0
    ep->FirstMessage= 0
    ep->LastMessage = 0
    
    if (LastIPCEndPoint<>0) then
        LastIPCEndPoint->NextEndPoint = ep
    else
        FirstIPCEndPoint = ep
    end if
    
    ep->NextEndPoint = 0
    ep->PrevEndPoint = LastIPCEndPoint
    LastIPCEndPoint = ep
end sub

destructor IPCMessage
    if (NextMessage<>0) then 
        NextMessage->Destructor()
        KFree(NextMessage)
    end if
    NextMessage = 0
end destructor

destructor IPCEndPoint()
    Owner->ReplyTo = 0
    
    MAGIC       = 0
    ID          = 0
    Owner       = 0
    Synchronous = 0
    EntryPoint  = 0
    Counter     = 0
    
    if (FirstIPCEndPoint    = @this) then FirstIPCEndPoint = NextEndPoint
    if (LastIPCEndPoint     = @this) then LastIPCEndPoint = PrevEndPoint
    
    if (PrevEndPoint<>0) then PrevEndPoint->NextEndPoint = NextEndPoint
    if (NextEndPoint<>0) then NextEndPoint->PrevEndPoint = PrevEndPoint
    
    if (FirstMessage<>0) then 
         FirstMessage->Destructor()
         KFree(FirstMessage)
    end if
    
    FirstMessage = 0
    LastMessage = 0
    KFree(IPCName)
    IPCName     = 0
end destructor

sub IPCEndPoint.Enqueue(msg as IPCMessage ptr)
    msg->NextMessage = 0
    if (this.LastMessage<>0)  then
        this.LastMessage->NextMessage = msg
    else
        this.FirstMessage = msg
    end if
    this.LastMessage = msg
    this.Counter += 1
end sub

function IPCEndPoint.Dequeue() as IPCMessage ptr
    if (this.FirstMessage<>0) then
        var ret = this.FirstMessage
        this.FirstMessage = this.FirstMessage->NextMessage
        if (this.FirstMessage=0) then this.LastMessage = 0
        return ret
    end if
    return 0
end function


function IPCEndPoint.ProcessReceive() as unsigned integer
    dim result as unsigned integer = 0

    
    if (Owner<>0) then
        if (Owner->State = ThreadState.Waiting) then
            
            var xmsg = Dequeue()
            if (xmsg<>0) then
                var ctx = vmm_get_current_context()
                Owner->VMM_Context->Activate()
                            
                dim st as IRQ_Stack ptr = cptr(IRQ_Stack ptr,Owner->SavedESP)
                st->EIP = EntryPoint
                st->ESP = st->ESP-44
                *cptr(unsigned integer ptr, st->ESP+4)  =ID
                *cptr(unsigned integer ptr, st->ESP+8)  =cuint(xmsg->SENDERPROCESS)
                *cptr(unsigned integer ptr, st->ESP+12) =cuint(xmsg->SENDER)
                *cptr(unsigned integer ptr, st->ESP+16) =xmsg->BODY.REG0
                *cptr(unsigned integer ptr, st->ESP+20) =xmsg->BODY.REG1
                *cptr(unsigned integer ptr, st->ESP+24) =xmsg->BODY.REG2
                *cptr(unsigned integer ptr, st->ESP+28) =xmsg->BODY.REG3
                *cptr(unsigned integer ptr, st->ESP+32) =xmsg->BODY.REG4       
                *cptr(unsigned integer ptr, st->ESP+36) =xmsg->BODY.REG5     
                *cptr(unsigned integer ptr, st->ESP+40) =xmsg->BODY.REG6     
                *cptr(unsigned integer ptr, st->ESP+44) =xmsg->BODY.REG7
                Owner->ReplyTo = cptr(Thread ptr,xmsg->Sender)
                if (ID<&h30) then
                    Scheduler.SetThreadReadyNow(Owner)
                else
                    Scheduler.SetThreadReady(Owner)
                end if
                ctx->Activate()
                
                result = 1
                KFree(xmsg)
            end if
        end if
    end if
    return result
end function

function IPCSendBody(_
    id as unsigned integer,th as Thread ptr,_
    body as IPCMessageBody ptr) as unsigned integer
    return IPCSend(id,th,BODY->REG0,BODY->REG1,BODY->REG2,BODY->REG3,BODY->REG4,BODY->REG5,BODY->REG6,BODY->REG7)
end function

function IPCSend(_
    id as unsigned integer,th as Thread ptr,_
    r0 as unsigned integer,r1 as unsigned integer,r2 as unsigned integer,r3 as unsigned integer,_
    r4 as unsigned integer,r5 as unsigned integer,r6 as unsigned integer,r7 as unsigned integer) as unsigned integer
    
    dim result as unsigned integer = 0
    var ipcHandler = IPCEndPoint.FindById(id)
    if (ipcHandler<>0) then
        var msg = cptr(IPCMessage ptr,KAlloc(sizeof(IPCMessage)))
        msg->BODY.REG0 = r0
        msg->BODY.REG1 = r1
        msg->BODY.REG2 = r2
        msg->BODY.REG3 = r3
        msg->BODY.REG4 = r4
        msg->BODY.REG5 = r5
        msg->BODY.REG6 = r6
        msg->BODY.REG7 = r7
        msg->SENDER = th
        if (th<>0) then
            msg->SENDERPROCESS = th->Owner
        end if
        ipcHandler->Enqueue(msg)
        result = 1
        
        'if receiver is ready for message then wake it
        if (ipcHandler->Owner->State=THreadState.Waiting) then
            if (ipcHandler->ProcessReceive()=1) then result = 2
        end if
    end if
    
    return result
end function