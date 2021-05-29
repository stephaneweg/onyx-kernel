@echo off
set KERNEL_NAME=\"Q-STEP\"
set KERNEL_VERSION=\"0.0.1\"


set ASSEMBLER=ToolChain\fasm.exe
set COMPILER=ToolChain\fbc.exe
set CFLAGS=-c  -nodeflibs -lang fb -arch 486 -i userland/include -i shared
set LINKER=Toolchain\bin\linux\ld.exe
set AFLAGS=


echo compile userland apps
if not exist obj mkdir obj
if not exist bin mkdir bin
if not exist bin\userland mkdir bin\userland
if not exist bin\sys mkdir bin\sys

%ASSEMBLER% userland/userland_header.asm obj/userland_header.o
for /d %%j in (userland\apps\*.*) do (
	if exist userland\apps\%%~nj\main.bas echo %COMPILER% %CFLAGS%  userland/apps/%%~nj/main.bas -o obj/%%~nj.o
	if exist userland\apps\%%~nj\main.bas %COMPILER% %CFLAGS%  userland/apps/%%~nj/main.bas -o obj/%%~nj.o
	if exist userland\apps\%%~nj\main.bas echo %LINKER% obj/userland_header.o obj/%%~nj.o -T userland/userland.ld -o bin/userland/%%~nj.bin
	if exist userland\apps\%%~nj\main.bas %LINKER% obj/userland_header.o obj/%%~nj.o -T userland/userland.ld -o bin/userland/%%~nj.bin
	
	if exist userland\apps\%%~nj\main.asm echo %ASSEMBLER% userland/apps/%%~nj/main.asm bin/userland/%%~nj.bin
	if exist userland\apps\%%~nj\main.asm %ASSEMBLER% userland/apps/%%~nj/main.asm bin/userland/%%~nj.bin
	
)


echo compile system binaries
for /d %%j in (userland\sys\*.*) do (
	if exist userland\sys\%%~nj\main.bas echo %COMPILER% %CFLAGS%  userland/sys/%%~nj/main.bas -o obj/%%~nj.o
	if exist userland\sys\%%~nj\main.bas %COMPILER% %CFLAGS%  userland/sys/%%~nj/main.bas -o obj/%%~nj.o
	if exist userland\sys\%%~nj\main.bas echo %LINKER% obj/userland_header.o obj/%%~nj.o -T userland/userland.ld -o bin/sys/%%~nj.bin
	if exist userland\sys\%%~nj\main.bas %LINKER% obj/userland_header.o obj/%%~nj.o -T userland/userland.ld -o bin/sys/%%~nj.bin
	
	if exist userland\sys\%%~nj/main.asm echo %ASSEMBLER% userland/sys/%%~nj/main.asm bin/sys/%%~nj.bin
	if exist userland\sys\%%~nj/main.asm %ASSEMBLER% userland/sys/%%~nj/main.asm bin/sys/%%~nj.bin
	
)

%ASSEMBLER% test.asm test.bin

pause