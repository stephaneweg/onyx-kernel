declare function GDICreate(_parent as unsigned integer,x as integer,y as integer,w as unsigned integer,h as unsigned integer) as unsigned integer
declare function GDIWindowCreate(w as unsigned integer,h as unsigned integer, t as any ptr) as unsigned integer
declare function GDIButtonCreate(_p as unsigned integer,x as integer,y as integer,w as unsigned integer,h as unsigned integer,t as any ptr,c as any ptr, parm as unsigned integer) as unsigned integer
declare function GDITextBoxCreate(_p as unsigned integer,x as integer,y as integer,w as unsigned integer,h as unsigned integer) as unsigned integer
declare function GDITextBlockCreate(_p as unsigned integer,x as integer,y as integer,t as unsigned byte ptr,c as unsigned integer) as unsigned integer
declare function GDIConsoleCreate(_p as unsigned integer,x as unsigned integer,y as unsigned integer,w as unsigned integer,h as unsigned integer) as unsigned integer

declare sub GDIClear(_gd as unsigned integer,c as unsigned integer)
declare sub GDIDrawLine(_parent as unsigned integer,x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
declare sub GDIDrawRectangle(_parent as unsigned integer,x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
declare sub GDIFillRectangle(_parent as unsigned integer,x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
declare sub GDIDrawText(_gd as unsigned integer,txt as unsigned byte ptr,x as integer,y as integer,c as unsigned integer)
declare sub GDIDrawChar(_gd as unsigned integer,cara as unsigned byte,x as integer,y as integer,c as unsigned integer)
declare sub GDIPutImage(_gd as unsigned integer,_x as unsigned integer,_y as unsigned integer,_width as unsigned integer,_height as unsigned integer,bpp as unsigned integer,_buffer as unsigned integer)
declare sub GDISetForegroundColor(g as unsigned integer,c as unsigned integer)
declare sub GDISetPosition(_gd as unsigned integer,x as integer,y as integer)
declare sub GDISetTransparent(_gdi as unsigned integer,transparent as unsigned integer)
declare sub GDISetVisible(_gdi as unsigned integer,visible as unsigned integer)
declare function GDIGetBuffer(_gdi as unsigned integer,w as unsigned integer ptr,h as unsigned integer ptr) as unsigned integer ptr


declare sub GDIButtonSetSkin(_btn as unsigned integer,skin as unsigned byte ptr)
declare sub GDIButtonSetIcon(_btn as unsigned integer,icon as unsigned byte ptr,big as unsigned integer)
declare sub GDIButtonSetSkinColor(_btn as unsigned integer,c as unsigned integer)
declare sub GDISetShadow(_gdi as unsigned integer,c as unsigned integer)


declare sub GDITextBoxGetText(_tb as unsigned integer,dst  as unsigned byte ptr)
declare sub GDITextBoxSetText(_p as unsigned integer,text as unsigned byte ptr)
declare sub GDITextBoxAppendChar(_p as unsigned integer,c as unsigned byte)
declare sub GDIBringToFront(_elem as unsigned integer)
declare sub GDIOnKeyPress(_elem as unsigned integer,callback as any ptr)
declare sub GDIOnMouseClick(_elem as unsigned integer,callback as any ptr)


declare function MessageBoxShow(text as any ptr,title as any ptr) as integer
declare function MessageConfirmShow(text as any ptr,title as any ptr) as integer

declare sub GDIInvalidate(_elem as unsigned integer)
declare sub GetScreenRes(byref x as unsigned integer,byref y as unsigned integer )
declare sub ConvertBuffer24TO32(dst as any ptr,src as any ptr,pixelcount as unsigned integer)
