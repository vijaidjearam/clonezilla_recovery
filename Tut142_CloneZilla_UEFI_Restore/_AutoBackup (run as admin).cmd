@echo off
title %~n0
color 1f
pushd "%~dp0"
echo Auto-Backup to IMG on next reboot
call "_CancelAutoCmd (run as admin).cmd"
title %~n0
echo.
echo OK TO DELETE BACKUP IMAGE "IMG"...
set BDIR=d:\images\IMG
if exist %BDIR% rd /s %BDIR% || (color 4f & echo FAILED TO DELETE BACKUP IMAGE & pause & goto :EOF)
set BDIR=e:\images\IMG
if exist %BDIR% rd /s %BDIR% || (color 4f & echo FAILED TO DELETE BACKUP IMAGE & pause & goto :EOF)
set BDIR=f:\images\IMG
if exist %BDIR% rd /s %BDIR% || (color 4f & echo FAILED TO DELETE BACKUP IMAGE & pause & goto :EOF)
set BDIR=g:\images\IMG
if exist %BDIR% rd /s %BDIR% || (color 4f & echo FAILED TO DELETE BACKUP IMAGE & pause & goto :EOF)
set BDIR=h:\images\IMG
if exist %BDIR% rd /s %BDIR% || (color 4f & echo FAILED TO DELETE BACKUP IMAGE & pause & goto :EOF)
set BDIR=i:\images\IMG
if exist %BDIR% rd /s %BDIR% || (color 4f & echo FAILED TO DELETE BACKUP IMAGE & pause & goto :EOF)
set BDIR=j:\images\IMG
if exist %BDIR% rd /s %BDIR% || (color 4f & echo FAILED TO DELETE BACKUP IMAGE & pause & goto :EOF)
set BDIR=k:\images\IMG
if exist %BDIR% rd /s %BDIR% || (color 4f & echo FAILED TO DELETE BACKUP IMAGE & pause & goto :EOF)

echo backup > C:\autobackup.tag
if not exist C:\autobackup.tag (color 4f & echo AUTOBACKUP FAILED! Please run as Admin & pause & goto :EOF)
color 2f
echo.
echo OK - Unattended Backup set on next boot.
pause
