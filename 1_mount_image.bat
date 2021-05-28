@echo off
rem copy ..\hd.img .
"c:\Program Files\OSFMount\OSFMount.com" -a -t file -m I: -o rw,hd -f %cd%\hd.img
pause