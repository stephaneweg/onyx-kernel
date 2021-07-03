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
            var handle = VFS_OPEN(fname,3)
			_EAX = cuint(handle)
            
        case &h04 'fcreate
            GetStringFromCaller(TmpString,_ESI)
            var fname = TmpString
            var handle = VFS_OPEN(fname,1)
			_EAX = cuint(handle)
            
        case &h05 'fread
            var handle = cptr(VFS_DESCRIPTOR ptr,_EBX)
            if (handle<>0) then
                var count = _ECX
                var dest = MapBufferFromCaller(cptr(any ptr,_EDI),count)
				_EAX = VFS_READ(handle,count,dest)
                UnMapBuffer(dest,count)
            else
                _EAX = 0
            end if
            
        case &h06 'fwrite
            var handle = cptr(VFS_DESCRIPTOR ptr,_EBX)
            if (handle<>0) then
                var count = _ECX
                var src = MapBufferFromCaller(cptr(any ptr,_ESI),count)
				_EAX = VFS_WRITE(handle,count,src)
                UnMapBuffer(src,count)
            end if
        case &h07 'fclose
            var handle = cptr(VFS_DESCRIPTOR ptr,_EBX)
            if (handle<>0) then
				VFS_CLOSE(handle)
            end if
        case &h08 'flen
            var handle = cptr(VFS_DESCRIPTOR ptr,_EBX)
            if (handle<>0) then
				_EAX = VFS_FSIZE(handle)
            else
                _EAX = 0
            end if
            
        case &h09 'fseek
            var handle = cptr(VFS_DESCRIPTOR ptr,_EBX)
             if (handle<>0) then
                _EAX = VFS_SEEK(handle,_ECX,_EDX)
            else
                _EAX = 0
            end if
            
        case &h0a 'readline
            var handle = cptr(VFS_DESCRIPTOR ptr,_EBX)
            if (handle<>0) then
				var s = VFS_INPUT(handle)
				if (s<>0) then
					var slen = strlen(s)+1
					var dest = MapBufferFromCaller(cptr(any ptr,_EDI),slen)
					memcpy(dest,s,slen)
					UnMapBuffer(dest,slen)
					_EAX = 1
				else
					_EAX = 0
				end if
            else
                _EAX = 0
            end if
            
        case &h0b 'eof
            var handle = cptr(VFS_DESCRIPTOR ptr,_EBX)
            if (handle<>0) then
                _EAX = VFS_EOF(handle)
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