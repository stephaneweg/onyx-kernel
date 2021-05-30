dim shared FAT_DirectoryBuffer as byte ptr
const FAT_DIRSIZE=65536
sub FAT_INIT()
    ConsoleWriteLine(@"Installing FAT File System")
	FAT_DirectoryBuffer=KAlloc(FAT_DIRSIZE)
	dim descriptor as FS_DESCRIPTOR ptr
	descriptor=KALLOC(sizeof(FS_DESCRIPTOR))
	descriptor->FS_NAME=@"FATFS"
	descriptor->SELECTMETHOD=@FAT_SELECT
	descriptor->FormatMethod=@FAT_FORMAT
	VFS_ADD_FS_DESCRIPTOR(descriptor)
    ConsoleWrite(@"FAT File system Installed")
    ConsolePrintOK()
    ConsoleNewLine()
end sub

sub FAT_FORMAT(disk as blockDevice ptr)
end sub

function FAT_SELECT(disk as BlockDevice ptr, parametre as byte ptr)  as FS_RESSOURCE ptr
	ConsoleWrite(@"Probe fat file system for ")
	ConsoleWrite(disk->RessourceName)
	ConsoleWrite(@" ... ")
	dim retval as FAT_FS_RESSOURCE ptr=0
	retval=KALLOC(sizeof(FAT_FS_RESSOURCE))
	retval->disk=disk
	dim myboot as FAT_BOOTSECTOR ptr
	dim MyBoot16 as BS16 ptr
	dim MyBoot32 as BS32 ptr
	myboot= KAlloc(4096)
	MyBoot16=cptr(BS16 ptr, cast(unsigned integer,myboot)+sizeof(FAT_BOOTSECTOR))
	MyBoot32=cptr(BS32 ptr, cast(unsigned integer,myboot)+sizeof(FAT_BOOTSECTOR))
	
	if (not disk->Read(disk,0,1,cptr(byte ptr,myboot))) then
		KFree(myboot)
		KFREE(retval)
		ConsoleSetForeground(12)
		ConsoleWriteLine(@"Unable to read disk")
		ConsoleSetForeground(7)
		return 0
	end if
	
	if (myboot->bps=0) or (myboot->spc=0) then
		Kfree(myboot)
		KFREE(retval)
		ConsoleSetForeground(12)
		ConsoleWriteLine(@"BPS or SPC values is invalid")
		ConsoleSetForeground(7)
		return 0
	end if
	dim cpt as integer
	dim sign as unsigned byte
	if (myboot->Sectors_Count<>0) then
		retval->SECTOR_COUNT=(myboot->Sectors_Count)
	else
		retval->SECTOR_COUNT=(myboot->Sectors_Count2)
	end if
	if (retval->SECTOR_COUNT=0) then
		KFree(myboot)
		KFREE(retval)
		ConsoleSetForeground(12)
		ConsoleWriteLine(@"SectorCount is invalid")
		ConsoleSetForeground(7)
		return 0
	end if
	
	if retval->SECTOR_COUNT<4085  then
		retval->FAT_TYPE=12
		ConsoleWrite(@"FAT12")
		sign=MyBoot16->Signature
		retval->Fat_limit=&hFF8
	else'if retval->SECTOR_COUNT<65525 then
	    retval->FAT_TYPE=16
		ConsoleWrite(@"FAT16")
		sign=MyBoot16->Signature
		retval->Fat_limit=&hFFF8
	'else
	'	retval->FAT_TYPE=32
	'	ConsoleWrite(@"FAT32")
	'	sign=MyBoot32->Signature
	'	retval->Fat_limit=&h0FFFFFF8
	end if
	if (sign <> &h29 and sign <> &h0) then
		KFree(myboot)
		KFREE(retval)
		ConsoleSetForeground(12)
		ConsoleWriteLine(@" Signature invalid")
		ConsoleSetForeground(7)
		return 0
	end if
	retval->reserved_sectors = myboot->reserved_sectors
	retval->root_dir_count = myboot->root_dir_ent
	retval->bytes_per_sector=myboot->bps
	retval->sector_per_cluster=myboot->spc
	retval->fat_count = myboot->fat_count
	if (retval->FAT_TYPE<>32) then
		retval->root_dir_sectors = (((myboot->root_dir_ent * 32) + (myboot->bps - 1)) / myboot->bps)
		retval->fat_sectors = (retval->fat_count * myboot->spf)
		retval->root_cluster=0
		retval->current_dir = KAlloc(retval->root_dir_sectors*retval->bytes_per_sector)
       
	else
		retval->root_dir_sectors = 0
		retval->fat_sectors = (retval->fat_count * myboot32->spf)
		retval->root_cluster=myboot32->root_cluster
		retval->current_dir = KAlloc(FAT_DIRSIZE)
	end if
	retval->data_sectors = retval->sector_count - (myboot->reserved_sectors + retval->fat_sectors + retval->root_dir_sectors)
	retval->total_clusters = retval->data_sectors / retval->sector_per_cluster
	retval->first_data_sector = retval->reserved_sectors + retval->fat_sectors + retval->root_dir_sectors
	retval->first_fat_sector =  retval->reserved_sectors
	KFree(myboot)
	
	retval->fat_table=KAlloc(retval->bytes_per_sector* retval->fat_sectors*2)

	disk->read(disk,retval->first_fat_sector,retval->fat_sectors,retval->fat_table)
	retval->current_clusternum=retval->root_cluster
	retval->IsDirty=0
	retval->Read_ROOT(retval->current_dir)
	retval->LOAD_FILE=@fat_loadfile
    retval->WRITE_FILE=@fat_writefile
    retval->LIST_DIR=@fat_ListDir
	ConsolePrintOK()
    ConsoleNewLine()	
	return retval 
end function



function FAT_FS_RESSOURCE.find_entry(fichier as byte ptr,first_cluster as unsigned integer,entnum as unsigned integer ptr,cnum as unsigned integer ptr,fsize as unsigned integer ptr,entrytype as unsigned byte) as unsigned integer
    
	dim clusternum as unsigned integer, entrynum as unsigned integer
	dim filename as unsigned byte ptr,nextchaine as unsigned byte ptr
	dim fname(0 to 29) as unsigned byte
	dim cpt as unsigned integer,trouve as integer,clusternum2 as unsigned integer
	dim newrep as FAT_ENTRY ptr
	
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

	
	
	'//par defaut on considÃ¨re  qu'il n'y a pas de repertoire suivant
	nextchaine=0
	cpt = 0
	while (filename[0]<>0) and (nextchaine=0) and (cpt<=12)
		if (filename[cpt]=47) then 		'"/"
			filename[cpt]=0			 	';//on isole le nom du repertoire
			nextchaine=filename+cpt+1	';//on definis le repertoire suivant
		end if
		cpt+=1
	wend
	
	
	str2fat(filename,@fname(0))					';//on converi le nom de repertoire en nom valide
    
	newrep=cptr(FAT_ENTRY ptr,FAT_DirectoryBuffer)			';//(sector_per_cluster*bytes_per_sector*4);
	this.Read(clusternum,cptr(byte ptr,newrep))	';//on charge le cluster
	
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

function FAT_FS_RESSOURCE.find(fname as unsigned byte ptr,attrib as unsigned byte ,repertoire as FAT_ENTRY ptr) as unsigned integer
    
	dim cpt1 as unsigned integer
	
	for cpt1  =0 to 254 
		if repertoire[cpt1].Entry_Name(0)<>0 then
            
            if	( _
					((attrib = &h10) and ((repertoire[cpt1].attrib AND &h10)<>0) AND (repertoire[cpt1].attrib <> &h0)) or _
					((attrib = &h20) and ((repertoire[cpt1].attrib AND &h10) =0) ) _
				) and _
				(repertoire[cpt1].Entry_Name(0)<>&he5) and _
				((repertoire[cpt1].attrib and &hF) <>&hf) then
                    
                    if (strncmp(@repertoire[cpt1].Entry_Name(0),fname,strlen(fname)) = 0) then return cpt1+1
			end if
				
		end if
	next
	return 0
end function



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



function FAT_FS_RESSOURCE.Absolute_sector(cluster as unsigned integer) as unsigned integer
	return ((cluster-2) * this.sector_per_cluster)  + this.first_data_sector
end function

sub FAT_FS_RESSOURCE.Read_ROOT(dst as FAT_ENTRY ptr)
	if (this.Fat_Type<>32) then
		this.Disk->Read(this.Disk,this.reserved_sectors+this.fat_sectors,this.root_dir_sectors,cptr(byte ptr,dst))
		this.Disk->Read(this.Disk,this.reserved_sectors+this.fat_sectors,this.root_dir_sectors,cptr(byte ptr,dst))
	else
		this.Read(this.root_cluster,cptr(byte ptr,dst))
	end if
end sub

sub FAT_FS_RESSOURCE.WRITE_ROOT(dst as FAT_ENTRY ptr)
	if (this.Fat_Type<>32) then
		this.Disk->Write(this.Disk,this.reserved_sectors+this.fat_sectors,this.root_dir_sectors,cptr(byte ptr,dst))
		this.Disk->Write(this.Disk,this.reserved_sectors+this.fat_sectors,this.root_dir_sectors,cptr(byte ptr,dst))
	else
		this.Write(this.root_cluster,cptr(byte ptr,dst))
	end if
end sub

sub FAT_FS_RESSOURCE.READ(clusternum as unsigned integer, dst as unsigned byte ptr)
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
        this.Disk->Read(this.Disk,this.Absolute_sector(nxt)-1,this.sector_per_cluster,buf)
        this.Disk->Read(this.Disk,this.Absolute_sector(nxt)-1,this.sector_per_cluster,buf)
        nxt	=find_fatentry(nxt)
        buf +=(this.sector_per_cluster*this.bytes_per_sector)
        cpt+=1
    wend
end sub

sub FAT_FS_RESSOURCE.WRITE(clusternum as unsigned integer,buffer as unsigned byte ptr)
    dim _next as unsigned integer
    dim _buff as unsigned byte ptr
   
                
	if ((clusternum=0)) then 
        this.write_root(cptr(FAT_ENTRY ptr,buffer))
        exit sub
    end if
    
    _next=clusternum
    _buff=buffer
    while(_next<this.fat_limit)
        'ConsoleWrite(@"Writing sector :" )
        'ConsoleWriteNumber(_next,10)
        'this.Disk->Write(this.Disk,this.Absolute_sector(_next)-1,this.sector_per_cluster,_buff)
        FatFS_WriteSectors(this.Disk,this.Absolute_sector(_next)-1,this.sector_per_cluster,_buff)
        
        _buff+=(this.sector_per_cluster*this.bytes_per_sector)
        _next = this.find_fatentry(_next)
    wend 
	'//printf("Ecriture du cluster %d adresse absolue %d (%d secteurs) \n",clusternum,fat_absolute_sector(clusternum),sector_per_cluster);
end sub

function  FAT_FS_RESSOURCE.find_fatentry(N as unsigned integer) as unsigned integer
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

sub FAT_FS_RESSOURCE.Set_Cluster(N as unsigned integer, value as unsigned integer)
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
        
		'*(unsigned short *)&fat_table[fatentoffset]=aecrire;
		'*(unsigned short *)&fat_table[fatoffset2]=aecrire; //writing value in the 2nd fat
	end if
    '//	fat_disk->ioctl(fat_disk,1,fat_secnum,1,fat_table);
    'this.disk->Write(this.disk,this.first_fat_sector,this.fat_sectors,this.fat_table)
	this.IsDirty=1
end sub

function FAT_FS_RESSOURCE.Free_Cluster(n as unsigned integer) as unsigned integer
    dim limit as unsigned integer
    dim _next as unsigned integer
	if (N>=this.total_clusters) then return  0

	_next=find_fatentry(N)
	this.set_cluster(N,&h0)
    
    'libérer le suivant
	if ((_next<this.fat_limit) and (_next>2)) then 
        this.free_cluster(_next)
    else
    'si on a libéré le dernier, on ecrit la fat sur le disque
       
    end if
    return 1
end function

function FAT_FS_RESSOURCE.Alloc_Cluster(count as unsigned integer) as unsigned integer
    dim tomark as unsigned integer=count
    dim value as unsigned integer
	
	'//printf("Recherche de %u cluster\n",count);
	tomark=this.find_free_cluster()
	if (tomark<>0) then
		this.set_cluster(tomark,fat_limit)
		'//yen a d'autres?
		if (count >1) then
			'//on essaye d'alouer
			'//si ça marche pas on libere
			value=this.alloc_cluster(count-1)
			if(value=0) then
				this.set_cluster(tomark,&h0)
				return 0
			else
				this.set_cluster(tomark,value)
				return tomark
			end if
		else
            '//non alors on a fini
            '//printf("Cluster aloue %d\n",tomark);
            return tomark
        end if
	end if
	return 0
end function

function FAT_FS_RESSOURCE.Find_Free_Cluster() as unsigned integer
    dim cpt as unsigned integer
    dim retval as unsigned integer
    dim quart as unsigned integer=this.total_clusters shr 2 '/4
	retval=0

    '//on cherche dans le premier quart en partant du debut
    cpt=2
    while (cpt<=this.total_clusters) and (retval=0)
        if (this.find_fatentry(cpt)=0) then return cpt
        cpt+=1
    wend
	'color(12,0);
	'printf("Unnable to locate free cluster\n");
	'color(7,0);
    return 0
end function

function FAT_FS_RESSOURCE.Count_Rep(repertoire as FAT_ENTRY ptr) as unsigned integer
    dim cpt1 as unsigned integer
    dim count as unsigned integer
    dim cara as unsigned byte
	count=0
	cara=repertoire[0].entry_name(0)
    cpt1=0
    while cara<>0
        if	(( (repertoire[cpt1].attrib and &h0010) <>0)  and _
			 ( (repertoire[cpt1].attrib and &hff00) = 0) and _
			 (cara<>&he5) and  (cara<>46)) then	count+=1

		if	(   ((repertoire[cpt1].attrib and &h0010)=0) and _
                ((repertoire[cpt1].attrib and &h0008)=0) and _
                ((repertoire[cpt1].attrib and &hff00)=0) and _
			     (repertoire[cpt1].size>0) and _
                (cara<>&he5) and (cara<>46)) then count+=1
                
                
		cara=repertoire[cpt1+1].entry_name(0)
        cpt1+=1
    wend
	return count
end function



function FAT_WRITEFILE(ressource  as FS_RESSOURCE ptr,fichier as unsigned byte ptr,taille as unsigned integer,buffer as unsigned byte ptr) as unsigned integer
    'ConsoleWrite(@"Writing file : ")
	'ConsoleWriteLine(fichier)
    
    dim theFat as FAT_FS_RESSOURCE ptr
	theFat=cptr(fat_fs_ressource ptr,ressource)
    
    dim clusternum as unsigned integer
    dim trouve as long
    dim size as unsigned integer
    dim cnum as unsigned integer
    dim lfncnum as unsigned integer
    dim entnum as unsigned integer
    dim nbrclust as unsigned integer
    dim newcluster as unsigned integer
    dim cpt as  integer
    dim cpt2 as  integer
    dim repertoire_parrent as unsigned byte ptr
    dim count as unsigned integer
    dim attrib as unsigned integer
    dim tmpname as unsigned byte ptr=KALLOC(256)
    dim acreer as unsigned byte ptr=KALLOC(32)
	nbrclust=(taille\(theFat->bytes_per_sector*theFat->sector_per_cluster))
    if (taille mod (theFat->bytes_per_sector*theFat->sector_per_cluster))>0 then nbrclust +=1
    
    strcpy(tmpname,fichier)
    strcpy(acreer,tmpname)
    
	'struct Directory *newrep;
    dim newRep as FAT_ENTRY ptr
    clusternum=theFat->find_entry(fichier,theFat->root_cluster,@entnum,@cnum,@size,&h20)
	
	if (clusternum>0) then
        theFat->Free_cluster(clusternum)
		
		'//on aloue de nouveaux cluster
		clusternum=theFat->alloc_Cluster(nbrclust)
        if (theFat->IsDirty) then
            theFat->disk->Write(theFat->disk,thefat->first_fat_sector,thefat->fat_sectors,thefat->fat_table)
            theFat->IsDirty=0
        end if
        
		'//on lis le repertoire pour le mettre a jour, et on le reecris
		newrep=cptr(FAT_ENTRY ptr,FAT_DirectoryBuffer)  '(struct Directory *)malloc(dirsize);'//(sector_per_cluster*bytes_per_sector*4);
        theFat->Read(cnum,cptr(unsigned byte ptr,newrep))
        theFat->Read(cnum,cptr(unsigned byte ptr,newrep))
		
        newrep[entnum].clusternum_high=cast(unsigned short,((clusternum  and &hffff0000) shr 16))
        newrep[entnum].clusternum_low =cast(unsigned short,(clusternum and &hffff))
        
		newrep[entnum].size=taille
        
        theFat->Write(cnum,cptr(unsigned byte ptr,newrep))
		theFat->Write(cnum,cptr(unsigned byte ptr,newrep))
        theFat->Write(clusternum,buffer)
        theFat->Write(clusternum,buffer)
        'KFree(newrep)
        KFREE(tmpname)
        KFREE(acreer)
		return -1
	else
        
        
        'ConsoleWriteLine(@"Create new file")
		repertoire_parrent=0
        cpt=strlen(tmpname)-1
        while(cpt>=0) and (repertoire_parrent=0)
            '//putchar("position %d : %c\n",cpt,repertoire[cpt]);
			if (tmpname[cpt]=47) then
                if (cpt>0) then
                    
                    strcpy(acreer,tmpname+cpt+1)
                    tmpname[cpt]=0 ';//on isole le repertoire parrent
                    repertoire_parrent=tmpname
                end if
            end if
            cpt-=1
        wend
        
        
        
		'//si on a prevu un repertoire parrent on doit le trouver
		if (repertoire_parrent<>0) then
            'ConsoleWrite(@"looking for the parent directory : ")
            'ConsoleWriteLine(repertoire_parrent)
			'//printf("Je cherche dans un repertoire parrent : %s\n",repertoire_parrent);
			trouve=theFat->find_entry(repertoire_parrent,theFat->root_cluster,@entnum,@cnum,@count,&h10)
			'//si on l'a pas trouve alors on quite
			if (trouve <0 ) then
                'ConsoleSetForeground(12)
				'ConsoleWriteLine(@"Can not find parrent directory")
                'ConsoleSetForeground(7)
                KFREE(tmpname)
                KFREE(acreer)
				return 0
			else
                
                '//si on l'a trouve alors on a le numero de cluster dans trouve
				cnum=cast(unsigned integer,trouve)
                'ConsoleWrite(@"parent dir found at ")
                'ConsoleWriteNumber(cnum,10)
                'ConsoleNewLine()
			end if
        else
			cnum=theFat->root_cluster
		end if
        
        
		clusternum=theFat->alloc_Cluster(nbrclust)
        if (thefat->IsDirty) then
            thefat->disk->Write(thefat->disk,thefat->first_fat_sector,thefat->fat_sectors,thefat->fat_table)
            thefat->IsDirty=0
        end if
        
		'//printf("J'ai ajoue %u cluster a partir de %u",nbrclust,clusternum);
		if (clusternum<>0) then
            'ConsoleWriteLine(@"cluster alocated at ")
            'ConsoleWriteNumber(clusternum,10)
			'//on lis le repertoire
            'ConsoleWriteLine(@"Reading directory entry")
            newrep=cptr(FAT_ENTRY ptr,FAT_DirectoryBuffer)'//(bytes_per_sector*sector_per_cluster*4);
            
            
			theFat->Read(cnum,cptr(unsigned byte ptr,newrep))
			theFat->Read(cnum,cptr(unsigned byte ptr,newrep))
			trouve=0
            cpt=0
            var maxEntry = ((theFat->bytes_per_sector*theFat->sector_per_cluster)/32) -1
            
            for cpt = 0 to maxEntry
                if ((newrep[cpt].entry_name(0)<>&he5) and (newrep[cpt].entry_name(0) <> &h00)  and not ((newrep[cpt].attrib and &hf) = &hf)) then
                    ConsoleWriteLine(@(newrep[cpt].entry_name(0)))
                else
                'if ((newrep[cpt].entry_name(0)=&he5) or (newrep[cpt].entry_name(0)= &h00) or ((newrep[cpt].attrib and &hf)=&hf)) then
            		if (newrep[cpt].entry_name(0)=&h00) then newrep[cpt+1].entry_name(0)=&h0
                    STR2FAT(acreer,@(newrep[cpt].entry_name(0)))
                    newrep[cpt].clusternum_high=cast(unsigned short,((clusternum  and &hffff0000) shr 16))
					newrep[cpt].clusternum_low =cast(unsigned short,(clusternum and &hffff))
                    newrep[cpt].attrib=&h20
					newrep[cpt].size=taille
					trouve=1
                    theFat->Write(cnum,cptr(unsigned byte ptr,newrep))
                    theFat->Write(cnum,cptr(unsigned byte ptr,newrep))
                    exit for
                end if
			next
			'KFree(newrep)
			KFREE(tmpname)
            KFREE(acreer)
            
			if (trouve<>0) then
				theFat->write(clusternum,buffer)
				theFat->write(clusternum,buffer)
				return -1
			else
                '//sinon on doit liberer les cluster aloues pour le fichier
                ConsoleSetForeground(12)
				ConsoleWriteLine(@"No more space in cluster to add file")
                ConsoleSetForeground(7)
                
                theFat->Free_Cluster(clusternum)
                 if (theFat->IsDirty) then
                    theFat->disk->Write(theFat->disk,thefat->first_fat_sector,thefat->fat_sectors,thefat->fat_table)
                    theFat->IsDirty=0
                end if
				return 0
            end if
		else
			ConsoleSetForeground(12)
            ConsoleWriteLine(@"No more cluster to create file")
			ConsoleSetForeground(7)
            KFREE(tmpname)
            KFREE(acreer)
			return 0
        end if
	end if
end function



function fat_loadfile(ressource  as FS_RESSOURCE ptr,fichier as unsigned byte ptr,size as unsigned integer ptr) as unsigned byte ptr
	'ConsoleWrite(@"Loading file : ")
	'ConsoleWriteLine(fichier)
	
	dim theFat as FAT_FS_RESSOURCE ptr
	theFat=cptr(fat_fs_ressource ptr,ressource)

	dim clusternum as unsigned integer,cnum as unsigned integer,entnum as unsigned integer
	dim nbrclust as unsigned integer
	dim buffer as unsigned byte ptr
	dim cpt as unsigned integer
	dim newrep as FAT_ENTRY ptr

	clusternum=theFat->find_entry(fichier,theFat->current_clusternum,@entnum,@cnum,size,&h20)
	if (clusternum<>0) then
		'//cnum contient le numero de cluster du repertoire parrent
		'//entnum contient le numero d'entree dans le fichier
		'//clusternum contient le numero de cluster du fichier
		'//size contient la taille du fichier
		var bytesPerCluster=theFat->bytes_per_sector*theFat->sector_per_cluster
        nbrClust=*size\bytesPerCluster
        if (*size mod bytesPerCluster)>0 then nbrClust+=1
		
		buffer=KAlloc(nbrclust*theFat->sector_per_cluster*theFat->bytes_per_sector)
		
		theFat->read(clusternum,buffer)
		theFat->read(clusternum,buffer)
		
		return buffer
	else
		*size=0
		ConsoleSetForeground(12)
		ConsoleWrite(@"FILE NOT FOUND : ")
		ConsoleWrite(fichier)
		consoleNewLine()
		ConsoleSetForeground(7)
		return 0
	end if
	return 0
end function

function FAT2STR(str1 as unsigned byte ptr,buffer as unsigned byte ptr) as unsigned byte ptr
    dim cpt1 as unsigned integer=0
    dim cpt2 as unsigned integer=0
    dim dotAdded as unsigned integer=0
    for cpt1=0 to 7
        if (str1[cpt1]<>32) then
            buffer[cpt2]=str1[cpt1]
        else
            exit for
        end if
        cpt2+=1
    next cpt1
    
    for cpt1=8 to 10
        if (str1[cpt1]<>32) then
            if (dotAdded=0) then
                buffer[cpt2]=46
                cpt2+=1
                dotAdded=1
            end if
            buffer[cpt2]=str1[cpt1]
        else
            exit for
        end if
        cpt2+=1
    next cpt1
    buffer[cpt2]=0
    return buffer
end function

function Fat_ListDir(ressource  as FS_RESSOURCE ptr,path as unsigned byte ptr,entrytype as unsigned integer,dst as VFSDirectoryEntry ptr,skip as unsigned integer,entryCount as unsigned integer) as unsigned integer
    dim nbuffer(0 to 32) as unsigned byte
    dim theFat as FAT_FS_RESSOURCE ptr
	theFat=cptr(fat_fs_ressource ptr,ressource)
    dim clusternum as unsigned integer,cnum as unsigned integer,entnum as unsigned integer,count as unsigned integer
    
    var slen=strlen(path)
    
    if (slen=0) then
        clusternum=theFat->root_cluster
    else
        clusternum=theFat->find_entry(path,theFat->root_cluster,@entnum,@cnum,@count,&h10)
    end if
    if (clusternum<>0) or (clusternum=theFat->root_cluster and slen=0) then
        
        dim buffer as unsigned byte ptr
        dim cpt as unsigned integer
        
        
		var newrep=cptr(FAT_ENTRY ptr,FAT_DirectoryBuffer)'//(bytes_per_sector*sector_per_cluster*4);
        theFat->Read(clusternum,cptr(unsigned byte ptr,newrep))
        theFat->Read(clusternum,cptr(unsigned byte ptr,newrep))
        
        dim retval as unsigned integer = 0
        cpt=0
        while (cpt <  (theFat->bytes_per_sector*theFat->sector_per_cluster)/32) 
            
            if (newrep[cpt].entry_name(0)<>0) and (newrep[cpt].entry_name(0)<>&he5) and (newrep[cpt].attrib<>0)  then
                
                    if ((newrep[cpt].attrib=&h10) and (entrytype=1 or entrytype=0)) then
                        if (retval>=skip and retval<skip+entryCount) then
                            memset(@(dst[retval-skip].FileName(0)),0,256)
                            FAT2STR(@newrep[cpt].entry_name(0),@(dst[retval-skip].FileName(0)))
                            dst[retval-skip].Size=0
                            dst[retval-skip].EntryType=1
                        end if
                        retval+=1
                    end if
                    if ((newrep[cpt].attrib=&h20) and (entrytype=2 or entrytype=0)) then
                        if (retval>=skip and retval<skip+entryCount) then
                            
                            memset(@(dst[retval-skip].FileName(0)),0,256)
                            FAT2STR(@newrep[cpt].entry_name(0),@(dst[retval-skip].FileName(0)))
                            
                            dst[retval-skip].Size=newrep[cpt].size
                            dst[retval-skip].EntryType=2
                        end if
                        retval+=1
                    end if
                    
            end if
            
            cpt+=1
        wend
        return retval
    else
        ConsoleWriteLine(@"error theFat->Find_entry result was 0")
    end if
    return 0
end function



sub FatFS_WriteSectors(disk as BlockDevice ptr,lba as unsigned integer,nbrBlocs as unsigned integer,buffer as unsigned byte ptr)
    dim i as unsigned integer
    dim j as unsigned integer
    for i=0 to nbrBlocs-1
        disk->Write(disk,lba+i,1,buffer+(i*512))
        for j=0 to 500000:next
    next i
end sub

sub FatFS_ReadSectors(disk as BlockDevice ptr,lba as unsigned integer,nbrBlocs as unsigned integer,buffer as unsigned byte ptr)
    dim i as unsigned integer
    dim j as unsigned integer
    for i=0 to nbrBlocs-1
        disk->Read(disk,lba+i,1,buffer+(i*512))
        'for j=0 to 500000:next
    next i
end sub