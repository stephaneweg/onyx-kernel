enum SeekOrigin
    SeekBegin = 0,
    SeekCurrent = 1,
    SeekEnd = 2
end enum

Type FileHandle field=1
    Path as TString ptr
    BufferSize as unsigned integer
    buffer as Unsigned byte ptr
    FileSize as unsigned integer
    FilePos as integer
    Dirty as integer
    declare function LSeek(count as integer,mode as SeekOrigin) as unsigned integer
    
    declare sub Create(p as unsigned byte ptr)
    declare function OPEN(p as unsigned byte ptr) as unsigned integer
    declare sub Close()
    declare function Read(count as unsigned integer,dst as unsigned byte ptr) as unsigned integer
    declare sub Write(count as unsigned integer,src as unsigned byte ptr)
    declare sub Flush()
    declare sub DeleteBuffer()
    declare sub CreateBuffer(s as unsigned integer)
    declare function ReadLine(dst as unsigned byte ptr) as unsigned integer
    declare constructor()
    declare destructor()
end type