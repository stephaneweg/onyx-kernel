TYPE REALMODE_MODULE FIELD=1
    MAGIC as unsigned integer
	PMIdt as unsigned integer
	EAX as unsigned integer
	EBX as unsigned integer
	ECX as unsigned integer
	EDX as unsigned integer
	ESI as unsigned integer
	EDI as unsigned integer
	ES as unsigned integer
	INT_NO as unsigned integer
END TYPE

#Define RealModeAddr &h3000
declare sub DoRealModeAction(src as REALMODE_MODULE ptr)
declare sub DoRealModeActionReg(eax as unsigned integer,ebx as unsigned integer,ecx as unsigned integer,edx as unsigned integer, esi as unsigned integer,edi as unsigned integer,es as unsigned integer,intno as unsigned integer)
declare sub RealMode_INIT()