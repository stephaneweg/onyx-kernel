
const KEY_LEFT=&h4B
const KEY_RIGHT=&h4D
const KEY_UP=&h48
const KEY_DOWN=&h50
const KEY_CTRL=29
const KEY_ALT=56
const KEY_ALTOFF=184
const KEY_SHIFT1=42             
const KEY_SHIFT2=54

dim shared KBD_UPDATED as unsigned integer
dim shared KBD_BUFFER(0 to 255) as unsigned byte
dim shared KBD_BUFFERPOS as unsigned integer
dim shared KBD_CTRL as byte
dim shared KBD_ALT as byte
dim shared KBD_SHIFT as byte
dim shared KBD_CIRC as byte
dim shared KBD_GUILLEMETS as byte
dim shared KEYBOARD_Loaded as byte

dim shared KBD_Thread as unsigned integer
declare sub KBD_PutChar(char as unsigned byte)
declare sub KBD_FLUSH()
declare sub INIT_KBD()
declare sub KBD_Thread_Loop(p as any ptr)
declare function KBD_GetChar() as unsigned byte
declare sub KBD_IRQ_Handler(_intno as unsigned integer,_senderproc as unsigned integer,_sender as unsigned integer,_eax as unsigned integer,_ebx as unsigned integer,_ecx as unsigned integer,_edx as unsigned integer,_esi as unsigned integer,_edi as unsigned integer,_ebp as unsigned integer,_esp as unsigned integer)
declare sub KBD_HANDLER(akey as unsigned byte)