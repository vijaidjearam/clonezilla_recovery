@echo off
title %~n0
color 1f
pushd "%~dp0"
echo Auto-Restore from IMG on next reboot
call "_CancelAutoCmd (run as admin).cmd"
title %~n0
set BDIR=
set X=
for %%a in (D E F G H I J K L M N O P Q R S T U V W X Y Z) DO if exist %%a:\images\IMG set X=1

if not "%X%"=="1" ( color 4f & echo BACKUP DOES NOT EXIST! && pause && goto :EOF)
echo restore > C:\autorestore.tag
if not exist C:\autorestore.tag (color 4f & echo AUTORESTORE FAILED! Please run as Admin & pause & goto :EOF)
color 2f
echo.
echo OK - Unattended Windows Restore set for next boot
pause
 