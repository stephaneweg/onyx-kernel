   
type keyWord
    word as unsigned byte ptr
    wordLen as unsigned integer
    nextKeyWord as keyWord ptr
    prevKeyWord as keyWord ptr
    declare constructor(w as unsigned byte ptr)
end type

type SourceLine
    tokenCount as unsigned integer
    tokens(0 to 1024) as unsigned byte ptr
    nextLine as sourceLine ptr
end type



declare sub ProcessFile(f as unsigned byte ptr)
declare sub ProcessLine(l as unsigned byte ptr)
declare function findToken(l as unsigned byte ptr) as KeyWord ptr
declare sub addToken(l as unsigned byte ptr,s as unsigned integer,sl as sourceLine ptr)
declare sub InitLexer()
dim shared keyWords as keyWord ptr

dim shared sourceLines as sourceLine ptr
dim shared lastSourceLine as sourceLine ptr


sub InitLexer()
    keyWords = 0
    var a = new KeyWord(@"sub")
    a = new KeyWord(@"end sub")
    a = new KeyWord(@"then")
    a = new KeyWord(@"function")
    a = new KeyWord(@"end function")
    a = new KeyWord(@"program")
    a = new KeyWord(@"end program")
    a = new KeyWord(@"class")
    a = new KeyWord(@"end class")
    a = new KeyWord(@"dim")
    a = new KeyWord(@"extends")
    a = new KeyWord(@"ptr")
    a = new KeyWord(@"new")
    a = new KeyWord(@"delete")
    a = new KeyWord(@"for")
    a = new KeyWord(@"to")
    a = new KeyWord(@"step")
    a = new KeyWord(@"next")
    a = new KeyWord(@"if")
    a = new KeyWord(@"else if")
    a = new KeyWord(@"else")
    a = new KeyWord(@"end if")
    a = new KeyWord(@"do")
    a = new KeyWord(@"loop")
    a = new KeyWord(@"until")
    a = new KeyWord(@"while")
    a = new KeyWord(@"wend")
    a = new KeyWord(@"select case")
    a = new KeyWord(@"end select")
    a = new KeyWord(@"case")
    a = new KeyWord(@"end case")
    a = new KeyWord(@"and")
    a = new KeyWord(@"or")
    a = new KeyWord(@"xor")
    a = new KeyWord(@"not")
    a = new KeyWord(@"=")
    a = new KeyWord(@"+")
    a = new KeyWord(@"++")
    a = new KeyWord(@"+=")
    a = new KeyWord(@"-")
    a = new KeyWord(@"--")
    a = new KeyWord(@"-=")
    a = new KeyWord(@"*")
    a = new KeyWord(@"/")
    a = new KeyWord(@"\")
    a = new KeyWord(@"%")
    a = new KeyWord(@">>")
    a = new KeyWord(@"<<")
    a = new KeyWord(@"<>")
    a = new KeyWord(@"<")
    a = new KeyWord(@"<")
    a = new KeyWord(@"<=")
    a = new KeyWord(@"=>")
    a = new KeyWord(@"@")
    a = new KeyWord(@"[")
    a = new KeyWord(@"]")
    a = new KeyWord(@"(")
    a = new KeyWord(@")")
    a = new KeyWord(@",")
    a = new KeyWord(@"as")
    
    a = new KeyWord(@"byte")
    a = new KeyWord(@"ubyte")
    a = new KeyWord(@"short")
    a = new KeyWord(@"ushort")
    a = new KeyWord(@"int")
    a = new KeyWord(@"uint")
    a = new KeyWord(@"long")
    a = new KeyWord(@"ulong")
    a = new KeyWord(@"double")
    a = new KeyWord(@"float")
    a = new KeyWord(@"string")
    a = new KeyWord(@"this")
    a = new KeyWord(@"sizeof")
    a = new KeyWord(@"static")
    a = new KeyWord(@"asm")
    a = new KeyWord(@"end asm")
end sub


constructor keyWord(w as unsigned byte ptr)
    word = w
    wordLen = strlen(w)
    this.NextKeyWord = 0
    this.PrevKeyWord = 0
    if (keyWords = 0) then
        keyWords = @this
    else
        var kw = keyWords
        var lastKeyWord = kw
        while kw<>0
            if (kw->wordLen<=wordLen) then
                this.NextKeyWord = kw
                if (kw->PrevKeyWord<>0) then kw->PrevKeyWord->nextKeyWord = @this
                this.PrevKeyWord = kw->PrevKeyWord
                kw->PrevKeyWord = @this
                if (kw=KeyWords) then KeyWords = @this
                exit while
            end if
            lastKeyWord = kw
            kw = kw->NextKeyWord
        wend
        if (this.NextKeyWord=0) then
            lastKeyWord->NextKeyWord = @this
            this.PrevKeyWord = lastKeyWord
        end if
    end if
end constructor

function findToken(l as unsigned byte ptr) as KeyWord ptr
    var kw = keyWords
    while kw<>0
        if (strncmp(kw->word,l,kw->WordLen)=0) then return kw
        kw=kw->NextKeyWord
    wend
    return 0
end function

sub addToken(l as unsigned byte ptr,s as unsigned integer,sl as sourceLine ptr)
    var newString=Malloc(s+1)
    memset(newstring,0,s+1)
    memcpy(newstring,l,s)
    sl->tokens(sl->TokenCount) = newString
    sl->tokenCount+=1
end sub


sub ProcessLine(l as unsigned byte ptr)
    dim sl as SourceLine ptr = MAlloc(sizeof(SourceLine))
    sl->TokenCount = 0
    
    var slen = strlen(l)
    dim current as integer
    dim prev as integer
    dim inString as integer =0
    prev = 0
    current =0
    while current<slen
        var c = l[current]
        if (c=34) then
            if (inString=1) then 
                inString = 0
                addToken(l+prev,(current-prev)+1,sl)
                prev=current+1
            else
                if (prev<current) then
                    addToken(l+prev,current-Prev,sl)
                end if
                prev=current
                inString = 1
            end if
        elseif (c=32 and inString=0) then
            if (prev<current) then
                    addToken(l+prev,current-Prev,sl)
            end if
            prev=current+1
        else
            var t = findToken(l+current)
            if (t<>0) then
                if (prev<current) then
                    addToken(l+prev,current-Prev,sl)
                end if
                addToken(l+current,t->WordLen,sl)
                current=current+t->WordLen
                Prev=current
                continue while
            end if
        end if
        current+=1
    wend
    if (prev<current) then
        addToken(l+prev,current-Prev,sl)
    end if
    
    
    if (sourceLines = 0) then
        sourceLines = sl
    else
        lastSourceLine->NextLine = sl
    end if
    lastSourceLIne = sl
    sl->NextLine = 0
end sub


sub ProcessFile(f as unsigned byte ptr)
    
    dim fsize as unsigned integer
    dim buff as unsigned byte ptr = VFS_LOAD_FILE(f,@fsize)
    dim isInString as integer = 0
    dim inComment as integer = 0
    if (buff<>0 and fsize<>0) then
        dim prev as unsigned integer = 0
        dim current as unsigned integer =0
        while current<fsize
            var c = buff[current]
            if ((c = 0) or (c=10) or (c = 13) or (c = asc(":"))) or ((c = asc("#")) and (isInString = 0)) then
                buff[current] = 0
                if (prev<current) then
                    if (inComment=0) then
                      ProcessLine(buff + prev)
                    end if
                end if
                if (c=asc("#")) then
                    inComment = 1
                else
                    inComment = 0
                end if
                prev = current+1
            elseif ((c=32 or c=9) and (isInString=0) and (prev=current)) then
                prev = current+1
            elseif (c=34 and inComment=0) then
                if (isInString =0) then
                    isInString = 1
                else
                    isInString = 0
                end if
            end if
            current+=1
        wend
        if (prev<current) and (inComment=0) then
            ProcessLine(buff + prev)
        end if
        
    end if
end sub