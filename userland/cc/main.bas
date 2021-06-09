#include "cc.bi"
#include "stdio.bi"
#include "notice.bi"


dim shared nogo as integer,noloc as integer,opindex as integer,opsize as integer
dim shared swactive as integer,swdefault as integer
dim shared swnext as integer ptr,swend as integer ptr,stage as integer ptr,wq as integer ptr
dim shared argcs as integer,argvs as integer ptr,wqptr as integer ptr

dim shared litptr as integer,macptr as integer,pptr as integer,ch as integer,nch as integer,declared as integer
dim shared iflevel as integer,skiplevel as integer,nxtlab as integer,litlab as integer,csp as integer
dim shared argstk as integer,argtop as integer,ncmp as integer,errflag as integer,_eof as integer,_output as integer
dim shared files as integer,filearg as integer

dim shared _input as integer = __EOF
dim shared _input2 as integer = __EOF
dim shared usexptr as integer = YES
dim shared ccode as integer = YES

dim shared snext as integer ptr,stail as integer ptr,slast as integer ptr
dim shared listfp as integer,lastst as integer,oldseg as integer