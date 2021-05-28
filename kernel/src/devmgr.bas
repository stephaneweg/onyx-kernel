dim shared Devices as Device ptr
sub DEVMGR_INIT()
    ConsoleWrite(@"Devices Manager initializing")
    Devices=0
    ConsolePrintOK()
    ConsoleNewLine()
end sub


function DEVMGR_FIND(diskname as byte ptr) as Device ptr
	dim dev as Device ptr
	dim cpt as integer
	dev = Devices
	while(dev<>0)
		cpt=0
		while (diskName[cpt]<>0) and (dev->RessourceName[cpt]<>0) and (diskName[cpt]=dev->RessourceName[cpt])
			cpt +=1
		wend
		if diskName[cpt]=dev->RessourceName[cpt] then return dev
		dev=dev->NextDevice
	wend
	return 0
end function

function DEVMGR_CREATE_DEVICE(devName as unsigned byte ptr) as Device ptr
    var newDev=cptr(Device ptr,KAlloc(sizeof(Device)))
    newDev->Constructor()
    newDev->RessourceName=devName
	newDev->NextDevice = Devices
	Devices = newDev
    return newDev
end function

function DEVMGR_CREATE_IO_DEVICE(devName as unsigned byte ptr) as IODevice ptr
    var newDev=cptr(IODevice ptr,KAlloc(sizeof(IODevice)))
    newDev->Constructor()
    newDev->RessourceName=devName
    newDev->NextDevice = Devices
	Devices = newDev
    return newDev
end function

function DEVMGR_CREATE_CHAR_DEVICE(devName as unsigned byte ptr) as CharDevice ptr
    var newDev=cptr(CharDevice ptr,KAlloc(sizeof(CharDevice)))
    newDev->Constructor()
    newDev->RessourceName=devName
    newDev->NextDevice = Devices
	Devices = newDev
    return newDev
end function

function DEVMGR_CREATE_BLOCK_DEVICE(devName as unsigned byte ptr) as BlockDevice ptr
    var newDev=cptr(BlockDevice ptr,KAlloc(sizeof(BlockDevice)))
    newDev->Constructor()
    newDev->RessourceName=devName
    newDev->NextDevice = Devices
	Devices = newDev
    return newDev
end function



