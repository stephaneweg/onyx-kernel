
Type IdentifierOperand field = 1
    ScopeInstruction as Instruction ptr
    Tokens as unsigned byte ptr ptr
    TokenString as unsigned byte ptr
    TokenCount as unsigned integer
    Level as unsigned integer
    OnProcess as any ptr
    declare static function Construct(l as unsigned integer,s as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer) as IdentifierOperand ptr

    declare constructor()
    declare constructor(l as unsigned integer,s as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    declare function Process() as integer
end type

Type Operand field = 1
    ScopeInstruction as Instruction ptr
    Tokens as unsigned byte ptr ptr
    TokenString as unsigned byte ptr
    TokenCount as unsigned integer
    Level as unsigned integer
    PrevOperand as Operand ptr
    NextOperand as Operand ptr
    Identifier as IdentifierOperand ptr
    LeftOp as Operand ptr
    RightOp as Operand ptr
    OP as unsigned byte ptr
    declare constructor(l as unsigned integer,s as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    declare destructor()
    declare function Process() as integer
end type


Type FunctionCallOperand extends IdentifierOperand field = 1
    FirstOperand as Operand ptr
    LastOperand as Operand ptr
    OperandCount as unsigned integer
    
    declare sub AddParameter(indexFirst as unsigned integer,indexLast as unsigned integer)
    declare constructor()
    declare constructor(s as Instruction ptr,tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
    declare destructor()
end type


declare function IdentifierOperandProcess(p as IdentifierOperand ptr) as integer
declare function FunctionCallOperandProcess(p as FunctionCallOperand ptr) as integer