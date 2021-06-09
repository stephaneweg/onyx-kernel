
include 'macros.inc'
program
		
include 'sys.inc'

MAIN:
	push ebp
	mov ebp,esp
	
	
	try t1
		xcall consoleWrite, lblHello
		xcall consoleNewLine
		xcall subMethod,0,20
		xcall consoleWrite,lblHello1
		xcall consoleNewLine
	catch t1
		push eax
		let [errNo]
		xcall consoleWrite,lblHello2
		xcall consoleWriteNumber,[errNo],10
		xcall consoleNewLine
	endtry t1
	
	
	
	mov eax,0x5
	int 0x30
	jmp $

	
beginProc subMethod,f,t
	var x
	for x,[f],[t],1,f1
	
		xcall consoleWrite,lblTest
		xcall consoleWriteNumber,[x],10
		xcall consoleNewLine
		
		ifg [x],15,if1
			throw 25
		endif if1
	next x,f1
endProc 2
		
string	lblHello ,	'Hello world'
string	lblHello1,	'this should not append'
string	lblHello2,	'Exception caught : '
string	lblTest,	'Test :'

errNo		dd 0x0
string	lblMultiply,'*'
string	lblAdd,		'+'
string	lblSub,		'-'
string	lblEqual,	'='

endProgram