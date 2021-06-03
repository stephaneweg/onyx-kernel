
#include once "instructions.bi"
constructor Instruction()
    IType       = instructionType.None
    OnProcess   = @ProcessInstruction
    OnDestroy   = @DestroyInstruction
    OnProcessEpilogue = 0
    EndInstruction    = 0
    OnProcessChildrenAfter = 0
    ScopeVarNum = 0
    Level       = 0
    FirstNode   = 0
    LastNode    = 0
    NextNode    = 0
    PrevNode    = 0
    ParentNode  = 0
    Tokens      = 0
    TokenString = 0
    TokenCount  = 0
    InClass     = 0
    IsClass     = 0
end constructor


destructor Instruction()
    'if (Tokens<>0) then print "destructor ";: ConsoleWrite(Tokens[0]):ConsoleNewLine()
    if (Tokens<>0) then free (Tokens)
    if (TokenString<>0) then free (TokenString)
    
    var n = this.FirstNode
    while n<>0
        var nn = n->NextNode
        cptr(sub(i as Instruction ptr),n->OnDestroy)(n)
        n = nn
    wend
    
    if (EndInstruction<>0) then
        cptr(sub(i as Instruction ptr),EndInstruction->OnDestroy)(EndInstruction)
    end if 
end destructor

sub DestroyInstruction(i as instruction ptr)
    delete i
end sub

sub ProcessInstruction(p as instruction ptr)
    if (p->TokenCount>0) then
       for i as unsigned integer = 0 to p->Level
           print "    ";
       next 
       
       if (p->InClass) then
           print " (IN CLASS)";
       end if
       ConsoleWrite(p->Tokens[0]):ConsoleNewLine()
       
       for i as unsigned integer=1 to p->TokenCount-1
           for j as unsigned integer = 0 to p->Level
               print "    ";
           next 
           print " *";
           
           ConsoleWrite(p->Tokens[i]):ConsoleNewLine()
       next
    end if
end sub



'------------------------------------------------


constructor ProcedureInstruction(parent as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    IType = Procedure
    OnDestroy = @DestroyProcedureInstruction
    OnProcess = @ProcessProcedureInstruction
    OnProcessEpilogue = @ProcessProcedureInstructionEpilogue
    FirstParameter = 0 
    LastParameter = 0
    ParametersCount = 0
    ProcedureName = tokens[1]
    if (parent<>0 and parent->IsClass) then
        AddParameter(@"this")
    end if
    
   
    
    for i as unsigned integer = 2 to count-1
        if (strcmp(tokens[i],@"(")<>0) and (strcmp(tokens[i],@")")<>0) and (strcmp(tokens[i],@",")<>0)then
            AddParameter(tokens[i])
        end if
    next
    
    
    if (ParametersCount>0) then
        var parm = FirstParameter
        dim pi as unsigned integer = 0
        while parm<>0
            parm->index = pi
            strcpy(parm->VarSymbol,@"[ebp+")
            strcpy(parm->VarSymbol+strlen(parm->VarSymbol),IntToStr((parm->index+1) *4,10))
            strcpy(parm->VarSymbol+strlen(parm->VarSymbol),@"]")
            
            pi+=1
            parm=parm->NextParameter
        wend
    end if
end constructor

destructor ProcedureInstruction()
    var p = this.FirstParameter
    while p<>0
        var pp = p->NextParameter
        delete p
        p = pp
    wend
end destructor

sub DestroyProcedureInstruction(i as ProcedureInstruction ptr)
    delete i
end sub

sub ProcessProcedureInstruction(p as ProcedureInstruction ptr)
    
    ConsoleNewLine()
    if (p->InClass and p->ParentNode<>0) then
        ConsoleWrite(cptr(ClassInstruction ptr,p->ParentNode)->ClassName)
        ConsoleWrite(@"_")
    end if
    ConsoleWrite(p->ProcedureName)
    ConsoleWrite(@":")
    ConsoleNewLine()
    
    ConsoleWrite(@"push ebp"):ConsoleNewLine()
    ConsoleWrite(@"mov ebp,esp"):ConsoleNewLine()
    var parm = p->FirstParameter
    while parm<>0
        ConsoleWrite(@";"):consoleWrite(parm->pName):ConsoleWrite(@" = [EBP+"):print (((parm->Index)*4)+4);:print("]")
        parm=parm->NextParameter
    wend
end sub

sub ProcessProcedureInstructionEpilogue(p as ProcedureInstruction ptr)
    ConsoleWrite(@"mov esp,ebp"):ConsoleNewLine()
    ConsoleWrite(@"pop ebp"):ConsoleNewLine()
    if (p->ParametersCount>0) then
        ConsoleWrite(@"ret "):ConsoleWrite(intToStr(p->ParametersCount*4,10)):ConsoleNewLine()
    else
        ConsoleWrite(@"ret"):ConsoleNewLine()
    end if
    ConsoleNewLine()
end sub


sub ProcedureInstruction.AddParameter(n as unsigned byte ptr)
    var p = new ProcedureParameter()
    p->pname = n
    
    ParametersCount += 1
    
    if (this.LastParameter<>0) then 
        this.LastParameter->NextParameter = p
    else
        this.FirstParameter = p
    end if
    p->NextParameter = 0
    this.LastParameter = p
    
end sub

'--------------------------------

constructor ClassInstruction(tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    OnDestroy = @DestroyClassInstruction
    OnProcess = @ProcessClassInstruction
    IsClass = 1
    ClassName = tokens[1]
end constructor

destructor ClassInstruction()
end destructor

sub DestroyClassInstruction(i as ClassInstruction ptr)
    delete i
end sub

sub ProcessClassInstruction(p as ClassInstruction ptr)
end sub

'------------------
constructor VarInstruction(parent as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    OnDestroy = @DestroyVarInstruction
    OnProcess = @ProcessVarInstruction
    VarSymbol = malloc(50)
    IType = Variable
    if (parent=0) then 
        IsGlobal = 1
    elseif(parent->ParentNode = 0) then
        IsGlobal = 1
    else
        IsGlobal = 0
        VarNum = parent->ScopeVarNum
        parent->ReserveVar()
    end if
    VarName = tokens[1]
    if (isGlobal=1) then
        
        strcpy(VarSymbol,@"[_")
        strcpy(VarSymbol+strlen(VarSymbol),VarName)
        strcpy(VarSymbol+strlen(VarSymbol),@"]")
    else
        strcpy(VarSymbol,@"[ebp-")
        strcpy(VarSymbol+strlen(VarSymbol),IntToStr((VarNum+1)*4,10))
        strcpy(VarSymbol+strlen(VarSymbol),@"]")
    end if
end constructor

destructor VarInstruction()
    free(VarSymbol)
end destructor

sub DestroyVarInstruction(i as varInstruction ptr)
    delete i
end sub

sub ProcessVarInstruction(p as varInstruction ptr)
    if (p->IsGlobal=0) then
        ConsoleWrite(@";Variable : "):ConsoleWrite(p->VarName):ConsoleWrite(@"(index :"):ConsoleWrite(IntToStr(p->VarNum,10)):ConsoleWrite(@")"):ConsoleNewLine()
        ConsoleWrite(@"sub esp,4")
        ConsoleNewLine()
        p->ParentNode->ReserveVar()
        
    else
        ConsoleWrite(@";Variable : "):ConsoleWrite(p->VarName):ConsoleNewLine()
        ConsoleWrite(@"_"):ConsoleWrite(p->VarName):ConsoleWrite(@" dd 0x0"):ConsoleNewLine()
    end if
end sub

constructor IfInstruction(parent as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    ElseInstruction = 0
    ILabelNum = AutoLabelNum
    AutoLabelNum+=1
    OnDestroy = @DestroyIfInstruction
    OnProcess = @ProcessIfInstruction
    OnProcessEpilogue = @ProcessChildrenEndIfInstruction
    IType = IFStatement
    if (count>1) then
        Condition = new OPerand(0,@this,@tokens[1],tokenString,count-1)
    else
        Condition = 0
    end if
end constructor

destructor IfInstruction()
    if (ElseInstruction<>0) then
        cptr(sub(i as Instruction ptr),ElseInstruction->OnDestroy)(ElseInstruction)
    end if
    if (Condition<>0) then
        delete Condition
    end if
end destructor


sub DestroyIfInstruction(i as IfInstruction ptr)
    delete i
end sub

sub ProcessIfInstruction(p as IfInstruction ptr)
    ConsoleWrite(p->tokens[0]):ConsoleNewLine()
 
    if (strcmp(p->Tokens[0],@"else")<>0) then
        if (p->Condition<>0) then
            p->Condition->Process()
            
            if (p->Condition->OP<>0) then
                if (strcmp(p->Condition->OP,@"=")=0) then
                    ConsoleWrite(@"cmp eax,ebx"):ConsoleNewLine()
                    ConsoleWrite(@"jne")
                elseif (strcmp(p->Condition->OP,@">")=0) then
                    ConsoleWrite(@"cmp eax,ebx"):ConsoleNewLine()
                    ConsoleWrite(@"jbe")
                elseif (strcmp(p->Condition->OP,@"<")=0) then
                    ConsoleWrite(@"cmp eax,ebx"):ConsoleNewLine()
                    ConsoleWrite(@"jae")
                elseif (strcmp(p->Condition->OP,@"or")=0) then
                    'ConsoleWrite(@"cmp eax,ebx"):ConsoleNewLine()
                    ConsoleWrite(@"jz")
                elseif (strcmp(p->Condition->OP,@"and")=0) then
                    'ConsoleWrite(@"cmp eax,ebx"):ConsoleNewLine()
                    ConsoleWrite(@"jz")
                end if
            else
                ConsoleWrite(@"test eax,eax"):ConsoleNewLine()
                ConsoleWrite(@"JZ")
            end if
            ConsoleWrite(@" _NOT_IF_"):ConsoleWrite(IntToStr(p->ILabelNum,10)):ConsoleNewLine()
        end if
    end if
end sub

sub ProcessChildrenEndIfInstruction(p as IfInstruction ptr)
    if (p->ElseInstruction<>0) then
        ConsoleWrite(@"JMP _END_IF_"):ConsoleWrite(IntToStr(p->ILabelNum,10)):ConsoleWrite(@":"):ConsoleNewLine()
    end if
    if (strcmp(p->Tokens[0],@"else")<>0) then
        ConsoleWrite(@"_NOT_IF_"):ConsoleWrite(IntToStr(p->ILabelNum,10)):ConsoleWrite(@":"):ConsoleNewLine()
    end if
    if (p->ElseInstruction<>0) then p->ElseInstruction->Process()
    if (p->ElseInstruction<>0) then
        ConsoleWrite(@"_END_IF_"):ConsoleWrite(IntToStr(p->ILabelNum,10)):ConsoleWrite(@":"):ConsoleNewLine()
    end if
end sub

constructor ProcedureParameter()
    nextParameter = 0
    VarSymbol = malloc(50)
end constructor

destructor ProcedureParameter()
    free(varSymbol)
end destructor




function Instruction.Construct(parent as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer) as instruction ptr
    dim ret as Instruction ptr
    if (strcmp(tokens[0],@"sub")=0) then
        ret = new ProcedureInstruction(parent,tokens,tokenString,count)
    elseif (strcmp(tokens[0],@"class")=0) then
        ret = new ClassInstruction(tokens,tokenString,count)
    elseif (strcmp(tokens[0],@"var")=0) then
        ret = new VarInstruction(parent,tokens,tokenString,count)
    elseif (strcmp(tokens[0],@"if")=0) then
        ret = new IfInstruction(parent,tokens,tokenString,count)
    elseif (strcmp(tokens[0],@"else")=0) then
        ret = new IfInstruction(parent,tokens,tokenString,count)
    elseif (strcmp(tokens[0],@"elseif")=0) then
        ret = new IfInstruction(parent,tokens,tokenString,count)
    else
        ret = new Instruction()
    end if
    ret->Tokens = tokens
    ret->TokenString = tokenString
    ret->TokenCount = count
    
    for i as unsigned integer = 0 to count-1
        var vi = cptr(VarInstruction ptr, parent->FindVar(tokens[i]))
        if (vi<>0) then
            tokens[i]=vi->VarSymbol
        else
            var pa = parent->FindParameter(tokens[i])
            if (pa<>0) then
                tokens[i]=pa->VarSymbol
            end if
        end if
        
    next 
    return ret
end function

function Instruction.FindVar(n as unsigned byte ptr) as instruction ptr
    var no = this.LastNode
    while no<>0
        if (no->IType = Variable) then
            if (strcmp(cptr(VarInstruction ptr,no)->VarName,n)=0) then return no
        end if
        no=no->PrevNode
    wend
    if (this.ParentNode<>0) then
        return this.ParentNode->FindVar(n)
    end if
    return 0
end function

function Instruction.FindParameter(n as unsigned byte ptr) as ProcedureParameter ptr
    
    if (this.IType<>instructionType.Procedure) then
        if (this.ParentNode<>0) then return this.ParentNode->FindParameter(n)
        return 0
    end if
    var p = cptr(ProcedureInstruction ptr,@this)
    var parm = p->FirstParameter
    while parm<>0
        if (strcmp(parm->pname,n)=0) then return parm
        parm = parm->NextParameter
    wend
    return 0
end function

sub Instruction.AddChild(i as instruction ptr)
    if (this.LastNode<>0) then
        this.LastNode->NextNode = i
    else
        this.FirstNode = i
    end if
    i->NextNode = 0
    i->PrevNode = this.LastNode
    this.LastNode = i
    i->ParentNode = @this
    i->Level = Level+1
    i->InClass = this.InClass or this.IsClass
    i->ScopeVarNum = this.ScopeVarNum
end sub

sub Instruction.Process()
    var varNum = this.ScopeVarNum
   
    
    if (this.OnProcess<>0) then cptr(sub(i as Instruction ptr),this.OnProcess)(@this)
    var n = this.FirstNode
    while n<>0
            n->ScopeVarNum = varNum
            n->Process
            n=n->NextNode
    wend
    if (this.ParentNode<>0 and this.FirstNode<>0) then
        if (varNum<>this.ScopeVarNum) then
            ConsoleWrite(@"add esp,"):ConsoleWrite(IntToStr((this.ScopeVarNum-varNum)*4,10)):ConsoleNewLine()
        end if
    end if
    
    if (this.OnProcessEpilogue<>0) then cptr(sub(i as Instruction ptr),this.OnProcessEpilogue)(@this)
end sub

sub Instruction.ReserveVar()
    this.ScopeVarNum +=1
end sub