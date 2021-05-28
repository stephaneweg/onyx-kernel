function SysCall33Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr
    dim CurrentThread as Thread ptr = Scheduler.CurrentRuningThread
    select case stack->EAX
        'concern files
        case &h01 'load file
            var fname = cptr(unsigned byte ptr,stack->ESI)
            dim fsize as unsigned integer  = 0
            var buff = VFS_LOAD_FILE(fname,@fsize)
            stack->ECX = fsize
            if (buff<>0) then
                memcpy(cast(unsigned byte ptr,stack->EDI),buff,fsize)
                KFree(buff)
            end if
        case &h02 'write file
            var fname = cptr(unsigned byte ptr,stack->EBX)
            dim fsize as unsigned integer = stack->ECX
            dim buff as unsigned byte ptr = cptr(unsigned byte ptr,stack->EDX)
            VFS_WRITE_FILE(fname,fsize,buff)
            
        case &h03 'fopen
            var fname = cptr(unsigned byte ptr,stack->ESI)
            var handle = cptr(FileHandle ptr,KAlloc(sizeof(FileHandle)))
            handle->Constructor()
            if (handle->Open(fname)=1) then
                stack->EAX = cast(unsigned integer,handle)
            else
                handle->destructor()
                KFree(handle)
                stack->EAX = 0
            end if
        case &h04 'fcreate
            var fname = cptr(unsigned byte ptr,stack->ESI)
            var handle = cptr(FileHandle ptr,KAlloc(sizeof(FileHandle)))
            handle->Constructor()
            handle->Create(fname)
            stack->EAX = cast(unsigned integer,handle)
        case &h05 'fread
            var handle = cptr(FileHandle ptr,stack->EBX)
            var count = stack->ECX
            var dest = cptr(unsigned byte ptr,stack->EDI)
            stack->EAX = handle->Read(count,dest)
        case &h06 'fwrite
            var handle = cptr(FileHandle ptr,stack->EBX)
            var count = stack->ECX
            var src = cptr(unsigned byte ptr,stack->ESI)
            handle->Write(count,src)
        case &h07 'fclose
            var handle = cptr(FileHandle ptr,stack->EBX)
            var doFlush  = stack->ECX
            if (doFlush=1) then handle->Flush()
            handle->Destructor()
            KFree(handle)
        case &h08 'flen
            var handle = cptr(FileHandle ptr,stack->EBX)
            stack->EAX = handle->FileSize
        case &h09 'fseek
            var handle = cptr(FileHandle ptr,stack->EBX)
            stack->EAX = handle->LSeek(stack->ECX,stack->EDX)
        case &h0a 'readline
            var handle = cptr(FileHandle ptr,stack->EBX)
            var dest = cptr(unsigned byte ptr,stack->EDI)
            stack->EAX = handle->ReadLine(dest)
        case &h0b 'eof
            var handle = cptr(FileHandle ptr,stack->EBX)
            stack->EAX = handle->FilePos>=handle->FileSize
        case &h0c 'list dir
            var path = cptr(unsigned byte ptr,stack->ESI)
            var dst = cptr(VFSDirectoryEntry ptr,stack->EDI)
            var cpt = stack->ECX
            var skip = stack->EDX
            var attrib = stack->EBX
            stack->EAX = VFS_LIST_DIR(path,attrib,dst,skip,cpt )
    end select
    return stack
end function