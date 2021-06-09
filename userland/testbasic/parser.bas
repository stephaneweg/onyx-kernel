

sub Instruction.AddInstruction(i as instruction ptr)
    if (this.LastInstruction<>0) then
        this.LastInstruction->NextInstruction = i
    else
        this.FirstInstruction = i
    end if
    i->PrevInstruction = this.LastInstruction
    i->NextInstruction = 0
    this.LastInstruction = i
    i->ParentInstruction = @this
end sub

function Instruction.Construct(l as SourceLine ptr) as Instruction ptr
    dim result as Instruction ptr
    
    if (strcmp(l->Tokens(0),@"program")=0) then
        result = new ProgramBlockInstruction()
    elseif(strcmp(l->Tokens(0),@"end program")=0) then
        result = new EndProgramInstruction()
        
    elseif(strcmp(l->Tokens(0),@"sub")=0) then
        result = new SubBlockInstruction(l)
    elseif(strcmp(l->Tokens(0),@"end sub")=0) then
        result = new EndSubInstruction()
        
        
    elseif(strcmp(l->Tokens(0),@"for")=0) then
        result = new ForBlockInstruction(l)
    elseif(strcmp(l->Tokens(0),@"next")=0) then
        result = new NextEndInstruction()
        
    elseif(strcmp(l->Tokens(0),@"asm")=0) then
        result = new BLockInstruction()
    elseif(strcmp(l->Tokens(0),@"end asm")=0) then
        result = new EndBlockInstruction()
    elseif(strcmp(l->Tokens(0),@"function")=0) then
        result = new BLockInstruction()
    elseif(strcmp(l->Tokens(0),@"class")=0) then
        result = new BLockInstruction()
    elseif(strcmp(l->Tokens(0),@"do")=0) then
        result = new BLockInstruction()
    elseif(strcmp(l->Tokens(0),@"select case")=0) then
        result = new BLockInstruction()
    elseif(strcmp(l->Tokens(0),@"case")=0) then
        result = new BLockInstruction()
    elseif(strcmp(l->Tokens(0),@"while")=0) then
        result = new BLockInstruction()
    elseif(strcmp(l->Tokens(0),@"if")=0) then
        result = new BLockInstruction()
    elseif(strcmp(l->Tokens(0),@"else if")=0) then
        result = new BLockElseInstruction()
    elseif(strcmp(l->Tokens(0),@"else")=0) then
        result = new BLockElseInstruction()
    elseif(strcmp(l->Tokens(0),@"end function")=0) then
        result = new EndBlockInstruction()
    elseif(strcmp(l->Tokens(0),@"end class")=0) then
        result = new EndBlockInstruction()
    elseif(strcmp(l->Tokens(0),@"loop")=0) then
        result = new EndBlockInstruction()
    elseif(strcmp(l->Tokens(0),@"wend")=0) then
        result = new EndBlockInstruction()
    elseif(strcmp(l->Tokens(0),@"end if")=0) then
        result = new EndBlockInstruction()
    elseif(strcmp(l->Tokens(0),@"end select")=0) then
        result = new EndBlockInstruction()
    elseif(strcmp(l->Tokens(0),@"end case")=0) then
        result = new EndBlockInstruction()
    else
        result = new Instruction()
    end if
    result->source  = l
    
    return result
end function

sub ProcessInstruction(i as Instruction ptr)
    static level as integer = 0
    for x as integer = 0 to level
        print "*";
    next
    'à remplacer par le "ON Process"
    for x as integer =0 to i->Source->TokenCount-1
        
        ConsoleWrite(@" ["):ConsoleWrite( i->Source->Tokens(x)):ConsoleWrite(@"]")
    next
    consoleNewLine()
    
    
    cptr(sub(n as Instruction ptr),i->OnProcess)(i)
    
    
    var c = i->FirstInstruction
    while c<>0
        c->StackPointer = i->StackPointer
        level+=1
        ProcessInstruction(c)
        level-=1
        c=c->NextInstruction
    wend
end sub


sub Parse(lines as SourceLine ptr)
    var sl = lines
    dim CurrentInstruction as Instruction ptr = 0
    dim RootInstruction as Instruction ptr  = 0
    while sl<>0
        dim i as Instruction ptr = Instruction.Construct(sl)
        if (RootInstruction = 0) then RootInstruction = i
        
        if (CurrentInstruction = 0) then
            CurrentInstruction = i
        else
            if (CurrentInstruction->IsBlockInstruction = 1) then
                i->StackPointer = CurrentInstruction->StackPointer
                if (i->IsNextBLockInstruction) then
                    
                    CurrentInstruction->AddInstruction(i)
                    i->ParentInstruction = CurrentInstruction->ParentInstruction
                    CurrentInstruction = i
                else
                    CurrentInstruction->AddInstruction(i)
                    if (i->isEndBlockInstruction) then
                        CurrentInstruction = CurrentInstruction->ParentInstruction
                    elseif(i->IsBlockInstruction) then
                        CurrentInstruction = i
                    end if
                end if    
            else
                Print "unexpected token ";:ConsoleWrite(sl->TOkens(0)):ConsoleNewLine()
            end if
        end if
        
        
        sl=>sl->NextLine
    wend
    
    
    ProcessInstruction(RootInstruction)
    cptr(sub(n as Instruction ptr),RootInstruction->OnDestroy)(RootInstruction)
end sub