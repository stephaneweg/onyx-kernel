OUTPUT_FORMAT("elf32-i386")
ENTRY (Mboot)

SECTIONS{
    . = 0x00100000;

    .text :{
        _KERNEL_START = .;

        *(.text)   
    }

    .rodata ALIGN (0x1000) : {
        *(.rodata)
          
    }

    .data ALIGN (0x1000) : {
        *(.data)
    }

    .bss : {
        SBSS = .;
        *(COMMON)
        *(.bss)
        EBSS = .;
	_KERNEL_END = .;
    }
}