@echo off
set KERNEL_NAME=\"Onyx\"
set KERNEL_VERSION=\"0.0.1\"
set searchPath=kernel\src\arch\x86,kernel\src,shared

set ASSEMBLER=ToolChain\fasm.exe
set COMPILER=ToolChain\fbc.exe
set CFLAGS=-c  -nodeflibs -lang fb -arch 486 -i kernel/include -i shared -d KERNEL_NAME=%KERNEL_NAME% -d KERNEL_VERSION=%KERNEL_VERSION%
set LINKER=Toolchain\bin\linux\ld.exe
set AFLAGS=
set objs=

echo compile resources
IF NOT EXIST bin\res mkdir bin\res
for /r %%j in (res\*.asm) do (
	echo    %%~nj...
	ToolChain\fasm.exe res/%%~nj.asm bin/res/%%~nj.bin
)

echo compile kernel objects
if not exist obj mkdir obj
if not exist bin mkdir bin
for %%t in (%searchPath%) do (
	for /r %%j in (%%t\*.asm) do (
		echo %ASSEMBLER% %AFLAGS% %%t\%%~nj.asm obj/%%~nj.o  
		%ASSEMBLER% %AFLAGS% %%t\%%~nj.asm obj/%%~nj.o  

		call set "objs=%%objs%% obj/%%~nj.o"
	)
rem	for /r %%j in (%%t\*.bas) do (
rem		echo %COMPILER% %CFLAGS%  %%t\%%~nj.bas -o obj/%%~nj.o
rem		%COMPILER% %CFLAGS%  %%t\%%~nj.bas -o obj/%%~nj.o
rem
rem		call set "objs=%%objs%% obj/%%~nj.o"
rem	)
)

%COMPILER% %CFLAGS%  kernel\src\main.bas -o obj/main.o
call set "objs=%%objs%% obj/main.o"



echo Linking kernel...
echo %LINKER% %objs% -m elf_i386  -T kernel/kernel.ld -o bin/kernel.elf -Map=kernel.map
%LINKER% %objs% -m elf_i386  -T kernel/kernel.ld -o bin/kernel.elf -Map=kernel.map



echo compile keymaps
IF NOT EXIST bin\keymaps mkdir bin\keymaps
for /r %%j in (keymaps\*.asm) do (
	echo    %%~nj...
	ToolChain\fasm.exe keymaps/%%~nj.asm bin/keymaps/%%~nj.map
)



pause