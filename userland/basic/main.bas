#define free(a) deallocate(a)
#define malloc(s) allocate(s)


function _byteStrToString(b as unsigned byte ptr) as string
    
    dim instring as unsigned integer = 0
    dim result as string = ""
    dim i as integer
    while b[i] <>0
        if (b[i]) = 34 and instring = 0 then
            instring = 1
        elseif (b[i]) = 34 and instring = 1 then
            instring = 0
        else
            result = result+ chr(b[i])
        end if
        i+=1
    wend
    return result
end function

#include once "../../../shared/stdlib.bi"
#include once "../../../shared/stdlib.bas"

#include once "vfs.bas"
#include once "console.bas"

dim shared AutoLabelNum as unsigned integer
#include once "parser/instructions.bas"
#include once "parser/operand.bas"

declare sub processFile(fname as unsigned byte ptr)
declare sub processLine(l as unsigned byte ptr)
declare function GetTokens(l as unsigned byte ptr,count as unsigned integer ptr) as unsigned byte ptr ptr
declare function shouldAddSpace(b as unsigned byte) as boolean
declare function sanitizeString(l as unsigned byte ptr) as unsigned byte ptr

dim shared CurrentInstruction as Instruction ptr


function GetTokens(l as unsigned byte ptr,count as unsigned integer ptr) as unsigned byte ptr ptr
    dim s as unsigned integer = strlen(l)
    dim keywords as unsigned byte ptr ptr = malloc(s*sizeof(unsigned byte ptr))
    *count = 0
    
    dim prev as unsigned integer = 0
    dim nbrTxt as unsigned integer = 0
    dim inString as unsigned integer = 0
    dim stringQuote as unsigned integer = 0
    dim isEscaped as unsigned integer = 0
    for i as unsigned integer = 0 to s-1
        var wasEscaped = isEscaped
        if ((l[i]=32 or l[i]=9) and inString = 0 ) then
            if (prev<i) then
                keywords[*count] = l+prev
                *count+=1
            end if
            l[i]=0
            prev = i+1
        elseif (l[i]=asc("\") and isEscaped=0) then
            isEscaped = 1
        elseif (l[i]=asc("'")) then
            if instring = 1 and stringQuote = 0 and isEscaped=0 then 
                instring = 0
            elseif instring = 0 then
                instring = 1
                stringquote = 0
            end if
        elseif (l[i]=34) then ' "
            if instring = 1 and stringquote = 1 and isEscaped = 0 then
                instring = 0
            elseif instring = 0 then
                instring = 1
                stringquote = 1
            end if
        end if
        if (wasEscaped) then isEscaped = 0
    next i
    if (prev<s) then
        keywords[*count] = l+prev
        *count+=1
    end if
    return keywords
end function

function shouldAddSpace(b as unsigned byte) as boolean
    return b = asc("(") or b=asc(",") or b=asc(")") or b=asc("=") or b=asc("+") or b=asc("-") or b=asc("*") or b=asc("/")  or b=asc("<") or b=asc(">") or b=asc(";")
    return false
end function

function isBlockToken(b as unsigned byte ptr) as boolean
    if (strcmp(b,@"type")=0) then return true
    if (strcmp(b,@"class")=0) then return true
    if (strcmp(b,@"properties")=0) then return true
    if (strcmp(b,@"sub")=0) then return true
    if (strcmp(b,@"function")=0) then return true
    if (strcmp(b,@"if")=0) then return true
    if (strcmp(b,@"while")=0) then return true
    if (strcmp(b,@"for")=0) then return true
    if (strcmp(b,@"do")=0) then return true
    if (strcmp(b,@"else")=0) then return true
    if (strcmp(b,@"elseif")=0) then return true
end function

function isEndBlockToken(b as unsigned byte ptr) as boolean
    if (strcmp(b,@"end")=0) then return true
    if (strcmp(b,@"wend")=0) then return true
    if (strcmp(b,@"next")=0) then return true
    if (strcmp(b,@"loop")=0) then return true
end function

function sanitizeString(l as unsigned byte ptr) as unsigned byte ptr
    dim tmpString as unsigned byte ptr = malloc(1024)
    memset(tmpString,0,1024)
    dim remain as integer = strlen(l)
    
    dim shift as integer  = 0
    dim parenthesisCount as integer = 0
    dim inString as unsigned integer = 0
    dim stringQuote as unsigned integer = 0
    dim isEscaped as unsigned integer = 0
    for i as unsigned integer = 0 to remain-1
     
        var wasEscaped = isEscaped
        
        if (l[i]=asc("#") and inString=0) then
            remain=i
            exit for
        end if
        if (l[i]=asc("(") and inString = 0) then 
            ParenthesisCount += 1
        elseif (l[i]=asc(")") and inString = 0) then 
            ParenthesisCount -= 1
        end if
        if (( shouldAddSpace(l[i]) ) and inString=0 and isEscaped = 0) then
              tmpString[i+Shift]=32
              tmpString[i+Shift+1]=l[i]
              tmpString[i+Shift+2]=32
              shift +=2
        'elseif (l[i] = asc(",")) and inString=0 and ParenthesisCount = 0 and isEscaped = 0 then
        '    tmpString[i+Shift]= 32
        'elseif (l[i] = 32 and parenthesisCount>0 and inString=0) then
        '    Shift-=1
        'elseif ((l[i] = asc(",") ) and parenthesisCount>0 and inString=0) then
        '   l[i]=32
        '   tmpString[i+Shift]=32
        else
            if (l[i]=asc("\") and isEscaped=0) then
                isEscaped = 1
            elseif (l[i]=asc("'")) then
                if instring = 1 and stringQuote = 0 and isEscaped=0 then 
                    instring = 0
                elseif instring = 0 then
                    instring = 1
                    stringquote = 0
                end if
            elseif (l[i]=34) then ' "
                if instring = 1 and stringquote = 1 and isEscaped = 0 then
                    instring = 0
                elseif instring = 0 then
                    instring = 1
                    stringquote = 1
                end if
            end if
            tmpString[i+Shift] = l[i]
        end if
        if (wasEscaped) then isEscaped = 0
    next i
    
    tmpString[remain+shift]=0
    dim prevSpace as boolean = 0
    dim sl as integer= remain+shift
    shift = 0
    instring = 0 
    stringQuote = 0
    for i as unsigned integer=0 to sl
        if (l[i]=asc("'")) then
            if instring = 1 and stringQuote = 0 and isEscaped=0 then 
                instring = 0
            elseif instring = 0 then
                instring = 1
                stringquote = 0
            end if
        elseif (l[i]=34) then ' "
            if instring = 1 and stringquote = 1 and isEscaped = 0 then
                instring = 0
            elseif instring = 0 then
                instring = 1
                stringquote = 1
            end if
        end if
        
        if (tmpString[i]=32) and (prevSpace=true) and (instring = 0) then
            shift+=1
        else
            tmpString[i-shift] = tmpString[i]
            prevSpace = tmpString[i]=32
        end if
    next
    return tmpString
end function


sub ProcessTokens(tokens as unsigned byte ptr ptr,tokenString as unsigned byte ptr, count as unsigned integer)
      if IsBlockToken(tokens[0]) then
          var i  = Instruction.Construct(CurrentInstruction,tokens,tokenString,count)
          if (CurrentInstruction<>0) then
              if (i->IType = IFStatement) and (CurrentInstruction->IType=IfStatement) then
                i->ParentNode = CurrentInstruction->ParentNode
                cptr(IfInstruction ptr,CurrentInstruction)->ElseInstruction = cptr(IfInstruction ptr,i)
              else 
                CurrentInstruction->AddChild(i)
              end if
              
          end if
          CurrentInstruction = i
          return
      end if
      if (isEndBlockToken(tokens[0])) then
          
          if (CurrentInstruction<>0) then
              var i  = Instruction.Construct(CurrentInstruction,tokens,tokenString,count)
              CurrentInstruction->EndInstruction = i
              CurrentInstruction = CurrentInstruction->ParentNode
              return
          else
              print "invalid token"
          end if
      
      end if
      
      if (CurrentInstruction<>0) then
          var i  = Instruction.Construct(CurrentInstruction,tokens,tokenString,count)
          CurrentInstruction->AddChild(i)
          return
      else
      
          print "invalid token"
      end if
      free(tokens)
      free(tokenString)
end sub

sub processLine(l as unsigned byte ptr)
    
    dim tmpString as unsigned byte ptr = sanitizeString(l)
    dim tokenCount as unsigned integer
    dim tokens as unsigned byte ptr ptr =GetTokens(tmpString,@tokenCount)
    if (tokenCount>0) then
        strtolowerFix(tokens[0])
        
        
        if (strcmp(tokens[0],@"include")=0) then
            
            processFile(tokens[1])
        else
            processTOkens(tokens,tmpString,tokenCount)
        end if
    end if
end sub

sub processFile(fname as unsigned byte ptr)
    print "Processing file ";fname

    dim lineData as unsigned byte ptr
    dim fsize as integer
    dim buffer as unsigned byte ptr = VFS_LOAD_FILE(fname,@fsize)
    dim instring as unsigned integer = 0
    if (fsize<>0 and buffer<>0) then
        dim startPos as unsigned integer
        for i as unsigned integer = 0 to fsize-1
            
            select case buffer[i]
                case 34
                    if (instring =0)  then
                        instring = 1
                    else
                        instring = 0
                    end if
                case asc(":")
                    if (instring=0) then
                        if (startPos<i) then
                            lineData = substring(buffer,startPos,i-startPos)
                            processLine(lineData)
                        end if
                        startPos = i+1
                    end if
                case 13 'new line
                    if (startPos<i) then
                        lineData = substring(buffer,startPos,i-startPos)
                        processLine(lineData)
                    end if
                    startPos = i+1
                case 10
                    if (startPos<i) then
                        lineData = substring(buffer,startPos,i-startPos)
                        processLine(lineData)
                    end if
                    startPos = i+1
                case else
            end select
        next i
        if (startPos<fsize-1) then
            lineData = substring(buffer,startPos,fSize-1)
            processLine(lineData)
        end if
        free(buffer)
    end if
end sub
AutoLabelNum = 0
CurrentInstruction = new Instruction()
var rootInstruction = CurrentInstruction
processFile(@"test2.bas")
rootInstruction->ScopeVarNum = 0
rootInstruction->Process()

delete rootInstruction
sleep
end


