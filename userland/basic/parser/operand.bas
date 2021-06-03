
constructor Operand(l as unsigned integer,s as Instruction ptr,t as unsigned byte ptr ptr,ts as unsigned byte ptr, count as unsigned integer)
    this.Tokens =  t
    this.TokenString = ts
    this.TokenCount = count
    this.ScopeInstruction = s
    Level = l
    LeftOp = 0
    RightOp = 0
    OP = 0
    Identifier = 0
    PrevOperand = 0
    NextOperand = 0
    dim zero as unsigned byte ptr = @"0"
    dim parenthesiscount as integer = 0
    
    
    dim oprc(0 to 4) as unsigned byte ptr => {@"or",@"and",@"=",@"<",@">"}
    for j as unsigned integer = 0 to 4
        for i as integer = 0 to this.TokenCount-1
            if (strcmp(tokens[i],@"(") = 0) then
                parenthesiscount+=1
            elseif (strcmp(tokens[i],@")") = 0) then
                parenthesiscount-=1
            elseif (parenthesiscount=0) then
                if (strcmp(tokens[i],oprc(j)) = 0) then
                    if (i<this.TokenCount-1) then 
                        RightOp = new Operand(Level+1,s,cptr(unsigned byte ptr ptr,cuint(tokens) + (i+1)*(sizeof(unsigned byte ptr))),tokenString,(this.TokenCount-i)-1)
                    else
                        RightOp = new Operand(Level+1,s,@zero,zero,1)
                    end if
                    
                    if (i>0) then
                        LeftOP = new Operand(Level+1,s,Tokens,tokenString, i)
                    else
                        LeftOP = new Operand(Level+1,s,@zero,zero,1)
                    end if
                   
                    Op = tokens[i]
                    exit constructor
                end if
            end if
        next
    next 
    
    if (strcmp(this.Tokens[0],@"(")=0) and (strcmp(this.Tokens[this.TokenCount-1],@")")=0) then
       this.Tokens +=1
       this.TOkenCount-=2
    end if
   
    
    
    dim opr(0 to 10) as unsigned byte ptr => {@"or",@"and",@"=",@"+",@"-",@"*",@"/",@"<",@">",@"shl",@"shr"}
    parenthesiscount=0
    
    
    for j as unsigned integer = 0 to 10
        for i as integer = 0 to this.TokenCount-1
            if (strcmp(tokens[i],@"(") = 0) then
                parenthesiscount+=1
            elseif (strcmp(tokens[i],@")") = 0) then
                parenthesiscount-=1
            elseif (parenthesiscount=0) then
                if (strcmp(tokens[i],opr(j)) = 0) then
                    if (i<this.TokenCount-1) then 
                        RightOp = new Operand(Level+1,s,cptr(unsigned byte ptr ptr,cuint(tokens) + (i+1)*(sizeof(unsigned byte ptr))),tokenString,(this.TokenCount-i)-1)
                    else
                        RightOp = new Operand(Level+1,s,@zero,zero,1)
                    end if
                    
                    if (i>0) then
                        LeftOP = new Operand(Level+1,s,Tokens,tokenString, i)
                    else
                        LeftOP = new Operand(Level+1,s,@zero,zero,1)
                    end if
                   
                    Op = tokens[i]
                    exit constructor
                end if
            end if
        next
    next 
    
    
    if op=0 then Identifier = IdentifierOperand.Construct(Level+1,s,tokens,tokenString,count)
end constructor

destructor Operand()
    if (LeftOP<>0) then 
        delete LeftOP
    end if
    if (RightOP<>0) then
        delete RightOP
    end if
    if (Identifier<>0) then
        delete Identifier
    end if
end destructor

function Operand.Process() as integer
    if (op<>0) then
        var ShouldPopLeft = 0
        if (LeftOp<>0) then
            ShouldPopLeft = LeftOp->Process()
            'result is in eax, i should push it to pop it later on ebx
            if (ShouldPopLeft=0 and RightOP<>0)  then
                ConsoleWrite(@"push eax"):ConsoleNewLine()
                ShouldPopLeft=1
            end if
        end if
        
        
        if RightOP<>0 then
            var shouldPopRight = RightOP->Process()
            if (strcmp(op,@"/")=0) then
                if (shouldPopRight) then
                    ConsoleWrite(@"pop ecx"):ConsoleNewLine()
                else
                    ConsoleWrite(@"mov ecx,eax"):ConsoleNewLine()
                end if
            else
                if (shouldPopRight) then
                    ConsoleWrite(@"pop ebx"):ConsoleNewLine()
                else
                    ConsoleWrite(@"mov ebx,eax"):ConsoleNewLine()
                end if
            end if
        end if
        
        if (ShouldPopLeft) then
            ConsoleWrite(@"pop eax"):ConsoleNewLine()
        end if
        
        if (strcmp(op,@"+")=0) then
            ConsoleWrite(@"add eax,ebx"):ConsoleNewLine()
            
        elseif (strcmp(op,@"-")=0) then
            ConsoleWrite(@"sub eax,ebx"):ConsoleNewLine()
        elseif (strcmp(op,@"/")=0) then
            ConsoleWrite(@"mov edx,0"):ConsoleNewLine()
            ConsoleWrite(@"div ecx"):ConsoleNewLine()
        elseif (strcmp(op,@"%")=0) then
            ConsoleWrite(@"mov edx,0"):ConsoleNewLine()
            ConsoleWrite(@"div ecx"):ConsoleNewLine()
            ConsoleWrite(@"mov eax,edx"):ConsoleNewLine()
        elseif (strcmp(op,@"*")=0) then
            ConsoleWrite(@"mul ebx"):ConsoleNewLine()
        elseif (strcmp(op,@"shl")=0) then
            ConsoleWrite(@"shl eax,ebx"):ConsoleNewLine()
        elseif (strcmp(op,@"shr")=0) then
            ConsoleWrite(@"shr eax,ebx"):ConsoleNewLine()
        elseif (strcmp(op,@"or")=0) then
            ConsoleWrite(@"or eax,ebx"):ConsoleNewLine()
        elseif (strcmp(op,@"and")=0) then
            ConsoleWrite(@"and eax,ebx"):ConsoleNewLine()
        elseif(strcmp(op,@"=")=0) and (this.Level>0) then
            ConsoleWrite(@"cmp eax,ebx"):ConsoleNewLine()
            ConsoleWrite(@"sete al"):ConsoleNewLine()
            ConsoleWrite(@"shr eax,1"):ConsoleNewLine()
            ConsoleWrite(@"sbb eax,eax"):ConsoleNewLine()
        elseif(strcmp(op,@">")=0) and (this.Level>0) then
            ConsoleWrite(@"cmp eax,ebx"):ConsoleNewLine()
            ConsoleWrite(@"setg al"):ConsoleNewLine()
            ConsoleWrite(@"shr eax,1"):ConsoleNewLine()
            ConsoleWrite(@"sbb eax,eax"):ConsoleNewLine()
        elseif(strcmp(op,@"<")=0) and (this.Level>0) then
            ConsoleWrite(@"cmp eax,ebx"):ConsoleNewLine()
            ConsoleWrite(@"setl al"):ConsoleNewLine()
            ConsoleWrite(@"shr eax,1"):ConsoleNewLine()
            ConsoleWrite(@"sbb eax,eax"):ConsoleNewLine()
        end if
        return 0
    else
        
        if (Identifier<>0) then
            return Identifier->Process()
        else
            ConsoleWrite(@"mov eax,0"):ConsoleNewLine()
            return 0
        end if
    end if
end function

constructor IdentifierOperand()
end constructor

constructor IdentifierOperand(l as unsigned integer,s as Instruction ptr,t as unsigned byte ptr ptr,ts as unsigned byte ptr, count as unsigned integer)
    this.Tokens = t
    this.TokenString = ts
    this.TokenCount = count
    this.ScopeInstruction = s
    this.Level  = l
    this.OnProcess = @IdentifierOperandProcess
    
end constructor

function IdentifierOperand.Construct(l as unsigned integer,s as Instruction ptr,t as unsigned byte ptr ptr,ts as unsigned byte ptr, count as unsigned integer) as IdentifierOperand ptr
    if (count>2) then
        if (strcmp(t[1],@"(")=0) and (strcmp(t[count-1],@")")=0) then
            
            return new FunctionCallOperand(s,t,ts,count)
        end if
    end if
    return new IdentifierOperand(l,s,t,ts,count)
end function

function IdentifierOperand.Process() as integer
    if (OnProcess<>0) then return cptr(function(p as IdentifierOperand ptr) as integer,OnProcess)(@this)
    return 0
end function

function IdentifierOperandProcess(p as IdentifierOperand ptr) as integer
    if (p->TokenCount>1) then
        print "ERROR invalid identifier :";
        for i as unsigned integer =0 to p->TokenCount-1
            ConsoleWrite p->Tokens[i]:consolewrite(@" ")
        next
        ConsoleNewLine()
        return 0
    end if
    ConsoleWrite(@"push ")
    ConsoleWrite(p->Tokens[0])
    ConsoleNewLine()
    return 1
end function

constructor FunctionCallOperand(s as Instruction ptr,t as unsigned byte ptr ptr,ts as unsigned byte ptr, count as unsigned integer)
    this.Tokens = t
    this.TokenString = ts
    this.TokenCount = count
    this.ScopeInstruction = s
    FirstOperand = 0
    LastOperand = 0
    OperandCount = 0
    
    dim prev as integer = 2
    for i as unsigned integer = 2 to count -1
        if (strcmp(t[i],@",")=0) then
            AddParameter(prev,i-1)
            prev=i+1
        end if
    next i
    if (prev<=count-2) then
        AddParameter(prev,count-2)
    end if
    OnProcess = @FunctionCallOperandProcess
end constructor

sub FunctionCallOperand.AddParameter(indexFirst as unsigned integer,indexLast as unsigned integer)
    var newOperand = new Operand(0,this.ScopeInstruction,cptr(unsigned byte ptr ptr,cuint(this.Tokens)+sizeof(unsigned byte ptr)*indexFirst),this.TokenString,(indexLast-indexFirst)+1)
    if (this.LastOperand<>0) then
        this.LastOperand->NextOperand = newOperand
    else
        this.FirstOperand = newOperand
    end if
    newOperand->NextOperand = 0
    newOperand->PrevOperand = this.LastOperand
    this.LastOperand = newOperand
    this.OperandCount+=1
end sub
    

destructor FunctionCallOperand()
end destructor

function FunctionCallOperandProcess(p as FunctionCallOperand ptr) as integer
    var parm = p->LastOperand
    while parm<>0
        if (parm->Process() = 0) then
            ConsoleWrite(@"push eax (parameter)")
            ConsoleNewLine()
        end if
        parm=parm->PrevOperand
    wend
    ConsoleWrite(@"call "):ConsoleWrite(p->Tokens[0]):ConsoleNewLine()
    ConsoleNewLine()
    return 0
end function