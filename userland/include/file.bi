TYPE VFSDirectoryEntry field = 1
    FileName(0 to 255) as unsigned byte
    EntryType as unsigned integer
    Size as unsigned integer
End Type



declare function ExecApp(path as unsigned byte ptr,args as unsigned byte ptr) as unsigned integer
declare function ExecAppAndWait(path as unsigned byte ptr,args as unsigned byte ptr) as unsigned integer
declare function VFS_Load_File(fname as unsigned byte ptr,fsize as unsigned integer ptr) as unsigned byte ptr
declare function FileOpen(p as unsigned byte ptr) as unsigned integer
declare function FileCreate(p as unsigned byte ptr) as unsigned integer
declare function FileRead(f as unsigned integer, count as unsigned integer,dest as any ptr) as unsigned integer
declare sub FileWrite(f as unsigned integer,count as unsigned integer,src as any ptr)
declare sub FileClose(f as unsigned integer,doFlush as integer)
declare function FileSize(f as unsigned integer) as unsigned integer
declare function FileSeek(f as unsigned integer,count as unsigned integer,mode as unsigned integer) as unsigned integer
declare function FileReadLine(f as unsigned integer,dst as any ptr) as unsigned integer
declare function FileEOF(f as unsigned integer) as unsigned integer
declare function VFSListDir(path as unsigned byte ptr,attrib as unsigned integer,skip as unsigned integer,count as unsigned integer,dst as VFSDirectoryEntry ptr) as unsigned integer
