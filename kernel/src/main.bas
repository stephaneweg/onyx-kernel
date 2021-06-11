
#include once "stdlib.bi"
#include once "multiboot.bi"
#include once "in_out.bi"
#include once "modules.bi"
#include once "realmode.bi"
#include once "gdt.bi"
#include once "pic.bi"
#include once "console.bi"
#include once "pmm.bi"
#include once "vmm.bi"
#include once "slab.bi"
#include once "kmm.bi"
#include once "interrupt.bi"
#include once "vesa.bi"
#include once "address_space.bi"
#include once "process.bi"
#include once "thread.bi"
#include once "scheduler.bi"
#include once "rng.bi"
#include once "syscall.bi"
#include once "semaphore.bi"
#include once "kernel.bi"
#include once "elf.bi"
#include once "udev.bi"
SUB MAIN (mb_info as multiboot_info ptr)
    asm cli
    ConsoleInit()
    
    GDT_INIT()
    InterruptsManager_Init()
    PMM_INIT(mb_info)
    VMM_INIT()
    
    VMM_INIT_LOCAL()
    SysConsole.Virt = cptr(unsigned byte ptr, ProcessConsoleAddress)
    current_context->map_page(SysConsole.VIRT,SysConsole.PHYS, VMM_FLAGS_USER_DATA)
    
    SlabInit()
    UDEV_INIT()
    RealMode_INIT()
    IRQ_DISABLE(0)
	
    IRQ_ATTACH_HANDLER(&h30,@Syscall30Handler)
    IRQ_ATTACH_HANDLER(&h31,@Syscall31Handler)
    Thread.InitManager()
    Process.InitEngine()
    
    MODULES_INIT(mb_info)
    'find the best graphic mode
    VMM_EXIT()
    var mode = VesaProbe()
    vmm_init_local()
    
    ConsoleNewLine()
    if (mode<>0) then        
        'switch to selected graphic mode
        VMM_EXIT()
        VesaSetMode(mode)
        vmm_init_local()
        Thread.Ready()
    else
       ConsoleWriteLine(@"Cannot set graphic mode")
    end if
   
    
    ConsoleWriteLIne(@"Kernel Loop")
    asm sti
    do
    loop
end sub

sub KERNEL_ERROR(message as unsigned byte ptr,code as unsigned integer)
    VMM_EXIT()
    VesaResetScreen()
    ConsoleSetBackGround(4)
    ConsoleSetForeground(15)
    ConsoleClear()
    ConsoleWriteLine(@"KERNEL PANIC")
    ConsoleWriteTextAndHex(@"Code : ",code,true)
    ConsoleNewLine()
    ConsoleWriteLine(@"Message :")
    ConsoleWriteLine(message)

    asm 
        cli
        .panic_halt:
            hlt
        jmp .panic_halt
    end asm
end sub

#include once "arch/x86/realmode.bas"
#include once "arch/x86/gdt.bas"
#include once "arch/x86/vmm.bas"
#include once "arch/x86/pic.bas"
#include once "console.bas"
#include once "modules.bas"
#include once "stdlib.bas"
#include once "pmm.bas"
#include once "slab.bas"
#include once "kmm.bas"
#include once "interrupt.bas"
#include once "drivers/vesa.bas"
#include once "process.bas"
#include once "address_space.bas"
#include once "thread.bas"
#include once "scheduler.bas"
#include once "rng.bas"
#include once "syscall.bas"
#include once "semaphore.bas"
#include once "udev.bas"