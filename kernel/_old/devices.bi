type Device field=1
    RessourceName as byte ptr
    DeviceType as unsigned byte ptr
	NextDevice as Device ptr
    declare constructor()
end type

type IODevice extends Device field=1
    declare constructor()
    IOCtl as function(dev as IODevice ptr,fnNum as unsigned integer,p1 as unsigned integer,p2 as unsigned integer,p3 as unsigned integer,p4 as unsigned integer) as unsigned integer
end type

type CharDevice extends Device field=1
    declare constructor()
end type

type BlockDevice extends Device field=1
	DiskNumber as integer
	Debut as integer
	Present as integer
	SectorCount as unsigned integer
    BytesCount as unsigned integer
	declare constructor()
	Read as function(res as BlockDevice ptr,lba as unsigned integer,sectorcount as unsigned short, b as byte ptr) as unsigned integer
	Write as function(res as BlockDevice ptr,lba as unsigned integer,sectorcount as unsigned short, b as byte ptr) as unsigned integer
end type

dim shared DeviceTypeName as unsigned byte ptr=@"DEVICE"
dim shared BlockDeviceTypeName as unsigned byte ptr=@"BLOCKDEVICE"
dim shared IODeviceTypeName as unsigned byte ptr=@"IODEVICE"
dim shared CharDeviceTypeName as unsigned byte ptr=@"CHARDEVICE"
