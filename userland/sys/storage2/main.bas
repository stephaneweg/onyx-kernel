#include once "stdlib.bi"
#include once "system.bi"
#include once "slab.bi"
#include once "console.bi"
#include once "gdi.bi"
#include once "tobject.bi"
#include once "tstring.bi"

#include once "hd.bas"
#include once "vfs.bi"

#include once "stdlib.bas"
#include once "system.bas"
#include once "slab.bas"
#include once "tobject.bas"
#include once "tstring.bas"
#include once "console.bas"
#include once "gdi.bas"



dim shared TMPString as unsigned byte ptr
dim shared TMPString2 as unsigned byte ptr
dim shared tmpFname as unsigned byte ptr

#include once "fs/fatfs.bi"
#include once "fs/fatfs_file.bi"

#include once "fs/fatfs.bas"
#include once "fs/fatfs_file.bas"
#include once "syscall33.bas"

declare sub mountRamdisk()
declare sub mountSys(argc as unsigned integer,argv as unsigned byte ptr ptr) 
sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    SlabInit()
    HD_INIT()
    tmpFname = MAlloc(1024)
    TMPString = MAlloc(1024)
    TMPString2 = MAlloc(1024)
    ConsoleWrite(@"Installing VFS")
	
	VFS_INIT()
	
	FAT_MOUNT(@"HDA1",@"SYS:/")
    
    DefineIPCHandler(&h33,@int33Handler,1)
    
    UDevCreate(@"VFS",1,0)
    WaitForEvent()
    Do:loop
end sub

sub VFS_INIT()
    ConsoleWrite(@"Initializing VFS")
    VFS_FIRST_NODE  = 0
    VFS_LAST_NODE   = 0
    ConsolePrintOK()
    ConsoleNewLine()
end sub

function VFS_CMP(s1 as unsigned byte ptr,s2 as unsigned byte ptr) as unsigned integer
    dim i as unsigned integer = 0
    while s1[i]<>0 and s2[i]<>0
        var c1 = s1[i]
        var c2 = s2[i]
        if (c1>=97 and c1<=122) then c1-=32
        if (c2>=97 and c2<=122) then c2-=32
        
        if (c1<>c2) then return 0
        i+=1
    wend
    return i
end function

function VFS_FIND_NODE(path as unsigned byte ptr) as VFS_NODE ptr
    var node = VFS_FIRST_NODE
    dim deepestNode as VFS_NODE ptr
    dim deepestNodeLen as unsigned integer = 0
    while node<>0
        var i = VFS_CMP(node->PATH,path)
        if (i>deepestNodeLen) then
            deepestNodeLen = i
            deepestNode = node
        end if
        node=node->NEXT_NODE
    wend
    return deepestNode
end function

function VFS_NODE_EXISTS(path as unsigned byte ptr) as unsigned integer
    var node = VFS_FIRST_NODE
    while node<>0
        if (strcmp(node->PATH,path)=0) then return 1
        node=node->NEXT_NODE
    wend
    return 0
end function

function VFS_UMOUNT(p as unsigned byte ptr) as unsigned integer
    var node = VFS_FIND_NODE(p)
    if (node<>0) then
        if (node->UMOUNT_METHOD<>0) then
            node->UMOUNT_METHOD(node->HANDLE)
        end if
        if (node->NEXT_NODE<>0) then node->NEXT_NODE->PREV_NODE = node->PREV_NODE
        if (node->PREV_NODE<>0) then node->PREV_NODE->NEXT_NODE = node->NEXT_NODE
        if (VFS_LAST_NODE=node) then VFS_LAST_NODE = node->PREV_NODE
        if (VFS_FIRST_NODE = node) then VFS_FIRST_NODE = node->NEXT_NODE
        Free(node)
    end if
    return 0
end function

function VFS_MKNOD(path as unsigned byte ptr,_
    handle as unsigned integer,_
    open_method as any ptr,_
    close_method as any ptr,_
    read_method as any ptr,_
    write_method as any ptr,_
    file_seek_method as any ptr,_
    ls_method as any ptr,_
    delete_method as any ptr, _
    umount_method as any ptr) as unsigned integer
    
    dim tmpPath as unsigned byte ptr= Malloc(strlen(path)+2)
    strcpy(tmpPath,path)
    
    if (tmpPath[strlen(path)-1]<>asc("/")) then
        tmpPath[strlen(path)] = asc("/")
        tmpPath[strlen(path)+1] = 0
    end if
    strToUpperFix(tmpPath)
    
    if (VFS_NODE_EXISTS(tmpPath)=0) then
        dim node as VFS_NODE ptr = Malloc(sizeof(VFS_NODE))
        node->PATH          = tmpPath
        node->MAGIC         = VFS_NODE_MAGIC
        node->HANDLE        = handle
        node->OPEN_METHOD   = open_method
        node->CLOSE_METHOD  = close_method
        node->READ_METHOD   = read_method
        node->WRITE_METHOD  = write_method
        node->LS_METHOD     = ls_method
        node->SEEK_METHOD   = file_seek_method
        node->UMOUNT_METHOD = umount_method
        
        
        node->NEXT_NODE = 0
        node->PREV_NODE = VFS_LAST_NODE
        if (VFS_LAST_NODE<>0) then 
            VFS_LAST_NODE->NEXT_NODE =node
        else
            VFS_FIRST_NODE = node
        end if
        VFS_LAST_NODE = node
        ConsoleWrite(@"VFS NODE CREATED : "):ConsoleWriteLine(node->PATH)
        return 1
    end if
    Free(tmpPath)
    return 0
end function

function VFS_DUMMY_OPEN(handle as unsigned integer,p as unsigned byte ptr) as unsigned integer
        return 1
end function

function VFS_FILE_EXISTS(p as unsigned byte ptr) as unsigned integer
    var retval = 0
    var e = VFS_OPEN(p,0)
    if (e<>0) then
        retval = 1
        VFS_CLOSE(e)
    end if
    return retval
end function


function VFS_OPEN(path as unsigned byte ptr,mode as unsigned integer) as VFS_DESCRIPTOR ptr
    var node = VFS_FIND_NODE(path)
    if (node<>0) then
        if (node->OPEN_METHOD<>0) then
            var h = node->OPEN_METHOD(node->HANDLE,path+strlen(node->PATH),mode)
            if (h<>0) then
                dim descr as VFS_DESCRIPTOR ptr = Malloc(sizeof(VFS_DESCRIPTOR))
                descr->VFS = node
                descr->HANDLE = h
                descr->MAGIC = VFS_DESCRIPTOR_MAGIC
                return descr
            end if
        end if
    end if
    return 0
end function

sub VFS_CLOSE(descr as VFS_DESCRIPTOR ptr)
    if (descr<>0) then
        if (descr->MAGIC=VFS_DESCRIPTOR_MAGIC) then
            if (descr->VFS<>0) then
                if (descr->VFS->MAGIC=VFS_NODE_MAGIC) then
                    if (descr->VFS->CLOSE_METHOD<>0) then
                        VFS_ERR = descr->VFS->CLOSE_METHOD(descr->VFS->HANDLE,descr->HANDLE)
                    end if
                end if
            else
                ConsoleWrite(@"NO HANDLE")
            end if
        else
            ConsoleWrite(@"INVALID MAGIC")
        end if
    else
        ConsoleWriteLine(@"NULL DESCRIPTOR")
    end if
end sub

function VFS_READ(descr as VFS_DESCRIPTOR ptr,count as unsigned integer,buffer as any ptr) as unsigned integer
    if (descr<>0) then
        if (descr->MAGIC=VFS_DESCRIPTOR_MAGIC) then
            if (descr->VFS<>0) then
                if (descr->VFS->MAGIC=VFS_NODE_MAGIC) then
                    if (descr->VFS->READ_METHOD<>0) then
                        VFS_ERR = descr->VFS->READ_METHOD(descr->VFS->HANDLE,descr->HANDLE,count,buffer)
                        return VFS_ERR
                    else
                        ConsoleWrite(@"NO READ METHOD")
                    end if
                else
                    ConsoleWrite(@"INVALID NODE MAGIC")
                end if
            else
                ConsoleWrite(@"NO HANDLE")
            end if
        else
            ConsoleWrite(@"INVALID DESCRIPTOR_MAGIC")
        end if
    else
        ConsoleWriteLine(@"NULL DESCRIPTOR")
    end if
    return 0
end function

function VFS_WRITE(descr as VFS_DESCRIPTOR ptr,count as unsigned integer,buffer as any ptr) as unsigned integer
    if (descr<>0) then
        if (descr->MAGIC=VFS_DESCRIPTOR_MAGIC) then
            if (descr->VFS<>0) then
                if (descr->VFS->MAGIC=VFS_NODE_MAGIC) then
                    if (descr->VFS->WRITE_METHOD<>0) then
                        VFS_ERR = descr->VFS->WRITE_METHOD(descr->VFS->HANDLE,descr->HANDLE,count,buffer)
                        return VFS_ERR
                    end if
                end if
            end if
        end if
    end if
    return 0
end function


function VFS_WRITESTRING(descr as VFS_DESCRIPTOR ptr,txt as unsigned byte ptr) as unsigned integer
    return VFS_WRITE(descr,strlen(txt),txt)
end function

function VFS_WRITELINE(descr as VFS_DESCRIPTOR ptr,txt as unsigned byte ptr) as unsigned integer
    dim bnewline(0 to 1) as unsigned byte
    bnewline(0) = 13
    bnewline(1) = 10
    VFS_WRITESTRING(descr,txt)
    return VFS_WRITE(descr,2,@bnewline(0))
end function

function VFS_WRITEBYTE(descr as VFS_DESCRIPTOR ptr,b as unsigned byte) as unsigned integer
    return VFS_WRITE(descr,1,@b)
end function

function VFS_SEEK(descr as VFS_DESCRIPTOR ptr,p as unsigned integer,m as unsigned integer) as unsigned integer
      if (descr<>0) then
        if (descr->MAGIC=VFS_DESCRIPTOR_MAGIC) then
            if (descr->VFS<>0) then
                if (descr->VFS->MAGIC=VFS_NODE_MAGIC) then
                    if (descr->VFS->SEEK_METHOD<>0) then
                        VFS_ERR = descr->VFS->SEEK_METHOD(descr->VFS->HANDLE,descr->HANDLE,p,m)
                        return VFS_ERR
                    end if
                end if
            end if
        end if
    end if
    return 0
end function


function VFS_EOF(descr as VFS_DESCRIPTOR ptr) as unsigned integer
    var h = cptr(VFS_FILE_DESCRIPTOR ptr,descr->HANDLE)
    if (h->MAGIC = VFS_FILE_DESCRIPTOR_MAGIC) then
        return h->END_OF_FILE
    else
        return 1
    end if
end function

function VFS_READBYTE(descr as VFS_DESCRIPTOR ptr) as unsigned byte
    dim result as unsigned byte
    VFS_READ(descr,sizeof(unsigned byte),@result)
    return result
end function

function VFS_READSHORT(descr as VFS_DESCRIPTOR ptr) as unsigned short
    dim result as unsigned short
    VFS_READ(descr,sizeof(unsigned short),@result)
    return result
end function

function VFS_READINTEGER(descr as VFS_DESCRIPTOR ptr) as unsigned integer
    dim result as unsigned integer
    VFS_READ(descr,sizeof(unsigned integer),@result)
    return result
end function
    
function VFS_READLONG(descr as VFS_DESCRIPTOR ptr) as unsigned longint
    dim result as unsigned longint
    VFS_READ(descr,sizeof(unsigned longint),@result)
    return result
end function
    
function VFS_FILENAME(path as unsigned byte ptr) as unsigned byte ptr
    var l = strlen(path)
    if (l>0) then
        for i as integer = l-1 to 0 step -1
            if (path[i] = asc("/")) then
                return path+i+1
            end if
        next i
    end if
    return path
end function

function VFS_PARENTPATH(path as unsigned byte ptr) as unsigned byte ptr
    dim tmpPath as unsigned byte ptr = Malloc(strlen(path)+1)
    strcpy(tmpPath,path)
    StrToUpperFix(tmpPath)
    var l = strlen(tmpPath)
    if (l>0) then
        for i as integer = l-1 to 0 step -1
            if (tmpPath[i] = asc("/")) then
                tmpPath[i] = 0
                return tmpPath
            end if
        next i
    end if
    Free(tmpPath)
    return 0
end function

function VFS_FPOS(descr as VFS_DESCRIPTOR ptr) as unsigned integer
    var h = cptr(VFS_FILE_DESCRIPTOR ptr,descr->HANDLE)
    if (h->MAGIC = VFS_FILE_DESCRIPTOR_MAGIC) then
        return h->FPOS
    else
        return 0
    end if
end function

function VFS_FSIZE(descr as VFS_DESCRIPTOR ptr) as unsigned integer
    var h = cptr(VFS_FILE_DESCRIPTOR ptr,descr->HANDLE)
    if (h->MAGIC = VFS_FILE_DESCRIPTOR_MAGIC) then
        return h->FSIZE
    else
        return 0
    end if
end function

dim shared input_data(0 to 1024) as unsigned byte
function VFS_INPUT(descr as VFS_DESCriPTOR ptr) as unsigned byte ptr
    var h = cptr(VFS_FILE_DESCRIPTOR ptr,descr->HANDLE)
    input_data(0)=0
    if (h->MAGIC = VFS_FILE_DESCRIPTOR_MAGIC) then
        if (h->END_OF_FILE=1) then 
            return 0
        end if
        dim i as unsigned integer = 0
        while VFS_EOF(descr)=0
            var b = VFS_READBYTE(descr)
            if (b=13) or (b=10) then
                input_data(i)=0
                if (i>0) then
                    return @input_data(0)
                else
                    input_data(0)=0
                    return @input_data(0)
                end if
            end if
            if (b=8) then
                if (i>0) then
                    i-=1
                    input_data(i)=0
                end if
            end if
            if (b>=32) then
                input_data(i)=b
                i+=1
            end if
        wend
        if (i>0) then
            input_data(i)=0
            return @input_data(0)
        end if
    else
        ConsoleWrite(@"INVALID INPUT DEVICE")
        input_data(0)=0
        return @input_data(0)
    end if
    return 0
end function


function VFS_WRITE_FILE(filename as unsigned byte ptr,filesize as unsigned integer, buffer as unsigned byte ptr) as unsigned integer
    dim result as unsigned integer = 0
    var fic = VFS_OPEN(filename,1)
    if (fic<>0) then
        result = VFS_WRITE(fic,filesize,buffer)
        VFS_CLOSE(fic)
    end if
    return result
end function

function VFS_LOAD_FILE(filename as unsigned byte ptr,filesize as unsigned integer ptr) as unsigned byte ptr
    dim result as unsigned byte ptr = 0
    var fic = VFS_OPEN(filename,0)
    if (fic<>0) then
        *filesize = VFS_FSIZE(fic)
        if ((*filesize)>0) then
            dim buffer as unsigned byte ptr = MAlloc(*filesize)
            var ok = VFS_READ(fic,*filesize,buffer)
            if (ok=0) then
                FREE(buffer)
                Buffer = 0
            end if
            result = buffer
        end if
        VFS_CLOSE(fic)
    end if
    return result
end function

function VFS_LIST_DIR(path as unsigned byte ptr,entrytype as unsigned integer,dst as VFSDirectoryEntry ptr,skip as unsigned integer,count as unsigned integer) as unsigned integer
   var node = VFS_FIND_NODE(path)
    if (node<>0) then
        if (node->LS_METHOD<>0) then
            return node->LS_METHOD(node->HANDLE,path+strlen(node->PATH),entrytype,dst,skip,count)
            
        end if
    end if
   return 0
end function