#define ELF_BITS32          1
#define ELF_BITS64          2
#define ELF_ENDIAN_LITTLE   1
#define ELF_ENDIAN_BIG      2
#define ELF_FORMAT_RELOCATABLE  1
#define ELF_FORMAT_EXECUTABLE   2
#define ELF_FORMAT_SHARED       3
#define ELF_FORMAT_CORE         4

#define ELF_ISA_NONE            0
#define ELF_ISA_SPARC           2
#define ELF_ISA_X86             3
#define ELF_ISA_MIPS            8
#define ELF_ISA_PPC             &h14
#define ELF_ISA_ARM             &h28
#define ELF_ISA_SUPERH          &h2A
#define ELF_ISA_IA64            &h32
#define ELF_ISA_X86_64          &h3E
#define ELF_ISA_AARCH64         &hB7

#define ELF_SEGMENT_TYPE_NULL   0
#define ELF_SEGMENT_TYPE_LOAD   1
#define ELF_SEGMENT_TYPE_DYN    2
#define ELF_SEGMENT_TYPE_INTERP 3
#define ELF_SEGMENT_TYPE_NOTE   4

#define ELF_SEGMENT_FLAG_EXEC   1
#define ELF_SEGMENT_FLAG_WRIT   2
#define ELF_SEGMENT_FLAG_READ   4 

#define ELF_MAGIC &h464C457F
TYPE ELF_PROG_HEADER_ENTRY field =1
    SegmentType     as unsigned integer
    Segment_P_ADDR  as unsigned integer
    Segment_V_ADDR  as unsigned integer
    UNDEFINED       as unsigned integer
    SegmentFSize     as unsigned integer
    SegmentMSize    as unsigned integer
    FLAGS           as unsigned integer
    padding        as unsigned integer
end type

TYPE ELF_HEADER field  = 1
    Magic       as unsigned integer
    bits        as unsigned byte
    Endianess   as unsigned byte
    version     as unsigned byte
    ABI         as unsigned byte
    Padding(0 to 7) as unsigned byte
    eFormat      as unsigned short
    ISA         as unsigned short
    ELF_VERSION as unsigned integer
    ENTRY_POINT as unsigned integer
    ProgHeaderTable as unsigned integer
    SectHeaderTable as unsigned integer
    Flags       as unsigned integer
    HeaderSize  as unsigned short
    ProgEntrySize   as unsigned short
    ProgEntryCount  as unsigned short
    SectEntrySize   as unsigned short
    SectEntryCount as unsigned short
    SectionNamesIndex as unsigned short
end type
    