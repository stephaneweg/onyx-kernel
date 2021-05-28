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
	KFree(image)
	Image =  targetImg
	Thread.Create(@this,Image->Init,5)
    IRQ_ENABLE(0)
end sub

function Process.RequestLoad(path as unsigned byte ptr,args as any ptr) as Process ptr
	dim result as Process ptr = 0
    dim fsize as unsigned integer
    dim image as EXECUTABLE_Header ptr = cptr(EXECUTABLE_Header ptr,VFS_LOAD_FILE(path,@fsize))
	
    if (image<>0 and fsize <>0) then
        result = cptr(Process ptr,KAlloc(sizeof(Process)))
        result->Constructor()
		result->Image = image
        result->ImageSize = fsize
        
		result->NextProcess = ProcessesToLoad
		ProcessesToLoad = result
		if (PROCESS_MANAGER_THREAD<>0) then
			if (PROCESS_MANAGER_THREAD->State = ThreadState.waiting) then Scheduler.SetThreadReady(PROCESS_MANAGER_THREAD,0)
		end if
    end if
    return result
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
