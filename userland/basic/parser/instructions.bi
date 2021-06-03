
enum instructionType
    None
    Procedure
    IfStatement
    ClassDefinition
    Variable
end enum

enum VarType
    None
    Number
    Instance
    VarString
end enum
    


type ProcedureParameter field = 1
    index as unsigned integer
    pname as unsigned byte ptr
    VarSymbol as unsigned byte ptr
    nextParameter as ProcedureParameter ptr
    declare constructor()
    declare destructor()
end type

TYPE instruction field = 1
    IType as instructionType
    ILabelNum as unsigned integer
    
    EndInstruction as Instruction ptr
    
    FirstNode as instruction ptr
    LastNode as instruction ptr
    
    NextNode as instruction ptr
    PrevNode as instruction ptr
    ParentNode as instruction ptr
    
    Level as unsigned integer
    Tokens as unsigned byte ptr ptr
    TokenString as unsigned byte ptr
    TokenCount as unsigned integer
    
    PrevScopeVarNum as unsigned integer
    ScopeVarNum as unsigned integer
    IsClass as boolean
    InClass as boolean
    OnDestroy as any ptr
    OnProcess as any ptr
    OnProcessChildrenAfter as any ptr
    OnProcessEpilogue as any ptr
    declare constructor()
    declare destructor()
    declare sub AddChild(i as instruction ptr)
    
    declare static function Construct(parent as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer) as instruction ptr
    declare sub Process()
    declare sub ReserveVar()
    declare function FindVar(n as unsigned byte ptr) as instruction ptr
    declare function FindParameter(n as unsigned byte ptr) as ProcedureParameter ptr
end Type

#include once "operand.bi"

Type ClassInstruction extends instruction field = 1
    ClassName as unsigned byte ptr
    declare constructor(tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    declare destructor()
end type

Type ProcedureInstruction extends instruction field = 1
    ProcedureName as unsigned byte ptr
    FirstParameter as ProcedureParameter ptr
    LastParameter as ProcedureParameter ptr
    ParametersCount as unsigned integer
    
    declare constructor(parent as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    declare destructor()
    declare sub addParameter(n as unsigned byte ptr)
end type

Type VarInstruction extends instruction field = 1
    VarName as unsigned byte ptr
    VarNum as unsigned integer
    VarSymbol as unsigned byte ptr
    IsGlobal as unsigned integer
    declare constructor(parent as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    declare destructor()
end type

Type IfInstruction extends instruction field = 1
    ElseInstruction as IfInstruction ptr
    Condition as Operand ptr
    declare constructor(parent as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    declare destructor()
end Type

declare sub ProcessInstruction(p as instruction ptr)
declare sub ProcessProcedureInstruction(p as ProcedureInstruction ptr)
declare sub ProcessProcedureInstructionEpilogue(p as ProcedureInstruction ptr)
declare sub ProcessClassInstruction(p as ClassInstruction ptr)
declare sub ProcessVarInstruction(p as varInstruction ptr)
declare sub ProcessIfInstruction(p as IfInstruction ptr)
declare sub ProcessChildrenEndIfInstruction(p as IfInstruction ptr)


declare sub DestroyClassInstruction(i as ClassInstruction ptr)
declare sub DestroyInstruction(i as instruction ptr)
declare sub DestroyProcedureInstruction(i as ProcedureInstruction ptr)
declare sub DestroyVarInstruction(i as varInstruction ptr)
declare sub DestroyIfInstruction(i as IfInstruction ptr)
