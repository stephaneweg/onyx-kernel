constructor TString()
    this.Len=0
    this.Buffer=MAlloc(512)
    this.BufferSize=512
    this.Buffer[0]=0
    this.Destruct = @TStringDestroy
end constructor

destructor TString()
    if this.Buffer<>0 then MFree(this.Buffer)
    this.Buffer = 0
    this.BufferSize = 0
    this.Len = 0
end destructor

sub TStringDestroy(elem as TString ptr)
    elem->destructor()
end sub

function TString.Create() as TString ptr
    NewObj(retval,TString)
    return retval
end function

sub TString.SetText(s as unsigned byte ptr)
    this.Len=strlen(s)
    this.ResizeBuffer(this.Len)

    dim i as integer
    while s[i]<>0
        this.Buffer[i]=s[i]
        i+=1
    wend
    this.Buffer[i]=0
end sub

sub TString.ResizeBuffer(newlen as unsigned integer)
    var newBufferSize=newlen+(512-(newlen mod 512))
    if (this.Buffer=0 or this.BufferSize<newBufferSize) then
        if (this.Buffer<>0) then MFree(this.Buffer)
        var b=MAlloc(newBufferSize)
        if (this.Buffer<>0) then memcpy(b,this.Buffer,this.BufferSize)
        this.Buffer=b
        this.BufferSize=newBufferSize
    end if
end sub

sub TString.AppendChar(c as unsigned byte)
    ResizeBuffer(this.Len+1)
    this.Buffer[this.Len]=c
    this.Len+=1
    this.Buffer[this.Len]=0
end sub

sub TString.AppendText(s as unsigned byte ptr)
    var l=strlen(s)
    dim i as integer
    for i=0 to l-1
        this.AppendChar(s[i])
    next i
end sub

sub TString.Trim()
    this.SetText(strtrim(this.Buffer))
end sub

sub TString.ToLower()
    this.SetText(strtolower(this.Buffer))
end sub

sub TString.ToUpper()
    this.SetText(strtoupper(this.Buffer))
end sub

sub TString.SubStr(start as unsigned integer,l as integer)
	if (l<0) then l=0
	this.SetText( substring(this.Buffer,start,l))
end sub

function TString.Compare(s as unsigned byte ptr) as integer
    return strcmp(this.Buffer,s)
end function

function TString.IndexOf(s as unsigned byte ptr) as integer
    return strindexof(this.Buffer,s)
end function

function TString.LastIndexOf(s as unsigned byte ptr) as integer
    return strlastindexof(this.Buffer,s)
end function

function TString.ContainsChar(b as unsigned byte) as integer
    dim cpt as integer
    for cpt=0 to this.Len
        if (this.BUffer[cpt]=b) then return -1
    next
    return 0
end function

function TString.EndsWithChar(b as unsigned byte) as integer
    return this.Buffer[this.Len-1]=b
end function

function TString.AsInt() as integer
    if (this.Buffer=0) then return 0
    return atoi(this.Buffer)
end function

function TString.AsUInt() as unsigned integer
    if (this.Buffer=0) then return 0
    return cast(unsigned integer,atoi(this.Buffer))
end function