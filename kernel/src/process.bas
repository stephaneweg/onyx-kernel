sub Process.InitEngine()
        FirstProcessList    = 0
        LastProcessList     = 0
        ProcessToTerminate  = 0
end sub

constructor Process()
    Image        = 0
    AddressSpace = 0
    
    if (LastProcessList<>0) then
        LastProcessList->NextProcessList = @this
    else
        FirstProcessList = @This
    end if
    PrevProcessList = LastProcessList
    LastProcessList = @this
    NextProcessList = 0
    
    if (Scheduler.CurrentRuningThread<>0) then
        if (Scheduler.CurrentRuningThread->Owner<>0) then
            VIRT_CONSOLE = Scheduler.CurrentRUningThread->Owner->VIRT_CONSOLE
        else
            VIRT_CONSOLE = @SYSCONSOLE
        end if
    else
        VIRT_CONSOLE = @SYSCONSOLE
    end if
    ServerChannels = 0
    ClientChannels = 0
    
    NextProcess = 0
    Threads = 0
end constructor


destructor Process()
    if (AddressSpace<>0) then
        
        AddressSpace->Destructor()
        KFree(AddressSpace)
        AddressSpace = 0
    end if
    
    if (NextProcessList<>0) then
        NextProcessList->PrevProcessList = PrevProcessList
    else
        LastProcessList = PrevProcessList
    end if
    
    if (PrevProcessList<>0) then
        PrevProcessList->NextProcessList = NextProcessList
    else
        FirstProcessList = NextProcessList
    end if
    
    NextProcessList= 0
    PrevProcessList= 0

    
    FreeConsole()
end destructor

function Process.CreateAddressSpace(virt as unsigned integer) as AddressSpaceEntry ptr
    var address_space = cptr(AddressSpaceEntry ptr,KAlloc(sizeof(AddressSpaceEntry)))
   
    
    address_space->VMM_Context  = @VMM_Context
    address_space->VirtAddr     = virt
    
    address_space->NextEntry    = AddressSpace
    address_space->PrevEntry    = 0
    if (AddressSpace<>0) then AddressSpace->PrevEntry=address_space
    
    AddressSpace = address_space
    
    return address_space
end function
    
function Process.FindAddressSpace(virt as unsigned integer)  as AddressSpaceEntry ptr
    var address_space = this.AddressSpace
    while address_space<>0
        if (address_Space->VirtAddr = virt) then return address_Space
        address_Space = address_Space->NextEntry
    wend
    return 0
end function

sub Process.RemoveAddressSpace(virt as unsigned integer)
    var address_space = FindAddressSpace(virt)
    if (address_space<>0) then
        if (address_space->PrevEntry<>0) then address_space->PrevEntry->NextEntry   = address_space->NextEntry
        if (address_space->NextEntry<>0) then address_space->NextEntry->PrevEntry   = address_space->PrevEntry
        if (this.AddressSpace=address_space) then this.AddressSpace= address_space->NextEntry
        address_space->NextEntry = 0
        address_space->PrevEntry = 0
        address_space->destructor()
        Kfree(Address_space)
    end if
end sub

sub Process.CreateConsole()
    FreeConsole()
    var console = cptr(VirtConsole ptr, KAlloc(sizeof(VirtConsole)))
    console->CursorX = 0
    console->CursorY = 0
    console->Foreground = 7
    console->Background = 0
    console->PHYS = PMM_ALLOCPAGE()
    console->VIRT =cptr(unsigned byte ptr, ProcessConsoleAddress)'cptr(unsigned byte ptr,&HB8000)
    
    current_context->map_page(console->VIRT,console->PHYS, VMM_FLAGS_USER_DATA)
    console->Activate()
    console->Clear()
    
    VIRT_CONSOLE = console
end sub

sub Process.FreeConsole()
    if (VIRT_CONSOLE <> @SYSCONSOLE) then
        if (CurrentConsole = VIRT_CONSOLE) then
            SysConsole.Activate()
        end if
        
        var used = false
        var proc=FirstProcessList
        while proc<>0
            if (proc<>@this) and (proc->VIRT_CONSOLE=VIRT_CONSOLE) then
                used = true
            end if
            proc=proc->NextProcessList
        wend
        if (not used) then
            VIRT_CONSOLE->Destructor()
            KFREE(VIRT_CONSOLE)
        end if
    end if
end sub


function Process.DoLoadFlat() as unsigned integer
    dim neededPages as unsigned integer = ((image->ImageEnd - ProcessAddress) shr 12)+2
    CodeAddressSpace = this.CreateAddressSpace(ProcessAddress)
    CodeAddressSpace->SBRK(neededPages)
    CodeAddressSpace->CopyFrom(image,ImageSize)
    return image->Init
end function

function Process.DoLoadElf() as unsigned integer
    var elfHeader = cptr(ELF_HEADER ptr,image)
    dim program_header as ELF_PROG_HEADER_ENTRY ptr = cast(ELF_PROG_HEADER_ENTRY ptr, cuint(elfHeader) + elfHeader->ProgHeaderTable)
    for counter as uinteger = 0 to elfHeader->ProgEntryCount-1
        dim start as unsigned integer       = program_header[counter].Segment_V_ADDR and VMM_PAGE_MASK
        dim real_size as unsigned integer   = program_header[counter].SegmentFSize + (program_header[counter].Segment_V_ADDR - start)
		dim real_mem_size as uinteger       = program_header[counter].SegmentMSize + (program_header[counter].Segment_V_ADDR - start)
        
        dim addr as uinteger = start
		dim end_addr as uinteger = start + real_size
		dim end_addr_mem as uinteger = start + real_mem_size
        
        var area = this.CreateAddressSpace(addr)
        var neededPages = (real_mem_size shr 12)
        if (neededPages shl 12)<real_mem_size then neededPages+=1
        
        
        area->SBRK(neededPages)
        
        if program_header[counter].SegmentType<>ELF_SEGMENT_TYPE_LOAD then
            'zone reserved
        else
            area->CopyFrom(cptr(any ptr,cuint(elfHeader)+ cuint(program_header[counter].Segment_P_ADDR)),real_size)
        end if
    next
    return elfHeader->ENTRY_POINT
end function

sub Process.DoLoad()
	    
	VMM_Context.Initialize()
    VMM_Context.map_page(VIRT_CONSOLE->VIRT,VIRT_CONSOLE->PHYS, VMM_FLAGS_USER_DATA)
	
    dim entry as unsigned integer = 0
    if (image->Magic = &hAADDBBFF) then
        entry = DoLoadFlat()
    elseif(image->MAGIC = ELF_MAGIC) then
        entry = DoLoadELF()
    end if
    
    StackAddressSpace = this.CreateAddressSpace(ProcessStackAddress)
    
    Image =  cptr(EXECUTABLE_HEADER ptr,ProcessAddress)	
    
    IRQ_DISABLE(0)
    var ctx = current_context
    VMM_Context.Activate()
	ParseArguments()
    ctx->Activate()
    IRQ_ENABLE(0)
    
	var th = Thread.Create(@this,entry)
    Scheduler.SetThreadReady(th)
end sub

sub Process.ParseArguments()
    Image->ArgsCount = 0
    if TmpArgs<>0 then
        if (strlen(strtrim(TmpArgs))>0) then
            if(Image->ArgsValues<>0) then
                dim tmpBuffer as unsigned byte ptr =KAlloc(strlen(TmpArgs)+1)
                var slen = strlen(TmpArgs)
                dim prev as unsigned integer = 0
                dim dst as unsigned byte ptr = tmpBuffer
                
                'parse the arguments to split the string and remove the quotes
                dim inQuotes as unsigned integer = 0
                dim quoteType as unsigned integer = 0
                dim j as unsigned integer = 0
                for i as unsigned integer =0 to slen
                    if (TmpArgs[i]=34) then
                        if (inQuotes = 0) then
                            inQuotes = 1
                            quoteType = 1
                            continue for
                        elseif quotetype = 1 then
                            inquotes  = 0
                            quotetype = 0
                            continue for
                        end if
                    end if
                    if (TmpArgs[i]=asc("'")) then
                        if (inQuotes = 0) then
                            inQuotes = 1
                            quoteType = 2
                            continue for
                        elseif quotetype = 2 then
                            inquotes  = 0
                            quotetype = 0
                            continue for
                        end if
                    end if
                    
                    if (tmpArgs[i]=0 or tmpArgs[i]=32) and (inquotes=0) then
                        if (j>0) then
                            dst[j] = 0
                            j+=1
                            'the pointer relative to the start of the string
                            Image->ArgsValues[image->ArgsCount]=dst-cuint(tmpBuffer)
                            dst =cptr(unsigned byte ptr, cuint(dst)+j)
                            j=0
                            image->ArgsCount+=1
                        end if
                    else
                        dst[j]=tmpArgs[i]
                        j+=1
                    end if
                next i
                if (j>0) then
                    dst[j] = 0
                    Image->ArgsValues[image->ArgsCount]=dst-cuint(tmpBuffer)
                    dst =cptr(unsigned byte ptr, cuint(dst)+j)
                    image->ArgsCount+=1
                end if
                'the strings pointer array at the begining of the zone
                dim dstArray as unsigned byte ptr ptr = cptr(unsigned byte ptr ptr,Image->ArgsValues)
                'the strings data after the pointer array
                dim dstString as unsigned byte ptr =cptr(unsigned byte ptr,cuint(Image->ArgsValues)+(image->ArgsCount*sizeof(unsigned byte ptr)))
                dim strSize as unsigned integer = (cuint(dst)-cuint(tmpBuffer))+1
                memcpy(dstString,tmpBuffer,strSize)
                'relocate the pointers
                for i as unsigned integer = 0 to image->ArgsCount-1
                    dstArray[i] = cptr(unsigned byte ptr, cuint(dstArray[i])+cuint(dstString))
                next i
                
                
                KFree(tmpBuffer)
            end if
        
            KFree(TmpArgs)
		end if
	end if
end sub

function Process.Create(image as EXECUTABLE_HEADER ptr,fsize as unsigned integer,args as unsigned byte ptr) as Process ptr
    dim result as Process ptr = 0
    result = cptr(Process ptr,KAlloc(sizeof(Process)))
    result->Constructor()
    
    result->Image = image
	result->Image->ArgsCount = 0'argsCount
	'to do: copy data of arguments
	if (args<>0) then
		result->TmpArgs = KAlloc(strlen(args)+1)
		memcpy(result->TmpArgs,args,strlen(args)+1)
	else
		result->TmpArgs = 0
	end if
    result->ImageSize = fsize
    
    result->DoLoad()
    return result
end function



sub Process.AddThread(t as any ptr)
    dim th as Thread ptr = cptr(Thread ptr,t)    
    th->NextThreadProc = this.Threads
    this.Threads = th
end sub



sub Process.RequestTerminate(app as Process ptr)
    var th=cptr(Thread ptr,app->Threads)
    while th<>0
		var n = th->NextThreadProc
        th->State = ThreadState.Terminating
		Scheduler.RemoveThread(th)
		th=n
    wend
    ProcessToTerminate = app
end sub

sub Process.Terminate(app as Process ptr)
    IPCSend(&h35,0,&hFFFFFF,cuint(app),0,0,0,0,0,0)
    var th=cptr(Thread ptr,app->Threads)
    while th<>0
		var n = th->NextThreadProc
        IRQ_THREAD_TERMINATED(cuint(th))
		Scheduler.RemoveThread(th)
		th->destructor()
		KFree(th)
		
		th=n
    wend
    app->Destructor()
    KFree(app)
    ConsoleWriteLine(@"Process terminated")
end sub

