dim shared MOUSE_CYCLE as byte
dim shared MOUSE_BYTE(0 to 2) as unsigned byte
const _time_out = 10000

dim shared OldMouseX as integer
dim shared OldMouseY as integer
dim shared OldMouseB as integer

dim shared MouseX as integer
dim shared MouseY as integer
dim shared MouseB as integer

dim shared MouseMaxX as integer
dim shared MouseMaxY as integer


declare sub INIT_MOUSE()
declare function MOUSE_INT_HANDLER(stack as IRQ_STACK ptr) as IRQ_STACK ptr
declare sub SET_MOUSE_LIMIT(x as integer,y as integer)
declare sub MOUSE_INSTALL()
declare function MOUSE_READ() as byte
declare sub MOUSE_WRITE(b as byte)
declare sub MOUSE_WAIT(a_type as integer)
declare sub MOUSE_DATA_ARIVED(b as byte)
declare sub MOUSE_SET_DATA()
dim shared MouseUpdated as unsigned integer
