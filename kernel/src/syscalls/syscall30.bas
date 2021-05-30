function SysCall30Handler(stack as IRQ_Stack ptr) as IRQ_Stack ptr
    dim CurrentThread as Thread ptr = Scheduler.CurrentRuningThread
    select case stack->EAX
        case &h01 'load app from memory
            var ctx = vmm_get_current_context()
            var p=Process.RequestLoadUser(cptr( EXECUTABLE_HEADER ptr,stack->EBX),stack->ECX,0)
            ctx->Activate()
            if (p<>0) then 
                    stack->EAX = 1
                    return Scheduler.Switch(stack, Scheduler.Schedule())
            else
                stack->EAX=0
            end if
        case &h02 'create thread
            var prio = stack->ECX
            if (prio<currentThread->BasePriority) then prio = CurrentThread->BasePriority
            var th = Thread.Create(currentThread->Owner,cptr(sub(p as any ptr),stack->EBX),prio)
            stack->EAX = cuint(th)
        
        case &h03 'yield
            return Scheduler.Switch(stack, Scheduler.Schedule())
            
        case &h04
			return currentThread->DoWait(stack)
        case &h05
			Process.RequestTerminateProcess(currentThread->Owner)
            return Scheduler.Switch(stack, Scheduler.Schedule())
        case &h06 ' thread wake up
            var th = cptr(Thread ptr,stack->EBX)
            var st =cptr(IRQ_Stack ptr,  th->SavedESP)
            st->EAX = stack->ECX
            st->EBX = stack->EDX
            if (th->State=ThreadState.WaitingReply or th->State=ThreadState.Waiting) then
                Scheduler.SetThreadReady(th,th->BasePriority)
            end if
        case &h07 'UDev create
            UserModeDevice.Create(cptr(unsigned byte ptr,stack->EBX),currentThread,stack->ECX,stack->EDX)
        case &h08 'UDEV Find
            stack->EAX =cuint( UserModeDevice.Find(cptr(unsigned byte ptr,stack->EBX)))
        case &h09 'UDev invoke
            if (UserModeDevice.Invoke(stack->EBX,currentThread,stack->ECX,stack->EDX,stack->ESI,stack->EDI)=1) then
                return Scheduler.Switch(stack,Scheduler.Schedule()) 
            else
                stack->EAX = 0
            end if
        case &h0A 'UDev return
            stack->ESP = stack->EBP
            
            if (CurrentThread->ReplyTO<>0) then
                if ((CurrentThread->ReplyTO->State=ThreadState.WaitingReply) and (CurrentThread->ReplyTO->ReplyFrom = CurrentThread)) then
                    var st =cptr(IRQ_Stack ptr, CurrentThread->ReplyTO->SavedESP)
                    st->EAX = stack->EBX
                    Scheduler.SetThreadReady(CurrentThread->ReplyTO,CurrentThread->ReplyTO->BasePriority)
                end if
            end if
			stack->ESP+=36
            return currentThread->DoWait(stack)
            
        case &h0B 'define irq handler
            IRQ_SET_THREAD_HANDLER(stack->EBX,CurrentThread,stack->ECX,stack->EDX)
       
        case &h0C 'enable irq
            IRQ_ENABLE(stack->EBX)
            
        case &h0D 'end of interrupt and signal sender
			
            stack->ESP = stack->EBP
            
            if (CurrentThread->ReplyTO<>0) then
                if ((CurrentThread->ReplyTO->State=ThreadState.WaitingReply) and (CurrentThread->ReplyTO->ReplyFrom = CurrentThread)) then
                    var st =cptr(IRQ_Stack ptr, CurrentThread->ReplyTO->SavedESP)
                    st->EAX = *cptr(unsigned integer ptr,stack->ESP+16)
                    st->EBX = *cptr(unsigned integer ptr,stack->ESP+20)
                    st->ECX = *cptr(unsigned integer ptr,stack->ESP+24)
                    st->EDX = *cptr(unsigned integer ptr,stack->ESP+28)
                    st->ESI = *cptr(unsigned integer ptr,stack->ESP+32)
                    st->EDI = *cptr(unsigned integer ptr,stack->ESP+36)
                    st->EBP = *cptr(unsigned integer ptr,stack->ESP+40)
                    Scheduler.SetThreadReady(CurrentThread->ReplyTO,CurrentThread->ReplyTO->BasePriority)
                end if
            end if
			stack->ESP+=40
            return currentThread->DoWait(stack)
        
        case &h0E 'signal trhead
            XappSignal2Parameters(cptr(Thread ptr,stack->EBX),stack->ECX,stack->esi, stack->EDI)
        case &h0F 'kill process
            var th = cptr(thread ptr,stack->EBX)
			Process.TerminateNow(th->Owner)
            if (th= CurrentThread) then return Scheduler.Switch(stack, Scheduler.Schedule())
        case &h10 'get string
            if (currentThread->ReplyTo<>0) then
                var phys = CurrentThread->ReplyTo->VMM_Context->Resolve(cptr(any ptr,stack->ESI))
                
                strcpy(cptr(unsigned byte ptr,stack->EDI),cptr(unsigned byte ptr,phys))
                stack->EAX = 1
            else
                stack->EAX = 0
            end if
        case &h11 'set string
            if (currentThread->ReplyTo<>0) then
                var phys = CurrentThread->ReplyTo->VMM_Context->Resolve(cptr(any ptr,stack->EDI))
                strcpy(cptr(unsigned byte ptr,phys),cptr(unsigned byte ptr,stack->ESI))
            end if
        case &h12 'Map buffer
            
            stack->EAX = 0
            if (currentThread->ReplyTo<>0) then
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
			if (currentThread->ReplyTo<>0) then
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
			
        case &hD0 'page alloc
            stack->EAX = (CurrentThread->Owner->SBRK(stack->EBX) shl 12) + ProcessAddress
            
        case &hE0 'Wait N time slice
             Scheduler.SetThreadRealTime(CurrentThread,stack->EBX)
             return  Scheduler.Switch(stack,Scheduler.Schedule()) 
        case &hE1'enter critical
            EnterCritical()
		case &hE2 'exit critical
			ExitCritical()
            
        case &hE3 'semaphore init
            var sem = cptr(Semaphore ptr,KAlloc(sizeof(Semaphore)))
            sem->Constructor
            stack->EAX  = cast(unsigned integer,sem)
        case &hE4 'semaphore lock
            var sem = cptr(Semaphore ptr, stack->EBX)
            if (not sem->SemLock(CurrentThread)) then
                return  Scheduler.Switch(stack,Scheduler.Schedule()) 
            end if
        case &hE5 'semaphore unlock
            var sem = cptr(Semaphore ptr, stack->EBX)
            sem->SemUnlock(CurrentThread)    
        case &hE6 '
             
             dim u0 as unsigned long = TotalEllapsed
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
        case &hFFFF
            currentThread->BasePriority = stack->EBX
    end select
    return stack
end function


		