declare sub ScreenInit()
declare sub LoadMouseCursor()
declare sub ScreenLoop()
declare sub UILoop(elem as GDIBase ptr)
declare sub ScreenDrawFront(elem as GDIBase ptr)
declare sub ScreenDrawBack(elem as GDIBase ptr)
dim shared RootScreen as GDIBase ptr
dim shared MouseCursor as GDIBase
dim shared ScreenBGR as GImage ptr

declare sub GenBackground()
declare function ComputeColor(c as unsigned integer,chanel as unsigned integer) as unsigned integer