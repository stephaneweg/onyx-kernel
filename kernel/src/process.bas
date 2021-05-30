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
	Thread.Create(@this,Image->Init,5)
    IRQ_ENABLE(0)
end sub

function Process.RequestLoadMem(image as EXECUTABLE_HEADER ptr,fsize as unsigned integer,args as any ptr,shouldFree as unsigned integer) as Process ptr
    dim result as Process ptr = 0
    result = cptr(Process ptr,KAlloc(sizeof(Process)))
    result->Constructor()
    result->Image = image
    result->ImageSize = fsize
    result->ShouldFreeMem = shouldFree
    result->NextProcess = ProcessesToLoad
    ProcessesToLoad = result
    if (PROCESS_MANAGER_THREAD<>0) then
        if (PROCESS_MANAGER_THREAD->State = ThreadState.waiting) then Scheduler.SetThreadReady(PROCESS_MANAGER_THREAD,0)
    end if
    return result
end function

function Process.RequestLoadUser(image as EXECUTABLE_HEADER ptr,fsize as unsigned integer,args as any ptr) as Process ptr
	
	if (fsize<>0) then
		dim newImg as EXECUTABLE_HEADER ptr = MAlloc(fsize)
		if (newImg<>0) then
			memcpy(cptr(unsigned byte ptr,newImg),cptr(unsigned byte ptr,image),fsize)
    
			return Process.RequestLoadMem(newImg,fsize,args,1)
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
