#include once "stdlib.bi"
static shared Result(0 to 2047) as unsigned byte
static shared Result2(0 to 2047) as unsigned byte


function sqrt(d as double) as double
	dim result as double = d
    dim i as integer
	SCW(i)
  
        fld qword ptr [result]
        fsqrt
        fst qword ptr [result]
        
    RCW()
	return result
end function

function dcos(d as double) as double
	dim result as double = d
    dim i as integer
	asm
  
        fld qword ptr [result]
        fcos
        fst qword ptr [result]
        
    end asm
	return result
end function

function dsin(d as double) as double
	dim result as double = d
    dim i as integer
	asm
  
        fld qword ptr [result]
        fsin
        fst qword ptr [result]
        
    end asm
	return result
end function

function fcos(d as single) as single
	dim result as double = d
    dim i as integer
	asm
  
        fld qword ptr [result]
        fcos
        fst qword ptr [result]
        
    end asm
	return result
end function

function fsin(d as single) as single
	dim result as double = d
    dim i as integer
	asm
  
        fld qword ptr [result]
        fsin
        fst qword ptr [result]
        
    end asm
	return result
end function

function strlen(s as unsigned byte ptr) as unsigned integer
    dim retval as unsigned integer
    retval=0
    while s[retval]<>0
        retval+=1
    wend
    return retval
end function

function strwlen(s as unsigned short ptr) as unsigned integer
    dim retval as unsigned integer
    retval=0
    while s[retval]<>0
        retval+=1
    wend
    return retval
end function

function strdlen(s as unsigned integer ptr) as unsigned integer
    dim retval as unsigned integer
    retval=0
    while s[retval]<>0
        retval+=1
    wend
    return retval
end function

function strtrim(s as unsigned byte ptr) as unsigned byte ptr
    dim retval  as unsigned byte ptr=@(Result(0))
    retval[0]=0
    dim i as integer=0
    dim j as integer=0
    while (s[i]<>0 and s[i]=32 and s[i]<>9 and s[i]<>10 and s[i]<>13)
        i+=1
    wend
    while(s[i]<>0)
        retval[j]=s[i]
        i+=1
        j+=1
    wend
    retval[j]=0
    
    strrev(retval)
    
    i=0
    j=0
    while (retval[i]<>0 and retval[i]=32 and retval[i]=9 and retval[i]=10 and retval[i]=13)
        i+=1
    wend
    while(retval[i]<>0)
        retval[j]=retval[i]
        i+=1
        j+=1
    wend
    retval[j]=0
    strrev(retval)
    
    return retval
end function

function strcontains(s as unsigned byte ptr,s2 as unsigned byte ptr) as integer
    return 0
end function

function strindexof(s as unsigned byte ptr,s2 as unsigned byte ptr) as integer
    var l1=strlen(s)
    var l2=strlen(s2)
    dim i as integer
    dim j as integer
    var ok=0
    for i=0 to l1-l2
        if s[i]=s2[0] then
            ok=1
            for j=0 to l2-1
                if s[i+j]<>s2[j] then 
                    ok=0
                    exit for
                end if
            next j
            if ok<>0 then return i
        end if
    next i
    return -1
end function

function strlastindexof(s as unsigned byte ptr,s2 as unsigned byte ptr) as integer
    var l1=strlen(s)
    var l2=strlen(s2)
    dim i as integer
    dim j as integer
    var ok=0
    for i=l1-l2 to 0 step -1
        if s[i]=s2[0] then
            ok=1
            for j=0 to l2-1
                if s[i+j]<>s2[j] then 
                    ok=0
                    exit for
                end if
            next j
            if ok<>0 then return i
        end if
    next i
    return -1
end function


function strncmp(s1 as unsigned byte ptr,s2 as unsigned byte ptr,count as unsigned integer) as integer
    dim retval as integer=0
    dim i as integer=0
    while i<count
		if (s1[i]<>s2[i]) then return s1[i]-s2[i]
        i+=1
    wend
    return 0
end function

function strcmp(s1 as unsigned byte ptr,s2 as unsigned byte ptr) as integer
    dim retval as integer=0
    dim i as integer=0
    while s1[i]=s2[i] and s1[i]<>0 and s2[i]<>0
        i+=1
    wend
    return s1[i]-s2[i]
end function

function strwcmp(s1 as unsigned short ptr,s2 as unsigned short ptr) as integer
    dim retval as integer=0
    dim i as integer=0
    while s1[i]=s2[i] and s1[i]<>0 and s2[i]<>0
        i+=1
    wend
    return s1[i]-s2[i]
end function


sub strrev(s as unsigned byte ptr)
    
    dim l as integer=strlen(s)
    dim i as integer
    dim tmp as unsigned byte
    dim tmp2 as unsigned byte
    for i=0 to (l/2)-1
        tmp=s[i]
        tmp2=s[l-i-1]
        s[i] = tmp2
        s[l-i-1]=tmp
    next i
end sub



sub strToUpperFix(s as unsigned byte ptr)
	dim i as unsigned integer
    i=0
    while s[i]<>0
        if (s[i]>=97 and s[i]<=122) then
            s[i]=s[i]-32
        end if
        i+=1
    wend
end sub

sub strToLowerFix(s as unsigned byte ptr)
    dim i as unsigned integer
    i=0
    while s[i]<>0 and i<1022
        if (s[i]>=65 and s[i]<=90) then
            s[i]=s[i]+32
        end if
        i+=1
    wend
    s[i]=0
end sub

function strtoupper(s as unsigned byte ptr) as unsigned byte ptr
    dim i as unsigned integer
    dim dst as unsigned byte ptr=@(Result(0))
    i=0
    while s[i]<>0 and i<1022
        if (s[i]>=97 and s[i]<=122) then
            dst[i]=s[i]-32
        else
            dst[i]=s[i]
        end if
        i+=1
    wend
    dst[i]=0
    return dst
end function


function strtolower(s as unsigned byte ptr) as unsigned byte ptr
    dim i as unsigned integer
    dim dst as unsigned byte ptr=@(Result(0))
    i=0
    while s[i]<>0 and i<1022
        if (s[i]>=65 and s[i]<=90) then
            dst[i]=s[i]+32
        else
            dst[i]=s[i]
        end if
        i+=1
    wend
    dst[i]=0
    return dst
end function

function substring(s as unsigned byte ptr,index as unsigned integer, count as integer) as unsigned byte ptr
    dim i as unsigned integer
    dim dst as unsigned byte ptr=@(Result(0))
    dim l as unsigned integer=strlen(s)
    i=0
    while s[i+index]<>0 and i+index<1022 and i+index<l  and (i<count or count=-1)
        dst[i]=s[i+index]
        i+=1
    wend
    dst[i]=0
    return dst
end function

function strendswith(src as unsigned byte ptr,search as unsigned byte ptr) as unsigned integer
    var lindex = strlastindexof(src,search)
    if (lindex>=0) and (lindex = strlen(src)-strlen(search)) then
        return 1
    else
        return 0
    end if
end function

function strcat(s1 as unsigned byte ptr,s2 as unsigned byte ptr) as unsigned byte ptr
    dim i1 as unsigned integer=0
    dim i2 as unsigned integer=0
    dim dst as unsigned byte ptr=@(Result(0))
    while s1[i1]<>0 and i1<1022
        dst[i1]=s1[i1]
        i1+=1
    wend
    
    while s2[i2]<>0 and i1+i2<1022
        dst[i1+i2]=s2[i2]
        i2+=1
    wend
    dst[i1+i2]=0
    return dst
end function


sub ftoa(d as double,b as unsigned byte ptr)
    dim l as integer = 0
    var dbl=d
    dim bstart as unsigned integer = cptr(unsigned integer,b)
    if (dbl<0) then
        b[0]=asc("-")
        dbl = -dbl
        l+=1
        bstart+=1
    end if
    
    dim integralPart as unsigned integer
    FloorD(integralPart,dbl)
    dim decimalPart as unsigned integer =(dbl-integralPart) *  100000000
    
    dim n as integer
    
    
    while (integralPart>0)
        n = integralPart mod 10
        b[l]=n+48
        integralPart=(integralPart - n)/10
        l+=1
    wend
    
    b[l]=0
    strrev(cast(unsigned byte ptr,bstart))
    if (decimalPart>0) then
        b[l]=asc("."):l+=1
        if (decimalPart<10000000) then b[l]=asc("0"):l+=1
        if (decimalPart<1000000)then b[l]=asc("0"):l+=1
        if (decimalPart<100000) then b[l]=asc("0"):l+=1
        if (decimalPart<10000)  then b[l]=asc("0"):l+=1
        if (decimalPart<1000)   then b[l]=asc("0"):l+=1
        if (decimalPart<100)    then b[l]=asc("0"):l+=1
        if (decimalPart<10)     then b[l]=asc("0"):l+=1
        bstart = cptr(unsigned integer,b)+l
        while (decimalPart>0)
            n = decimalPart mod 10
            b[l]=n+48
            decimalPart=(decimalPart - n)/10
            l+=1
        wend
        b[l] = 0
        strRev(cast(unsigned byte ptr,bstart))
    end if
end sub

function FloatToStr(c as single) as unsigned byte ptr
    var dbl=c
    dim neg as integer=0
    if dbl<0 then
        neg=-1
        dbl=-dbl
    end if
    
    
    dim intDbl as single =  dbl shr 0
    var floatPart=(dbl*cast(single,1000000))-(intDbl*1000000)
    if neg then
        intDbl=-intDbl
    end if
    
    dim strResult as unsigned byte ptr= @(Result2(0))
    strCpy(strResult,IntToStr(intDbl,10))
   
    if (floatPart>0) then
         strCat(strResult,@".")
         if (floatPart<100000) then strCat(strResult,@"0")
         if (floatPart<10000) then strCat(strResult,@"0")
         if (floatPart<1000) then strCat(strResult,@"0")
         if (floatPart<100) then strCat(strResult,@"0")
         if (floatPart<10) then strCat(strResult,@"0")
         strCat(strResult,IntToStr(floatPart,10))
    end if
    return strResult
end function

function DoubleToStr(c as double) as unsigned byte ptr
    var dbl=c
    dim neg as integer=0
    if dbl<0 then
        neg=-1
        dbl=-dbl
    end if
    
    
    dim intDbl as double =  dbl shr 0
    'var floatPart=(dbl*cast(double,10000000000))-(intDbl*10000000000)
    var floatPart=(dbl*cast(double,1000000))-(intDbl*1000000)
    if neg then
        intDbl=-intDbl
    end if
    
    dim strResult as unsigned byte ptr= @(Result2(0))
    strCpy(strResult,IntToStr(intDbl,10))
   
    if (floatPart>0) then
         strCat(strResult,@".")
         'if (floatPart<1000000000) then strCat(strResult,@"0")
         'if (floatPart<100000000) then strCat(strResult,@"0")
         'if (floatPart<10000000) then strCat(strResult,@"0")
         'if (floatPart<1000000) then strCat(strResult,@"0")
         if (floatPart<100000) then strCat(strResult,@"0")
         if (floatPart<10000) then strCat(strResult,@"0")
         if (floatPart<1000) then strCat(strResult,@"0")
         if (floatPart<100) then strCat(strResult,@"0")
         if (floatPart<10) then strCat(strResult,@"0")
         strCat(strResult,IntToStr(floatPart,10))
    end if
    return strResult
end function


function ULongToStr (number as unsigned long,abase as unsigned integer) as unsigned byte ptr
    dim buffer as unsigned byte ptr
    dim dst as unsigned byte ptr=@(Result(0))
    dim i as  unsigned long=number
    dim l as unsigned long=0
    dim n as unsigned long
    dim bbase as unsigned long = abase
    
    if (i=0) then
        dst[0]=48
        dst[1]=0
        return dst
    end if
    
    
    while (i>0)
        n = i mod bbase
        if (n<10) then
            dst[l]=n+48
        else
            dst[l]=n+55
        end if
        i=(i - n)/bbase
        l+=1
    wend
    dst[l]=0
    strrev(dst)
    return dst
end function

function LongToStr (number as long,abase as unsigned integer) as unsigned byte ptr
    dim buffer as unsigned byte ptr
    dim dst as unsigned byte ptr=@(Result(0))
    dim i as  long=number
    dim l as long=0
    dim neg as integer=0
    dim n as integer
    dim bbase as unsigned long = abase
    if (i=0) then
        dst[0]=48
        dst[1]=0
        return dst
    end if
    
    if (i<0) then
        i=-i
        neg=-1
    end if
    
    while (i>0)
        n = i mod bbase
        if (n<10) then
            dst[l]=n+48
        else
            dst[l]=n+55
        end if
        i=(i - n)/bbase
        l+=1
    wend
    if (neg) then
        dst[l]=45
        l+=1
    end if
    dst[l]=0
    strrev(dst)
    return dst
end function


function UIntToStr (number as unsigned integer,abase as unsigned integer) as unsigned byte ptr
    dim buffer as unsigned byte ptr
    dim dst as unsigned byte ptr=@(Result(0))
    dim i as  unsigned integer=number
    dim l as unsigned integer=0
    dim n as unsigned integer
    if (i=0) then
        dst[0]=48
        dst[1]=0
        return dst
    end if
    
    
    while (i>0)
        n = i mod abase
        if (n<10) then
            dst[l]=n+48
        else
            dst[l]=n+55
        end if
        i=(i - n)/abase
        l+=1
    wend
    dst[l]=0
    strrev(dst)
    return dst
end function

function IntToStr (number as integer,abase as unsigned integer) as unsigned byte ptr
    dim buffer as unsigned byte ptr
    dim dst as unsigned byte ptr=@(Result(0))
    dim i as  integer=number
    dim l as integer=0
    dim neg as integer=0
    dim n as integer
    dim bbase as integer = abase
    if (i=0) then
        dst[0]=48
        dst[1]=0
        return dst
    end if
    
    if (i<0) then
        i=-i
        neg=-1
    end if
    
    while (i>0)
        n = i mod bbase
        if (n<10) then
            dst[l]=n+48
        else
            dst[l]=n+55
        end if
        i=(i - n)/bbase
        l+=1
    wend
    if (neg) then
        dst[l]=45
        l+=1
    end if
    dst[l]=0
    strrev(dst)
    return dst
end function

function strcpy(dst as unsigned byte ptr,src as unsigned byte ptr) as unsigned byte ptr
    dim i as unsigned integer
    i=0
    while src[i]<>0
        dst[i]=src[i]
        i+=1
    wend
    dst[i]=src[i]
    return dst
end function

sub memcpy cdecl alias "memcpy"(dst as any ptr,src as any ptr,cpt as unsigned integer)
    asm
		mov esi,[src]
		mov edi,[dst]
		mov ecx,[cpt]
		cld
		rep movsb
	end asm
end sub

sub memcpy16(dst as any ptr,src as any ptr,cpt as unsigned integer)
    asm
		mov esi,[src]
		mov edi,[dst]
		mov ecx,[cpt]
		cld
		rep movsw
	end asm
end sub

sub memcpy32(dst as any ptr,src as any ptr,cpt as unsigned integer)
	asm
		mov esi,[src]
		mov edi,[dst]
		mov ecx,[cpt]
		cld
		rep movsd
	end asm
end sub


sub memcpy512(dst as any ptr,src as any ptr,cpt as unsigned integer)
	asm
		mov esi, [src]	
		mov edi, [dst]	
		mov ecx, [cpt]	
		
		memcpy64t_LoopCopy:
		movq  mm0, [esi+0]    ';1
		movq  mm1, [esi+8]  ';1
		movq  mm2, [esi+16]  ';1
		movq  mm3, [esi+24]  ';1
		movq  mm4, [esi+32]    ';1
		movq  mm5, [esi+40]  ';1
		movq  mm6, [esi+48]  ';1
		movq  mm7, [esi+56]  ';1
        
		movq  [edi+0] , mm0 ';1
		movq  [edi+8] , mm1 ';1
		movq  [edi+16], mm2 ';1
		movq  [edi+24], mm3 ';1   
		movq  [edi+32] , mm4 ';1
		movq  [edi+40] , mm5 ';1
		movq  [edi+48], mm6 ';1
		movq  [edi+56], mm7 ';1
		add edi,64
		add esi,64
        loop memcpy64t_LoopCopy
    
    
		emms
	end asm
end sub

sub memcpy64(dst as any ptr,src as any ptr,cpt as unsigned integer)
	dim dwByteCount as unsigned integer = cpt * 8
	asm
		mov esi, [src]
		mov ecx, [dwByteCount]
		mov edi, [dst]
		sub ecx, 256
		jl memcpy64_DonePreWarm

		memcpy64_PreWarm:
		'// Pre-warm the read buffer
		';clocks
		 mov al, [esi]  		';1
		 mov bl, [esi+32] 		';0
		 mov al, [esi+64] 		';1
		 mov bl, [esi+96] 		';0
		 mov al, [esi+128] 		';1
		 mov bl, [esi+160] 		';0
		 mov al, [esi+192] 		';1
		 mov bl, [esi+224] 		';0
 
		'// The nop will force the code
		'// to pair better.
		add esi, 256  			';1 
		nop   		  			';0 
 
		sub ecx, 256  			';1
		jg memcpy64_PreWarm		';0

		memcpy64_DonePreWarm:
		mov ecx, [dwByteCount]	';
		mov esi, [src]			';
		sub ecx, 8
		jl memcpy64_DoneCopy
		
		memcpy64_LoopCopy:
		movq mm0, [esi+ecx] ';1
		movq [edi+ecx], mm0 ';1
		sub ecx, 8  		';1
		jg memcpy64_LoopCopy  		';0
		memcpy64_DoneCopy:
		emms
	end asm
end sub

sub memset cdecl alias "memset"(dst as any ptr,value as unsigned byte,cpt as unsigned integer) 
    asm
		movb al,[value]
		mov ecx,[cpt]
		mov edi,[dst]
		cld
		rep stosb
	end asm
end sub

sub memset16(dst as any ptr,value as unsigned short ,cpt as unsigned integer) 
    asm
		movw ax,[value]
		mov ecx,[cpt]
		mov edi,[dst]
		cld
		rep stosw
	end asm
end sub

sub memset32(dst as any ptr,value as unsigned integer ,cpt as unsigned integer) 
	asm
		mov eax,[value]
		mov ecx,[cpt]
		mov edi,[dst]
		cld
		rep stosd
	end asm
end sub



function atoi(s as unsigned byte ptr) as integer
    if (s[0]= 48) and ((s[1]=120) or (s[1]=88)) then return atoihex(s+2)
    if (s[0]= 38) and ((s[1]=104) or (s[1]=72)) then return atoihex(s+2)
    
    dim res as integer=0
    dim i as integer=0
    dim fact as integer=1
    if (s[0]=45) then 
        fact=-1
        i=1
    end if
    if (s[0]=43) then i=1
    while (s[i]<>0)
        res=res*10+ s[i]-48
        i+=1
    wend
    return res*fact
end function


function atof(s as unsigned byte ptr) as double
    dim rez as double =0
    dim fact as double=1
    if (s[0]=45) then
        s+=1
        fact =-1
    end if
    dim point_seen as integer=0
    dim i as integer =0
    dim d as integer
    while s[i]<>0
        if (s[i] = 46) then
            point_seen = 1
        else
            d = s[i] - 48 '- "0"
            if (d >= 0 and d <= 9) then
                if (point_seen<>0) then fact =  fact /10.0
                rez = rez * 10.0 + cast(double,d)
            end if
        end if
        i+=1
    wend    
    
 
  return rez * fact
end function

function atoihex(s as unsigned byte ptr) as unsigned integer
    dim res as integer=0
    dim i as integer=0
    dim d as integer
     while (s[i]<>0)
        d=s[i]
        if (d>=48 and d<=57) then res=res*16+ d-48
        if (d>=65 and d<=70) then res=res*16+ d-55
        if (d>=97 and d<=102) then res=res*16+ d-87
        i+=1
    wend
    return res
end function

function atol(s as unsigned byte ptr) as long
    if (s[0]= 48) and ((s[1]=120) or (s[1]=88)) then return atolhex(s+2)
    
    dim res as long=0
    dim i as long=0
    dim fact as long=1
    if (s[0]=45) then 
        fact=-1
        i=1
    end if
    if (s[0]=43) then i=1
    while (s[i]<>0)
        res=res*10+ s[i]-48
        i+=1
    wend
    return res*fact
end function

function atolhex(s as unsigned byte ptr) as unsigned long
    dim res as long=0
    dim i as long=0
    dim d as long
     while (s[i]<>0)
        d=s[i]
        if (d>=48 and d<=57) then res=res*16+ d-48
        if (d>=65 and d<=70) then res=res*16+ d-55
        if (d>=97 and d<=102) then res=res*16+ d-87
        i+=1
    wend
    return res
end function






function absolute(value as integer) as integer
    if (value<0) then return -value
    return value
end function