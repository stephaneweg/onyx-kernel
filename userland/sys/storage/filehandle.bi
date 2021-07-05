enum SeekOrigin
    SeekBegin = 0,
    SeekCurrent = 1,
    SeekEnd = 2
end enum


Type FileHandle field=1
    FilePos     as integer
    FileSize    as unsigned integer
    BufferSize  as unsigned integer
    buffer      as Unsigned byte ptr
    Dirty       as integer
    Path        as TString ptr
    
    ReadMethod      as function(fd as FileHandle ptr,count as unsigned integer,dst as unsigned byte ptr) as unsigned integer
    ReadLineMethod  as function(fd as FileHandle ptr,dst as unsigned byte ptr) as unsigned integer
    WriteMethod     as sub(fd as FileHandle ptr,count as unsigned integer,src as unsigned byte ptr)
    FlushMethod     as sub(fd as FileHandle ptr)
    LSeekMethod     as function(fd as FileHandle ptr,count as integer,mode as SeekOrigin) as unsigned integer
    
    declare function Read(count as unsigned integer,dst as unsigned byte ptr) as unsigned integer
    declare function ReadLine(dst as unsigned byte ptr) as unsigned integer
    declare sub Write(count as unsigned integer,src as unsigned byte ptr)
    declare sub Flush()
    
    declare function LSeek(count as integer,mode as SeekOrigin) as unsigned integer
    
    declare sub Create(p as unsigned byte ptr)
    
    declare function OPEN(p as unsigned byte ptr) as unsigned integer
    declare sub Close()
    
   
    
    declare sub DeleteBuffer()
    declare sub CreateBuffer(s as unsigned integer)
    declare constructor()
    declare destructor()
end type

declare function FileHandleReadLine(fd as FileHandle ptr,dst as unsigned byte ptr) as unsigned integer
declare function FileHandleRead(fd as FileHandle ptr,count as unsigned integer,dst as unsigned byte ptr) as unsigned integer
declare sub FileHandleWrite(fd as FileHandle ptr,count as unsigned integer,src as unsigned byte ptr)
declare sub FileHandleFlush(fd as FileHandle ptr)
declare function FileHandleLSeek(fd as FileHandle ptr,count as integer,mode as SeekOrigin) as unsigned integer

declare function RandomRead(fd as FileHandle ptr,count as unsigned integer,dst as unsigned byte ptr) as unsigned integer
