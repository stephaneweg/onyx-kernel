sub int33Handler(_intno as unsigned integer,_senderproc as unsigned integer,_sender as unsigned integer,_eax as unsigned integer,_ebx as unsigned integer,_ecx as unsigned integer,_edx as unsigned integer,_esi as unsigned integer,_edi as unsigned integer,_ebp as unsigned integer,_esp as unsigned integer)

    select case _EAX
        'concern files
        case &h01 'load file
            GetStringFromCaller(TmpString,_ESI)
            var fname = TmpString
        
            dim fsize as unsigned integer  = 0
            var buff = VFS_LOAD_FILE(fname,@fsize)
            _ECX = fsize
            if (buff<>0) then
                var buffX = MapBufferFromCaller(cptr(any ptr,_EDI),fsize)
                memcpy(buffX,buff,fsize)
                UnMapBuffer(buffX,fsize)
                Free(buff)
                _EAX = 1
            else
                _EAX = 0
            end if
            
        case &h02 'write file
            GetStringFromCaller(TmpString,_EBX)
            var fname = TmpString
            dim fsize as unsigned integer = _ECX
            var buffX = MapBufferFromCaller(cptr(any ptr,_EDX),fsize)
            VFS_WRITE_FILE(fname,fsize,buffX)
            UnMapBuffer(buffX,fsize)

            
        case &h03 'fopen
            GetStringFromCaller(TmpString,_ESI)
            var fname = TmpString
            var handle = cptr(FileHandle ptr,MAlloc(sizeof(FileHandle)))
            handle->Constructor()
            if (handle->Open(fname)=1) then
                _EAX = cast(unsigned integer,handle)
            else
                handle->destructor()
                Free(handle)
                _EAX = 0
            end if
            
        case &h04 'fcreate
            GetStringFromCaller(TmpString,_ESI)
            var fname = TmpString
            
            var handle = cptr(FileHandle ptr,MAlloc(sizeof(FileHandle)))
            handle->Constructor()
            handle->Create(fname)
            _EAX = cast(unsigned integer,handle)
            
        case &h05 'fread
            var handle = cptr(FileHandle ptr,_EBX)
            if (handle<>0) then
                var count = _ECX
                var dest = MapBufferFromCaller(cptr(any ptr,_EDI),count)
                _EAX = handle->Read(count,dest)
                UnMapBuffer(dest,count)
            else
                _EAX = 0
            end if
            
        case &h06 'fwrite
            var handle = cptr(FileHandle ptr,_EBX)
            if (handle<>0) then
                var count = _ECX
                var src = MapBufferFromCaller(cptr(any ptr,_ESI),count)
                handle->Write(count,src)
                UnMapBuffer(src,count)
            end if
        case &h07 'fclose
            var handle = cptr(FileHandle ptr,_EBX)
            if (handle<>0) then
                var doFlush  = _ECX
                if (doFlush=1) then handle->Flush()
                handle->Destructor()
                Free(handle)
            end if
        case &h08 'flen
            var handle = cptr(FileHandle ptr,_EBX)
            if (handle<>0) then
                _EAX = handle->FileSize
            else
                _EAX = 0
            end if
            
        case &h09 'fseek
            var handle = cptr(FileHandle ptr,_EBX)
             if (handle<>0) then
                _EAX = handle->LSeek(_ECX,_EDX)
            else
                _EAX = 0
            end if
            
        case &h0a 'readline
            var handle = cptr(FileHandle ptr,_EBX)
            if (handle<>0) then
                _EAX = handle->ReadLine(TMPString)
                var slen = strlen(TMPString)+1
                var dest = MapBufferFromCaller(cptr(any ptr,_EDI),slen)
                memcpy(dest,TMPString,slen)
                UnMapBuffer(dest,slen)
            else
                _EAX = 0
            end if
            
        case &h0b 'eof
            var handle = cptr(FileHandle ptr,_EBX)
            if (handle<>0) then
                if (handle->FileSize=-1) then 
                    _EAX = 0
                else
                    _EAX = handle->FilePos>=handle->FileSize
                end if
            else
                _EAX = -1
            end if
            
        case &h0c 'list dir
            
            GetStringFromCaller(TmpString,_ESI)
            var path = TmpString
            var cpt = _ECX
            var dst = MapBufferFromCaller(cptr(any ptr,_EDI),sizeof(VFSDirectoryEntry)*cpt)
            
            var skip = _EDX
            var attrib = _EBX
            _EAX = VFS_LIST_DIR(path,attrib,dst,skip,cpt )
            UnMapBuffer(dst,sizeof(VFSDirectoryEntry)*cpt)
    end select
    EndIPCHandlerAndSignal()
end sub