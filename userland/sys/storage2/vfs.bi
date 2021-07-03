TYPE VFSDirectoryEntry field = 1
    FileName(0 to 255) as unsigned byte
    EntryType as unsigned integer
    Size as unsigned integer
End Type

TYPE VFS_NODE FIELD=1
    MAGIC as unsigned integer
    PATH as unsigned byte ptr
    HANDLE as unsigned integer
    
    OPEN_METHOD     as function(handle as unsigned integer,p as unsigned byte ptr,mode as unsigned integer) as unsigned integer
    READ_METHOD     as function(handle as unsigned integer,descriptor as unsigned integer,count as unsigned integer,dest as any ptr) as unsigned integer
    WRITE_METHOD    as function(handle as unsigned integer,descriptor as unsigned integer,count as unsigned integer,src as any ptr) as unsigned integer
    CLOSE_METHOD    as function(handle as unsigned integer,descriptor as unsigned integer) as unsigned integer
    LS_METHOD       as function(handle as unsigned integer,path as unsigned byte ptr,entrytype as unsigned integer,dst as VFSDirectoryEntry ptr,skip as unsigned integer,count as unsigned integer) as unsigned integer
    DELETE_METHOD   as function(handle as unsigned integer,p as unsigned byte ptr) as unsigned integer
    SEEK_METHOD       as function(handle as unsigned integer,descriptor as unsigned integer,p as unsigned integer,mode as unsigned integer) as unsigned integer
    UMOUNT_METHOD   as function(handle as unsigned integer) as unsigned integer
    NEXT_NODE as VFS_NODE ptr
    PREV_NODE as VFS_NODE ptr
    
end TYPE

TYPE VFS_DESCRIPTOR field=1
    MAGIC as unsigned integer
    VFS as VFS_NODE ptr
    HANDLE as unsigned integer
end type

TYPE VFS_FILE_DESCRIPTOR field = 1
    MAGIC               as unsigned integer
    END_OF_FILE         as unsigned integer
    FPOS                as unsigned integer
    FSIZE               as unsigned integer
end type

#define VFS_NODE_MAGIC &h43214321
#define VFS_DESCRIPTOR_MAGIC &h12341234
#define VFS_FILE_DESCRIPTOR_MAGIC &h33333333

dim shared VFS_FIRST_NODE as VFS_NODE ptr
dim shared VFS_LAST_NODE as VFS_NODE ptr
dim shared VFS_ERR as unsigned integer

declare sub VFS_INIT()
declare function VFS_CMP(s1 as unsigned byte ptr,s2 as unsigned byte ptr) as unsigned integer
declare function VFS_FIND_NODE(path as unsigned byte ptr) as VFS_NODE ptr
declare function VFS_MKNOD(path as unsigned byte ptr,_
    handle as unsigned integer,_
    open_method as any ptr,_
    close_method as any ptr,_
    read_method as any ptr,_
    write_method as any ptr,_
    file_seek_method as any ptr,_
    ls_method as any ptr,_
    delete_method as any ptr,_
    umount_method as any ptr) as unsigned integer
    
declare function VFS_DUMMY_OPEN(handle as unsigned integer,p as unsigned byte ptr) as unsigned integer
declare function VFS_FILE_EXISTS(p as unsigned byte ptr) as unsigned integer
declare function VFS_OPEN(path as unsigned byte ptr,mode as unsigned integer) as VFS_DESCRIPTOR ptr
declare sub VFS_CLOSE(n as VFS_DESCRIPTOR ptr)
declare function VFS_SEEK(descr as VFS_DESCRIPTOR ptr,p as unsigned integer,m as unsigned integer) as unsigned integer
declare function VFS_READ(descr as VFS_DESCRIPTOR ptr,count as unsigned integer,buffer as any ptr) as unsigned integer
declare function VFS_WRITE(descr as VFS_DESCRIPTOR ptr,count as unsigned integer,buffer as any ptr) as unsigned integer
declare function VFS_READBYTE(descr as VFS_DESCRIPTOR ptr) as unsigned byte
declare function VFS_READSHORT(descr as VFS_DESCRIPTOR ptr) as unsigned short
declare function VFS_READINTEGER(descr as VFS_DESCRIPTOR ptr) as unsigned integer
declare function VFS_READLONG(descr as VFS_DESCRIPTOR ptr) as unsigned longint
declare function VFS_PARENTPATH(path as unsigned byte ptr) as unsigned byte ptr
declare function VFS_FILENAME(path as unsigned byte ptr) as unsigned byte ptr
declare function VFS_EOF(descr as VFS_DESCRIPTOR ptr) as unsigned integer
declare function VFS_WRITELINE(descr as VFS_DESCRIPTOR ptr,txt as unsigned byte ptr) as unsigned integer
declare function VFS_WRITESTRING(descr as VFS_DESCRIPTOR ptr,txt as unsigned byte ptr) as unsigned integer
declare function VFS_WRITEBYTE(descr as VFS_DESCRIPTOR ptr,b as unsigned byte) as unsigned integer
declare function VFS_UMOUNT(p as unsigned byte ptr) as unsigned integer
declare function VFS_FSIZE(descr as VFS_DESCRIPTOR ptr) as unsigned integer
declare function VFS_INPUT(descr as VFS_DESCriPTOR ptr) as unsigned byte ptr

declare function VFS_WRITE_FILE(filename as unsigned byte ptr,filesize as unsigned integer, buffer as unsigned byte ptr) as unsigned integer
declare function VFS_LOAD_FILE(filename as unsigned byte ptr,filesize as unsigned integer ptr) as unsigned byte ptr
    
declare function VFS_LIST_DIR(path as unsigned byte ptr,entrytype as unsigned integer,dst as VFSDirectoryEntry ptr,skip as unsigned integer,count as unsigned integer) as unsigned integer