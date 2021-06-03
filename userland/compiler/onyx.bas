
#define ubyteptr unsigned byte ptr
#define FB_TEMPSTRBIT  &h80000000
#define FB_ISTEMP(s) (((cptr(FBSTRING ptr,s)->len) and FB_TEMPSTRBIT)<>0)
#define FB_STRSIZE(s) ((cptr(FBSTRING ptr,s)->LEN) and &h7FFFFFFF)
#define FB_STRPTR(s,size)  IIF( s=0, 0 ,IIF(size=-1, cptr(FBSTRING PTR,s)->BUFFER ,cptr(unsigned byte ptr,s)))
#define FB_TRUE (-1)
#define FB_FALSE 0
#define FB_WCHAR unsigned short
#define hStrRoundSize( size ) ((size +31) and &hFFFFFFE0)

#macro FB_STRSETUP_FIX(s,size,p,l)

    if s = 0 then
        p = 0
        l = 0
    elseif size = -1 then
            p = cptr(FBSTRING PTR,s)->BUFFER
            l = FB_STRSIZE(s)
    else
            p =cptr(unsigned byte ptr,s)
            l = strlen(p)
    end if
#endmacro

#macro FB_STRSETUP_DYN(s,size,p,l)
    if (s=0) then
        p = 0
        l = 0
    else
        select case size
            case -1
                p = cptr(FBSTRING PTR,s)->BUFFER
                l = FB_STRSIZE(s)
            case 0
                p =cptr(unsigned byte ptr,s)
                l = strlen(p)
            case else
                p =cptr(unsigned byte ptr,s)
                l = size-1
        end select
    end if
#endmacro

type FB_LISTELEM field = 1
    Prev as FB_LISTELEM ptr
    next as FB_LISTELEM ptr
end type

type FB_LIST field =  1
    cnt as integer
    head as FB_LISTELEM ptr
    tail as FB_LISTELEM ptr
    fhead as FB_LISTELEM ptr
end type

Type FBSTRING field = 1
    buffer as ubyteptr 'pointer to the real string data
    len    as integer 'string len 
    size   as integer 'size of allocated memory block
end TYPE
    

type FB_CTX field = 1
    null_string as FBSTRING
end type


type FB_STR_TMPDESC field = 1
    elem as FB_LISTELEM
    desc as FBSTRING
end type


type FB_STR_TMPDESCW field = 1
    elem as FB_LISTELEM
    desc as FB_WCHAR ptr
end type

#define FB_STR_TMPDESCRIPTORS 256
dim shared fb_tmpdsTB(0 to FB_STR_TMPDESCRIPTORS) as FB_STR_TMPDESC
dim shared fb_tmpdsTBW(0 to FB_STR_TMPDESCRIPTORS) as FB_STR_TMPDESCW
dim shared tmpdsList as FB_LIST
dim shared _FB_CTX as FB_CTX

declare sub OnyxInit()
sub OnyxInit()
    tmpdsList.cnt = 0
    tmpdsList.head = 0
    tmpdsList.tail = 0
    tmpdsList.fhead = 0
    _FB_CTX.null_string.BUFFER = 0
    _FB_CTX.null_string.LEN = 0
    _FB_CTX.null_string.SIZE = 0
end sub
    
declare sub _fb_hListDynInit cdecl alias "fb_hListDynInit@4"(list as FB_LIST ptr)
declare sub _fb_hListInit cdecl alias "fb_hListInit@16"( list as FB_LIST ptr,table as any ptr,elem_size as integer,size as integer)
declare function _fb_hListAllocElem alias "fb_hListAllocElem@4"(list as FB_LIST ptr) as FB_LISTELEM ptr
declare sub _fb_hListDynElemAdd cdecl alias "fb_hListDynElemAdd@8"(list as FB_LIST ptr,elem as FB_LISTELEM ptr)
declare sub _fb_hListFreeElem cdecl alias "fb_hListFreeElem@8"(list as FB_LIST ptr,elem as FB_LISTELEM ptr)
declare sub _fb_hListDynElemRemove cdecl alias "fb_hListDynElemRemove@8"(list as FB_LIST ptr,elem as FB_LISTELEM ptr)


sub _fb_hListDynInit cdecl alias "fb_hListDynInit@4"(list as FB_LIST ptr)
    memset(list, 0, sizeof(FB_LIST))
end sub

sub _fb_hListInit cdecl alias "fb_hListInit@16"( list as FB_LIST ptr,table as any ptr,elem_size as integer,size as integer)
    dim i as integer
    dim nextElem as FB_LISTELEM ptr
    dim elem as unsigned byte ptr = cptr(unsigned byte ptr,table)

    _fb_hListDynInit( list )
	
	list->fhead = cptr(FB_LISTELEM ptr,elem)
    for i=0 to size-1
        if (i < size-1) then
            nextElem =cptr(FB_LISTELEM ptr,cuint(elem)+elem_size)
		else
			nextElem = 0
        end if
        cptr(FB_LISTELEM ptr,elem)->prev = 0
        cptr(FB_LISTELEM ptr,elem)->next = nextElem
		
		elem += elem_size
    next
end sub

sub _fb_hListDynElemAdd cdecl alias "fb_hListDynElemAdd@8"(list as FB_LIST ptr,elem as FB_LISTELEM ptr)
	if( list->tail <> 0 ) then
		list->tail->next = elem
	else
		list->head = elem
    end if

	elem->prev = list->tail
	elem->next = 0

	list->tail = 0

    list->cnt+=1
end sub

function _fb_hListAllocElem alias "fb_hListAllocElem@4"(list as FB_LIST ptr) as FB_LISTELEM ptr
    dim elem as FB_LISTELEM ptr
    
	elem = list->fhead
	if( elem = 0 ) then
		return 0
    end if

	list->fhead = elem->next

    _fb_hListDynElemAdd( list, elem )

	return elem
end function

sub _fb_hListFreeElem cdecl alias "fb_hListFreeElem@8"(list as FB_LIST ptr,elem as FB_LISTELEM ptr)
    _fb_hListDynElemRemove( list, elem )

	elem->next = list->fhead
	list->fhead = elem
end sub

sub _fb_hListDynElemRemove cdecl alias "fb_hListDynElemRemove@8"(list as FB_LIST ptr,elem as FB_LISTELEM ptr)
    
	if( elem->prev <> 0 ) then
		elem->prev->next = elem->next
	else
		list->head = elem->next
    end if

	if( elem->next <> 0 ) then
		elem->next->prev = elem->prev
	else
		list->tail = elem->prev
    end if

    elem->prev = 0
    elem->next = 0

    list->cnt-=1
end sub

declare function _fb_hStrAllocTemp_NoLock cdecl alias "fb_hStrAllocTemp_NoLock@8" (s as FBSTRING ptr,size as integer) as FBSTRING ptr
declare function _fb_StrConcat cdecl alias "fb_StrConcat@20"(dst as FBString ptr,str1 as any ptr,str1_size as integer,str2 as any ptr,str2_size as integer) as FBString ptr
declare sub _fb_hStrConcat cdecl alias "fb_hStrConcat@20"(dst as unsigned byte ptr,src1 as unsigned byte ptr,len1 as integer,src2 as unsigned byte ptr,len2 as integer)
declare sub _fb_hStrCopy cdecl alias "fb_hStrCopy@12"(dst as unsigned byte ptr,src as unsigned byte ptr,bytes as integer)
declare function _fb_hStrAlloc cdecl alias "fb_hStrAlloc@8"(s as FBSTRING PTR,size as integer) as FBSTRING ptr
declare function _fb_hStrRealloc cdecl alias "fb_hStrRealloc@12"(s as FBSTRING ptr,size as integer,pres as integer) as FBSTRING PTR
declare function _fb_hStrDelTempDesc cdecl alias "fb_hStrDelTempDesc@4"(s as FBSTRING ptr) as integer
declare function _fb_StrAllocTempResult cdecl alias "fb_StrAllocTempResult@4" (src as FBSTRING ptr) as FBString ptr
declare function _fb_hStrDelTemp_NoLock cdecl alias "fb_hStrDelTemp_NoLock@4"(s as  FBSTRING ptr) as integer

declare function _fb_StrAllocTempDescZ cdecl alias "fb_StrAllocTempDescZ@4"(s as unsigned byte ptr) as FBSTRING ptr
declare function _fb_StrAllocTempDescZEx cdecl alias "fb_StrAllocTempDescZEx@8"(s as unsigned byte ptr,l as integer) as FBSTRING ptr
declare function _fb_hStrAllocTmpDesc cdecl alias "fb_hStrAllocTmpDesc@0"() as  FBSTRING ptr
declare sub _fb_hStrFreeTmpDesc cdecl alias "fb_hStrFreeTmpDesc@4"(dsc as FB_STR_TMPDESC ptr)

declare sub _fb_hStrSetLength cdecl alias "fb_hStrSetLength@8"(s as FBSTRING ptr,size as integer)
declare sub _fb_StrDelete cdecl alias "fb_StrDelete@4"(s as FBSTRING ptr)
declare function _fb_StrAssignEx cdecl alias "fb_StrAssignEx@24"(dst as any ptr,dst_size as integer,src as any ptr,src_size as integer,fill_rem as integer,is_init as integer) as any ptr
declare function _fb_StrAssign cdecl alias "fb_StrAssign@20"(dst as any ptr,dst_size as integer,src as any ptr,src_size as integer,fill_rem as integer) as any ptr
declare function _fb_StrConcatAssign cdecl alias "fb_StrConcatAssign@20"(dst as any ptr,dst_size as integer,src as any ptr,src_size as integer,fillrem as integer) as any ptr
declare function _fb_CHR cdecl alias "fb_CHR"(args as integer,...)  as FBSTRING ptr
declare function _FB_STRLEN cdecl alias "fb_StrLen@8" (s as any ptr,str_size as integer) as integer
declare function _FB_IntToStr cdecl alias "fb_IntToStr@4" (num as integer) as FBSTRING ptr
declare function _FB_FloatToStr cdecl alias "fb_FloatToStr@4" (num as single) as FBSTRING ptr
declare function _FB_DoubleToStr cdecl alias "fb_DoubleToStr@8" (num as double) as FBSTRING ptr
declare function _FB_UIntToStr cdecl alias "fb_UIntToStr@4" (num as unsigned integer) as FBSTRING ptr
declare function _FB_LongintToStr cdecl alias "fb_LongintToStr@8" (num as long) as FBSTRING ptr
declare function _FB_ULongintToStr cdecl alias "fb_ULongintToStr@8" (num as unsigned long) as FBSTRING ptr
declare function _FB_StrInit cdecl alias "fb_StrInit@20"(dst as any ptr,dst_size as integer,src as any ptr,src_size as integer,fill_rem as integer) as any ptr
declare function _FB_StrCompare cdecl alias "fb_StrCompare@16" (str1 as any ptr, str1_size as integer,str2 as any ptr,str2_size as integer) as integer
declare function _fb_StrMid cdecl alias "fb_StrMid@12"(src as FBSTRING ptr,start as integer,l as integer) as FBSTRING ptr
declare function _fb_StrUcase2 cdecl alias "fb_StrUcase2@8"(src as FBSTRING ptr,mode as integer) as FBSTRING ptr
declare function _fb_StrLcase2 cdecl alias "fb_StrLcase2@8"(src as FBSTRING ptr,mode as integer) as FBSTRING ptr

function _fb_StrAllocTempDescZEx cdecl alias "fb_StrAllocTempDescZEx@8"(s as unsigned byte ptr,l as integer) as FBSTRING ptr
    dim dsc as FBSTRING ptr
 	dsc = _fb_hStrAllocTmpDesc( )


    if( dsc = 0 ) then return @_FB_CTX.null_string

    dsc->BUFFER = s
	dsc->len = l
	dsc->size = l

	return dsc
end function

function _fb_StrAllocTempDescZ cdecl alias "fb_StrAllocTempDescZ@4"(s as unsigned byte ptr) as FBSTRING ptr
    dim l as integer
    if (s<>0) then
        l = strlen(s)
    else
        l = 0
    end if

	return _fb_StrAllocTempDescZEx( s, l )
end function

function  _fb_hStrAllocTmpDesc cdecl alias "fb_hStrAllocTmpDesc@0"() as  FBSTRING ptr
    dim dsc as FB_STR_TMPDESC ptr

	if( (tmpdsList.fhead = 0) and (tmpdsList.head = 0) ) then
		_fb_hListInit( @tmpdsList, @fb_tmpdsTB(0), sizeof(FB_STR_TMPDESC), FB_STR_TMPDESCRIPTORS )
    end if
    
	dsc = cptr(FB_STR_TMPDESC ptr,_fb_hListAllocElem( @tmpdsList ))
	
    if( dsc = 0 ) then
		return 0
    end if
	
    dsc->desc.BUFFER = 0
	dsc->desc.len  = 0
	dsc->desc.size = 0

	return @dsc->desc
end function

function _fb_hStrAllocTemp_NoLock cdecl alias "fb_hStrAllocTemp_NoLock@8" (s as FBSTRING ptr,size as integer)  as FBSTRING ptr
    dim try_alloc as boolean = (s = 0)

    if( try_alloc ) then
        s = _fb_hStrAllocTmpDesc( )
        if( s= 0 ) then return 0
    end if

    if( _fb_hStrRealloc( s ,size, FB_FALSE ) = 0 ) then
    
        if( try_alloc ) then _fb_hStrDelTempDesc( s )
        return 0
    else
        s->LEN = s->LEN OR FB_TEMPSTRBIT
    end if
    return s
end function


function _fb_StrConcat cdecl alias "fb_StrConcat@20"(dst as FBString ptr,str1 as any ptr,str1_size as integer,str2 as any ptr,str2_size as integer) as FBString ptr
    dim str1_ptr as unsigned byte ptr
    dim str2_ptr as unsigned byte ptr
    dim str1_len as integer
    dim str2_len as integer

	FB_STRSETUP_FIX( str1, str1_size, str1_ptr, str1_len )

	FB_STRSETUP_FIX( str2, str2_size, str2_ptr, str2_len )

    if (str1_len+str2_len =0) then
        _fb_StrDelete(dst)
    else
        dst = _fb_hStrAllocTemp_NoLock( dst, str1_len+str2_len )
		_fb_hStrConcat( dst->BUFFER, str1_ptr, str1_len, str2_ptr, str2_len )
	end if

	if( str1_size = -1 ) then
		_fb_hStrDelTemp_NoLock(cptr(FBSTRING ptr,str1))
    end if
    
	if( str2_size = -1 ) then
		_fb_hStrDelTemp_NoLock(cptr(FBSTRING ptr,str2))
    end if

	return dst
end function

sub _fb_hStrConcat cdecl alias "fb_hStrConcat@20"(dst as unsigned byte ptr,src1 as unsigned byte ptr,len1 as integer,src2 as unsigned byte ptr,len2 as integer)
    memcpy(dst,src1,len1)
    dst+=len1
    memcpy(dst,src2,len2)
    dst[len2]=0
end sub

sub _fb_hStrCopy cdecl alias "fb_hStrCopy@12"(dst as unsigned byte ptr,src as unsigned byte ptr,bytes as integer)
    if( (src <> 0) and (bytes > 0) ) then
        memcpy(dst,src,bytes)
    end if
    dst[bytes]=0
end sub

function _fb_hStrAlloc cdecl alias "fb_hStrAlloc@8"(s as FBSTRING PTR,size as integer) as FBSTRING ptr
    dim newsize as integer = hStrRoundSize( size )

	s->BUFFER = cptr(unsigned byte ptr,malloc(newsize+1))
    if (s->BUFFER = 0) then
        s->BUFFER = cptr(unsigned byte ptr,malloc(size+1))
        if (s->Buffer = 0) then
            s->len= 0
            s->size = 0
            return 0
        end if
        newsize = size
    end if

	s->size = newsize
	s->len = size

    return s
end function

function _fb_hStrRealloc cdecl alias "fb_hStrRealloc@12"(s as FBSTRING ptr,size as integer,pres as integer) as FBSTRING PTR
    dim newsize as integer = hStrRoundSize(size)
    newsize += (newsize shr 3)

    if (s->BUFFER = 0) or (size> s->size) or (newsize < (s->size - (s->size shr 3))) then
        if (pres = FB_FALSE) then
			_fb_StrDelete( s )

			s->BUFFER =cptr(unsigned byte ptr,malloc(newsize+1))
            if (s->BUFFER = 0) then
				s->BUFFER = cptr(unsigned byte ptr,malloc(size+1))
				newsize = size
			end if
		else
            dim pszOld as unsigned byte ptr = s->BUFFER
            s->BUFFER = cptr(unsigned byte ptr,realloc(pszOld,newsize+1))
			if( s->BUFFER =0) then
                s->BUFFER = cptr(unsigned byte ptr,realloc(pszOld,size+1))
				newsize = size
                if (s->BUFFER = 0) then
                    s->BUFFER = pszOld
                    return 0
                end if
            end if
		end if
        
        if (s->BUFFER = 0) then
            s->len = 0
            s->size = 0
            return 0
        end if
		s->size = newsize
	end if

	_fb_hStrSetLength( s, size )

    return s
end function

function _fb_StrAllocTempResult cdecl alias "fb_StrAllocTempResult@4" (src as FBSTRING ptr) as FBString ptr
    dim dsc as FBSTRING ptr
 	dsc = _fb_hStrAllocTmpDesc( )
    if( dsc = 0 ) then
    	return @_FB_CTX.null_string
    end if


    dsc->BUFFER = src->BUFFER
    dsc->len  = src->len or FB_TEMPSTRBIT
    dsc->size = src->size

	src->BUFFER  = 0
	src->len  = 0
	src->size = 0

	return dsc
end function

function _fb_hStrDelTempDesc cdecl alias "fb_hStrDelTempDesc@4"(s as FBSTRING ptr) as integer
    dim item as FB_STR_TMPDESC ptr = cptr(FB_STR_TMPDESC ptr, cuint(s)-offsetOf(FB_STR_TMPDESC,desc))
    
    if (item < @fb_tmpdsTB(0) or item > @fb_tmpdsTB(FB_STR_TMPDESCRIPTORS-1)) then
        return -1
    end if

	_fb_hStrFreeTmpDesc( item )
    return 0
end function

function _fb_hStrDelTemp_NoLock cdecl alias "fb_hStrDelTemp_NoLock@4"(s as  FBSTRING ptr) as integer
    if (s = 0) then return -1
    
    if( FB_ISTEMP( s ) ) then _fb_StrDelete( s )
	
    return _fb_hStrDelTempDesc( s )
end function

sub _fb_hStrFreeTmpDesc cdecl alias "fb_hStrFreeTmpDesc@4"(dsc as FB_STR_TMPDESC ptr)
	_fb_hListFreeElem( @tmpdsList,  @dsc->elem )

	dsc->desc.Buffer = 0
	dsc->desc.len  = 0
	dsc->desc.size = 0
end sub

sub _fb_hStrSetLength  cdecl alias "fb_hStrSetLength@8"(s as FBSTRING ptr,size as integer)
    s->len = (size or (s->len and FB_TEMPSTRBIT))
end sub

sub _fb_StrDelete cdecl alias "fb_StrDelete@4"(s as FBSTRING ptr)
    if (s=0 or s->BUFFER = 0) then exit sub
    Free(s->BUFFER)
    s->BUFFER = 0
    s->LEN = 0
    s->SIZE = 0
end sub



function _fb_StrAssignEx cdecl alias "fb_StrAssignEx@24"(dst as any ptr,dst_size as integer,src as any ptr,src_size as integer,fill_rem as integer,is_init as integer) as any ptr
    dim dstr as FBString ptr
    dim src_ptr as unsigned byte ptr
    dim src_len as integer
    
    if (dst = 0) then
        if (src_size = -1) then _fb_hStrDelTemp_NoLock(cptr(FBSTRING ptr,src))
        return dst
    end if

	FB_STRSETUP_FIX( src, src_size, src_ptr, src_len )
    
    if (dst_size = -1) then
        dstr = cptr(FBSTRING ptr,dst)
        
        if (src_len = 0) then
            if (is_INIT = FB_FALSE) then
                _fb_StrDelete(dstr)
            else
                dstr->BUFFER = 0
                dstr->LEN = 0
                dstr->SIZE = 0
            end if
        else
            if (src_size =-1) and FB_ISTEMP(src) then
                if (is_INIT = FB_FALSE) then _fb_StrDelete(dstr)
                
                dstr->BUFFER = cptr(unsigned byte ptr,src_ptr)
                dstr->len = src_len
                dstr->size = cptr(FBSTRING ptr,src)->size
                
                cptr(FBSTRING ptr,src)->BUFFER = 0
                cptr(FBSTRING ptr,src)->len = 0
                cptr(FBSTRING ptr,src)->size = 0
                
                _fb_hStrDelTempDesc( cptr(FBSTRING ptr,src))
                
                return dst
            end if

            if (IS_INIT = FB_FALSE) then
                if( FB_STRSIZE( dst ) <> src_len ) then _fb_hStrRealloc( dstr, src_len, FB_FALSE )
            else
                _fb_hStrAlloc( dstr, src_len )
            end if
			_fb_hStrCopy( dstr->BUFFER, src_ptr, src_len )
		end if
	else '* fixed-len or zstring.. */
        if (src_len = 0) then
            cptr(unsigned byte ptr,dst)[0] = 0
		else
            if (dst_size = 0) then
                dst_size = src_len
            else
                dst_size-=1
                if (dst_size<src_len) then
                    src_len=dst_size
                end if
            end if
			
            _fb_hStrCopy(cptr(unsigned byte ptr,dst), src_ptr, src_len )
        end  if
		
        if (fill_rem<>0) then
			dst_size -= src_len
			if( dst_size > 0 ) then
                memset(cptr(unsigned byte ptr,cuint(dst)+src_len),0,dst_size)
            end if
        end if
    end if


	if( src_size = -1 ) then
		_fb_hStrDelTemp_NoLock(cptr(FBSTRING ptr,src))
    end if

	return dst
end function

function _fb_StrAssign cdecl alias "fb_StrAssign@20"(dst as any ptr,dst_size as integer,src as any ptr,src_size as integer,fill_rem as integer) as any ptr
    return _fb_StrAssignEx( dst, dst_size, src, src_size, fill_rem, FB_FALSE )
end function

function _fb_StrConcatAssign cdecl alias "fb_StrConcatAssign@20"(dst as any ptr,dst_size as integer,src as any ptr,src_size as integer,fillrem as integer) as any ptr
    dim dstr as FBSTRING ptr
    dim src_ptr as unsigned byte ptr
    dim src_len as integer
    dim dst_len as integer
	
	if( dst = 0 ) then
		if( src_size = -1 ) then
			_fb_hStrDelTemp_NoLock(cptr(FBSTRING ptr,src))
        end if
		return dst
	end if

	FB_STRSETUP_FIX( src, src_size, src_ptr, src_len )

	if( src_len > 0 ) then
		if( dst_size = -1 ) then
        	dstr = cptr(FBSTRING ptr,dst)
        	dst_len = FB_STRSIZE( dst )

			_fb_hStrRealloc( dstr, dst_len+src_len, FB_TRUE )

			_fb_hStrCopy(cptr(unsigned byte ptr,cuint(dstr->BUFFER)+dst_len), src_ptr, src_len )
		else
			dst_len = strlen(cptr(unsigned byte ptr,dst))
            
			if( dst_size > 0 ) then
                dst_size-=1
				if( src_len > dst_size - dst_len ) then
					src_len = dst_size - dst_len
                end if
            end if

			_fb_hStrCopy( cptr(unsigned byte ptr,cuint(dst)+dst_len) , src_ptr, src_len )

			if( (fillrem <> 0) and (dst_size > 0) ) then
                
				dst_size -= (dst_len + src_len)
				if( dst_size > 0 ) then
					memset( cptr(unsigned byte ptr,cuint(dst)+dst_len+src_len),0, dst_size )
                end if
			end if
		end if
	end if


	if( src_size = -1 ) then _fb_hStrDelTemp_NoLock( cptr(FBSTRING ptr,src))
	return dst
end function

function _fb_CHR cdecl alias "fb_CHR"(args as integer,...)  as FBSTRING ptr
    dim dst as FBSTRING ptr
    dim num as unsigned integer
    dim i as integer
    if args<=0 then
    	return @_FB_CTX.null_string
    end if
    
    dst = _fb_hStrAllocTemp_NoLock( 0, args )
    
    if (dst <> 0 ) then
        
        Dim VARGS As Any Ptr 
        VARGS = va_first()
        for i = 0 to args-1
            num = va_arg(VARGS,unsigned integer)
            dst->BUFFER[i] = cast(unsigned byte,num)
            VARGS = va_next(VARGS,unsigned integer)
        next
		dst->BUFFER[args] = 0
    else
    	dst = @_FB_CTX.null_string
    end if
    return dst
end function

function _FB_STRLEN cdecl alias "fb_StrLen@8" (s as any ptr,str_size as integer) as integer
    dim l as integer
    if (s=0) then return 0
    
    if (str_size = -1) then
		l = FB_STRSIZE( s )
		_fb_hStrDelTemp_NoLock( cptr(FBSTRING PTR,s))
	else
		l = strlen(cptr(unsigned byte ptr,s))
    end if
    
	return l
end function


function _FB_FloatToStr cdecl alias "fb_FloatToStr@4" (num as single) as FBSTRING ptr
    dim dst as FBSTRING ptr

	dst = _fb_hStrAllocTemp_NoLock( 0, sizeof( integer ) * 3 )
	if( dst <>0 ) then
        var s = FloatToStr(num)
        var sl = strlen(s)
        memcpy(dst->BUFFER,s,sl+1)
        _fb_hStrSetLength( dst,sl)
	else
		dst = @_FB_CTX.null_string
    end if
    return dst
end function

function _FB_DoubleToStr cdecl alias "fb_DoubleToStr@8" (num as double) as FBSTRING ptr
    dim dst as FBSTRING ptr

	dst = _fb_hStrAllocTemp_NoLock( 0, sizeof( integer ) * 3 )
	if( dst <>0 ) then
        var s = DoubleToStr(num)
        var sl = strlen(s)
        memcpy(dst->BUFFER,s,sl+1)
        _fb_hStrSetLength( dst,sl)
	else
		dst = @_FB_CTX.null_string
    end if
    return dst
end function

function _FB_IntToStr cdecl alias "fb_IntToStr@4" (num as integer) as FBSTRING ptr
    dim dst as FBSTRING ptr

	dst = _fb_hStrAllocTemp_NoLock( 0, sizeof( integer ) * 3 )
	if( dst <>0 ) then
        var s = IntToStr(num,10)
        var sl = strlen(s)
        memcpy(dst->BUFFER,s,sl+1)
        _fb_hStrSetLength( dst,sl)
	else
		dst = @_FB_CTX.null_string
    end if
    return dst
end function

function _FB_ULongintToStr cdecl alias "fb_ULongintToStr@8" (num as unsigned long) as FBSTRING ptr
    dim dst as FBSTRING ptr

	dst = _fb_hStrAllocTemp_NoLock( 0, sizeof( integer ) * 3 )
	if( dst <>0 ) then
        var s = ULongToStr(num,10)
        var sl = strlen(s)
        memcpy(dst->BUFFER,s,sl+1)
        _fb_hStrSetLength( dst,sl)
	else
		dst = @_FB_CTX.null_string
    end if
    return dst
end function

function _FB_LongintToStr cdecl alias "fb_LongintToStr@8" (num as long) as FBSTRING ptr
    dim dst as FBSTRING ptr

	dst = _fb_hStrAllocTemp_NoLock( 0, sizeof( integer ) * 3 )
	if( dst <>0 ) then
        var s = LongToStr(num,10)
        var sl = strlen(s)
        memcpy(dst->BUFFER,s,sl+1)
        _fb_hStrSetLength( dst,sl)
	else
		dst = @_FB_CTX.null_string
    end if
    return dst
end function

function _FB_UIntToStr cdecl alias "fb_UIntToStr@4" (num as unsigned integer) as FBSTRING ptr
    dim dst as FBSTRING ptr

	dst = _fb_hStrAllocTemp_NoLock( 0, sizeof( integer ) * 3 )
	if( dst <>0 ) then
        var s = UIntToStr(num,10)
        var sl = strlen(s)
        memcpy(dst->BUFFER,s,sl)
        _fb_hStrSetLength( dst, sl )
	else
		dst = @_FB_CTX.null_string
    end if
    return dst
end function

function _FB_StrInit cdecl alias "fb_StrInit@20"(dst as any ptr,dst_size as integer,src as any ptr,src_size as integer,fill_rem as integer) as any ptr
	return _fb_StrAssignEx( dst, dst_size, src, src_size, fill_rem, FB_TRUE )
end function

function _FB_StrCompare cdecl alias "fb_StrCompare@16" (str1 as any ptr, str1_size as integer,str2 as any ptr,str2_size as integer) as integer
	dim str1_ptr as unsigned byte ptr
    dim str2_ptr as unsigned byte ptr
    dim str1_len as integer
    dim str2_len as integer
    dim res as integer
    
	if( (str1 <> 0) and (str2 <> 0) ) then
		FB_STRSETUP_FIX( str1, str1_size, str1_ptr, str1_len )
        FB_STRSETUP_FIX( str2, str2_size, str2_ptr, str2_len )
            
        res = StrNCMP( str1_ptr,str2_ptr,min(str1_len,str2_len))
        if (res = 0) and (str1_len<> str2_len) then
            res = iif(str1_len>str2_len,1,-1)
        end if
	elseif str1 = 0 then
		if str2 = 0 then 'of both are empty return eq
            res = 0
		else
            FB_STRSETUP_FIX( str2, str2_size, str2_ptr, str2_len )
            res = iif(str2_len = 0,0,-1)
		end if
    else 'only str2 is empty
		FB_STRSETUP_FIX( str1, str1_size, str1_ptr, str1_len )
        'if left empty return eq
		res = iif(str1_len = 0,0,1)
    end if



	if( str1_size = -1 ) then _fb_hStrDelTemp_NoLock(cptr(FBSTRING ptr,str1))
	if( str2_size = -1 ) then _fb_hStrDelTemp_NoLock(cptr(FBSTRING ptr,str2))

	return res
end function

function _fb_StrMid cdecl alias "fb_StrMid@12"(src as FBSTRING ptr,start as integer,l as integer) as FBSTRING ptr
    dim dst as FBSTRING ptr
    dim src_len as integer
    src_len = FB_STRSIZE( src )
    if (src<>0) and (src->BUFFER <>0) and (src_len>0) then
        
        if( (start > 0) and (start <= src_len) and (l <> 0) ) then
            start-=1

        	if( l < 0 ) then l = src_len

        	if( start + l > src_len ) then l = src_len - start

            dst = _fb_hStrAllocTemp_NoLock( 0, l )
			if( dst <> 0 ) then
                memcpy(dst->BUFFER,cptr(unsigned byte ptr,cuint(src->BUFFER)+(start*sizeof(unsigned byte))),l)
                dst->BUFFER[l]=0
        	else
        		dst = @_FB_CTX.null_string
            end if
        else
        	dst = @_FB_CTX.null_string
        end if
	else
		dst = @_FB_CTX.null_string
    end if

	_fb_hStrDelTemp_NoLock( src )

	return dst
end function

function _fb_StrUcase2 cdecl alias "fb_StrUcase2@8"(src as FBSTRING ptr,mode as integer) as FBSTRING ptr
    dim dst as FBSTRING ptr
    dim i as integer=0
    dim l as integer=0
    dim c as integer=0
    dim s as unsigned byte ptr
    dim d as unsigned byte ptr
    
    if (src = 0) then return @_FB_CTX.null_string
    
    if (src->BUFFER<>0) then
        l = FB_STRSIZE(src)
		dst = _fb_hStrAllocTemp_NoLock(0, l )
    else
        dst = 0
    end if

	if( dst<>0 )then
		s = src->BUFFER
		d = dst->BUFFER

        for i = 0 to l-1
            c = s[i]
            if( (c >= 97) and (c <= 122) ) then c -= 32
            d[i] = c
        next
        d[l]=0
    else
		dst = @_FB_CTX.null_string
	end if

	
	_fb_hStrDelTemp_NoLock( src )
	return 0
end function

function _fb_StrLcase2 cdecl alias "fb_StrLcase2@8"(src as FBSTRING ptr,mode as integer) as FBSTRING ptr
    dim dst as FBSTRING ptr
    dim i as integer=0
    dim l as integer=0
    dim c as integer=0
    dim s as unsigned byte ptr
    dim d as unsigned byte ptr
    
    if (src = 0) then return @_FB_CTX.null_string
    
    if (src->BUFFER<>0) then
        l = FB_STRSIZE(src)
		dst = _fb_hStrAllocTemp_NoLock(0, l )
    else
        dst = 0
    end if

	if( dst<>0 )then
		s = src->BUFFER
		d = dst->BUFFER

        for i = 0 to l-1
            c = s[i]
            if( (c >= 65) and (c <= 90) ) then c += 32
            d[i] = c
        next
        d[l]=0
    else
		dst = @_FB_CTX.null_string
	end if

	
	_fb_hStrDelTemp_NoLock( src )
	return 0
end function

declare function _fb_WStrAlloc cdecl alias "fb_WstrAlloc@4"(chars as integer) as FB_WCHAR ptr
declare function _fb_WStrAllocTemp cdecl alias "fb_WStrAllocTemp@4"(chars as integer) as FB_WCHAR ptr
declare sub _fb_wstr_Del cdecl alias "fb_wstr_Del@4"(s as FB_WCHAR ptr)
declare sub _fb_WstrDelete cdecl alias "fb_WstrDelete@4"(s as FB_WCHAR ptr)
declare function _fb_wstr_Len cdecl alias "fb_wstr_Len@4"(s as FB_WCHAR ptr) as integer
declare function _fbWstrLen cdecl alias "fb_WstrLen@4"(s as FB_WCHAR ptr) as integer
declare sub _fb_wstr_Copy cdecl alias "fb_wstr_Copy@12"(dst as FB_WCHAR ptr,src as FB_WCHAR ptr,l as integer)
declare function _fb_WstrMid cdecl alias "fb_WstrMid@12"(src as FB_WCHAR ptr,start as integer,l as integer) as FB_WCHAR ptr

sub _fb_wstr_Del cdecl alias "fb_wstr_Del@4"(s as FB_WCHAR ptr)
   free(s)
end sub

sub _fb_WstrDelete cdecl alias "fb_WstrDelete@4"(s as FB_WCHAR ptr)
    _fb_wstr_del(s)
end sub

function _fb_wstr_AllocTemp cdecl alias "fb_wstr_AllocTemp@4"(chars as integer) as FB_WCHAR ptr
    return cptr(FB_WCHAR ptr,malloc((chars+1)*sizeof(FB_WCHAR)))
end function

function _fb_WStrAlloc cdecl alias "fb_WstrAlloc@4"(chars as integer) as FB_WCHAR ptr
    if (chars<=0) then return 0
    return _fb_wstr_AllocTemp(chars)
end function

function _fb_wstr_Len cdecl alias "fb_wstr_Len@4"(s as FB_WCHAR ptr) as integer
    return strwlen(s)
end function


sub _fb_wstr_Copy cdecl alias "fb_wstr_Copy@12"(dst as FB_WCHAR ptr,src as FB_WCHAR ptr,l as integer)
   memcpy16(dst,src,l)
end sub

function _fbWstrLen cdecl alias "fb_WstrLen@4"(s as FB_WCHAR ptr) as integer
    return strwlen(s)
end function

function _fb_WstrMid cdecl alias "fb_WstrMid@12"(src as FB_WCHAR ptr,start as integer,l as integer) as FB_WCHAR ptr
    
    dim dst as FB_WCHAR ptr
    dim src_len as integer
    
    if (src = 0) then return 0
    
    src_len = _fb_wstr_Len( src )
    
    if( src_len = 0 ) then return 0
    
    if( (start <= 0) or (start > src_len) or (l = 0) ) then return 0
    
    start=start-1

    if( l < 0 ) then l = src_len

    if( start + l > src_len ) then l = src_len - start

    dst = _fb_wstr_AllocTemp( l )
    
	if( dst <>  0 ) then _fb_wstr_Copy( dst,cptr(FB_WCHAR ptr, cuint(src)+ (start*sizeof(FB_WCHAR))), l )
    
    return dst
end function 


type FBARRAYDIM
    elements as unsigned integer
    _lbound as integer
    _ubound as integer
end type

enum FBARRAY_FLAGS
    FBARRAY_FLAGS_DIMENSIONS = &h0000000f
	FBARRAY_FLAGS_FIXED_DIM  = &h00000010
	FBARRAY_FLAGS_FIXED_LEN  = &h00000020
	FBARRAY_FLAGS_RESERVED   = &hffffffc0
end enum

type FBARRAY
    buffer as any ptr
    _ptr as any ptr
    size as integer
    element_len as integer
    dimensions as integer
    flags as integer
    dimTB(0 to 0) as FBARRAYDIM
end type

declare function _fb_ArrayErrase cdecl alias "fb_ArrayErase@8" (array as FBARRAY ptr) as integer
declare function _fb_ArrayClear cdecl alias "fb_ArrayClear@4"(array as FBARRAY ptr) as integer
declare sub _fb_ArrayResetDesc cdecl alias "fb_ArrayResetDesc@4"(array as  FBARRAY ptr)
declare sub _fb_ArrayStrErase cdecl alias "fb_ArrayStrErase@4"(array as FBARRAY ptr)
declare sub _fb_ArrayDestructStr cdecl alias "fb_ArrayDestructStr@4"(array as FBARRAY ptr)
declare sub _fb_hArrayDtorStr cdecl alias "fb_hArrayDtorStr@12"(array as FBARRAY ptr,dtor as any ptr,base_idx as integer)

function _fb_ArrayClear cdecl alias "fb_ArrayClear@4"(array as FBARRAY ptr) as integer
    if (array->_ptr<>0) then
        memset(array->_ptr,0,array->size)
    end if
    return 0
end function

sub _fb_ArrayResetDesc cdecl alias "fb_ArrayResetDesc@4"(array as  FBARRAY ptr)
    
	array->buffer = 0
	array->buffer = 0
	array->size = 0
	
	array->flags = array->flags and ( FBARRAY_FLAGS_DIMENSIONS or FBARRAY_FLAGS_FIXED_DIM or FBARRAY_FLAGS_FIXED_LEN)

	memset(@array->dimTB(0), 0, array->dimensions * sizeof( FBARRAYDIM ) )
end sub

function _fb_ArrayErase cdecl alias "fb_ArrayErase@8" (array as FBARRAY ptr) as integer
	if( array->_ptr<>0 ) then

        if( array->flags and FBARRAY_FLAGS_FIXED_LEN ) then
			_fb_ArrayClear( array )
        else
            free( array->_ptr )
			_fb_ArrayResetDesc( array )
        end if
    end if

	return  0
end function

sub _fb_hArrayDtorStr cdecl alias "fb_hArrayDtorStr@12"(array as FBARRAY ptr,dtor as any ptr,base_idx as integer)
    dim i as unsigned integer
    dim elements as integer
    dim _dim as FBARRAYDIM ptr
    dim _this as FBSTRING ptr
    
    if (array->_ptr = 0) then return
    _dim = @array->dimTB(0)
    
    elements = _dim->elements - base_idx
    _dim = cptr(FBARRAYDIM ptr, cuint(_dim)+sizeof(FBARRAYDIM))
    
    for i = 1 to array->dimensions-1
        
        elements =elements * _dim->elements
        _dim+=1
    next


    
    _this = cptr(FBSTRING ptr, cuint(array->_ptr)+(base_idx + (elements-1)))
    while elements>0
        if (_this->BUFFER <> 0) then
			_fb_StrDelete( _this )
            _this=cptr(FBSTRING ptr,cuint(_this)-sizeof(FBSTRING))
            elements-=1
            
        end if
    wend
end sub

sub _fb_ArrayDestructStr cdecl alias "fb_ArrayDestructStr@4"(array as FBARRAY ptr)
	_fb_hArrayDtorStr( array, 0, 0 )
end sub

sub _fb_ArrayStrErase cdecl alias "fb_ArrayStrErase@4"(array as FBARRAY ptr)
	_fb_ArrayDestructStr( array )

	if( array<>0 and not(array->flags and FBARRAY_FLAGS_FIXED_LEN) ) then
		_fb_ArrayErase( array )
	end if
end sub