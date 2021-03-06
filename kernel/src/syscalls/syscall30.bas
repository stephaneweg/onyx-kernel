function SysCall30Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr
    dim CurrentThread as Thread ptr = Scheduler.CurrentRuningThread
    select case stack->EAX
    case &h00 'set idle
            IDLE_THREAD = CurrentThread
            return Scheduler.Switch(stack, Scheduler.Schedule())
    case &h01 'load app from memory
            var ctx = vmm_get_current_context()
            var args = cptr(unsigned byte ptr,stack->ESI)
            if (args<>0) then
                if (strlen(args)=0) then args = 0
            end if
            var stdIn   = @CONSOLE_PIPE
            var stdout  = @CONSOLE_PIPE
            
            if (CurrentThread->Owner<>0) then
                stdIn   = CurrentThread->Owner->STD_IN
                stdOut  = CurrentThread->Owner->STD_OUT
            end if
            
            var p=Process.Create(cptr( EXECUTABLE_HEADER ptr,stack->EBX),stack->ECX,args,stdIn,stdOut)
            ctx->Activate()
            if (p<>0) then 
                    p->Parent = CurrentThread->Owner
                    if (stack->EDX = 1) then
                        CurrentThread->STATE = WaitingForProcess
                        p->WaitingThread = CurrentThread
                        return Scheduler.Switch(stack, Scheduler.Schedule())
                    end if
                    stack->EAX = 1
            '        return Scheduler.Switch(stack, Scheduler.Schedule())
            else
                stack->EAX=0
            end if
        case &h02 'create thread
            var th = Thread.Create(currentThread->Owner,stack->EBX)
            
            Scheduler.SetThreadReady(th)
            stack->EAX = cuint(th)
        
        case &h03 'yield
            return Scheduler.Switch(stack, Scheduler.Schedule())
            
        case &h04
			return currentThread->DoWait(stack)
        case &h05
            IRQ_DISABLE(0)
			Process.RequestTerminate(currentThread->Owner)
            Scheduler.CurrentRuningThread=0
            IRQ_ENABLE(0)
            return Scheduler.Switch(stack, Scheduler.Schedule())
        case &h06 ' thread wake up
            if (SlabMeta.IsValidAddr(cptr(any ptr,stack->ebx))=1) then
            
                var th = cptr(Thread ptr,stack->EBX)
                if (th->IsValid()) then
                    var st =cptr(IRQ_Stack ptr,  th->SavedESP)
                    
                    if (th->State=ThreadState.WaitingReply or th->State=ThreadState.Waiting) then
                         st->EAX = stack->ECX
                         st->EBX = stack->EDX
                        'shedule the thread immediately
                         Scheduler.SetThreadReady(th)
                         return Scheduler.Switch(stack, Scheduler.Schedule())
                    end if
                end if
            end if
        case &h07 'UDev create
            UserModeDevice.Create(cptr(unsigned byte ptr,stack->EBX),currentThread,stack->ECX,stack->EDX)
        case &h08 'UDEV Find
            stack->EAX =cuint( UserModeDevice.Find(cptr(unsigned byte ptr,stack->EBX)))
        case &h09 'UDev invoke
            if (UserModeDevice.Invoke(stack->EBX,currentThread,stack->ECX,stack->EDX,stack->ESI,stack->EDI)=1) then
                'the udev thread will be run directly
                return Scheduler.Switch(stack,Scheduler.Schedule()) 
            else
                stack->EAX = 0
            end if
        case &h0A 'UDev return
            stack->ESP = stack->EBP
            
            if (CurrentThread->ReplyTO->IsValid()) then
                if ((CurrentThread->ReplyTO->State=ThreadState.WaitingReply) and (CurrentThread->ReplyTO->ReplyFrom = CurrentThread)) then
                    var st =cptr(IRQ_Stack ptr, CurrentThread->ReplyTO->SavedESP)
                    st->EAX = stack->EBX
                    'wake the caller and run it directly
                    Scheduler.SetThreadReady(CurrentThread->ReplyTO)
                end if
            end if
			stack->ESP+=36
            return currentThread->DoWait(stack)
            
        case &h0C 'enable irq
            IRQ_ENABLE(stack->EBX)
            
        
        
        case &h0E 'signal trhead
            if (SlabMeta.IsValidAddr(cptr(any ptr,stack->ebx))=1) then
                XappSignal2Parameters(cptr(Thread ptr,stack->EBX),stack->ECX,stack->esi, stack->EDI)
                return Scheduler.Switch(stack,Scheduler.Schedule()) 
            end if
        case &h0F 'kill process
            if (SlabMeta.IsValidAddr(cptr(any ptr,stack->ebx))=1) then 
                var pc = cptr(Process ptr,stack->EBX)
                Process.Terminate(pc) 
                if (CurrentThread->Owner=pc) then  return Scheduler.Switch(stack, Scheduler.Schedule())
            end if
        case &h10 'get string
            if (currentThread->ReplyTo->IsValid()) then
                var phys = CurrentThread->ReplyTo->VMM_Context->Resolve(cptr(any ptr,stack->ESI))
                var virt = vmm_kernel_automap(phys,PAGE_SIZE,VMM_FLAGS_KERNEL_DATA)
                
                strcpy(cptr(unsigned byte ptr,stack->EDI),cptr(unsigned byte ptr,virt))
                stack->EAX = 1
            else
                stack->EAX = 0
            end if
        case &h11 'set string
            if (currentThread->ReplyTo->IsValid()) then
                var phys = CurrentThread->ReplyTo->VMM_Context->Resolve(cptr(any ptr,stack->EDI))
                 var virt = vmm_kernel_automap(phys,PAGE_SIZE,VMM_FLAGS_KERNEL_DATA)
                strcpy(cptr(unsigned byte ptr,virt),cptr(unsigned byte ptr,stack->ESI))
            end if
        case &h12 'Map buffer
            
            stack->EAX = 0
            if (currentThread->ReplyTo->IsValid()) then
                if (currentThread->ReplyTo->VMM_Context<>0) then
				
                    var startPage = stack->ESI and &hFFFFF000
                    var endPage = ((stack->ESI + stack->ECX -1) and &hFFFFF000)
					var nbPages = ((endPage-startPage) shr 12)+1
					var freePages = currentThread->VMM_Context->find_free_pages(nbPages,ProcessMapAddress,&hFFFFF000)
					if (freePages<>0) then
						var dst = freePages
						for i as unsigned integer=startPage to endPage step 4096
							var phys = CurrentThread->ReplyTo->VMM_Context->Resolve(cptr(any ptr,i))
							CurrentThread->VMM_Context->Map_Page(cptr(any ptr,dst),cptr(any ptr,phys),VMM_FLAGS_USER_DATA)
							dst+=4096
						next i
						stack->EAX = freePages or (stack->ESI and &hFFF)
					end if
                end if
            end if
		case &h13 'Unmap buffer
			var addr = stack->EBX
			var size = stack->ECX
			var startPage = stack->EBX and &hFFFFF000
			var endPage = (stack->EBX + stack->ECX -1) and &hFFFFF000
			for i as unsigned integer = startPage to endPage step 4096
				CurrentThread->VMM_Context->unmap_page(cptr(any ptr,i))
			next i
			
		case &h14 'mapBuffer to caller
			if (currentThread->ReplyTo->IsValid()) then
                if (currentThread->ReplyTo->VMM_Context<>0) then
				
                    var startPage = stack->ESI and &hFFFFF000
                    var endPage = ((stack->ESI + stack->ECX -1) and &hFFFFF000)
					var nbPages = ((endPage-startPage) shr 12)+1
					var freePages = currentThread->ReplyTo->VMM_Context->find_free_pages(nbPages,ProcessMapAddress,&hFFFFF000)
					if (freePages<>0) then
						var dst = freePages
						for i as unsigned integer=startPage to endPage step 4096
							var phys = CurrentThread->VMM_Context->Resolve(cptr(any ptr,i))
							CurrentThread->ReplyTo->VMM_Context->Map_Page(cptr(any ptr,dst),cptr(any ptr,phys),VMM_FLAGS_USER_DATA)
							dst+=4096
						next i
						stack->EAX = freePages or (stack->ESI and &hFFF)
					end if
                end if
            end if	
        case &h15 'get parent process
            stack->EAX = 0
            if (stack->EBX<>0) then
                if (SlabMeta.IsValidAddr(cptr(any ptr,stack->ebx))=1) then
                    var proc = cptr(Process ptr,stack->EBX)
                    stack->EAX =cuint( proc->Parent)
                end if
            else
                if (CurrentThread->Owner<>0) then
                    stack->EAX =cuint( CurrentThread->Owner->Parent)
                end if
            end if
'ipc related
        case &hC0 'define IPC handler
            var ep = IPCEndPoint.CreateID(stack->EBX,CurrentThread,stack->ECX,stack->EDX)
            if (ep<>0) then
                stack->EAX = ep->ID
            else
                stack->EAX = 0
            end if
            
            
        case &hC1 'end of ipc handler
            stack->ESP = stack->EBP
            
            if (CurrentThread->ReplyTO->IsValid()) then
                if ((CurrentThread->ReplyTO->State=ThreadState.WaitingReply) and (CurrentThread->ReplyTO->ReplyFrom = CurrentThread)) then
                    var st =cptr(IRQ_Stack ptr, CurrentThread->ReplyTO->SavedESP)
                    st->EAX = *cptr(unsigned integer ptr,stack->ESP+20)
                    st->EBX = *cptr(unsigned integer ptr,stack->ESP+24)
                    st->ECX = *cptr(unsigned integer ptr,stack->ESP+28)
                    'st->EDX = *cptr(unsigned integer ptr,stack->ESP+32)
                    'st->ESI = *cptr(unsigned integer ptr,stack->ESP+36)
                    'st->EDI = *cptr(unsigned integer ptr,stack->ESP+40)
                    'st->EBP = *cptr(unsigned integer ptr,stack->ESP+44)
                    
                    'reply directly from interrupt
                    Scheduler.SetThreadReady(CurrentThread->ReplyTO)
                end if
            end if
			stack->ESP+=48
            return currentThread->DoWait(stack)
        
        case &hC2 'IPC Send
            var endPoint = IPCEndPoint.FindBYId(stack->EBX)
            if (endPoint<>0) then
                
                dim body as IPCMessageBody ptr = cptr(IPCMessageBody ptr,stack->ECX)
                var ipcSendResult = IPCSendBody(stack->EBX,CurrentThread,body)
               
                if (ipcSendResult<>0) then
                    'caller must wait
                    if (endPoint->Synchronous = 1) then
                        stack->EAX = &hFF
                        CurrentThread->State=ThreadState.WaitingReply
                        CurrentThread->ReplyFrom=endPoint->Owner
                        return  Scheduler.Switch(stack,Scheduler.Schedule()) 
                    elseif (ipcSendResult = 2) then 'received is waked up
                        return  Scheduler.Switch(stack,Scheduler.Schedule()) 
                    end if
                end if
            end if
            
        case &hD0 'page alloc
            stack->EAX = 0
            if (CurrentThread<>0) then
                if (CurrentThread->Owner<>0) then
                    IRQ_DISABLE(0)
                    var freeAddr = CurrentThread->VMM_Context->find_free_pages(stack->EBX,ProcessHeapAddress,&hFFFFFFFF)
                    var addressSpace = CurrentThread->Owner->CreateAddressSpace(freeAddr)
                    addressSpace->SBRK(stack->EBX)
                    stack->EAX=freeAddr
                    IRQ_ENABLE(0)
'                    if(CurrentThread->Owner->HeapAddressSpace<>0) then
'                        stack->EAX = cuint(CurrentThread->Owner->HeapAddressSpace->SBRK(stack->EBX))
'                    end if
                end if
            end if
        case &hD1 'Page Free
            if (CurrentThread<>0) then
                if (CurrentThread->Owner<>0) then
                    IRQ_DISABLE(0)
                    CurrentThread->Owner->RemoveAddressSpace(stack->EBX)
                    IRQ_ENABLE(0)
                end if
            end if
            
        case &hE0 'Wait N time slice
             'asm cli
             Scheduler.SetThreadRealTime(CurrentThread,stack->EBX)
             'asm sti
             return  Scheduler.Switch(stack,Scheduler.Schedule()) 
        case &hE1'enter critical
            EnterCritical()
		case &hE2 'exit critical
			ExitCritical()
            
        case &hE3 'Mutex init
            var _mutex = cptr(Mutex ptr,KAlloc(sizeof(Mutex)))
            _mutex->Constructor
            stack->EAX  = cuint(_mutex)
        case &hE4 'Mutex acquire
            if (SlabMeta.IsValidAddr(cptr(any ptr,stack->ebx))=1) then
                var _mutex = cptr(Mutex ptr, stack->EBX)
                if (not _mutex->Acquire(CurrentThread)) then
                    return  Scheduler.Switch(stack,Scheduler.Schedule()) 
                end if
            end if
        case &hE5 'Mutex release
            if (SlabMeta.IsValidAddr(cptr(any ptr,stack->ebx))=1) then
                var _mutex = cptr(Mutex ptr, stack->EBX)
                _mutex->Release(CurrentThread) 
            end if
             
        case &hE6'create signal
                var si = cptr(Signal ptr,KAlloc(sizeof(Signal)))
                si->Constructor()
                stack->EAX = cuint(si)
        case &hE7'signal wait
            if (SlabMeta.IsValidAddr(cptr(any ptr,stack->ebx))=1) then
                var si = cptr(Signal ptr, stack->EBX)
                if (not si->Wait(CurrentThread)) then
                    return  Scheduler.Switch(stack,Scheduler.Schedule()) 
                end if
            end if
        case &hE8'signal set
            if (SlabMeta.IsValidAddr(cptr(any ptr,stack->ebx))=1) then
                var si = cptr(Signal ptr, stack->EBX)
                si->Set() 
            end if
         
        case &hE9 '
             
             dim u0 as unsigned longint = TotalEllapsed
             dim i0 as unsigned integer
             dim i1 as unsigned integer
             asm
                 mov eax,[u0]
                 mov ebx,[u0+4]
                 mov [i0],eax
                 mov [i1],ebx
             end asm
             
             stack->EAX = i0
             stack->EBX = i1   
             
        case &hF0 'Random
            stack->EAX = NextRandomNumber(stack->EBX,stack->ECX)
        case &hF1 'GetTimeBCD
            stack->EAX = GetTimeBCD()
        case &hF2 '
            stack->EAX = GetDateBCD()
		case &hF3
			stack->EAX = (XRes shl 16) or YRes
			stack->EBX = BPP
			stack->ECX = LFBSize
			stack->EDI = LFB
        case &hF4 'mem info
            stack->EAX = TotalPagesCount
            stack->EBX = TotalFreePages
            stack->ECX = SlabMeta.SlabCount
        case &hF5 'CPU IDLE COunt
            stack->EAX = IDLE_ThreadRunCount
            IDLE_ThreadRunCount = 0
    end select
    return stack
end function


		