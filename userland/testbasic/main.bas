#include once "../../shared/stdlib.bi"
#include once "../../shared/stdlib.bas"
#include once "onyx_glue.bas"
#include once "lexer.bas"
#include once "instruction.bi"
#include once "instruction.bas"
#include once "parser.bas"

InitLexer()
processfile(@"testfile.txt")


parse(sourceLines)
print "done"
sleep
asm
_EndProgram:
end asm

    