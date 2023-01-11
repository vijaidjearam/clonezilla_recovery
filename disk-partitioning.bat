
@echo off

:: Set the size of the new partitions in MB
set partition1_size=500
set partition2_size=20480
set partition1_label=clonezilla
set partition2_label=backup

:: Create the first new partition
C:\Windows\System32\cmd.exe /c "C:\Windows\System32\diskpart.exe /s create_partition1.txt"

:: Create the second new partition
C:\Windows\System32\cmd.exe /c "C:\Windows\System32\diskpart.exe /s create_partition2.txt"

:: Create the "images" folder
md "Z:\images"

:: Create the "backup.tag" file
echo Backup created on %date% %time% > "Z:\backup.tag"

:: Download the latest stable version of Clonezilla in zip format
curl -LJO "https://deac-ams.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.0.2-21/clonezilla-live-3.0.2-21-amd64.zip"

:: Extract the clonezilla-live-3.0.2-21-amd64.zip
powershell.exe -Command "& {Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('clonezilla-live-3.0.2-21-amd64.zip', 'c:\temp\');}"

:: Copy "/EFI" and "/Live" directories from the downloaded archive to the root of the volume clonezilla
robocopy c:\temp\EFI Y:\EFI /E
robocopy c:\temp\live Y:\live /E

:: remove the downloaded zip file
del clonezilla-live-3.0.2-21-amd64.zip

:: Clear and recreate c:\temp
rmdir /s/q c:\temp
mkdir c:\temp

:: Download the latest stable version of Clonezilla in zip format
curl -LJO "https://raw.githubusercontent.com/vijaidjearam/clonezilla_recovery/main/Tut142_CloneZilla_UEFI_Restore.zip"

:: Extract the Tut142_CloneZilla_UEFI_Restore.zip
powershell.exe -Command "& {Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('Tut142_CloneZilla_UEFI_Restore.zip', 'c:\temp\');}"

:: remove the downloaded zip file
del Tut142_CloneZilla_UEFI_Restore.zip

:: copy files from Tut142_CloneZilla_UEFI_Restore to clonezilla partition
robocopy c:\temp Y:\EFI\boot\ /E

:: Exit the script
exit
