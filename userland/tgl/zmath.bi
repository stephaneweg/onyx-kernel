type M4 field = 1
    m(0 to 3,0 to 3) as single
end type

type M3 field = 1
    m(0 to 2,0 to 2) as single
end type

type M34 field = 1
    m(0 to 2,0 to 3) as single
end type



#define _X v(0)
#define _Y v(1)
#define _Z v(2)
#define _W v(3)

type V3
    v(0 to 2) as single
end type

type V4
    v(0 to 3) as single
end type
declare function gl_Matrix_Inv(r as single ptr,m as single ptr,n as integer) as integer
declare function fabs(n as single) as single

declare sub gl_M4_id(a as M4 ptr)
declare function gl_M4_IsId(a as M4 ptr) as integer

declare sub gl_M4_Move(a as M4 ptr,b as M4 ptr)
declare sub gl_MoveV3(a as V3 ptr,b as  V3 ptr)

declare sub gl_MulM4V3(a as V3 ptr,b as M4 ptr, c as V3 ptr)
declare sub gl_MulM3V3(a as V3 ptr,b as M4 ptr,c as V3 ptr)

declare sub gl_M4_MulV4(a as V4 ptr,b as M4 ptr,c as V4 ptr)
declare sub gl_M4_InvOrtho(a as M4 ptr,b as M4 ptr)
declare sub gl_M4_Inv(a as M4 ptr,b as M4 ptr)
declare sub gl_M4_Mul(c as M4 ptr,a as M4 ptr,b as M4 ptr)
declare sub gl_M4_MulLeft(c as M4 ptr,a as M4 ptr)
declare sub gl_M4_Transpose(a as M4 ptr, b as M4 ptr)
declare sub gl_M4_Rotate(a as M4 ptr,t as single,u as integer)
declare function gl_V3_Norm(a as V3 ptr) as integer

declare function gl_V3_New(x as single,y as single,z as single) as V3
declare function gl_V4_New(x as single,y as single,z as single,w as single) as V4
