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
    var didAlloc = SlabMeta.SlabEntry.Alloc(sizeof(slab))>0
    if (not didAlloc) then
        KERNEL_ERROR(@"Could not initalize Slab memory management",0)
    end if
    ConsoleWriteLine(@"Slab allocator initialized")
end sub

function SlabMetaData.KAlloc(size as unsigned integer) as any ptr
    dim s as unsigned integer = GetSmallestPowerOfTwoo(size)
    if (s>=&h1000) then
        dim  requiredPages as unsigned integer = s shr 12
        if (requiredPages shl 12)<s then requiredPages+=1
        var p= PageAlloc(requiredPages)
        if (p<>0) then
            memset32(p,0,requiredPages shl 10)
        end if
        return p
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
        Kernel_ERROR(@"The slab could not allocate memory",0)
    end if
    
    return result
end function

sub SlabMetaData.KFree(addr as any ptr)
    var current = FirstSlab
    while current<>0
        if (current->Free(addr)) = 1 then return
        current=>Current->NextSlab
    wend
    dim xaddr as unsigned integer=cast(unsigned integer, addr)
    if ((xaddr shr 12) shl 12) = xaddr then
        PageFree(addr)
        return
    end if
    KERNEL_ERROR(@"The address is not part of a slab",0)
end sub
        
sub Slab.Init(isize as unsigned short)
    
    if (isize<minSize) then isize=minSize
    isize = GetSmallestPowerOfTwoo(isize)
    
    this.IsFull = 0
    this.ItemSize = isize
    this.NextSlab = 0
    this.SlabStart = cast(unsigned integer,PageAlloc(4))
  
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
        if (retval<>0) then
            memset32(retval,0,this.ItemSize shr 2)
        end if
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

