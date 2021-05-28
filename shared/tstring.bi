
type TString extends TObject field=1
    buffer as unsigned byte ptr
    len as unsigned integer
    buffersize as unsigned integer
    
    declare static function Create() as TString ptr
    
    declare sub SetText(s as unsigned byte ptr)
    declare sub AppendChar(c as unsigned byte)
    declare sub AppendText(s as unsigned byte ptr)
    declare sub Trim()
    declare sub ToLower()
    declare sub ToUpper()
    declare sub SubStr(start as unsigned integer,l as integer)
    declare function IndexOf(s as unsigned byte ptr) as integer
    declare function LastIndexOf(s as unsigned byte ptr) as integer
    declare function Compare(s as unsigned byte ptr) as integer
    declare function EndsWithChar(s as unsigned byte) as integer
    declare function ContainsChar(s as unsigned byte) as integer
    declare function AsInt() as integer
    declare function AsUInt() as unsigned integer
    declare Constructor()
    declare Destructor()
    declare sub ResizeBuffer(newlen as unsigned integer)
end type

declare sub TStringDestroy(elem as TString ptr)
