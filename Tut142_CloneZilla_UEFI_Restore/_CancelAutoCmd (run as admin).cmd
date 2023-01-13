@echo off
title %~n0
if exist C:\autorestore.tag del C:\autorestore.tag
if exist C:\autobackup.tag del C:\autobackup.tag
if exist C:\autobackup.tag (color 4f & echo Please run as Admin & pause & exit 1)
if exist C:\autorestore.tag (color 4f & echo Please run as Admin & pause & exit 1)
