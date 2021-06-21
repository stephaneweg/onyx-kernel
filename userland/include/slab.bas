


function Malloc cdecl alias "malloc" (s as unsigned integer) as any ptr
    return SlabMeta.Alloc(s)
end function

sub Free cdecl alias "free" (addr as any ptr)
     SlabMeta.Free(addr)
end sub

function Realloc alias "realloc" (addr as any ptr,newsize as unsigned integer) as any ptr
    dim b as unsigned byte ptr =SlabMeta.Alloc(newsize)
    
    if (b<>0) then
        dim oldSize as unsigned integer= SlabMeta.GetSize(addr)
        memcpy(b,addr,min(newsize,oldsize))
        slabMeta.free(addr)
        return b
    else
        return addr
    end if
end function

function GetSmallestPowerOfTwoo(value as unsigned integer) as unsigned integer
    dim pwr as unsigned integer = 0
    dim v as unsigned integer = value
    asm
        BSR eax,[v]
        mov [pwr],eax
    end asm
    if (1 shl pwr) < v then pwr+=1
    v = 1 shl pwr
    return v
end function

sub SlabInit()
    SlabMeta.SlabPagesEntries = 0
    SlabMeta.SlabEntry.init(sizeof(slab))
    SlabMeta.FirstSlab = 0
    var didAlloc = SlabMeta.SlabEntry.Alloc(sizeof(slab))>0
    if (not didAlloc) then
		do:loop
    end if
end sub

function SlabMetaData.SlabAllocPage(count as unsigned integer) as any ptr
        'var entry = SlabPagesEntries
        'while entry<>0
        '    if (entry->PagesCount=count and entry->IsFree=1) then
        '        entry->IsFree = 0
        '        return entry->PageAddr
        '    end if
        '    entry = entry->NextPage
        'wend
        
        var p= PAlloc(count)
        'if (p<>0) then
        '    entry = MAlloc(sizeof(SlabPageEntry))
        '    entry->PageAddr = p
        '    entry->PagesCount = count
        '    entry->IsFree = 0
        '    entry->NextPage = SlabPagesEntries
        '    SlabPagesEntries = entry
        'end if
        return p
end function

sub SlabMetaData.SlabFreePage(addr as any ptr)
    'var entry = SlabPagesEntries
    'while entry<>0
    '    if (entry->PageAddr = addr) then
    '        entry->IsFree = 1
    '        return
    '    end if
    '    entry = entry->NextPage
    'wend
    PFree(addr)
end sub

function SlabMetaData.SlabPageSize(addr as any ptr) as unsigned integer
    var entry = SlabPagesEntries
    while entry<>0
        if (entry->PageAddr = addr) then
            return entry->PagesCount shl 12
        end if
        entry = entry->NextPage
    wend
    return 0
end function

function SlabMetaData.Alloc(size as unsigned integer) as any ptr
     dim s as unsigned integer = GetSmallestPowerOfTwoo(size)
    if (s>=&h1000) then
        dim  requiredPages as unsigned integer = s shr 12
        if (requiredPages shl 12)<s then requiredPages+=1
        return SlabAllocPage(requiredPages)
    end if
    
    var current = FirstSlab
    dim result as any ptr
    while current<>0
        if (current->IsFull=0) then
            result = current->Alloc(size)
            if (result<>0) then 
                return result
            end if
        end if
        current=current->NextSlab
    wend
    
    
    
    dim newSlab as Slab ptr =cptr(Slab ptr, this.SlabEntry.Alloc(sizeof(slab)))
    newSlab->init(size)
    newSlab->NextSlab = this.FirstSlab
    this.FirstSlab = newSlab
    
  
    
    result = newSlab->Alloc(size)

    if (result=0) then
        'Kernel_ERROR(@"The slab could not allocate memory",0)
    end if
    
    return result
end function

sub SlabMetaData.Free(addr as any ptr)
    var current = FirstSlab
    while current<>0
        if (current->Free(addr)) = 1 then return
        current=>Current->NextSlab
    wend
    dim xaddr as unsigned integer=cast(unsigned integer, addr)
    if ((xaddr shr 12) shl 12) = xaddr then
        SlabFreePage(addr)
        return
    end if
    'KERNEL_ERROR(@"The address is not part of a slab",0)
end sub

function SlabMetaData.GetSize(addr as any ptr) as unsigned integer
  var current = FirstSlab
  dim xaddr as unsigned integer=cuint(addr)
  while current<>0
        if (current->Owns(addr)) = 1 then
            return current->ItemSize
        end if
        current=>Current->NextSlab
  wend
  if ((xaddr shr 12) shl 12) = xaddr then
      return SlabPageSize(addr)
  end if
  return 0
end function


sub Slab.Init(isize as unsigned integer)
    
    if (isize<minSize) then isize=minSize
    isize = GetSmallestPowerOfTwoo(isize)
    
    this.IsFull = 0
    this.ItemSize = isize
    this.NextSlab = 0
    this.SlabStart = cast(unsigned integer,PAlloc(4))
  
	memset32(cptr(any ptr,this.slabStart),0,&h1000)
    
    dim numEntries as unsigned integer = (&h4000/this.ItemSize)-1
    this.FreeList = cptr(SlabENtry ptr,this.SlabStart)
    dim current as SlabEntry ptr = this.FreeList
    
    dim i as unsigned integer
    for i=1 to numEntries-1
        current->NextEntry= cptr(SlabEntry ptr,this.SlabStart + (i*isize))
        current= current->NextEntry
    next
    
end sub

function Slab.Alloc(isize as unsigned integer) as any ptr
       if (isize<minSize) then isize=minSize
        isize = GetSmallestPowerOfTwoo(isize)
       
        if (isize <> this.ItemSize) or (this.FreeList = 0) then
            return 0
        end if
        
        dim retval as any ptr = this.FreeList
        this.FreeList =  this.FreeList->NextEntry
        if (this.FreeList = 0) then IsFull = 1
        'if (retval<>0) then
        '    memset32(retval,0,this.ItemSize shr 2)
        'end if
        return retval
end function

function Slab.Free(addr as any ptr) as unsigned byte
    if (addr < this.SlabStart) or (addr>=this.SlabStart+&h4000) then
        return 0
    end if
    dim newEntry as SlabEntry ptr = cptr(SlabEntry ptr, addr)
    newEntry->NextEntry = this.FreeList
    this.FreeList = newEntry
    this.IsFull = 0
    return 1
end function

function Slab.Owns(addr as any ptr) as unsigned integer
     if (addr < this.SlabStart) or (addr>=this.SlabStart+&h4000) then
        return 0
    end if
    return 1
end function