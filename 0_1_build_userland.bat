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
for /d %%j in (userland\src\*.*) do (
	echo %COMPILER% %CFLAGS%  userland/src/%%~nj/main.bas -o obj/%%~nj.o
	%COMPILER% %CFLAGS%  userland/src/%%~nj/main.bas -o obj/%%~nj.o
	echo %LINKER% obj/userland_header.o obj/%%~nj.o -T userland/userland.ld -o bin/userland/%%~nj.bin
	%LINKER% obj/userland_header.o obj/%%~nj.o -T userland/userland.ld -o bin/userland/%%~nj.bin
)


echo compile system binaries
for /r %%j in (sys\*.bas) do (
	echo %COMPILER% %CFLAGS%  sys/%%~nj.bas -o obj/%%~nj.o
	%COMPILER% %CFLAGS%  sys/%%~nj.bas -o obj/%%~nj.o
	echo %LINKER% obj/userland_header.o obj/%%~nj.o -T userland/userland.ld -o bin/sys/%%~nj.bin
	%LINKER% obj/userland_header.o obj/%%~nj.o -T userland/userland.ld -o bin/sys/%%~nj.bin
)

pause