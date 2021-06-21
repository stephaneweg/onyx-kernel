#define minSize 64




function GetSmallestPowerOfTwoo(value as unsigned integer) as unsigned integer
    dim pwr as unsigned integer = 0
    dim v as unsigned integer = value
    asm
        BSR eax,[v]
        mov [pwr],eax
    end asm
    if (pwr<minSlabPower) then pwr=minSlabPower
    if (1 shl pwr) < v then pwr+=1
    v = 1 shl pwr
    return v
end function

sub SlabInit()
     
    SlabMeta.SlabEntry.init(sizeof(slab))
    SlabMeta.FirstSlab = 0
    SlabMeta.SlabCount = 0
    var didAlloc = SlabMeta.SlabEntry.Alloc(sizeof(slab))>0
    if (not didAlloc) then
        KERNEL_ERROR(@"Could not initalize Slab memory management",0)
    end if
    ConsoleWriteLine(@"Slab allocator initialized")
end sub


function SlabMetaData.KAlloc(size as unsigned integer) as any ptr
    dim s as unsigned integer = GetSmallestPowerOfTwoo(size)
    if (s>=&h1000) then
        KERNEL_ERROR(@"Size too big to be allocated",size)
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
    newSlab->PrevSlab = 0
    this.SlabCount +=1
    if (this.FirstSlab<>0) then
        this.FirstSlab->PrevSlab = newSlab
    end if
    this.FirstSlab = newSlab
    
  
    
    result = newSlab->Alloc(size)

    if (result=0) then
        Kernel_ERROR(@"The slab could not allocate memory",0)
    end if
    
    return result
end function

sub SlabMetaData.KFree(addr as any ptr)
    var current = FirstSlab
    while current<>0
        if (current->Free(addr)) = 1 then 
            if (current->IsEmpty = 1) then
                if (current->NextSlab<>0) then current->NextSlab->PrevSlab = current->PrevSlab
                if (current->PrevSlab<>0) then current->PrevSlab->NextSlab = current->NextSlab
                if (current = FirstSlab) then FirstSlab = current->NextSlab
                current->Destructor()
                this.SlabEntry.Free(current)
                this.SlabCount -=1
            end if
            return
        end if
        current=>Current->NextSlab
    wend
    KERNEL_ERROR(@"The address is not part of a slab",0)
end sub
        
function SlabMetaData.IsValidAddr(addr as any ptr) as unsigned integer
    
    var current = FirstSlab
    while current<>0
        if (current->IsValidAddr(addr)) = 1 then return 1
        current=>Current->NextSlab
    wend
    return 0
end function
        
destructor Slab()
    if (this.SlabStart<>0) then
        KMM_FreePage(cptr(any ptr,this.SlabStart))
    end if
    this.SlabStart = 0
end destructor

sub Slab.Init(isize as unsigned short)
    
    if (isize<minSize) then isize=minSize
    isize = GetSmallestPowerOfTwoo(isize)
    
    this.IsFull = 0
    this.IsEmpty  = 1
    this.ItemsCount = 0
    this.ItemSize = isize
    this.NextSlab = 0
    this.SlabStart = cast(unsigned integer,KMM_ALLOCPAGE())
  
	memset32(cptr(any ptr,this.slabStart),0,&h400)
    
    dim numEntries as unsigned integer = (&h1000/this.ItemSize)-1
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
        if (retval<>0) then
            memset32(retval,0,this.ItemSize shr 2)
        end if
        this.IsEmpty = 0
        this.ItemsCount += 1
        return retval
end function

function Slab.Free(addr as any ptr) as unsigned byte
    if (addr < this.SlabStart) or (addr>=this.SlabStart+&h1000) then
        return 0
    end if
    dim newEntry as SlabEntry ptr = cptr(SlabEntry ptr, addr)
    newEntry->NextEntry = this.FreeList
    this.FreeList = newEntry
    this.IsFull = 0
    this.ItemsCount -=1
    if (this.ItemsCount = 0) then
        this.IsEmpty = 1
    else
        this.IsEmpty = 0
    end if
    return 1
end function

function Slab.IsValidAddr(addr as any ptr) as unsigned integer
     
    if (addr < this.SlabStart) or (addr>=this.SlabStart+&h1000) then
        return 0
    end if
    return 1
end function

