constructor FileHandle()
    Path = Path->Create()
    buffer = 0
    FilePos = 0
    FileSize = 0
    Dirty = 0
    BufferSize = 0
    
    
    ReadMethod      = 0
    WriteMethod     = 0
    FlushMethod     = 0
    ReadLineMethod  = 0
    
end constructor

destructor FileHandle()
    DeleteBuffer()
    delete this.Path
end destructor



sub FileHandle.DeleteBuffer()
    if (this.Buffer<>0) then
        Free(this.Buffer)
        this.Buffer=0
        this.FileSize = 0
        this.FilePos = 0
        this.Dirty = 0
        this.BufferSize = 0
        this.Path->SetText(@"")
    end if
end sub

sub FileHandle.CreateBuffer(s as unsigned integer)
    var ss = ((s shr 12)+1) shl 12
    if (ss>this.BufferSize) then
        dim b as unsigned byte ptr = MAlloc(ss)
        if (this.Buffer<>0) then
            memcpy(b,this.Buffer,this.BufferSize)
            Free(this.Buffer)
        end if
        this.Buffer = b
        this.BufferSize = ss
    end if
end sub
    
    
sub FileHandle.Create(p as unsigned byte ptr)
    DeleteBuffer()
    this.Path->SetText(p)
end sub

function FileHandle.Open(p as unsigned byte ptr) as unsigned integer
    DeleteBuffer()
    
    if (strcmp(p,@"random")=0) then
        this.FileSize   = -1
        this.FilePos    = 0
        this.Dirty      =0
        this.Path->SetText(p)
        
        this.ReadMethod         = @RandomRead
        this.ReadLineMethod     = 0
        this.WriteMethod        = 0
        this.FlushMethod        = 0
        this.LSeekMethod        = 0
        return 1
    else
        dim s as unsigned integer
        dim b as unsigned byte ptr
        b = VFS_LOAD_FILE(p,@s)
        if (b<>0 and s<>0) then
            this.CreateBuffer(s)
            memcpy(this.Buffer,b,s)
            Free(b)
            this.FileSize = s
            this.FilePos = 0
            this.Dirty = 0
            this.Path->SetText(p)
            
            
            this.ReadMethod      = @FileHandleRead
            this.ReadLineMethod  = @FileHandleReadLine
            this.WriteMethod     = @FileHandleWrite
            this.FlushMethod     = @FileHandleFlush
            this.LSeekMethod     = @FileHandleLSeek
            return 1
        end if
    end if
    return 0
end function

sub FileHandle.Flush()
    if (FlushMethod<>0) then
       FlushMethod(@this)
    end if
end sub

function FileHandle.LSeek(count as integer,mode as SeekOrigin) as unsigned integer
    if (LSeekMethod<>0) then
        return LSeekMethod(@this,count,mode)
    end if
    return 0
end function

function FileHandle.Read(count as unsigned integer,dst as unsigned byte ptr) as unsigned integer
    if (ReadMethod<>0) then
        return ReadMethod(@this,count,dst)
    end if
    return 0
end function

function FileHandle.ReadLine(dst as unsigned byte ptr) as unsigned integer
    if (ReadLineMethod<>0) then
        return ReadLineMethod(@this,dst)
    end if
    return 0
end function

sub FileHandle.Write(count as unsigned integer,src as unsigned byte ptr)
    if (WriteMethod<>0) then
        WriteMethod(@this,count,src)
    end if
end sub

'specific methods for "real files"
function FileHandleRead(fd as FileHandle ptr,count as unsigned integer,dst as unsigned byte ptr) as unsigned integer
    dim cpt as integer = count
    dim st as integer = fd->FilePos
    
    if (fd->FilePos+cpt>fd->FileSize) then
        cpt = fd->FileSize-fd->FilePos
    end if
    
    
    if (st<0) then st = 0
    if (cpt<0) then cpt = 0
    
    if (cpt>0) then
        memcpy(dst,cptr(unsigned byte ptr, cast(unsigned integer,fd->Buffer)+  st),cpt)
        st+=cpt
        fd->FilePos = st
    end if
    return cpt
end function

function FileHandleReadLine(fd as FileHandle ptr,dst as unsigned byte ptr) as unsigned integer
    dim i as integer = 0
    dim c as unsigned byte = fd->Buffer[fd->FilePos]
    while c<>10 and c<>13 and c<>0 and fd->FilePos<fd->FileSize
        dst[i] = c
        i+=1
        fd->FilePos+=1
        c=fd->Buffer[fd->FilePos]
    wend
    fd->FilePos+=1
    c=fd->Buffer[fd->FilePos]
    while (c=0 or c=13 or c=10) and fd->FilePos<fd->FileSize
        fd->FilePos+=1
        c=fd->Buffer[fd->FilePos]
    wend
    dst[i]=0
    return i
end function

sub FileHandleWrite(fd as FileHandle ptr,count as unsigned integer,src as unsigned byte ptr)
    if (count>0) then
        var newSize = fd->FilePos + count
        
        if (newSize>fd->FileSize) then
            fd->CreateBuffer(newSize)
            fd->FileSize = newSize
        end if
        
        memcpy(cptr(unsigned byte ptr,cast(unsigned integer,fd->Buffer )+fd->FilePos),src,count)
        fd->FilePos+=count
        fd->Dirty = 1
    end if
end sub

sub FileHandleFlush(fd as FileHandle ptr)
     if (fd->Dirty = 1 and fd->FileSize>0) then
        fd->Dirty = 0
        VFS_WRITE_FILE(fd->Path->Buffer,fd->FileSize,fd->Buffer)
    end if
end sub

function FileHandleLSeek(fd as FileHandle ptr,count as integer,mode as SeekOrigin) as unsigned integer
    if (mode = SeekBegin) then
        fd->FilePos = 0
    elseif(mode = SeekEnd) then
        fd->FilePos = fd->FileSize
    end if
    fd->FilePos+=count
    if (fd->FilePos > fd->FileSize) then
        fd->CreateBuffer(fd->FilePos)
        fd->FileSize = fd->FilePos
    end if
    return fd->FilePos
end function


'specifics method for special files


function RandomRead(fd as FileHandle ptr,count as unsigned integer,dst as unsigned byte ptr) as unsigned integer
    for i as integer = 0 to count-1
        dst[i] = NextRandomNumber(0,&hFFFFFFFF) and &hFF
    next i
    return count
end function
    
    