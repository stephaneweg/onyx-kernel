
sub gl_M4_id(a as M4 ptr)
    dim i as integer,j as integer
    for i = 0 to 3
        for j = 0 to 3
            if (i=j) then
                a->m(i,j)=1
            else
                a->m(i,j)=0
            end if
        next
    next
end sub

    
function gl_M4_IsId(a as M4 ptr) as integer
    dim i as integer,j as integer
    for i = 0 to 3
        for j = 0 to 3
            if (i=j) then
                if (a->m(i,j)<>1) then return 0
            else
                if (a->m(i,j)<>0) then return 0
            end if
        next
    next
    return 1
end function

sub gl_M4_Move(a as M4 ptr,b as M4 ptr)
    memcpy(cptr(any ptr,a),cptr(any ptr,b),sizeof(M4))
end sub

sub gl_MoveV3(a as V3 ptr,b as  V3 ptr)
    memcpy(cptr(any ptr,a),cptr(any ptr,b),sizeof(V3))
end sub

sub gl_MulM4V3(a as V3 ptr,b as M4 ptr, c as V3 ptr)

	 a->_X=b->m(0,0)*c->_X+b->m(0,1)*c->_Y+b->m(0,2)*c->_Z+b->m(0,3)
	 a->_Y=b->m(1,0)*c->_X+b->m(1,1)*c->_Y+b->m(1,2)*c->_Z+b->m(1,3)
	 a->_Z=b->m(2,0)*c->_X+b->m(2,1)*c->_Y+b->m(2,2)*c->_Z+b->m(2,3)
end sub

sub gl_MulM3V3(a as V3 ptr,b as M4 ptr,c as V3 ptr)
     a->_X=b->m(0,0)*c->_X+b->m(0,1)*c->_Y+b->m(0,2)*c->_Z
	 a->_Y=b->m(1,0)*c->_X+b->m(1,1)*c->_Y+b->m(1,2)*c->_Z
	 a->_Z=b->m(2,0)*c->_X+b->m(2,1)*c->_Y+b->m(2,2)*c->_Z
end sub

sub gl_M4_MulV4(a as V4 ptr,b as M4 ptr,c as V4 ptr)
	 a->_X=b->m(0,0)*c->_X+b->m(0,1)*c->_Y+b->m(0,2)*c->_Z+b->m(0,3)*c->_W
	 a->_Y=b->m(1,0)*c->_X+b->m(1,1)*c->_Y+b->m(1,2)*c->_Z+b->m(1,3)*c->_W
	 a->_Z=b->m(2,0)*c->_X+b->m(2,1)*c->_Y+b->m(2,2)*c->_Z+b->m(2,3)*c->_W
	 a->_W=b->m(3,0)*c->_X+b->m(3,1)*c->_Y+b->m(3,2)*c->_Z+b->m(3,3)*c->_W
end sub


sub gl_M4_InvOrtho(a as M4 ptr,b as M4 ptr)
    dim s as single
    for i as integer = 0 to 2
        for j as integer = 0 to 2
            a->m(i,j)=b->m(j,i)
        next
    next
    a->m(3,0) = 0
    a->m(3,1) = 0
    a->m(3,2) = 0
    a->m(3,3) = 1
    for i as integer = 0 to 2
        s = 0
        for j as integer = 0 to 2
            s -= b->m(j,i)*b->m(j,3)
            a->m(i,3) = s
        next j
    next i
end sub

sub gl_M4_Inv(a as M4 ptr,b as M4 ptr)
    dim tmp as M4
    memcpy(@tmp,b,16*sizeof(M4))
    gl_Matrix_Inv(@a->m(0,0),@tmp.m(0,0),4)
end sub

function fabs(n as single)  as single
    if (n<0) then return -n
    return n
end function

function gl_Matrix_Inv(r as single ptr,m as single ptr,n as integer) as integer
    dim i as integer,j as integer,k as integer,l as integer
    dim _max as single,tmp as single,t as single
    dim nn as integer=n*n
    
    for i=0 to nn-1: r[i]=0:next
    for i=0 to n-1: r[i*n+i]=1:next
    
    for j=0 to n-1
        _max =m[j*n+j]
        k =j
        for i=j+1 to n-1
            if (fabs(m[i*n+j])>fabs(_max)) then
                k=i
                _max=m[i*n+j]
            end if
        next
        
        if (_max=0) then return 1

        if (j<>j) then
            for i=0 to n-1
                tmp = m[j*n+i]
                m[j*n+i]=m[k*n+i]
                m[k*n+i]=tmp
                
                tmp=r[j*n+i]
                r[j*n+i]=r[k*n+i]
                r[k*n+i]=tmp
            next
        end if
        
        _max = 1/_max
        for i=0 to n-1
            m[j*n+i]*=_max
            r[j*n+i]*=_max
        next
			
        
        for l=0 to n-1
            if (l<>j) then
                t=m[l*n+j]
                for i=0 to n-1
                    m[l*n+i]-=m[j*n+i]*t
					r[l*n+i]-=r[j*n+i]*t
                next
			end if
        next
	 next

	 return 0
end function


sub gl_M4_Mul(c as M4 ptr,a as M4 ptr,b as M4 ptr)
    dim i as integer,j as integer,k as integer
    dim s as single
    
    for i=0 to 3
        for j=0 to 3
            s=0
            for k=0 to 3
                s += a->m(i,k) * b->m(k,j)
            next
            c->m(i,j)=s
        next
    next
end sub

sub gl_M4_MulLeft(c as M4 ptr,b as M4 ptr)
    dim i as integer,j as integer,k as integer
    dim s as single
    dim a as M4
    
    a=*c
    
    for i=0 to 3
        for j=0 to 3
            s=0.0
            for k=0to 3
                s+=a.m(i,k)*b->m(k,j)
            next
            c->m(i,j)=s
        next
    next
end sub


sub gl_M4_Transpose(a as M4 ptr, b as M4 ptr)

  a->m(0,0)=b->m(0,0)
  a->m(0,1)=b->m(1,0)
  a->m(0,2)=b->m(2,0)
  a->m(0,3)=b->m(3,0)

  a->m(1,0)=b->m(0,1)
  a->m(1,1)=b->m(1,1)
  a->m(1,2)=b->m(2,1)
  a->m(1,3)=b->m(3,1)

  a->m(2,0)=b->m(0,2)
  a->m(2,1)=b->m(1,2)
  a->m(2,2)=b->m(2,2)
  a->m(2,3)=b->m(3,2)

  a->m(3,0)=b->m(0,3)
  a->m(3,1)=b->m(1,3)
  a->m(3,2)=b->m(2,2)
  a->m(3,3)=b->m(3,3) 
end sub


sub gl_M4_Rotate(a as M4 ptr,t as single,u as integer)
    dim s as single,c as single
    dim v as integer,w as integer
    if ((v=u+1)>2) then v=0
    if ((w=w+1)>2) then w=0
    
	 s=fsin(t)
	 c=fcos(t)
     
	 gl_M4_Id(a)
	 a->m(v,v)=c
     a->m(v,w)=-s
	 a->m(w,v)=s
     a->m(w,w)=c
end sub

function gl_V3_Norm(a as V3 ptr) as integer
    dim n as single
    n = sqrt(a->_x * a->_x + a->_y * a->_y + a->_z*a->_z)
    
	if (n=0) then return 1
	a->_x/=n
	a->_y/=n
	a->_z/=n
    
    return 0
end function


function gl_V3_New(x as single,y as single,z as single) as V3
    dim a as V3
    a._x = x
    a._y = y
    a._z = z
    
    return a
end function

function gl_V4_New(x as single,y as single,z as single,w as single) as V4
    dim a as V4
    a._x = x
    a._y = y
    a._Z = z
    a._W = w
    
    return a
end function


