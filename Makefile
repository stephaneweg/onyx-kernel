FBC = fbc
ASSEMBLER = fasm
FBCFLAGS = -c -gen GAS -nodeflibs -lang fb -arch 486 -i shared -d KERNEL_NAME=\"Onyx\" -d KERNEL_VERSION=\"0.1.1\"
FBCFLAGS_KERNEL = -i kernel/include
LD = i686-linux-gnu-ld
SRCS_KERNEL =$(shell find kernel/src/ -name *.asm)
SRCS_KERNEL += kernel/src/main.bas
OBJS_KERNEL = $(addprefix obj/,$(addsuffix .o,$(basename $(notdir $(SRCS_KERNEL)))))

kernel: $(OBJS_KERNEL)
	$(LD) $^ -m elf_i386 -T kernel/kernel.ld -o kernel.elf -Map=kernel.map

obj/%.o:  kernel/src/main.bas
	$(FBC) $(FBCFLAGS) $(FBCFLAGS_KERNEL) $^ -o $@

obj/%.o:  kernel/src/arch/x86/%.asm
	$(ASSEMBLER) $^ $@
