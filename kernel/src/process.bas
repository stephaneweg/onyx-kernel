sub Process.InitEngine()
        FirstProcess = 0
        ProcessesToTerminate = 0
        ProcessesToLoad = 0
end sub

constructor Process()
    Image  = 0
    NextProcess = 0
    Threads = 0
    PagesCount = 0
end constructor


destructor Process()
	for i as unsigned integer = 0 to this.PagesCount -1
        var phys = this.VMM_Context.Resolve(cptr(any ptr,(i shl 12)+ProcessAddress))
        PMM_FREEPAGE(phys)
    next i
end destructor


sub Process.DoLoad()
    IRQ_DISABLE(0)
	dim neededPages as unsigned integer = ((image->ImageEnd - ProcessAddress) shr 12)+2
    var ctx = current_context
	VMM_Context.Initialize()
	VMM_Context.Activate()
	SBRK(neededPages)
	
	var targetImg = cptr(EXECUTABLE_HEADER ptr,ProcessAddress)
	memcpy(targetImg,image,ImageSize)
    if ShouldFreeMem then
        KFree(image)
	end if
    Image =  targetImg
	Image->ArgsCount = 0
	ParseArguments()
	Thread.Create(@this,Image->Init,5)
    IRQ_ENABLE(0)
end sub

sub Process.ParseArguments()
    if TmpArgs<>0 then
		if (Image->ArgsValues<>0) then
            dim tmpBuffer as unsigned byte ptr =Malloc(strlen(TmpArgs)+1)
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
            
            
            MFree(TmpArgs)
            MFree(tmpBuffer)
		end if
	end if
end sub

function Process.RequestLoadMem(image as EXECUTABLE_HEADER ptr,fsize as unsigned integer,shouldFree as unsigned integer,args as unsigned byte ptr) as Process ptr
    dim result as Process ptr = 0
    result = cptr(Process ptr,KAlloc(sizeof(Process)))
    result->Constructor()
	
    result->Image = image
	result->Image->ArgsCount = 0'argsCount
	'to do: copy data of arguments
	if (args<>0) then
		result->TmpArgs = Malloc(strlen(args))
		memcpy(result->TmpArgs,args,strlen(args)+1)
	else
		result->TmpArgs = 0
	end if
    result->ImageSize = fsize
    result->ShouldFreeMem = shouldFree
    result->NextProcess = ProcessesToLoad
    ProcessesToLoad = result
    if (PROCESS_MANAGER_THREAD<>0) then
        if (PROCESS_MANAGER_THREAD->State = ThreadState.waiting) then Scheduler.SetThreadReady(PROCESS_MANAGER_THREAD,0)
    end if
    return result
end function

function Process.RequestLoadUser(image as EXECUTABLE_HEADER ptr,fsize as unsigned integer,args as unsigned byte ptr) as Process ptr
	
	if (fsize<>0) then
		dim newImg as EXECUTABLE_HEADER ptr = MAlloc(fsize)
		if (newImg<>0) then
			memcpy(cptr(unsigned byte ptr,newImg),cptr(unsigned byte ptr,image),fsize)
    
			return Process.RequestLoadMem(newImg,fsize,1,args)
		end if
	end if
    return 0
end function

function Process.SBRK(pagesToAdd as unsigned integer) as unsigned integer
    var retval = this.PagesCount
    for i as unsigned integer=0 to pagesToAdd-1
        'var vaddr = PageAlloc(1)
        'var paddr = current_context->Resolve(vaddr)
        var paddr = PMM_ALLOCPAGE(1)
		if (paddr = 0) then return 0
        this.VMM_Context.MAP_PAGE(cptr(any ptr,(this.PagesCount shl 12) + ProcessAddress),paddr,VMM_FLAGS_USER_DATA)
        this.PagesCount+=1
    next i
    return retval
end function

sub Process.AddThread(t as any ptr)
    dim th as Thread ptr = cptr(Thread ptr,t)    
    th->NextThreadProc = this.Threads
    this.Threads = th
end sub



sub Process.TerminateNow(app as Process ptr)
    'destroy the thread
	 var th=cptr(Thread ptr,app->Threads)
	 while th<>0
		var n = th->NextThreadProc
        IRQ_THREAD_TERMINATED(cuint(th))
		Scheduler.RemoveThread(th)
		'destroy the thread
		th->destructor()
		'free its memory
		KFree(th)
		
		th=n
	 wend
     
     'destroy the app	
    app->Destructor()
    
    KFree(app)
end sub

sub Process.RequestTerminateProcess(app as Process ptr)
    var th=cptr(Thread ptr,app->Threads)
    while(th<>0)
        IRQ_THREAD_TERMINATED(cuint(th))
        th->State = ThreadState.Terminating
        Scheduler.RemoveThread(th)
        th=th->NextThreadProc
    wend
	
    app->NextProcess = ProcessesToTerminate
    ProcessesToTerminate = app
    
	
    if (PROCESS_MANAGER_THREAD<>0) then
        if (PROCESS_MANAGER_THREAD->State = ThreadState.waiting) then Scheduler.SetThreadReady(PROCESS_MANAGER_THREAD,0)
    end if
end sub
    
    
    

sub Process.Terminate(app as Process ptr,args as any ptr)
	'destroy the thread
	 var th=cptr(Thread ptr,app->Threads)
	 while th<>0
		var n = th->NextThreadProc
		
		'destroy the thread
		th->destructor()
		'free its memory
		KFree(th)
		
		th=n
	 wend
	
	'destroy the app	
    app->Destructor()
    
    KFree(app)
end sub
