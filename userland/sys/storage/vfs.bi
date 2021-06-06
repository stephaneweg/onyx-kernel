
TYPE VFSDirectoryEntry field = 1
    FileName(0 to 255) as unsigned byte
    EntryType as unsigned integer
    Size as unsigned integer
End Type

    
type FS_RESSOURCE FIELD=1
	Disk as BlockDevice ptr
	LOAD_FILE as function(ressource as FS_RESSOURCE ptr,filename as unsigned byte ptr,size as unsigned integer ptr) as unsigned byte ptr
    WRITE_FILE as function(ressource  as FS_RESSOURCE ptr,filename as unsigned byte ptr,size as unsigned integer,buffer as unsigned byte ptr) as unsigned integer
    DELETE_FILE as function(ressource  as FS_RESSOURCE ptr,filename as unsigned byte ptr) as unsigned integer
    CREATE_DIR as function(ressource  as FS_RESSOURCE ptr,path as unsigned byte ptr) as unsigned integer
    LIST_DIR as function(ressource  as FS_RESSOURCE ptr,path as unsigned byte ptr,entrytype as unsigned integer,dst as VFSDirectoryEntry ptr,skip as unsigned integer,count as unsigned integer) as unsigned integer
    
end type


type FS_DESCRIPTOR FIELD=1
	FS_NAME as byte ptr
    FormatMethod as sub(disk as BlockDevice ptr)
	SelectMethod as function(disk as BlockDevice ptr, parametre as byte ptr)  as FS_RESSOURCE ptr
	NextDescriptor as FS_DESCRIPTOR ptr
end type

type VFS_ENTRY FIELD=1
	PATH as byte ptr
	FileSystem as FS_RESSOURCE ptr
	Disk as BlockDevice ptr
    declare function DELETE_FILE(filename as unsigned byte ptr) as unsigned integer
	declare function LOAD_FILE(filename as unsigned byte ptr,filesize as unsigned integer ptr) as unsigned byte ptr
    declare function WRITE_FILE(filename as unsigned byte ptr,filesize as unsigned integer,buffer as unsigned byte ptr) as unsigned integer
    declare function CREATE_DIR(path as unsigned byte ptr) as unsigned integer
    declare function LIST_DIR(path as unsigned byte ptr,entrytype as unsigned integer,dst as VFSDirectoryEntry ptr,skip as unsigned integer,count as unsigned integer) as unsigned integer
	
	NextEntry as VFS_Entry ptr
end type

type VFS_DIRECTORY_ENTRY FIELD=1
    EntryType as unsigned integer
    NAME as unsigned byte ptr
    Size as unsigned integer
end type



dim shared FS_DESCRIPTORS as FS_DESCRIPTOR ptr
dim shared FS_ENTRIES as VFS_ENTRY ptr

declare sub VFS_INIT()
declare sub VFS_SHOW_DESCRIPTORS()
declare sub VFS_ADD_FS_DESCRIPTOR(descr as FS_DESCRIPTOR ptr)
declare sub VFS_FORMAT(diskname as byte ptr,filesystemname as byte ptr)
declare sub VFS_MOUNT(diskName as byte ptr,fileSystemName as byte ptr, path as byte ptr)
declare function VFS_GET_FILE_SYSTEM_BY_NAME(fileSystemName as byte ptr) as FS_DESCRIPTOR ptr
declare function VFS_LOAD_FILE(filename as unsigned byte ptr,filesize as unsigned integer ptr) as unsigned byte ptr
declare function VFS_DELETE_FILE(filename as unsigned byte ptr) as unsigned integer
declare function VFS_WRITE_FILE(filename as unsigned byte ptr,filesize as unsigned integer, buffer as unsigned byte ptr) as unsigned integer
declare function VFS_CREATE_DIR(path as unsigned byte ptr) as unsigned integer
declare function VFS_LIST_DIR(path as unsigned byte ptr,entrytype as unsigned integer,dst as VFSDirectoryEntry ptr,skip as unsigned integer,count as unsigned integer) as unsigned integer
