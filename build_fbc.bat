@echo off
set ASSEMBLER=ToolChain\fasm.exe
set COMPILER=ToolChain\fbc.exe
set CC=Toolchain\bin\win32\gcc.exe
set LINKER=Toolchain\bin\linux\ld.exe

set FBCFLAGS=-c  -nodeflibs -lang fb -arch 486 -i userland\compiler\fbc -i userland\compiler -i userland/include -i shared -d ENABLE_STANDALONE

set AFLAGS=
set objs=
echo compile fbc objects
set searchPath=userland\compiler\rtlib,userland\compiler\fbc
if not exist obj\fbc mkdir obj\fbc
if not exist bin mkdir bin

%ASSEMBLER% userland/userland_header.asm obj/userland_header.o

echo %COMPILER% %FBCFLAGS%  userland\compiler\fbc.bas -o obj/fbc/fbc.o
%COMPILER% %FBCFLAGS%  userland\compiler\fbc.bas -o obj/fbc/fbc.o

call set "objs=%%objs%% obj/fbc/fbc.o"
pause
for %%t in (%searchPath%) do (


	for /r %%j in (%%t\*.asm) do (
		echo %ASSEMBLER% %AFLAGS% %%t\%%~nj.asm obj/fbc/%%~nj.o  
		%ASSEMBLER% %AFLAGS% %%t\%%~nj.asm obj/fbc/%%~nj.o  

		call set "objs=%%objs%% obj/fbc/%%~nj.o"
	)
	for /r %%j in (%%t\*.bas) do (
		echo %COMPILER% %FBCFLAGS%  %%t\%%~nj.bas -o obj/fbc/%%~nj.o
		%COMPILER% %FBCFLAGS%  %%t\%%~nj.bas -o obj/fbc/%%~nj.o

		call set "objs=%%objs%% obj/fbc/%%~nj.o"
	)
)




rem echo Linking freebasic...
echo  %LINKER% obj/userland_header.o %objs% -T userland/userland.ld -o bin/sys/fbc.bin
%LINKER% obj/userland_header.o %objs% -T userland/userland.ld -o bin/sys/fbc.bin
pause