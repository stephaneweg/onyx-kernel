const null=0
#macro SCW(i)
  asm
  sub esp,2
  fnstcw    [esp]
  mov   ax, [esp]
  and   ax, &HF3FF
  or    ax, &H0400
  mov   [i],ax
  fldcw [i]
#endmacro
#macro RCW()
  fldcw [esp]
  add   esp, 2
  end asm
#endmacro

#macro FloorD(i,d)
  SCW(i)
  fld   qword ptr [d]
  fistp dword ptr [i]
  RCW()
#endmacro

declare function min(v1 as unsigned integer,v2 as unsigned integer) as unsigned integer
declare function sqrt(d as double) as double
declare function fcos(d as double) as double
declare function fsin(d as double) as double
declare function strlen(s as  unsigned byte ptr) as unsigned integer
declare function strncmp(s1 as  unsigned byte ptr,s2 as  unsigned byte ptr,count as unsigned integer) as integer
declare function strcmp(s1 as  unsigned byte ptr,s2 as  unsigned byte ptr) as integer
declare function strtrim(s as  unsigned byte ptr) as unsigned byte ptr
declare function strcontains(s as  unsigned byte ptr,s2 as  unsigned byte ptr) as integer
declare function strindexof(s as  unsigned byte ptr,s2 as  unsigned byte ptr) as integer
declare function strlastindexof(s as  unsigned byte ptr,s2 as  unsigned byte ptr) as integer

declare sub strrev(s as unsigned byte ptr)
declare function strendswith(src as unsigned byte ptr,search as unsigned byte ptr) as unsigned integer
declare function strcpy(dst as unsigned byte ptr,src as  unsigned byte ptr) as unsigned byte ptr
declare function strtoupper(s as  unsigned byte ptr) as unsigned byte ptr
declare function strtolower(s as  unsigned byte ptr) as unsigned byte ptr
declare function strcat(s1 as  unsigned byte ptr,s2 as  unsigned byte ptr) as unsigned byte ptr
declare function substring(s as  unsigned byte ptr,index as unsigned integer, count as integer) as unsigned byte ptr

declare sub memcpy(dst as any ptr,src as any ptr,cpt as unsigned integer)
declare sub memcpy16(dst as any ptr,src as any ptr,cpt as unsigned integer)
declare sub memcpy32(dst as any ptr,src as any ptr,cpt as unsigned integer)
declare sub memset(dst as any ptr,value as unsigned byte,cpt as unsigned integer) 
declare sub memset16(dst as any ptr,value as unsigned short,cpt as unsigned integer) 
declare sub memset32(dst as any ptr,value as unsigned integer,cpt as unsigned integer) 

declare function atoi(s as  unsigned byte ptr) as integer
declare function atoihex(s as  unsigned byte ptr) as unsigned integer
declare function atol(s as  unsigned byte ptr) as long
declare function atolhex(s as  unsigned byte ptr) as unsigned long
declare function atof(s as unsigned byte ptr) as double
declare sub ftoa(d as double,b as unsigned byte ptr)

declare function absolute(value as integer) as integer
declare function IntToStr (number as unsigned integer,abase as unsigned integer) as unsigned byte ptr
declare function DoubleToStr(c as double) as unsigned byte ptr