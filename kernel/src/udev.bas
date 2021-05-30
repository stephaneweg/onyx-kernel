sub UDEV_INIT()
    UserModeDevices = 0
end sub


sub UserModeDevice.Create(n as unsigned byte ptr,th as Thread ptr,descr as unsigned integer, entryPoint as unsigned integer)
    dim dev as UserModeDevice ptr= Malloc(sizeof(UserModeDevice))
    dev->Name = Malloc(strlen(n)+1):strcpy(dev->Name,n)
    dev->OwnerThread = th
    dev->Descriptor = descr
    dev->Entry = entryPoint
    dev->NextDev = UserModeDevices
    UserModeDevices = dev
    ConsoleWrite(@"UDEV : Device ")
    ConsoleWrite(dev->Name)
    ConsoleWriteLine(@" created")
end sub

function UserModeDevice.Find(n as unsigned byte ptr) as unsigned integer
    var dev = UserModeDevices
    while dev<>0
        if (strcmp(dev->Name,n)=0) then return dev->Descriptor
        dev=dev->NextDev
    wend
    return 0
end function

function UserModeDevice.Invoke(d as unsigned integer,callerTHread as Thread ptr,param1 as unsigned integer,param2 as unsigned integer,param3 as unsigned integer,param4 as unsigned integer) as unsigned integer
    var dev = UserModeDevices
    
    while dev<>0
        if (dev->Descriptor=d) then
            if (dev->OwnerThread->State=THreadState.Waiting) then
                dev->OwnerThread->ReplyTo = callerThread
                callerThread->ReplyFrom = dev->OwnerThread
                callerThread->State=ThreadState.WaitingReply
                XappSignal6Parameters(dev->OwnerThread,dev->Entry,dev->Descriptor,cuint(callerThread),param1,param2,param3,param4)
            
                return 1
            else 'to do:implement a pool
            end if
        end if
        dev=dev->NextDev
    wend
    return 0
end function