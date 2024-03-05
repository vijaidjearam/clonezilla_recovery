#Calculate the required space for recovery volume (allocating 2/3 of used space)
$Drive = "C:"
$DriveInfo = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$Drive'"
$UsedSpace = ($DriveInfo.Size - $DriveInfo.FreeSpace)
$usedspaceformatted = "{0:N2} Gb" -f ($UsedSpace/ 1Gb)
Write-Host "Used Space on $Drive : $usedspaceformatted"
$partitionsize = $UsedSpace*(2/3)
$partitionsizeformatted = "{0:N2} Gb" -f ($partitionsize/ 1Gb)
Write-Host "Partition Space for recovery : $partitionsizeformatted"


#Shrink existing partition C to create new partitions
$drive = Get-Partition -DriveLetter C 
$size = $drive.Size 
$newSize = $size - (500MB + $partitionsize)
$newSizeformatted = "{0:N2} Gb" -f ($newSize/ 1Gb)
Write-Host "New c partition Size  : $newSizeformatted "
Resize-Partition -DriveLetter C -Size $newSize  


#Stop the Shell HW Detection temporarily so that it doesnt prompt for format drive 
#Need to try suspend-service -Name ShellHWDetection -Confirm
Stop-Service -Name ShellHWDetection -force 
 
#Create a new partition called clonezilla with a size of 500 MB and format it as FAT32 
New-Partition -DiskNumber 0 -Size 500MB -DriveLetter Y | Format-Volume -FileSystem FAT32 -NewFileSystemLabel "clonezilla" -Confirm:$False   

 
#Create a new partition called backup with a size value of $partitionsize and format it as NTFS 
New-Partition -DiskNumber 0 -UseMaximumSize -DriveLetter Z | Format-Volume -FileSystem NTFS -NewFileSystemLabel "backup" -Confirm:$False 


#Start the Shell HW Detection which was disabled
Start-Service -Name ShellHWDetection

#creating backup.tag and images folder in the backup partition
New-Item -Path Z:\ -Name backup.tag -Force
New-Item -ItemType Directory -Path Z:\ -Name images -Force

#creating a file clonezilla.tag just to identify the correct partition when adding bootmenu entry via BIOS
New-Item -Path Y:\ -Name clonezilla.tag -Force
 
#create a temp directory 
$path = "C:\temp"
If(!(test-path -PathType container $path))
{
      New-Item -ItemType Directory -Path $path
}

#download the latest version of clonezilla from sourceforge.net
$site = "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/"
$html = Invoke-WebRequest -Uri $site -UseBasicParsing
$links = $html.Links | Where-Object {$_.href -match "clonezilla_live_stable\/\d.\d.\d-\d{2}\/"}
$latest = ($links | Sort-Object -Property href -Descending)[0]
$ver = $latest.href | % {$_ -match "\d.\d.\d-\d{2}" > $null; $matches[0]}
$url = "https://netix.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/"+$ver+"/clonezilla-live-"+$ver+"-amd64.zip"
$fileName = "clonezilla-live.zip"
#Invoke-WebRequest -Uri $url -OutFile c:\temp\$fileName
Start-BitsTransfer -Source $url -Destination c:\temp\$fileName

#extract clonezilla.zip and remove zip file
Expand-Archive -LiteralPath "C:\temp\clonezilla-live.zip" -DestinationPath C:\temp\clonezilla-live
Remove-Item C:\temp\clonezilla-live.zip

#copy clonezilla EFI and Live system folders from the extracted location to Clonezilla partition
Copy-Item -Recurse -Path C:\temp\clonezilla-live\EFI -Destination y:\ -Force
Copy-Item -Recurse -Path C:\temp\clonezilla-live\live -Destination y:\ -Force

#Download the modified EFI and grub.cfg file from github repo
$url = "https://codeload.github.com/vijaidjearam/clonezilla_recovery/zip/refs/heads/main"
#Invoke-WebRequest -Uri $url -OutFile c:\temp\clonezilla_recovery.zip
Start-BitsTransfer -Source $url -Destination c:\temp\clonezilla_recovery.zip

#Extract the files and remove the zip file
Expand-Archive -LiteralPath c:\temp\clonezilla_recovery.zip -DestinationPath C:\temp\clonezilla_recovery
Remove-Item C:\temp\clonezilla_recovery.zip

#Copy the necessary files to clonezilla partition Y:\EFI\boot
Copy-Item -Recurse -Path C:\temp\clonezilla_recovery\clonezilla_recovery-main\Tut142_CloneZilla_UEFI_Restore\* -Destination Y:\EFI\boot\ -Force

# removing the temp folder
Remove-Item -Recurse -Path C:\temp -Force

#checking if the disk is NVME or SSD or HDD and changing the grub.cfg accordingly
if (-Not ((Get-PhysicalDisk| Where-Object {($_.DeviceId -eq 0)}).BusType -like "NVMe"))
{
write-host "The local disk is SSD so modifying the grub.cfg accordingly"
Remove-Item -Path Y:\EFI\boot\grub.cfg -Force
Rename-Item -Path Y:\EFI\boot\grub-sda.cfg -NewName grub.cfg -Force
}
else
{
write-host "The local disk is NVMe so modifying the grub.cfg accordingly"
}

# converting the clonezilla partition to recovery partition
## downloading the diskpart script txt file from github 
Start-BitsTransfer -Source https://raw.githubusercontent.com/vijaidjearam/clonezilla_recovery/main/powershell/clonezilla-part-to-recovery.txt -Destination $env:temp\clonezilla-part-to-recovery.txt
diskpart /s $env:temp\clonezilla-part-to-recovery.txt
Remove-Item $env:temp\clonezilla-part-to-recovery.txt -Force

## downloading the diskpart script for making the backup partition -> recovery partition
Start-BitsTransfer -source https://raw.githubusercontent.com/vijaidjearam/clonezilla_recovery/main/powershell/backup-part-to-recovery.txt -Destination $env:temp\backup-part-to-recovery.txt
## downloading the batchscript to make the backup partition -> recovery partition
Start-BitsTransfer -Source https://raw.githubusercontent.com/vijaidjearam/clonezilla_recovery/main/powershell/backup-part-to-recovery.bat -Destination $env:temp\backup-part-to-recovery.bat
write-host "Take a backup of the system by rebooting to clonezilla, after the backup is completed run the backup-part-to-recovery.bat to seal the backup recovery partition" -ForegroundColor Green
