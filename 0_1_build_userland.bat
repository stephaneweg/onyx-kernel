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
if not exist bin\utils mkdir bin\utils
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


echo building FASM
%ASSEMBLER% userland/FASM/main.asm bin/fasm.bin

echo building utilities
for /d %%j in (userland\utils\*.*) do (
	if exist userland\utils\%%~nj\main.bas echo %COMPILER% %CFLAGS%  userland/utils/%%~nj/main.bas -o obj/%%~nj.o
	if exist userland\utils\%%~nj\main.bas %COMPILER% %CFLAGS%  userland/utils/%%~nj/main.bas -o obj/%%~nj.o
	if exist userland\utils\%%~nj\main.bas echo %LINKER% obj/userland_header.o obj/%%~nj.o -T userland/userland.ld -o bin/utils/%%~nj.bin
	if exist userland\utils\%%~nj\main.bas %LINKER% obj/userland_header.o obj/%%~nj.o -T userland/userland.ld -o bin/utils/%%~nj.bin
	
	if exist userland\utils\%%~nj\main.asm echo %ASSEMBLER% userland/utils/%%~nj/main.asm bin/utils/%%~nj.bin
	if exist userland\utils\%%~nj\main.asm %ASSEMBLER% userland/utils/%%~nj/main.asm bin/utils/%%~nj.bin
	
)
pause