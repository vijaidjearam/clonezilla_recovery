
@echo off

:: Set the amount of free space to leave in GB
set free_space=25

:: Set the size of the new partitions in MB
set partition1_size=500
set partition2_size=20000
set partition1_label=clonezilla
set partition2_label=backup

:: Get the current partition size in bytes
for /F "tokens=2 delims= " %%i in ('wmic logicaldisk where "DeviceID='C:'" get Size /VALUE') do set C_size=%%i

:: Calculate the new partition size in bytes
set /A new_size=%C_size% - (%free_space%*1024*1024*1024)

:: Shrink the current partition
C:\Windows\System32\cmd.exe /c "C:\Windows\System32\diskpart.exe /s shrink_partition.txt"

:: Create the first new partition
C:\Windows\System32\cmd.exe /c "C:\Windows\System32\diskpart.exe /s create_partition1.txt"

:: Create the second new partition
C:\Windows\System32\cmd.exe /c "C:\Windows\System32\diskpart.exe /s create_partition2.txt"

:: Set the location of the volume
set volume_location=

:: Get the drive letter of the volume with the specified label
for /F "tokens=2 delims= " %%i in ('wmic volume where "Label='%partition2_label%'" get DriveLetter /VALUE') do set volume_location=%%i

:: Check if the volume with the specified label was found
if "%volume_location%"=="" (
    echo The volume with the label %partition2_label% was not found.
    exit /b
) else (
    echo The volume with the label %partition2_label% was found at %volume_location%.
)

:: Create the "images" folder
md "%volume_location%\images"

:: Create the "backup.tag" file
echo Backup created on %date% %time% > "%volume_location%\backup.tag"

:: Set the location of the volume
set volume_location=

:: Get the drive letter of the volume with the specified label
for /F "tokens=2 delims= " %%i in ('wmic volume where "Label='%partition1_label%'" get DriveLetter /VALUE') do set volume_location=%%i

:: Check if the volume with the specified label was found
if "%volume_location%"=="" (
    echo The volume with the label %partition1_label% was not found.
    exit /b
) else (
    echo The volume with the label %partition1_label% was found at %volume_location%.
)

:: Download the latest stable version of Clonezilla in zip format
curl -LJO "https://deac-ams.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.0.2-21/clonezilla-live-3.0.2-21-amd64.zip"

:: Extract the clonezilla-live-3.0.2-21-amd64.zip
powershell.exe -Command "& {Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('clonezilla-live-3.0.2-21-amd64.zip', 'c:\temp\');}"

:: Copy "/EFI" and "/Live" directories from the downloaded archive to the root of the volume clonezilla
robocopy c:\temp\EFI %volume_location%\ /E
robocopy c:\temp\live %volume_location%\ /E

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
robocopy c:\temp %volume_location%\EFI\boot\ /E


:: Exit the script
exit


