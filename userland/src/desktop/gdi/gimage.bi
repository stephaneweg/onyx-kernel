
enum HorizontalAlignment
    Left = 0
    Right = 1
    Center = 2
end enum

type RGBType field = 1
    R as unsigned byte
    G as unsigned byte
    B as unsigned byte
end type

Type BMPHeader field = 1
        format  as Unsigned SHORT
        size    as unsigned integer
        reserved1 as unsigned short
        reserved2 as unsigned short
        dataOffset as unsigned integer
        
        dibSize as unsigned integer
        pixelWidth as unsigned integer
        pixelHeight as unsigned integer
        colorPlanes as unsigned short
        bitsPerPixel as unsigned short
        compressionMethod as unsigned integer
        ImageSize as unsigned integer
        XRes as unsigned integer
        YRes as unsigned integer
        ColCH as unsigned integer
        IC as unsigned integer
end type


TYPE GImage extends TObject
    _width as unsigned integer
    _height as unsigned integer
    _buffer as unsigned integer ptr
    _bufferSize as unsigned integer
    
    OnSizeChanged as any ptr
    declare constructor()
    declare destructor()
    
    declare property Width() as unsigned integer
    declare property Width(w as unsigned integer)
    declare property Height() as unsigned integer
    declare property Height(h as unsigned integer)
    declare sub SetSize(w as unsigned integer,h as unsigned integer)    
    declare sub CreateBuffer()
    
    declare sub Clear(c as unsigned integer)
    declare sub SetPixel(_x as integer,_y as integer,c as unsigned integer)
    declare sub DrawLine(x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
    declare sub FillRectangle(x1 as integer,y1 as integer,x2 as integer,y2 as integer, c as unsigned integer)
    declare sub FillRectangleAlpha(x1 as integer,y1 as integer,x2 as integer,y2 as integer, c as unsigned integer)
    declare sub FillRectangleAlphaHalf(x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
    declare sub DrawRectangle(x1 as integer,y1 as integer,x2 as integer,y2 as integer, c as unsigned integer)
    declare sub PutOtherRaw(src as unsigned integer ptr,_w as integer,_h as integer,x as integer,y as integer)
    declare sub PutOther(src as GImage ptr,x as integer,y as integer,transparent as integer)
    declare sub PutOtherPart(src as GImage ptr,x as integer,y as integer,sourceX as integer,sourceY as integer,sourceWidth as integer,sourceHeight as integer, transparent as integer)
    declare sub DrawTextMultiLine(s as unsigned byte ptr,x1 as integer,y1 as integer,c as integer,fdata as FontData ptr,ratio as integer,w as integer,textAlign as HorizontalAlignment)
    declare sub DrawText(txt as unsigned byte ptr,x1 as integer,y1 as integer,c as integer,fdata as FontData ptr,ratio as integer)
    declare sub DrawChar(asciicode as unsigned byte,x1 as integer,y1 as integer,c as integer,fdata as FontData ptr,ratio as integer)
	declare static Function LoadFromRaw(path as unsigned byte ptr,_w as unsigned integer,_h as unsigned integer) as GImage ptr
    declare static Function LoadFromBitmap(path as unsigned byte ptr) as GImage ptr
end type


declare sub GImageDestroy(elem as GImage ptr)
dim shared GImageTypeName as unsigned byte ptr=@"GImage"
