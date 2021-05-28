OUTPUT_FORMAT("binary")
ENTRY (IMAGE_START)

SECTIONS{
    . = 0x40000000;

    .text ALIGN (0x0010):{
        IMAGE_START = .;

        *(.text)	
    }

    .rodata ALIGN (0x0001) : {
        *(.rodata)
        _CTORS = .;
        *(.ctors)
        _CTORS_END = .;       
    }

    .data ALIGN (0x0010) : {
	DATA_BEGIN = .;
        *(.data)
    }

    .bss : {
        SBSS = .;
        *(COMMON)
        *(.bss)
        EBSS = .;

        IMAGE_END = .;
    }
}