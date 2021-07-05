set mypath=%cd%
cd qemu
qemu-system-i386.exe -m 1G -hda ..\hd.img -device sb16 -D con
pause