
const FAT_DIRSIZE=65536
function STR2FAT(texte as unsigned byte ptr,buffer as unsigned byte ptr) as integer
	dim cpt as integer,cpt2 as integer
	dim cara as unsigned byte

	for cpt=0 to 10 
		buffer[cpt]=&h20
	next
	if (texte[0]= &h20) then return 0
	if (texte[0]= &h0) then return 0
	if (texte[0]= &h2e) then ' "."
		if (texte[1]<>&h2e) then
			if (texte[1]<>&h0) then return 0
			buffer[0]=&h2e
			return -1
		end if
		if (texte[2]<>0) and (texte[2]<>&h47) then return 0
		buffer[0]=&h2e
		buffer[1]=&h2e
		return -1
	end if
    
	cpt=0
	while (cpt<11) and (texte[cpt]<>0)
		cara=texte[cpt]
		if (cara=&h2e) then
			cpt2=cpt
			while (cpt2<11) and (texte[cpt2]<>0)
                cara=texte[cpt2+1]
                if ((cara>=97) and (cara<=122)) then cara -= 32
				buffer[8+(cpt2-cpt)]=cara
				cpt2+=1
			wend
			exit while
		end if
		if ((cara>=97) and (cara<=122)) then cara -= 32
		buffer[cpt]=cara
		cpt+=1
	wend
	return -1
end function


sub FAT_MOUNT(dev as unsigned byte ptr,path as unsigned byte ptr)
    ConsoleWrite(@"MOUNT "):ConsoleWrite(dev):ConsoleWrite(@" AS FATFS :")
    var disk = HD_FIND(dev)
    if (disk<>0) then
        
        dim myboot as FAT_BOOTSECTOR ptr        
        dim MyBoot16 as BS16 ptr
        dim MyBoot32 as BS32 ptr
        myboot= PAlloc(1)
        MyBoot16=cptr(BS16 ptr, cast(unsigned integer,myboot)+sizeof(FAT_BOOTSECTOR))
        MyBoot32=cptr(BS32 ptr, cast(unsigned integer,myboot)+sizeof(FAT_BOOTSECTOR))
        
        
        if (disk->READ(disk,0,1,cptr(unsigned byte ptr,myboot))=0) then
            ConsoleWriteLine(@"UNABLE TO READ BLOCK DEVICE")
            return
        end if
        if (myboot->bps=0) or (myboot->spc=0) then
            PFree(myboot)
            ConsoleSetForeground(12)
            ConsoleWriteLine(@"BPS or SPC values is invalid")
            ConsoleSetForeground(7)
            return
        end if
        
        var seccount = iif(myboot->Sectors_Count<>0,myboot->Sectors_Count,myboot->Sectors_Count2)
        if (seccount=0) then
            PFree(myboot)
            ConsoleSetForeground(12)
            ConsoleWriteLine(@"INVALID SECTOR COUNT")
            ConsoleSetForeground(7)
        end if
            
            
        
        dim retval as FATFS_DESCRIPTOR ptr = MAlloc(sizeof(FATFS_DESCRIPTOR))
        dim cpt as integer
        dim sign as unsigned byte
        retval->SECTOR_COUNT = seccount
            
        
        if retval->SECTOR_COUNT<4085  then
            retval->FAT_TYPE=12
            ConsoleWrite(@" FAT12 ")
            sign=MyBoot16->Signature
            retval->Fat_limit=&hFF8
        else'if retval->SECTOR_COUNT<65525 then
            retval->FAT_TYPE=16
            ConsoleWrite(@" FAT16 ")
            sign=MyBoot16->Signature
            retval->Fat_limit=&hFFF8
        'else
        '	retval->FAT_TYPE=32
        '	ConsoleWrite(@"FAT32")
        '	sign=MyBoot32->Signature
        '	retval->Fat_limit=&h0FFFFFF8
        end if
        if (sign <> &h29 and sign <> &h0) then
            PFree(myboot)
            Free(retval)
            ConsoleSetForeground(12)
            ConsoleWriteLine(@" Signature invalid")
            ConsoleSetForeground(7)
            return
        end if
        retval->reserved_sectors = myboot->reserved_sectors
        retval->root_dir_count = myboot->root_dir_ent
        retval->bytes_per_sector=myboot->bps
        retval->sector_per_cluster=myboot->spc
        retval->fat_count = myboot->fat_count
        
        retval->FAT_DirectoryBuffer = PAlloc(65536 shr 12)
        if (retval->FAT_TYPE<>32) then
            retval->root_dir_sectors = (((myboot->root_dir_ent * 32) + (myboot->bps - 1)) / myboot->bps)
            retval->fat_sectors = (retval->fat_count * myboot->spf)
            retval->root_cluster=0
        else
            retval->root_dir_sectors = 0
            retval->fat_sectors = (retval->fat_count * myboot32->spf)
            retval->root_cluster=myboot32->root_cluster
        end if
        retval->data_sectors = retval->sector_count - (myboot->reserved_sectors + retval->fat_sectors + retval->root_dir_sectors)
        retval->total_clusters = retval->data_sectors / retval->sector_per_cluster
        retval->first_data_sector = retval->reserved_sectors + retval->fat_sectors + retval->root_dir_sectors
        retval->first_fat_sector =  retval->reserved_sectors
        PFree(myboot)
	
        var ftable_size = retval->bytes_per_sector* retval->fat_sectors*2
        var ftable_pages = (ftable_size shr 12)
        if (ftable_pages shl 12) < ftable_size then ftable_pages+=1
        retval->fat_table = PAlloc(ftable_pages)
        retval->fat_table_pcount = ftable_pages
        
        retval->disk = disk
        retval->disk->READ(retval->disk,retval->first_fat_sector,retval->fat_sectors,retval->fat_table)
        
        retval->IsDirty=0
        'retval->LOAD_FILE=@fat_loadfile
        'retval->WRITE_FILE=@fat_writefile
        'retval->LIST_DIR=@fat_ListDir
        
        ConsolePrintOK()
        ConsoleNewLine()	
        VFS_MKNOD(path,cuint(retval),@FATFS_OPEN,@FATFS_CLOSE,@FATFS_READ,@FATFS_WRITE,@FATFS_SEEK,0,0,@FATFS_UMOUNT)
    else
        ConsoleWrite(@"UNABLE TO OPEN BLOCK DEVICE"):ConsoleWriteLine(dev)
    end if
end sub     

function FATFS_DESCRIPTOR.Absolute_sector(cluster as unsigned integer) as unsigned integer
	return ((cluster-2) * this.sector_per_cluster)  + this.first_data_sector
end function

sub FATFS_DESCRIPTOR.READ_ROOT(dst as FAT_ENTRY ptr)
    
    if (this.Fat_Type<>32) then
        this.DISK->READ(this.Disk,(this.RESERVED_SECTORS+this.FAT_SECTORS),this.ROOT_DIR_SECTORS,cptr(unsigned byte ptr,dst))
	else
		this.READ_CHAIN(this.root_cluster,cptr(byte ptr,dst))
	end if
end sub

sub FATFS_DESCRIPTOR.WRITE_ROOT(src as FAT_ENTRY ptr)
    if (this.Fat_Type<>32) then
        this.DISK->WRITE(this.Disk,(this.RESERVED_SECTORS+this.FAT_SECTORS),this.ROOT_DIR_SECTORS,cptr(unsigned byte ptr,src))
	else
		this.WRITE_CHAIN(this.root_cluster,cptr(byte ptr,src))
	end if
end sub

sub FATFS_DESCRIPTOR.READ_CHAIN(clusternum as unsigned integer, dst as unsigned byte ptr)
	dim nxt as unsigned integer
	dim buf as unsigned byte ptr
	dim cpt as integer = 0
	
	if ((clusternum=0))  then
		this.Read_ROOT(cptr(FAT_ENTRY ptr ,dst))
		exit sub
	end if
    
    nxt = clusternum
    buf=dst 
    cpt = 0
    while(nxt<this.fat_limit)
        this.DISK->READ(this.Disk,(this.Absolute_sector(nxt)-1),this.sector_per_cluster,buf)
        
        nxt	=find_fatentry(nxt)
        buf +=(this.sector_per_cluster*this.bytes_per_sector)
        cpt+=1
    wend
end sub

sub FATFS_DESCRIPTOR.WRITE_CHAIN(clusternum as unsigned integer, src as unsigned byte ptr)
	dim nxt as unsigned integer
	dim buf as unsigned byte ptr
	dim cpt as integer = 0
	
	if ((clusternum=0))  then
		this.Write_ROOT(cptr(FAT_ENTRY ptr ,src))
		exit sub
	end if
    
    nxt = clusternum
    buf=src 
    cpt = 0
    while(nxt<this.fat_limit)
        this.DISK->WRITE(this.Disk,(this.Absolute_sector(nxt)-1),this.sector_per_cluster,buf)
        nxt	=find_fatentry(nxt)
        buf +=(this.sector_per_cluster*this.bytes_per_sector)
        cpt+=1
    wend
end sub

function FATFS_DESCRIPTOR.READ_NEXT_CLUSTER(clusternum as unsigned integer,dst as unsigned byte ptr) as unsigned integer
    if (clusternum<this.FAT_LIMIT) then
        
        this.DISK->READ(this.Disk,(this.Absolute_sector(clusternum)-1),this.sector_per_cluster,dst)
        
        
        var nxt =  find_fatentry(clusternum)
        if (nxt>=this.FAT_LIMIT) then return 0
        return nxt
    end if
    return 0
end function

function  FATFS_DESCRIPTOR.find_fatentry(N as unsigned integer) as unsigned integer
	dim table_value16 as unsigned short
	dim table_value32 as unsigned integer
	dim table_value as unsigned integer
	dim cluster_size as unsigned integer=this.bytes_per_sector
	dim fatoffset as unsigned integer
	dim fatentoffset as unsigned integer

	if (this.fat_type = 12) then fatoffset = N + (N shr 1)
	if (this.fat_type = 16) then fatoffset = N shl 1
	if (this.fat_type = 32) then fatoffset = N shl 2
	
	fatentoffset = fatoffset

	
	
	if (this.Fat_Type<>32) then
		table_value16 = *cptr(unsigned short ptr, @fat_table[fatentoffset])
		if this.Fat_Type=12 then
			if ((N AND &h0001)=&h0001) then 
				table_value16 = table_value16 shr 4
			else 
				table_value16 = table_value16 AND &hfff
			end if
		end if
	else
		table_value32 = *cptr(unsigned integer ptr, @fat_table[fatentoffset]) AND &h0fffffff
	end if

	if (fat_type<>32) then
		return table_value16
	else
		return table_value32
	end if
end function


function FATFS_DESCRIPTOR.find(fname as unsigned byte ptr,attrib as unsigned byte ,repertoire as FAT_ENTRY ptr) as unsigned integer
	dim cara as unsigned byte
	dim cpt1 as unsigned integer,cpt2 as unsigned integer
	dim trouve as unsigned integer,ok as unsigned integer,isdir as unsigned integer

	isdir = 0
	if (attrib = &h10) then isdir=1

	trouve=0
	cara=repertoire[0].Entry_Name(0)
	
	
	
	cpt1=0
	while (cpt1<255) and (trouve=0)
		ok=0
		if (isdir=1) then
			if( ((repertoire[cpt1].attrib AND &h10)<>0) AND (cara<>&he5) AND ((repertoire[cpt1].attrib AND &hf) <>&hf) AND (repertoire[cpt1].attrib <> &h0)) then ok = 1
		else
			if( ((repertoire[cpt1].attrib AND &h10)=0) AND (cara<>&he5) AND ((repertoire[cpt1].attrib and &hF) <>&hf)) then ok = 1
		end if
		
		if (ok=1) then
            trouve=1
			for cpt2=0 to 10 
				if (fname[cpt2]<>repertoire[cpt1].Entry_Name(cpt2)) then trouve=0
			next
				
			if (trouve=1) then 
                exit while
            end if
		end if
		cara=repertoire[cpt1+1].Entry_Name(0)
		cpt1+=1
	wend
	
	suiteb:
	if (trouve=1) then
		return cpt1+1
	else
		return 0
	end if
end function

function FATFS_DESCRIPTOR.find_entry(fichier as byte ptr,first_cluster as unsigned integer,entnum as unsigned integer ptr,cnum as unsigned integer ptr,fsize as unsigned integer ptr,entrytype as unsigned byte) as unsigned integer
	dim clusternum as unsigned integer, entrynum as unsigned integer
	dim filename as unsigned byte ptr,nextchaine as unsigned byte ptr
	dim fname(0 to 29) as unsigned byte
	dim cpt as unsigned integer,trouve as integer,clusternum2 as unsigned integer
	dim newrep as FAT_ENTRY ptr
	
    if (fichier=0) then return this.root_cluster
	'//cas 1)  on ne specifie rien, c'est donc le dossier racine
	if fichier[0]=0 then return this.root_cluster
	
	'//cas 2), on ne specifie que le repertoire racine
	if (fichier[0]=47) and (fichier[1]=0) then return this.root_cluster

	'//cas 3) on recherche dans le repertoire courrant
	if (fichier[0]<>47) then 
		clusternum=first_cluster 	';//le cluster de depart est donc le cluster courrant
		filename=fichier 			';//le nom du fichier est celui specifie
	'//cas 4 on recherche dans le repertoire racine
	else			
		clusternum=this.root_cluster		';//le cluster de depart est donc le cluster courrant
		filename=fichier+1
	end if

	
	
	'//par defaut on considère  qu'il n'y a pas de repertoire suivant
	nextchaine=0
	cpt = 0
	while (filename[0]<>0) and (nextchaine=0) and (cpt<=12)
		if (filename[cpt]=47) then 		'"/"
			filename[cpt]=0			 	';//on isole le nom du repertoire
			nextchaine=filename+cpt+1	';//on definis le repertoire suivant
		end if
		cpt+=1
	wend
	
	
	str2fat(filename,@fname(0))					        ';//on converi le nom de repertoire en nom valide
    
    newrep=cptr(FAT_ENTRY ptr,this.FAT_DirectoryBuffer)		';//(sector_per_cluster*bytes_per_sector*4);
	this.READ_CHAIN(clusternum,cptr(byte ptr,newrep))	';//on charge le cluster
    
	'//:s'il n'y a pas de prochaine chaine, on recherche un fichier
	if (nextchaine = 0) then
		trouve=this.find(@fname(0),entrytype,newrep)		';//on cherche l'entree
		if (trouve) then
			clusternum2=((newrep[trouve-1].clusternum_high shl 16) AND &hFFFF0000) + ((newrep[trouve-1].clusternum_low) AND &h0000FFFF)
			*entnum=trouve-1
			*cnum  = clusternum
			*fsize = newrep[trouve-1].size
			return clusternum2
		else
			return 0
		end if
	'//sinon on recher d'abord un repertoire pour trouver le fichier dedans
	else
		trouve=this.find(@fname(0),&h10,newrep)
		if (trouve>0) then
			clusternum2=((newrep[trouve-1].clusternum_high shl 16) AND &hFFFF0000) + ((newrep[trouve-1].clusternum_low) AND &h0000FFFF)
			return this.find_entry(nextchaine,clusternum2,entnum,cnum,fsize,entrytype)
		else
			return 0
		END IF
	end if
	return 0
end function


function FATFS_DESCRIPTOR.Find_Free_Cluster() as unsigned integer
    dim cpt as unsigned integer
    dim retval as unsigned integer
	retval=0

    cpt=2
    while (cpt<=this.total_clusters) and (retval=0)
        if (this.find_fatentry(cpt)=0) then return cpt
        cpt+=1
    wend
    return 0
end function

sub FATFS_DESCRIPTOR.Set_Cluster(N as unsigned integer, value as unsigned integer)
    dim table_value_16 as unsigned short
    dim aecrire as unsigned short
	dim table_value_32 as unsigned integer
    dim table_value as unsigned integer
	dim cluster_size as unsigned integer=this.bytes_per_sector
    dim fatoffset as unsigned integer
    dim fatsecnum as unsigned integer
    dim fatentoffset as unsigned integer
    dim fatoffset2 as unsigned integer
    if (N>=this.total_clusters) then return

	if (fat_type = 12) then fatoffset = N + (N shr 1)   '/2
	if (fat_type = 16) then fatoffset = N shl 1         '*2
	if (fat_type = 32) then fatoffset = N shl 2         '*4
	
	fatentoffset = fatoffset ';//fatoffset % cluster_size;
	fatoffset2 = fatoffset+((this.fat_sectors/this.fat_count)*this.bytes_per_sector)

	if (fat_type=32) then
        *cptr(unsigned integer ptr,@this.fat_table[fatentoffset])=value
		*cptr(unsigned integer ptr,@this.fat_table[fatoffset2])=value
		'*(unsigned int *)&fat_table[fatoffset2]=value;//writing value in the 2nd fat
    elseif (fat_type=16)  then
        *cptr(unsigned short ptr,@this.fat_table[fatentoffset])=value and &hFFFF
		*cptr(unsigned short ptr,@this.fat_table[fatoffset2])=value and &hFFFF
        
		'*(unsigned short *)&fat_table[fatentoffset]=value&0xffff;
		'*(unsigned short *)&fat_table[fatoffset2]  =value&0xffff; //writing value in the 2nd fat
    elseif (fat_type=12) then
    
		table_value_16 =*(cptr(unsigned short ptr,@this.fat_table[fatentoffset]))
		if ((N and &h0001)=&h0001) then 
            aecrire= ((table_value_16 and &h000f) or ((value  and &h0fff) shl 4))
		else            
            aecrire= ((table_value_16 and &hf000) or (value  and &h0fff))
        end if
        *cptr(unsigned short ptr,@this.fat_table[fatentoffset])=aecrire
		*cptr(unsigned short ptr,@this.fat_table[fatoffset2])=aecrire
	end if
	this.IsDirty=1
end sub

function FATFS_DESCRIPTOR.Alloc_Cluster() as unsigned integer
    dim tomark as unsigned integer
    dim value as unsigned integer
	
	'//printf("Recherche de %u cluster\n",count);
	tomark=this.find_free_cluster()
	if (tomark<>0) then
		this.set_cluster(tomark,fat_limit)
        return tomark
	end if
	return 0
end function

sub FATFS_DESCRIPTOR.FREE_CLUSTER(n as unsigned integer)
   var nextCluster = n
   while  (nextCluster<>0 and nextCluster<>this.FAT_LIMIT)
        this.set_cluster(nextCluster,0)
        nextCluster = find_fatentry(nextCluster)
   wend
end sub
       
   
function FATFS_OPENREAD(fat as FATFS_DESCRIPTOR ptr,path as unsigned byte ptr) as unsigned integer
    
    dim tmpPath as unsigned byte ptr = MAlloc(strlen(path)+1)
    strcpy(tmpPath,path)
    StrToUpperFix(tmpPath)
    var fileName    = VFS_FILENAME(tmpPath)
    
    
    
    dim clusternum as unsigned integer,cnum as unsigned integer,entnum as unsigned integer
	dim nbrclust as unsigned integer
	dim buffer as unsigned byte ptr
    dim fsize as unsigned integer
	dim cpt as unsigned integer
	dim newrep as FAT_ENTRY ptr
    
    clusternum=fat->find_entry(tmpPath,fat->root_cluster,@entnum,@cnum,@fsize,&h20)
    dim descr as FATFS_FILE ptr = 0
    if (clusternum<>0) then
        'CONSOLE_WRITE(@"PARENT DIR LOCATED AT CLUSTER : "):CONSOLE_WRITE_NUMBER(cnum,10):CONSOLE_NEW_LINE()
        'CONSOLE_WRITE(@"FILE LOCATED AT CLUSTER : "):CONSOLE_WRITE_NUMBER(clusternum,10):CONSOLE_NEW_LINE()
        'CONSOLE_WRITE(@"FILE SIZE : "):CONSOLE_WRITE_NUMBER(fsize,10):CONSOLE_NEW_LINE()
        'CONSOLE_WRITE(@"FILE PATH : "):CONSOLE_WRITE_LINE(tmpPath)
        
        descr = MAlloc(sizeof(FATFS_FILE))
        descr->MAGIC                = VFS_FILE_DESCRIPTOR_MAGIC
        descr->WRITEABLE            = 0
        descr->TRUNCATE             = 0
        descr->DIRECTORY_CLUSTER    = cnum
        descr->FILE_CLUSTER         = clusternum
        descr->DIRTY                = 0
        descr->CURRENT_CLUSTER      = 0
        descr->NEXT_CLUSTER         = 0
        descr->FPOS                 = 0
        descr->FPOS_IN_CLUSTER      = 0
        descr->FSIZE                = fsize
        str2FAT(filename,@descr->FAT_FILENAME(0))
        
        descr->FS                   = fat
        descr->END_OF_FILE          = 0
        descr->CLUSTER_SIZE         = fat->sector_per_cluster*fat->bytes_per_sector
        descr->CLUSTER_PAGES        = descr->CLUSTER_SIZE shr 12
        if (descr->CLUSTER_PAGES shl 12) < descr->CLUSTER_SIZE then descr->CLUSTER_PAGES+=1
        descr->CLUSTER              = PAlloc(descr->CLUSTER_PAGES)
    end if
    Free(tmpPath)
    return cuint(descr)
end function


function FATFS_OPENWRITE(fat as FATFS_DESCRIPTOR ptr,path as unsigned byte ptr,appendMode as unsigned integer) as unsigned integer
    dim tmpPath as unsigned byte ptr = MAlloc(strlen(path)+1)
    strcpy(tmpPath,path)
    StrToUpperFix(tmpPath)
    var parentPATH = VFS_PARENTPATH(tmpPath)
    var fileName = VFS_FILENAME(tmpPath)
    
    dim clusternum as unsigned integer,cnum as unsigned integer,entnum as unsigned integer
	dim nbrclust as unsigned integer
	dim buffer as unsigned byte ptr
    dim fsize as unsigned integer
	dim cpt as unsigned integer
	dim newrep as FAT_ENTRY ptr
    dim clusternumParentDir as unsigned integer
    clusternum=fat->find_entry(tmpPath,fat->root_cluster,@entnum,@cnum,@fsize,&h20)
    dim descr as FATFS_FILE ptr = 0
    
    if (clusternum<>0) then
        clusternumParentDir = cnum
        'free the existing clusters if we overwrite the existing files
        if (appendMode=0) then
            fat->FREE_CLUSTER(clusternum)
        end if
    else
        if (parentPath<>0) then
            clusternumParentDir = fat->find_entry(parentPATH,fat->root_cluster,@entnum,@cnum,@fsize,&h10)
        else
            clusternumParentDir = 0
        end if
    end if
    
    if (clusternumParentDir<>0) or (parentPath=0)  then
        descr = MAlloc(sizeof(FATFS_FILE))
        descr->MAGIC                = VFS_FILE_DESCRIPTOR_MAGIC
        descr->WRITEABLE            = 1
        descr->TRUNCATE             = iif(appendMode=0,1,0)
        descr->DIRTY                = 0
        descr->DIRECTORY_CLUSTER    = clusternumParentDir
        descr->FILE_CLUSTER         = iif(appendMode=0,0,clusterNum)'set here to cluster num  if we keep data (apped mode)
        descr->CURRENT_CLUSTER      = 0
        descr->NEXT_CLUSTER         = 0
        descr->FPOS                 = 0
        descr->FPOS_IN_CLUSTER      = 0
        descr->FSIZE                = iif(appendMode=0,0,fsize)
        str2FAT(filename,@descr->FAT_FILENAME(0))
        
        descr->FS                   = fat
        descr->END_OF_FILE          = 0
        descr->CLUSTER_SIZE         = fat->sector_per_cluster*fat->bytes_per_sector
        descr->CLUSTER_PAGES        = descr->CLUSTER_SIZE shr 12
        if (descr->CLUSTER_PAGES shl 12) < descr->CLUSTER_SIZE then descr->CLUSTER_PAGES+=1
        descr->CLUSTER              = PAlloc(descr->CLUSTER_PAGES)
        memset(descr->CLUSTER,0,descr->CLUSTER_SIZE)
        
        
         'seek to the end if append mode
        if (appendMode=1) and (descr->FILE_CLUSTER<>0) then
            descr->NEXT_CLUSTER = descr->FILE_CLUSTER
            do
                descr->LOAD_CLUSTER()
            loop until (descr->NEXT_CLUSTER  = 0) or (descr->NEXT_CLUSTER = fat->FAT_LIMIT)
            
            descr->FPOS = descr->FSIZE
            descr->FPOS_IN_CLUSTER = descr->FSIZE mod descr->CLUSTER_SIZE
        end if
    else
        ConsoleWrite(@"DIRECTORY NOT FOUND : "):ConsoleWriteLine(parentPATH)
    end if
    if (parentPath<>0) then Free(parentPATH)
    Free(tmpPath)
    return cuint(descr)
end function



function FATFS_CLOSE(handle as unsigned integer,descr as any ptr) as unsigned integer
    dim descriptor as FATFS_FILE ptr = cptr(FATFS_FILE ptr,descr)
    descriptor->CLOSE()
    
    Free(descriptor)
    
    return 1
end function

function FATFS_WRITE(handle as unsigned integer,descr as any ptr,count as unsigned integer,src as unsigned byte ptr) as unsigned integer
    if (count<=0) then return 0
    dim descriptor as FATFS_FILE ptr = cptr(FATFS_FILE ptr,descr)
    return descriptor->WRITE(count,src)
end function

function FATFS_READ(handle as unsigned integer,descr as any ptr,count as unsigned integer,dest as  unsigned byte ptr) as unsigned integer
    if (count<=0) then return 0
    dim descriptor as FATFS_FILE ptr = cptr(FATFS_FILE ptr,descr)
    if (descriptor->FPOS>=descriptor->FSIZE) then 
        descriptor->END_OF_FILE = 1
        return 0
    end if
    if (descriptor->END_OF_FILE<>0) then return 0
    return descriptor->READ(count,dest)
end function

function FATFS_SEEK(handle as unsigned integer,descr as any ptr,p as unsigned integer,m as unsigned integer) as unsigned integer
    dim descriptor as FATFS_FILE ptr = cptr(FATFS_FILE ptr,descr)
    
    'if it's in the same cluster, do not need to rewrite
    if (p \ descriptor->CLUSTER_SIZE) = (descriptor->FPOS\descriptor->CLUSTER_SIZE) then
        descriptor->FPOS = p
        descriptor->FPOS_IN_CLUSTER = p  mod descriptor->CLUSTER_SIZE
        return descriptor->FPOS
    end if
    
    if (descriptor->DIRTY=1) then
        descriptor->WRITE_CLUSTER()
    end if
    
    descriptor->FPOS = 0
    descriptor->FPOS_IN_CLUSTER = 0
    descriptor->CURRENT_CLUSTER = 0
    descriptor->NEXT_CLUSTER = descriptor->FILE_CLUSTER
    
    'find the cluster corresponding to the position
    do
        descriptor->CURRENT_CLUSTER = descriptor->NEXT_CLUSTER
        descriptor->NEXT_CLUSTER = descriptor->FS->find_fatentry(descriptor->CURRENT_CLUSTER)
        
        if (descriptor->FPOS + descriptor->CLUSTER_SIZE) > p then
            descriptor->FPOS_IN_CLUSTER = p mod descriptor->CLUSTER_SIZE
            descriptor->FPOS+=descriptor->FPOS_IN_CLUSTER
            exit do
        else
            descriptor->FPOS+=descriptor->CLUSTER_SIZE
        end if
    loop
    'load that cluster
    descriptor->FS->READ_NEXT_CLUSTER(descriptor->CURRENT_CLUSTER,descriptor->CLUSTER)
    return descriptor->FPOS
end function

function FATFS_OPEN(fat as FATFS_DESCRIPTOR ptr,path as unsigned byte ptr,mode as unsigned integer) as unsigned integer
    select case mode
        case 0'read
            return FATFS_OPENREAD(fat,path)
        case 1'create
            return FATFS_OPENWRITE(fat, path,0)
        case 2'append
            return FATFS_OPENWRITE(fat, path,1)
        case 3'random
            return FATFS_OPENWRITE(fat, path,2)
    end select
    return 0
end function

function FATFS_UMOUNT(fat as FATFS_DESCRIPTOR ptr) as unsigned integer
    PFree(fat->FAT_DIRECTORYBUFFER)
    PFree(fat->FAT_TABLE)
    fat->FAT_TABLE = 0
    fat->DISK = 0
    fat->FAT_DIRECTORYBUFFER= 0
    return 0
end function

