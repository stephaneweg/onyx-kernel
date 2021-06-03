extern realmode_begin alias "realmode_begin" as byte
extern realmode_end   alias "realmode_end"   as byte

sub RealMode_INIT()
    ConsoleWrite(@"Loading realmode module ... ")
    dim fsize as unsigned integer=0
    dim abuffer as unsigned byte ptr=0
    dim rstart as unsigned byte ptr = @realmode_begin
    dim rend as unsigned byte ptr = @realmode_end
    
    MemCpy(cptr(unsigned byte ptr,RealModeAddr),rstart,cuint(rend)-cuint(rstart))
    
    ConsoleNewLine()
    
end sub

sub DoRealModeAction(src as  REALMODE_MODULE ptr)
    
    
    dim module as REALMODE_MODULE ptr
    dim rmsub as sub()
	module= cptr(REALMODE_MODULE ptr,RealModeAddr)
    if (module->Magic<>&hABCDABCD) then
        ConsoleSetForeground(4)
        ConsoleWriteLine(@"Real mode module : incorrect magic")
        ConsoleSetForeground(7)
		return
    end if
    
    rmsub=cptr(sub(), RealModeAddr + sizeof(REALMODE_MODULE))
    
    if (src<>module) then
        module->INT_NO=src->int_no
        module->EAX=src->eax
        module->EBX=src->ebx
        module->ECX=src->ecx
        module->EDX=src->edx
        module->ESI=src->esi
        module->EDI=src->edi
        module->ES=src->es
    end if
    
    module->PMIdt=cast(unsigned integer,@IDT_POINTER)
	rmsub()
    
    if (src<>module) then
        src->INT_NO=src->int_no
        src->EAX=module->eax
        src->EBX=module->ebx
        src->ECX=module->ecx
        src->EDX=module->edx
        src->ESI=module->esi
        src->EDI=module->edi
        src->ES=module->es
    end if
end sub

sub DoRealModeActionReg(eax as unsigned integer,ebx as unsigned integer,ecx as unsigned integer,edx as unsigned integer, esi as unsigned integer,edi as unsigned integer,es as unsigned integer,intno as unsigned integer)
    dim module as REALMODE_MODULE ptr
	module= cptr(REALMODE_MODULE ptr,RealModeAddr)
    	
    module->INT_NO=intno
    module->EAX=eax
    module->EBX=ebx
    module->ECX=ecx
    module->EDX=edx
    module->ESI=esi
    module->EDI=edi
    module->ES=es
	
    DoRealModeAction(module)
end sub