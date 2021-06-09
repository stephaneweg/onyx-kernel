
constructor Instruction
    AType = InstructionType.None
    source  = 0
    isBlockInstruction = 0
    isNextBlockInstruction = 0
    nextInstruction = 0
    prevInstruction = 0
    firstInstruction = 0
    lastInstruction = 0
    StackPointer = 0
    OnDestroy = @DestroyInstruction
    OnProcess = @ProcessUnknownInstruction
end constructor


destructor Instruction()
    var i = FirstInstruction
    while i<>0
        var n=i->NextInstruction
        cptr(sub(ins as instruction ptr),i->OnDestroy)(i)
        i=n
    wend
end destructor

constructor EndBlockInstruction()
    isEndBlockInstruction = 1
end constructor

constructor BlockInstruction()
    IsBLockInstruction = 1
end constructor

constructor BlockElseInstruction()
    IsBLockInstruction = 1
    isNextBlockInstruction = 1
end constructor

constructor ProgramBlockInstruction
    AType = InstructionType.ProgramInstruction
    OnProcess = @ProcessProgramInstruction
end constructor

constructor EndProgramInstruction
    AType  = InstructionType.EndProgramInstruction
    OnProcess = @ProcessEndProgramInstruction
end constructor

constructor Parameter(pname as unsigned byte ptr,ptype as unsigned byte ptr,_isPtr as integer)
    this.IDName = pname
    this.ISPointer = _isPtr
    
    if (strcmp(ptype,@"byte")=0) then
        IDType = IdentifierType.TByte
        IDSize = 1
    elseif (strcmp(ptype,@"ubyte")=0) then
        IDType = IdentifierType.TUByte
        IDSize = 1
    elseif (strcmp(ptype,@"short")=0) then
        IDType = IdentifierType.TShort
        IDSize = 2
    elseif (strcmp(ptype,@"ushort")=0) then
        IDType = IdentifierType.TUShort
        IDSize = 2
    elseif  (strcmp(ptype,@"int")=0) then
        IDType = IdentifierType.TInt
        IDSize = 4
    elseif (strcmp(ptype,@"uint")=0) then
        IDType = IdentifierType.TUInt
        IDSize = 4
    elseif (strcmp(ptype,@"long")=0) then
        IDType = IdentifierType.TLong
        IDSize = 8
    elseif (strcmp(ptype,@"ulong")=0) then
        IDType = IdentifierType.TULong
        IDSize = 8
    elseif (strcmp(ptype,@"single")=0) then
        IDType = IdentifierType.TSingle
        IDSize = 4
    elseif (strcmp(ptype,@"double")=0) then
        IDType = IdentifierType.TDouble
        IDSize = 8
    elseif (strcmp(ptype,@"string")=0) then
        IDType = IdentifierType.TString
        IDSize = 4
        ISPointer = 1
    else 
        IDType = IdentifierType.TClass
        IDSize = 4
        ISPointer = 1
    end if
end constructor

constructor SubBlockInstruction(l as SourceLine ptr)
    AType  = InstructionType.SubInstruction
    OnProcess = @ProcessSubInstruction
    SubName = l->Tokens(1)
    ParametersSize = 0
    ParametersCount = 0
    
    Parameters = 0
    LastParameter = 0
    
    for i as unsigned integer= 2 to l->TokenCount-1
        if (strcmp(l->Tokens(i),@"as")=0) then
            var p =new Parameter(l->Tokens(i-1),l->Tokens(i+1),strcmp(l->Tokens(i+2),@"ptr")=0)
            if (LastParameter<>0) then
                LastParameter->NextParameter=p
            else
                Parameters = p
            end if
            
            p->IDOffset = 8+ParametersSize
            p->PrevParameter = LastParameter
            p->NextParameter = 0
            
            LastParameter = p
            ParametersSize+=p->IDSize
            ParametersCount+=1
        end if
    next i
    
end constructor

constructor EndSubInstruction()
    AType = InstructionType.EndSubInstruction
    OnProcess = @ProcessEndSubInstruction
end constructor


constructor ForBlockInstruction(l as SourceLine ptr)
    AType = InstructionType.ForInstruction
    OnProcess = @ProcessForInstruction
    InitialValue = 0
    LimitValue = 0
    StepValue = 0
    Direction = 1
    
    dim hasLimit as integer = 0
    dim t as unsigned byte
    dim prev as unsigned integer = 1
    for cpt as integer = 1 to l->TokenCount-1
        if (strcmp(l->Tokens(cpt),@"=")=0) then
            TargetIdentifier = Operand.Construct(@l->Tokens(0),prev,cpt-1)
            Prev = cpt+1
        elseif(strcmp(l->Tokens(cpt),@"to")=0) then
            InitialValue = Operand.Construct(@l->Tokens(0),prev,cpt-1)
            prev = cpt+1
        elseif(strcmp(l->Tokens(cpt),@"step")=0) then
            LimitValue = Operand.Construct(@l->Tokens(0),prev,cpt-1)
            prev= cpt+1
            hasLimit = 1
        end if
    next
    if (prev<=l->TokenCount-1) then
        if (hasLimit = 0) then
            LimitValue  = Operand.Construct(@l->Tokens(0),prev,l->TokenCount-1)
            StepValue   = Operand.ConstructSimple(@"1")
        else
            StepValue   = Operand.Construct(@l->Tokens(0),prev,l->TokenCount-1)
        end if
    end if
end constructor

constructor NextEndInstruction()
    AType = InstructionType.NextInstruction
    OnProcess = @ProcessNextInstruction
end constructor

function Operand.Construct(t as unsigned byte ptr ptr,iFirst as unsigned integer,iLast as unsigned integer) as Operand ptr
    var op = cptr(Operand ptr,malloc(sizeof(Operand)))
    for cpt as unsigned integer = iFirst to iLast
        op->Tokens(op->TokenCount) = t[cpt]
        op->TokenCount+=1
    next
    return op
end function

function Operand.ConstructSimple(t as unsigned byte ptr) as Operand ptr
    var op = cptr(Operand ptr,malloc(sizeof(Operand)))
    op->TokenCount=1
    op->Tokens(0)=t
    return op
end function

sub DestroyInstruction(i as Instruction ptr)
    
    i->Destructor()
    free(i)
end sub



sub ProcessUnknownInstruction(i as Instruction ptr)
end sub

sub ProcessProgramInstruction(i as ProgramBlockInstruction ptr)
    ConsoleWrite(@"use32"):ConsoleNewLine()
    ConsoleWrite(@"org 0x40000000"):ConsoleNewLine()
    ConsoleWrite(@"IMAGE_START:"):ConsoleNewLine()
    ConsoleWrite(@"dd 0xAADDBBFF"):ConsoleNewLine()
    ConsoleWrite(@"dd _init"):ConsoleNewLine()
    ConsoleWrite(@"_argc: dd 0x0"):ConsoleNewLine()
    ConsoleWrite(@"dd _argv"):ConsoleNewLine()
    ConsoleWrite(@"dd IMAGE_END"):ConsoleNewLine()
	ConsoleNewLIne()
    ConsoleWrite(@"_init"):ConsoleNewLine()
    ConsoleWrite(@"push _argv"):ConsoleNewLine()
    ConsoleWrite(@"push dword [_argc]"):ConsoleNewLine()
    ConsoleWrite(@"call main"):ConsoleNewLine()
    ConsoleWrite(@"ret"):ConsoleNewLine():ConsoleNewLine()
end sub

sub ProcessEndProgramInstruction(i as ProgramBlockInstruction ptr)
     ConsoleWrite(@"_argv:"):ConsoleNewLine()
     ConsoleWrite(@"rb 1024"):ConsoleNewLine()
     ConsoleWrite(@"IMAGE_END:"):ConsoleNewLine()
end sub

sub ProcessSubInstruction(i as SubBlockInstruction ptr)
    ConsoleWrite(i->SubName):ConsoleWrite(@":"):ConsoleNewLine()
    ConsoleWrite(@"push ebp"):ConsoleNewLine()
    ConsoleWrite(@"mov ebp,esp"):ConsoleNewLine()
    
    var p = i->Parameters
    while (p<>0)
        ConsoleWrite(@";"):ConsoleWrite(p->IDName):
        if (p->IDOffset>=0) then
            ConsoleWrite(@" = [EBP+")
        else
            ConsoleWrite(@" = [EBP")
        end if
        ConsoleWrite(IntToStr(p->IDOffset,10)):ConsoleWrite(@"]"):ConsoleNewLine()
        p=p->NextParameter
    wend
end sub


sub ProcessEndSubInstruction(i as EndSubInstruction ptr)
    dim parent as SubBlockInstruction ptr = cptr(SubBlockInstruction ptr,i->parentInstruction) 
    ConsoleWrite(@"mov esp,ebp"):ConsoleNewLine()
    ConsoleWrite(@"pop ebp"):ConsoleNewLine()
    if (parent->ParametersSize>0) then
        ConsoleWrite(@"ret "):ConsoleWrite(intToStr(parent->ParametersSize,10)):ConsoleNewLine()
    else
        ConsoleWrite(@"ret"):ConsoleNewLine()
    end if
    ConsoleNewLine()
end sub

sub ProcessForInstruction(i as ForBlockInstruction ptr)
    ProcessGetter(i->InitialValue,i)
    ProcessAssign(i->TargetIdentifier,i)
    ConsoleWrite(@"_For_begin:"):ConsoleNewLine()
    ProcessGetter(i->TargetIdentifier,i)
    ProcessGetter(i->LimitValue,i)
    ConsoleWrite(@"pop ebx"):ConsoleNewLine()
    ConsoleWrite(@"pop eax"):ConsoleNewLine()
    ConsoleWrite(@"cmp eax,ebx"):ConsoleNewLine()
    if (i->Direction=1) then
        ConsoleWrite(@"jg ")
    else
        ConsoleWrite(@"jl ")
    end if
    ConsoleWrite(@" _For_end")
    ConsoleNewLine()    
end sub

sub ProcessNextInstruction(i as NextEndInstruction ptr)
    if (i->ParentInstruction->AType = ForInstruction) then
        var parentFor = cptr(ForBlockInstruction ptr,i->ParentInstruction)
        processGetter(parentFor->StepValue,parentFor)
        processGetter(parentFor->TargetIdentifier,parentFor)
        ConsoleWrite(@"pop eax"):ConsoleNewLine()
        ConsoleWrite(@"pop ebx"):ConsoleNewLine()
        ConsoleWrite(@"add eax,ebx"):COnsoleNewLine()
        ConsoleWrite(@"push eax"):COnsoleNewLine()
        ProcessAssign(parentFor->TargetIdentifier,parentFor)
        ConsoleWrite(@"jmp _For_begin"):ConsoleNewLine()
        ConsoleWrite(@"_For_end"):ConsoleNewLine()
    else
        Print "Error : unexpected next"
        asm
            jmp _EndProgram
        end asm
    end if
end sub

sub ProcessGetterEX(tokens as unsigned byte ptr,count as integer,i as Instruction ptr)
    
end sub
sub ProcessGetter(source as Operand ptr,i as Instruction ptr)
    'result will be in the stack
    if (source->TokenCount=1) then
        ConsoleWrite(@"push ")
        ConsoleWrite(source->Tokens(0))
        ConsoleNewLine()
    else
        dim parenthesis as integer = 0
        dim braces as integer = 0
        for i as integer = 0 to source->TokenCount-1
            if (strcmp(source->Tokens(i),@"(")=0) then
                parenthesis+=1
            elseif (strcmp(source->Tokens(i),@"[")=0) then
                braces+=1
            elseif (strcmp(source->Tokens(i),@"]")=0) then
                braces-=1
             elseif (strcmp(source->Tokens(i),@")")=0) then
                parenthesis-=1
            end if
        next i
    end if
end sub

sub ProcessAssign(target as Operand ptr,i as Instruction ptr)
    'value to assign should be in the stack
    if (target->TokenCount=1) then
        ConsoleWrite(@"pop ")
        'to do : find the [ebp-x] or [ebp+x] if its a variable
        ConsoleWrite(target->Tokens(0))
        ConsoleNewLine()
    end if
end sub