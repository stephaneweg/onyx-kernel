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

type FAT_FS_RESSOURCE extends FS_RESSOURCE FIELD=1
	FAT_TYPE as unsigned byte
	SECTOR_COUNT as unsigned integer
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
	fat_table as unsigned byte ptr
	current_dir as FAT_ENTRY ptr
	current_clusternum as unsigned integer
	IsDirty as unsigned integer
	
	declare sub READ_ROOT(dst as FAT_ENTRY ptr)
	declare sub READ(custernum as unsigned integer,dst as unsigned byte ptr)
    declare sub WRITE_ROOT(dst as FAT_ENTRY ptr)
    declare sub WRITE(clusternum as unsigned integer,buffer as unsigned byte ptr)
    
    declare sub Set_Cluster(N as unsigned integer, value as unsigned integer)
    declare function Find_Free_Cluster()as unsigned integer
    declare function Alloc_Cluster(count as unsigned integer) as unsigned integer
    declare function Free_Cluster(n as unsigned integer) as unsigned integer
	declare function absolute_sector(cluster as unsigned integer) as unsigned integer
    
    declare function Count_Rep(repertoire as FAT_ENTRY ptr) as unsigned integer
	declare function find_fatentry(N as unsigned integer) as unsigned integer
	declare function find(fname as unsigned byte ptr,attrib as unsigned byte ,repertoire as FAT_ENTRY ptr) as unsigned integer
	declare function find_entry(fichier as byte ptr,first_cluster as unsigned integer,entnum as unsigned integer ptr,cnum as unsigned integer ptr,fsize as unsigned integer ptr,entrytype as unsigned byte) as unsigned integer
    declare function Find_Rep(repertoire as unsigned byte ptr,first_cluster as unsigned integer,entnum as unsigned integer ptr,cnum as unsigned integer ptr,count as unsigned integer ptr) as long
end type


declare sub FAT_INIT()
declare sub FAT_FORMAT(disk as blockDevice ptr)
declare function FAT_SELECT(disk as BlockDevice ptr, parametre as byte ptr) as FS_RESSOURCE ptr
declare function STR2FAT(str1 as unsigned byte ptr,buffer as unsigned byte ptr) as integer
declare function FAT2STR(str1 as unsigned byte ptr,buffer as unsigned byte ptr) as unsigned byte ptr
declare function fat_loadfile(ressource  as FS_RESSOURCE ptr,fichier as unsigned byte ptr,size as unsigned integer ptr) as unsigned byte ptr
declare function FAT_WRITEFILE(ressource  as FS_RESSOURCE ptr,fichier as unsigned byte ptr,taille as unsigned integer,buffer as unsigned byte ptr) as unsigned integer
declare function Fat_ListDir(ressource  as FS_RESSOURCE ptr,path as unsigned byte ptr,entrytype as unsigned integer,dst as VFSDirectoryEntry ptr,skip as unsigned integer,count as unsigned integer) as unsigned integer

declare sub FatFS_WriteSectors(disk as BlockDevice ptr,lba as unsigned integer,nbrBlocs as unsigned integer,buffer as unsigned byte ptr)
declare sub FatFS_ReadSectors(disk as BlockDevice ptr,lba as unsigned integer,nbrBlocs as unsigned integer,buffer as unsigned byte ptr)