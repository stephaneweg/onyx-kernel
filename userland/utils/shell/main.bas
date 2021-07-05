#include once "stdlib.bi"
#include once "stdlib.bas"


#include once "system.bi"
#include once "slab.bi"
#include once "console.bi"
#include once "file.bi"
#include once "system.bas"
#include once "console.bas"
#include once "slab.bas"
#include once "file.bas"

dim shared input_data(0 to 4096) as unsigned byte

dim shared entries(0 to 50) as VFSDirectoryEntry
declare function STD_INPUT() as unsigned byte ptr
declare sub DO_COMMANDX(cmd as unsigned byte ptr,_stdin as unsigned integer)
declare sub DO_COMMAND(cmd as unsigned byte ptr,_stdin as unsigned integer,_stdout as unsigned integer)
declare function GET_EXEC_PATH(cmd as unsigned byte ptr) as unsigned byte ptr
declare function GET_APP_PATH(cmd as unsigned byte ptr) as unsigned byte ptr
sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
    SlabInit()
    Do
		ConsoleWrite(@"root@onyx:# ")
		dim cmd as unsigned byte ptr = 0
		while cmd=0
			cmd = STD_INPUT()
		wend
        if cmd>0 then
            if (strcmp(cmd,@"exit")=0) then 
                exit do
            elseif (strcmp(cmd,@"ping")=0) then
                ConsoleWriteLine(@"pong")
            else
                DO_COMMANDX(cmd,0)
                STDIO_SET_IN(0)
                STDIO_SET_OUT(0)
            end if
        end if
	loop	
    ExitApp()
end sub


function str_TRIMX(x as unsigned byte ptr) as unsigned byte ptr
	dim s as unsigned byte ptr = x
	while (s[0]=32) or (s[0]=9) 
		s+=1
	wend
	var i = strlen(s)-1
	while (i>0) and (s[i]=32)
		s[i]=0
		i-=1
	wend
	return s
end function

function STD_INPUT() as unsigned byte ptr
    dim i as unsigned integer = 0
    do
        var b = STDIO_READ(0)
        'if (STDIO_ERR_NUM<>0) then
        '    input_data(i)=0
        '    if (i>0) then
        '        return @input_data(0)
        '    else
        '        return 0
        '    end if
        'end if
        if (b=13) or (b=10) then
            if (i>0) then
                ConsoleNewLine()
                input_data(i)=0
                if (i>0) then
                    return @input_data(0)
                else
                    return 0
                end if
            end if
        end if
        if (b=8) then
            if (i>0) then
                ConsoleBackSpace()
                i-=1
                input_data(i)=0
            end if
        end if
        if (b>=32) then ' and b<128) then
            ConsolePutChar(b)
            input_data(i)=b
            i+=1
        end if
    loop
    return 0
end function


sub DO_COMMANDX(cmd as unsigned byte ptr,_stdin as unsigned integer)
	cmd = str_TRIMX(cmd)
	dim i as unsigned integer = 0
	var inQuote = 0
	while cmd[i]<>0
		if (cmd[i]=34) then
			if (inQuote=0) then 
				inQuote=1
			else
				inQuote=0
			end if
		elseif (cmd[i]=asc("|")) and (inQuote=0) then
			cmd[i]=0
			var leftCMD  = str_TRIMX(cmd)
			var rightCMD = str_TRIMX(cmd+i+1)
			
			var p = STDIO_CREATE()
			DO_COMMAND(leftCMD,_stdin,p)
			DO_COMMANDX(rightCMD,p)
			exit sub
		end if
		i+=1
	wend
	
	DO_COMMAND(cmd,_stdin,0)
    
end sub

sub DO_COMMAND(cmd as unsigned byte ptr,_stdin as unsigned integer,_stdout as unsigned integer)
    if (cmd<>0) then
        dim i as unsigned integer
        dim cmdArgs as unsigned byte ptr = 0
        dim cmdName as unsigned byte ptr = cmd
        
        dim stdOutPath as unsigned byte ptr = 0
        dim stdInPath as unsigned byte ptr = 0
        
        var inQuote = 0
        
        
        while cmd[i]<>0
            if (cmd[i]=34) then
                if (inQuote=0) then 
                    inQuote=1
                else
                    inQuote=0
                end if
            elseif (cmd[i]=asc(">")) and (inQuote=0) then
                stdOutPath = cmd+i+1
                cmd[i]=0
            elseif (cmd[i]=asc("<")) and (inQuote=0) then 
                stdInPath = cmd+i+1
                cmd[i]=0
            end if
            i+=1
        wend
        i=0
        while cmd[i]<>0
            if (cmd[i]=32) then
                cmd[i]=0
                cmdArgs=cmd+i+1
                exit while
            end if
            i+=1
        wend
        if (stdInPath<>0) then
            while stdInPath[0]=32:stdInPath+=1:wend
            i = strlen(stdInPath)-1
            while (i>0) and (stdInPath[i]=32)
                stdInPath[i]=0
                i-=1
            wend
        end if
        if (stdOutPath<>0) then
            while stdOutPath[0]=32:stdOutPath+=1:wend
            i = strlen(stdOutPath)-1
            while (i>0) and (stdOutPath[i]=32)
                stdOutPath[i]=0
                i-=1
            wend
        end if
        
        if (cmdArgs<>0) then
            while cmdArgs[0]=32:cmdArgs+=1:wend
            i = strlen(cmdArgs)-1
            while (i>0) and (cmdArgs[i]=32)
                cmdArgs[i]=0
                i-=1
            wend
        end if
                
        var path = GET_EXEC_PATH(cmd)
        
        if (path<>0) then
			dim _astdin as unsigned integer = 0
			dim _astdout as unsigned integer = 0
            dim _stdinbuff as unsigned byte ptr = 0
            dim _stdinbuffsize as unsigned integer = 0
            dim _stdoutFile as unsigned integer = 0
            
            
            'create the stdout for the child process
			if (stdOutPath<>0 and _stdout=0) then 
                _stdoutFile = FileCreate(stdOutPath)
                if (_stdoutFile=0) then
                    CONSOLEWrite(@"Could not open file : "):ConsoleWriteLine(stdOutPath)
                    return
                end if
                _astdout = STDIO_CREATE()
            end if
            
            'create the stdin for the child process
			if (stdInPath<>0 and _stdin=0)  then 
                _stdinbuff = VFS_LOAD_FILE(stdInPath,@_stdinbuffsize)
                
                if (_stdinbuff<>0 and _stdinbuffsize>0) then
                    _astdin = STDIO_CREATE()
                    for i as integer = 0 to _stdinbuffsize-1
                        STDIO_WRITE_BYTE(_astdin,_stdinbuff[i])
                    next
                    Free(_stdinbuff)
                else
                    COnsoleWrite(@" Cannot read input stream "):COnsoleWriteLine(stdInPath)
                    exit sub
                end if
            end if
            
            STDIO_SET_IN(iif(_stdin<>0,_stdin,_astdin))
            STDIO_SET_OUT(iif(_stdout<>0,_stdout,_astdout))
            if (ExecAppAndWait(path,cmdArgs)=0) then
                path = GET_APP_PATH(cmd)
                if (ExecAppAndWait(path,cmdArgs)=0) then
                    ConsoleWrite(@"Command not found :"):ConsoleWriteLine(cmd)
                end if
            end if
            STDIO_SET_OUT(0)
            STDIO_SET_IN(0)
            'read the output and save it to file
			if (_astdout<>0 and _stdoutFile<>0) then
                ConsoleWrite(@"Writing output to "):ConsoleWrite(stdOutPath)
                do
                    var b = STDIO_READ(_astdout)
                    if (STDIO_ERR_NUM) = 0 then
                    'if (b=0) then exit do
                        FileWrite(_stdoutFile,1,@b)
                    else
                        exit do
                    end if
                loop
                ConsoleWriteLine(@" OK")
                FileClose(_stdoutFile,1)
            end if
            'F_CLOSE(_astdin)
            'F_CLOSE(_astdout)
            
        else
            ConsoleWrite(@"COMMAND NOT FOUND : "):ConsoleWriteLine(cmd)
        end if
        
        
    end if
end sub


function GET_APP_PATH(cmd as unsigned byte ptr) as unsigned byte ptr
    dim path as unsigned byte ptr = 0
    'if (FILE_EXISTS(path)) then return path
    path = strcat( strcat(@"SYS:/APPS/",cmd),@".APP/MAIN.BIN")
    return path
end function

function GET_EXEC_PATH(cmd as unsigned byte ptr) as unsigned byte ptr
    dim path as unsigned byte ptr = 0
    'if (FILE_EXISTS(path)) then return path
    path = strcat( strcat(@"SYS:/BIN/",cmd),@".bin")
    return path
end function