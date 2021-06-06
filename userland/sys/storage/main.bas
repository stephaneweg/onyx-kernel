#include once "stdlib.bi"
#include once "system.bi"
#include once "slab.bi"
#include once "console.bi"
#include once "gdi.bi"
#include once "tobject.bi"
#include once "tstring.bi"

#include once "hd.bas"
#include once "vfs.bi"
#include once "filehandle.bi"

#include once "stdlib.bas"
#include once "system.bas"
#include once "slab.bas"
#include once "tobject.bas"
#include once "tstring.bas"
#include once "console.bas"
#include once "gdi.bas"
#include once "filehandle.bas"



dim shared TMPString as unsigned byte ptr
dim shared TMPString2 as unsigned byte ptr
dim shared tmpFname as unsigned byte ptr

#include once "fs/fatfs.bas"
#include once "syscall33.bas"

declare sub mountSys(argc as unsigned integer,argv as unsigned byte ptr ptr) 
sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    EnterCritical()
    SlabInit()
    HD_INIT()
    tmpFname = MAlloc(1024)
    TMPString = MAlloc(1024)
    TMPString2 = MAlloc(1024)
    ConsoleWrite(@"Installing VFS")
	FS_DESCRIPTORS = 0
	FS_ENTRIES = 0
    
    FAT_INIT()
	mountSys(argc,argv)
    DefineIRQHandler(&h33,@int33Handler,1)
    
    UDevCreate(@"VFS",1,0)
    ExitCritical()
    WaitForEvent()
    Do:loop
end sub

sub mountSys(argc as unsigned integer,argv as unsigned byte ptr ptr) 
	dim drivename(0 to 20) as unsigned byte
	dim fsname(0 to 20) as unsigned byte
	if (argc>0) then
		for i as unsigned integer=0 to argc-1
			if (strncmp(argv[i],@"sys=",4)=0) then
				dim parm as unsigned byte ptr = cptr(unsigned byte ptr,cuint(argv[i])+4)
				var dd  = strindexof(parm,@":")
				if (dd>0 and dd<20) then
					memcpy(@drivename(0),parm,dd)
					drivename(dd)=0
					memcpy(@fsname(0),parm+dd+1,(strlen(parm)-dd)-1)
					fsname((strlen(parm)-dd)-1)=0
					
					VFS_MOUNT(@drivename(0),@fsname(0),@"SYS:/")
				end if
			end if
		next i
	end if
end sub

sub VFS_SHOW_DESCRIPTORS()
	ConsoleWriteLine(@"Available Filesystems")
	var node = FS_DESCRIPTORS
	while(node<>0)
		ConsoleWriteLine(node->FS_NAME)
		node=node->NextDescriptor
	wend
end sub


sub VFS_ADD_FS_DESCRIPTOR(descr as FS_DESCRIPTOR ptr)
	descr->NextDescriptor = FS_DESCRIPTORS
	FS_DESCRIPTORS = descr
end sub

sub VFS_FORMAT(diskname as byte ptr,filesystemname as byte ptr)
    dim dev as BlockDevice ptr = HD_FIND(diskName)
	dim filesystem as FS_DESCRIPTOR ptr = VFS_GET_FILE_SYSTEM_BY_NAME(fileSystemName)
    if (filesystem<>0) and (dev<>0) then
        'if (dev->DeviceType=BlockDeviceTypeName) then
            ConsoleWrite(@"VFSFormat : caling format  ")
			ConsoleWrite(diskname)
			ConsoleWrite(@" using ")
			ConsoleWrite(filesystem->FS_NAME)
			ConsoleWriteLine(@" File system...")
            filesystem->FormatMethod(dev)
        'else
        '    ConsoleWrite(@"VFS_FORMAT : not a block device : ")
		'	ConsoleWriteLine(diskname)
        'end if
    end if
end sub

sub VFS_MOUNT(diskName as byte ptr,fileSystemName as byte ptr, path as byte ptr)
    dim dev as BlockDevice ptr = HD_FIND(diskName)
    if (dev=0) then
            ConsoleSetForeGround(12)
            ConsoleWriteLine(@"Unable to mount ")
            ConsoleWrite(diskName)
            ConsoleWrite(@" as ")
            ConsoleWrite(fileSystemName)
            ConsoleWrite(@" to ")
            ConsoleWrite(path)
            ConsoleWriteLine(@" : cannot get device descriptor")
            ConsoleSetForeGround(7)
            exit sub
    end if
	dim filesystem as FS_DESCRIPTOR ptr = VFS_GET_FILE_SYSTEM_BY_NAME(fileSystemName)
	dim entry as VFS_ENTRY ptr
	dim fsres as FS_RESSOURCE ptr
	
	if (dev <>0) and (filesystem<>0) then
        
			ConsoleWrite(@"VFSMount : Mounting ")
			ConsoleWrite(diskName)
			ConsoleWrite(@" as ")
			ConsoleWrite(path)
			ConsoleWrite(@" using ")
			ConsoleWrite(filesystem->FS_NAME)
			ConsoleWriteLine(@" File system...")
			
			
			fsres = filesystem->SelectMethod(dev ,0)
			if (fsres<>0) then
				entry=MAlloc(sizeof(VFS_ENTRY))
				entry->PATH=path
				entry->Disk=dev
				entry->FileSystem=fsres
				entry->NextEntry = FS_ENTRIES
				FS_ENTRIES = entry
				ConsoleWriteLine(@"VFSMount : Mount success")
			else
				ConsoleWriteLine(@"VFSMount : Mount Error")
			end if
	else
		if (dev =0) then 
			ConsoleWrite(@"VFSMount : No such device : ")
			ConsoleWriteLine(diskname)
		end if
		if (filesystem=0) then
			ConsoleWrite(@"VFSMount : unknown filesystem : ")
			ConsoleWriteLine(fileSystemName)
		end if
	end if
end sub

function VFS_GET_FILE_SYSTEM_BY_NAME(fileSystemName as byte ptr) as FS_DESCRIPTOR ptr

	dim filesystem as FS_DESCRIPTOR ptr
	dim cpt as integer
	filesystem=FS_DESCRIPTORS
	while(filesystem<>0)
		
		cpt=0
		while (fileSystemName[cpt]<>0) and (filesystem->FS_NAME[cpt]<>0) and (fileSystemName[cpt]=filesystem->FS_NAME[cpt])
			cpt +=1
		wend
		if fileSystemName[cpt]=filesystem->FS_NAME[cpt] then return filesystem
		filesystem=filesystem->NextDescriptor
	wend
	return 0
end function


function VFS_LOAD_FILE(filename as unsigned byte ptr,filesize as unsigned integer ptr) as unsigned byte ptr
	dim entry as VFS_ENTRY ptr
	dim foundEntry as VFS_ENTRY ptr
	
	dim maxLen as integer
	dim cpt as integer
	
	entry=FS_ENTRIES
	foundEntry=0
	while(entry<>0)
		cpt=0
		while (entry->PATH[cpt]<>0) and (filename[cpt]<>0) and (entry->PATH[cpt]=filename[cpt])
			cpt+=1
		wend
		if (entry->PATH[cpt-1]=filename[cpt-1]) then
			if (cpt>maxLen) then
				maxLen=cpt
				foundEntry=entry
			end if
		end if
		entry=entry->NextEntry
	wend
	if (foundEntry<>0) then
		return foundEntry->LOAD_FILE(filename,filesize)
	else
		ConsoleWriteLine(@"VFS: ERROR mount point not found")
		return 0
	end if
end function

function VFS_DELETE_FILE(filename as unsigned byte ptr) as unsigned integer
	dim entry as VFS_ENTRY ptr
	dim foundEntry as VFS_ENTRY ptr
	
	dim maxLen as integer
	dim cpt as integer
	
	entry=FS_ENTRIES
	foundEntry=0
	while(entry<>0)
		cpt=0
		while (entry->PATH[cpt]<>0) and (filename[cpt]<>0) and (entry->PATH[cpt]=filename[cpt])
			cpt+=1
		wend
		if (entry->PATH[cpt-1]=filename[cpt-1]) then
			if (cpt>maxLen) then
				maxLen=cpt
				foundEntry=entry
			end if
		end if
		entry=entry->NextEntry
	wend
	if (foundEntry<>0) then
		return foundEntry->DELETE_FILE(filename)
	else
		ConsoleWriteLine(@"VFS: ERROR mount point not found")
		return 0
	end if
end function

function VFS_WRITE_FILE(filename as unsigned byte ptr,filesize as unsigned integer,buffer as unsigned byte ptr) as unsigned integer
	dim entry as VFS_ENTRY ptr
	dim foundEntry as VFS_ENTRY ptr
	
	dim maxLen as integer
	dim cpt as integer
	
	entry=FS_ENTRIES
	foundEntry=0
	while(entry<>0)
		cpt=0
		while (entry->PATH[cpt]<>0) and (filename[cpt]<>0) and (entry->PATH[cpt]=filename[cpt])
			cpt+=1
		wend
		if (entry->PATH[cpt-1]=filename[cpt-1]) then
			if (cpt>maxLen) then
				maxLen=cpt
				foundEntry=entry
			end if
		end if
		entry=entry->NextEntry
	wend
	if (foundEntry<>0) then
		return foundEntry->WRITE_FILE(filename,filesize,buffer)
	else
		ConsoleWriteLine(@"VFS: ERROR mount point not found")
		return 0
	end if
end function

function VFS_CREATE_DIR(path as unsigned byte ptr) as unsigned integer
	dim entry as VFS_ENTRY ptr
	dim foundEntry as VFS_ENTRY ptr
	
	dim maxLen as integer
	dim cpt as integer
	
	entry=FS_ENTRIES
	foundEntry=0
	while(entry<>0)
		cpt=0
		while (entry->PATH[cpt]<>0) and (path[cpt]<>0) and (entry->PATH[cpt]=path[cpt])
			cpt+=1
		wend
		if (entry->PATH[cpt-1]=path[cpt-1]) then
			if (cpt>maxLen) then
				maxLen=cpt
				foundEntry=entry
			end if
		end if
		entry=entry->NextEntry
	wend
	if (foundEntry<>0) then
		return foundEntry->CREATE_DIR(path)
	else
		ConsoleWriteLine(@"VFS: ERROR mount point not found")
		return 0
	end if
end function

function VFS_LIST_DIR(path as unsigned byte ptr,entrytype as unsigned integer,dst as VFSDirectoryEntry ptr,skip as unsigned integer,count as unsigned integer) as unsigned integer
	dim entry as VFS_ENTRY ptr
	dim foundEntry as VFS_ENTRY ptr
	
	dim maxLen as integer
	dim cpt as integer
	
	entry=FS_ENTRIES
	foundEntry=0
	while(entry<>0)
		cpt=0
		while (entry->PATH[cpt]<>0) and (path[cpt]<>0) and (entry->PATH[cpt]=path[cpt])
			cpt+=1
		wend
		if (entry->PATH[cpt-1]=path[cpt-1]) then
			if (cpt>maxLen) then
				maxLen=cpt
				foundEntry=entry
			end if
		end if
		entry=entry->NextEntry
	wend
    
	if (foundEntry<>0) then
		return foundEntry->LIST_DIR(path,entrytype,dst,skip,count)
	else
		ConsoleWriteLine(@"VFS: ERROR mount point not found")
		return 0
	end if
    
end function


function VFS_ENTRY.LOAD_FILE(fname as unsigned byte ptr,filesize as unsigned integer ptr) as unsigned byte ptr
	*filesize=0
	dim relativePath as unsigned byte ptr = tmpFname
    strcpy(relativePath,fname)
	dim cpt as integer
	cpt=0
	while this.PATH[cpt]<>0
		cpt+=1
	wend
	relativePath=cptr(unsigned byte ptr,relativePath+cpt)
    dim retval as unsigned byte ptr=0
    
    if (this.FileSystem->LOAD_FILE<>0) then
        retval = this.FileSystem->LOAD_FILE(this.Filesystem,relativePath,filesize)
    end if
    return retval
end function


function VFS_ENTRY.DELETE_FILE(fname as unsigned byte ptr) as unsigned integer
    dim relativePath as unsigned byte ptr = tmpFname
    strcpy(relativePath,fname)   
	dim cpt as integer
	cpt=0
	while this.PATH[cpt]<>0
		cpt+=1
	wend
	relativePath=cptr(unsigned byte ptr,relativePath+cpt)
    dim retval as unsigned integer=0
    if (this.FileSystem->LOAD_FILE<>0) then
        retval = this.FileSystem->DELETE_FILE(this.Filesystem,relativePath)
    end if
    return retval
end function

function VFS_ENTRY.WRITE_FILE(fname as unsigned byte ptr,filesize as unsigned integer,buffer as unsigned byte ptr) as unsigned integer
    dim relativePath as unsigned byte ptr = tmpFname
    strcpy(relativePath,fname)  
	dim cpt as integer
	cpt=0
	while this.PATH[cpt]<>0
		cpt+=1
	wend
	relativePath=cptr(unsigned byte ptr,relativePath+cpt)
    dim retval as unsigned integer=0
    if (this.FileSystem->WRITE_FILE<>0) then
        retval = this.FileSystem->WRITE_FILE(this.Filesystem,relativePath,filesize,buffer)
    end if
    return retval
end function

function VFS_ENTRY.CREATE_DIR(path as unsigned byte ptr) as unsigned integer
    dim relativePath as unsigned byte ptr = tmpFname
    strcpy(relativePath,path)  
	dim cpt as integer
	cpt=0
	while this.PATH[cpt]<>0
		cpt+=1
	wend
	relativePath=cptr(unsigned byte ptr,relativePath+cpt)
    dim retval as unsigned integer=0
    if (this.FileSystem->Create_Dir<>0) then
        retval = this.FileSystem->CREATE_DIR(this.Filesystem,relativePath)
    end if
    return retval
end function

function VFS_ENTRY.LIST_DIR(path as unsigned byte ptr,entrytype as unsigned integer,dst as VFSDirectoryEntry ptr,skip as unsigned integer,count as unsigned integer) as unsigned integer
    dim relativePath as unsigned byte ptr = tmpFname
    strcpy(relativePath,path)  
    
	dim cpt as integer
	cpt=0
	while this.PATH[cpt]<>0
		cpt+=1
	wend
	relativePath=cptr(unsigned byte ptr,relativePath+cpt)
    dim retval as unsigned integer
    if (this.FileSystem->LIST_DIR<>0) then
        retval = this.FileSystem->LIST_DIR(this.Filesystem,relativePath,entrytype,dst,skip,count)
    end if
    return retval
end function