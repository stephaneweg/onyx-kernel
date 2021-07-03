type FAT_BOOTSECTOR FIELD=1
	JMPCODE(0 to 2) as unsigned byte
	OEM_NAME(0 to 7) as unsigned byte
	BPS as unsigned short
	SPC as unsigned byte
	reserved_sectors as unsigned short
	fat_count as unsigned byte
	root_dir_ent as unsigned short
	sectors_count as unsigned short
	media_descriptor as unsigned byte
	spf as unsigned short
	spt as unsigned short
	heads as unsigned short
	hidden as unsigned integer
	sectors_count2 as unsigned integer
end TYPE

type BS16 FIELD=1
	drive_num as unsigned byte
	reserved as unsigned byte
	signature as unsigned byte
	serial_num as unsigned integer
	volume_name(0 to 10) as unsigned byte
	fs_type(0 to 7) as unsigned byte
end type

type BS32 FIELD=1
	spf as unsigned integer
	mirror_flags as unsigned short
	fs_version as unsigned short
	root_cluster as unsigned integer
	fs_info as unsigned short
	backup_boot_sector as unsigned short
	reserved(0 to 11) as unsigned byte
	drive_num as unsigned byte
	reserved2 as unsigned byte
	signature as unsigned byte
	serial_num as unsigned integer
	volume_name(0 to 10) as unsigned byte
	fs_type(0 to 7) as unsigned byte
end type

type FAT_ENTRY FIELD=1
	Entry_Name(0 to 7) as unsigned byte
	ext(0 to 2) as unsigned byte
	attrib as unsigned byte
	reserved as unsigned byte
	creatime_sec as unsigned byte
	creatime as unsigned short
	creadate as unsigned short
	accessdate as unsigned short
	clusternum_high as unsigned short
	modiftime as unsigned short
	modifdate as unsigned short
	clusternum_low as unsigned short
	size as unsigned integer
end type

TYPE FATFS_DESCRIPTOR field = 1
    disk            as BlockDevice ptr
    FAT_DirectoryBuffer as unsigned byte ptr
    FAT_TYPE        as unsigned byte
    SECTOR_COUNT    as unsigned integer
    
    reserved_sectors as unsigned short
	root_dir_count as unsigned short
	bytes_per_sector as unsigned short
	sector_per_cluster as unsigned byte
	root_dir_sectors as unsigned integer
	fat_count as unsigned integer
	fat_sectors as unsigned integer
	data_sectors as unsigned integer
	total_clusters as unsigned integer
	first_data_sector as unsigned integer
	first_fat_sector as unsigned integer
	root_cluster as unsigned integer
	fat_limit  as unsigned integer
	
	current_clusternum as unsigned integer
	IsDirty as unsigned integer
    
    FAT_TABLE as unsigned byte ptr
    FAT_TABLE_PCOUNT as unsigned integer
    
    declare function    Absolute_sector(cluster as unsigned integer) as unsigned integer
    declare function    find(fname as unsigned byte ptr,attrib as unsigned byte ,repertoire as FAT_ENTRY ptr) as unsigned integer
    declare function    find_entry(fichier as byte ptr,first_cluster as unsigned integer,entnum as unsigned integer ptr,cnum as unsigned integer ptr,fsize as unsigned integer ptr,entrytype as unsigned byte) as unsigned integer
    declare function    find_fatentry(N as unsigned integer) as unsigned integer

    declare sub         WRITE_ROOT(src as FAT_ENTRY ptr)
    declare sub         READ_ROOT(dst as FAT_ENTRY ptr)
    declare sub         READ_CHAIN(clusternum as unsigned integer, dst as unsigned byte ptr)
    declare sub         WRITE_CHAIN(clusternum as unsigned integer,src as unsigned byte ptr)
    declare function    READ_NEXT_CLUSTER(clusternum as unsigned integer,dst as unsigned byte ptr) as unsigned integer

    declare function    Find_Free_Cluster() as unsigned integer
    declare sub         Set_Cluster(N as unsigned integer, value as unsigned integer)
    declare function    Alloc_Cluster() as unsigned integer
    declare sub         FREE_CLUSTER(n as unsigned integer)

END TYPE


declare function STR2FAT(texte as unsigned byte ptr,buffer as unsigned byte ptr) as integer
declare sub FAT_MOUNT(dev as unsigned byte ptr,path as unsigned byte ptr)
declare function FATFS_OPEN(fat as FATFS_DESCRIPTOR ptr,path as unsigned byte ptr,mode as unsigned integer) as unsigned integer
declare function FATFS_CLOSE(handle as unsigned integer,descr as any ptr) as unsigned integer
declare function FATFS_READ(handle as unsigned integer,descr as any ptr,count as unsigned integer,dest as  unsigned byte ptr) as unsigned integer
declare function FATFS_WRITE(handle as unsigned integer,descr as any ptr,count as unsigned integer,src as unsigned byte ptr) as unsigned integer
declare function FATFS_SEEK(handle as unsigned integer,descr as any ptr,p as unsigned integer,m as unsigned integer) as unsigned integer
declare function FATFS_UMOUNT(fat as FATFS_DESCRIPTOR ptr) as unsigned integer

declare function FATFS_OPENREAD(fat as FATFS_DESCRIPTOR ptr,path as unsigned byte ptr) as unsigned integer
declare function FATFS_OPENWRITE(fat as FATFS_DESCRIPTOR ptr,path as unsigned byte ptr,appendMode as unsigned integer) as unsigned integer

