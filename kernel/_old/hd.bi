type PARTINFO field=1
	bootflag as unsigned byte
	head as unsigned byte
	geom as unsigned short
	id as unsigned byte
	endhead as unsigned byte
	endgeom as unsigned short
	startpos as unsigned integer
	nbrsect as unsigned integer
end type



declare sub HD_INIT()
declare sub HD_DETECT(pbase as unsigned short)
declare sub DETECT_PARTITIONS(dev as BlockDevice ptr)
declare function HD_READ_SECTOR(drivenum as unsigned byte,lba as unsigned integer,sectorcount as unsigned short,b as byte ptr) as unsigned integer
declare function HD_WRITE_SECTOR(drivenum as unsigned byte,lba as unsigned integer,sectorcount as unsigned short,b as byte ptr) as unsigned integer
declare sub HD_WAIT(disknum as unsigned short)
declare function HD_READ(res as BlockDevice ptr, lba as unsigned integer,sectorcount as unsigned short, b as byte ptr) as unsigned integer
declare function HD_WRITE(res as BlockDevice ptr, lba as unsigned integer,sectorcount as unsigned short, b as byte ptr) as unsigned integer
