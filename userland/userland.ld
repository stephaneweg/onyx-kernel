OUTPUT_FORMAT("elf32-i386")
ENTRY (IMAGE_START)

SECTIONS{
    . = 0x40000000;

    .text ALIGN (0x0010):{
        IMAGE_START = .;

        *(.text)	
    }

    .rodata ALIGN (0x1000) : {
        *(.rodata)
        _CTORS = .;
        *(.ctors)
        _CTORS_END = .;       
    }

    .data ALIGN (0x1000) : {
	DATA_BEGIN = .;
        *(.data)
    }

    .bss ALIGN (0x1000) : {
        SBSS = .;
        *(COMMON)
        *(.bss)
        EBSS = .;

        IMAGE_END = .;
    }
}