constructor FileHandle()
    Path = Path->Create()
    buffer = 0
    FilePos = 0
    FileSize = 0
    Dirty = 0
    BufferSize = 0
end constructor

destructor FileHandle()
    DeleteBuffer()
end destructor

sub FileHandle.DeleteBuffer()
    if (this.Buffer<>0) then
        KFree(this.Buffer)
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
        dim b as unsigned byte ptr = KAlloc(ss)
        if (this.Buffer<>0) then
            memcpy(b,this.Buffer,this.BufferSize)
            KFree(this.Buffer)
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
    dim s as unsigned integer
    dim b as unsigned byte ptr
    b = VFS_LOAD_FILE(p,@s)
    if (b<>0 and s<>0) then
        this.CreateBuffer(s)
        memcpy(this.Buffer,b,s)
        KFree(b)
        this.FileSize = s
        this.FilePos = 0
        this.Dirty = 0
        this.Path->SetText(p)
        return 1
    end if
    return 0
end function

sub FileHandle.Flush()
    if (this.Dirty = 1 and this.FileSize>0) then
        this.Dirty = 0
        VFS_WRITE_FILE(this.Path->Buffer,this.FileSize,this.Buffer)
    end if
end sub

function FileHandle.LSeek(count as integer,mode as SeekOrigin) as unsigned integer
    if (mode = SeekBegin) then
        FilePos = 0
    elseif(mode = SeekEnd) then
        FilePos = FileSize
    end if
    FilePos+=count
    if (FilePos>this.FileSize) then
        this.CreateBuffer(FilePos)
        this.FileSize = FilePos
    end if
    return FilePos
end function

function FileHandle.Read(count as unsigned integer,dst as unsigned byte ptr) as unsigned integer
    dim cpt as integer = count
    dim st as integer = this.FilePos
    
    if (this.FilePos+cpt>this.FileSize) then
        cpt = this.FileSize-this.FilePos
    end if
    
    
    if (st<0) then st = 0
    if (cpt<0) then cpt = 0
    
    if (cpt>0) then
        memcpy(dst,cptr(unsigned byte ptr, cast(unsigned integer,this.Buffer)+  st),cpt)
        st+=cpt
        this.FilePos = st
    end if
    return cpt
end function

function FileHandle.ReadLine(dst as unsigned byte ptr) as unsigned integer
    dim i as integer = 0
    dim c as unsigned byte = this.Buffer[this.FilePos]
    while c<>10 and c<>13 and c<>0 and this.FilePos<this.FileSize
        dst[i] = c
        i+=1
        this.FilePos+=1
        c=this.Buffer[this.FilePos]
    wend
    this.FilePos+=1
    c=this.Buffer[this.FilePos]
    while (c=0 or c=13 or c=10) and this.FilePos<this.FileSize
        this.FilePos+=1
        c=this.Buffer[this.FilePos]
    wend
    dst[i]=0
    return i
end function

sub FileHandle.Write(count as unsigned integer,src as unsigned byte ptr)
    if (count>0) then
        var newSize = this.FilePos + count
        
        if (newSize>this.FileSize) then
            this.CreateBuffer(newSize)
            this.FileSize = newSize
        end if
        
        memcpy(cptr(unsigned byte ptr,cast(unsigned integer,this.Buffer )+this.FilePos),src,count)
        this.FilePos+=count
        this.Dirty = 1
    end if
end sub
        

    
    