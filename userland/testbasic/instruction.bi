enum InstructionType
    None
    ProgramInstruction
    EndProgramInstruction
    SubInstruction
    EndSubInstruction
    FunctionInstruction
    ForInstruction
    NextInstruction
end enum

enum IdentifierType
    TByte
    TUByte
    TShort
    TUShort
    TInt
    TUint
    TLong
    TULong
    TDouble
    TSingle
    TClass
    TString
end enum

Type Operand
    Tokens(0 to 255) as unsigned byte ptr
    TokenCount as unsigned integer
    
    declare static function Construct(t as unsigned byte ptr ptr,iFirst as unsigned integer,iLast as unsigned integer) as Operand ptr
    declare static function ConstructSimple(t as unsigned byte ptr) as Operand ptr
    
end Type

Type Identifier
    IDName as unsigned byte ptr
    IDType as IdentifierType
    IDSize as unsigned integer
    IDOffset as integer
    ISPointer as integer
end type

Type Parameter extends Identifier
    NextParameter as Parameter ptr
    PrevParameter as Parameter ptr
    declare constructor(pname as unsigned byte ptr,ptype as unsigned byte ptr,_isPtr as integer)
end type

Type Instruction
    AType as InstructionType
    source as SourceLine ptr
    
    isBlockInstruction as integer
    isNextBlockInstruction as integer
    isEndBlockInstruction as integer
    
    nextInstruction as Instruction ptr
    prevInstruction as Instruction ptr
    firstInstruction as Instruction ptr
    lastInstruction as Instruction ptr
    parentInstruction as Instruction ptr
    StackPointer as integer
    
    declare constructor()
    declare sub AddInstruction(i as instruction ptr)
    declare static function Construct(l as SourceLine ptr) as Instruction ptr
    
    onDestroy as any ptr
    onProcess as any ptr
    declare destructor()
end type



type BlockInstruction extends Instruction
    declare constructor
end type

type EndBlockInstruction extends instruction
    declare constructor
end type

type BlockElseInstruction extends Instruction
    declare constructor
end type



type ProgramBlockInstruction extends BlockInstruction
    declare constructor
end type

type EndProgramInstruction extends EndBlockInstruction
    declare constructor
end type

type SubBlockInstruction extends BlockInstruction
    SubName as Unsigned byte ptr
    ParametersCount as unsigned integer
    ParametersSize as unsigned integer
    Parameters as Parameter ptr
    LastParameter as Parameter ptr
    declare constructor(l as SourceLine ptr)
end type

type EndSubInstruction extends EndBlockInstruction
    declare constructor
end type

type ForBlockInstruction extends BlockInstruction
    TargetIdentifier as Operand ptr
    InitialValue    as Operand ptr
    LimitValue      as Operand ptr
    StepValue       as Operand ptr
    Direction       as integer
    declare constructor(l as SourceLine ptr)
end type

type NextEndInstruction extends EndBlockInstruction
    declare constructor()
end type


declare sub DestroyInstruction(i as Instruction ptr)
declare sub ProcessUnknownInstruction(i as Instruction ptr)
declare sub ProcessProgramInstruction(i as ProgramBlockInstruction ptr)
declare sub ProcessEndProgramInstruction(i as ProgramBlockInstruction ptr)

declare sub ProcessSubInstruction(i as SubBlockInstruction ptr)
declare sub ProcessEndSubInstruction(i as EndSubInstruction ptr)

declare sub ProcessForInstruction(i as ForBlockInstruction ptr)
declare sub ProcessNextInstruction(i as NextEndInstruction ptr)

declare sub ProcessGetterEX(tokens as unsigned byte ptr,count as integer,i as Instruction ptr)
declare sub ProcessGetter(source as Operand ptr,i as Instruction ptr)
declare sub ProcessAssign(target as Operand Ptr,i as Instruction ptr) 