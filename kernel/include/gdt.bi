
type gdt_entry  FIELD=1
    limit_low as unsigned short
    base_low as unsigned short
    base_middle as byte
    access as byte
    granularity as byte
    base_high as byte
end type

type gdt_ptr  FIELD=1
	theLimit as unsigned short
	thebase as unsigned integer
end type


type registres field=1
    eax as unsigned integer
    ecx as unsigned integer
    edx as unsigned integer
    ebx as unsigned integer
    esp as unsigned integer
    ebp as unsigned integer
    esi as unsigned integer
    edi as unsigned integer
end type

type TSS_Struct field=1
        link    as unsigned short
        link_h  as unsigned short
        esp0    as unsigned integer
        ss0     as unsigned short
        ss0_h   as unsigned short
        esp1    as unsigned integer
        ss1     as unsigned short
        ss1_h   as unsigned short
        esp2    as unsigned integer
        ss2     as unsigned short
        ss2_h   as unsigned short
        cr3     as unsigned integer
        eip     as unsigned integer
        eflags  as unsigned integer
        registres as registres
        es      as unsigned short
        es_h    as unsigned short
        cs      as unsigned short
        cs_h    as unsigned short
        ss      as unsigned short
        ss_h    as unsigned short
        ds      as unsigned short
        ds_h    as unsigned short
        fs      as unsigned short
        fs_h    as unsigned short
        gs      as unsigned short
        gs_h    as unsigned short
        ldt     as unsigned short
        ldt_h   as unsigned short
        trap    as unsigned short
        iomap_base   as unsigned short
        reserved (0 to 7) as unsigned integer
        iomap (0 to 255) as unsigned byte
end type

declare SUB GDT_INIT()
declare SUB GDT_FLUSH()
declare function gdt_create_seg(thebase as unsigned integer,thelimit as unsigned integer, theaccess as byte,realmode as byte = 0) as unsigned integer
declare sub gdt_set_gate(num as unsigned integer,thebase as unsigned integer, thelimit as unsigned integer, theaccess as byte,realmode as byte = 0)

declare function gdt_find_free() as unsigned integer
declare sub gdt_delete(i as unsigned integer)
declare sub ldt_set_gate(theLdt as gdt_entry ptr,thebase as unsigned integer, thelimit as unsigned integer, theaccess as byte,realmode as byte = 0)
declare sub init_ktss()
