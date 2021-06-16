declare SUB MAIN (mb_info as multiboot_info ptr)
declare sub KERNEL_ERROR(message as unsigned byte ptr,code as unsigned integer)
extern KERNEL_START alias "KERNEL_START" as byte
extern KERNEL_END   alias "KERNEL_END"   as byte

#define KSTART @KERNEL_START
#define KEND @KERNEL_END
#define xkend cptr(any ptr,(((cuint(@KERNEL_END) shr 12)+1) shl 12))
#define cbyteptr(x) cptr(unsigned byte ptr,x)

declare sub EnterGraphicMode(mode as unsigned integer)