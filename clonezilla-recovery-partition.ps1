#Claculate the required space for recovery volume (allocating 1/3 of used space)
$Drive = "C:"
$DriveInfo = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$Drive'"
$UsedSpace = (($DriveInfo.Size - $DriveInfo.FreeSpace) / 1GB) 
Write-Host "Used Space on $Drive : $UsedSpace"
$partitionsize = ((($DriveInfo.Size - $DriveInfo.FreeSpace) / 1GB) * 0.333333333333333GB)
Write-Host "Partition Space for recovery : $partitionsize GB"


#Shrink existing partition C to create new partitions
$drive = Get-Partition -DriveLetter C 
$size = $drive.Size 
$newSize = $size - (500MB + $partitionsize)
Write-Host "New c partition Size  : $newSize GB"
Resize-Partition -DriveLetter C -Size $newSize  

#Stop the Shell HW Detection temporarily so that it doesnt prompt for format drive 
Stop-Service -Name ShellHWDetection
 
#Create a new partition called clonezilla with a size of 500 MB and format it as FAT32 
New-Partition -DiskNumber 0 -Size 500MB -DriveLetter Y | Format-Volume -FileSystem FAT32 -NewFileSystemLabel "clonezilla" -Confirm:$False   
 
#Create a new partition called backup with a size value of $partitionsize and format it as NTFS 
New-Partition -DiskNumber 0 -Size $partitionsize -DriveLetter Z | Format-Volume -FileSystem NTFS -NewFileSystemLabel "backup" -Confirm:$False 

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
Invoke-WebRequest -Uri $url -OutFile c:\temp\$fileName

#extract clonezilla.zip and remove zip file
Expand-Archive -LiteralPath 'C:\temp\clonezilla-live.zip' -DestinationPath C:\temp\clonezilla-live
Remove-Item C:\temp\clonezilla-live.zip

#copy clonezilla EFI and Live system folders from the extracted location to Clonezilla partition
Copy-Item -Recurse -Path C:\temp\clonezilla-live\EFI -Destination y:\ -Force
Copy-Item -Recurse -Path C:\temp\clonezilla-live\live -Destination y:\ -Force

#Download the modified EFI and grub.cfg file from github repo
$url = "https://raw.githubusercontent.com/vijaidjearam/clonezilla_recovery/main/Tut142_CloneZilla_UEFI_Restore.zip"
$fileName = "Tut142_CloneZilla_UEFI_Restore.zip"
Invoke-WebRequest -Uri $url -OutFile c:\temp\$fileName

#Extract the files and remove the zip file
Expand-Archive -LiteralPath c:\temp\$fileName -DestinationPath C:\temp\Tut142_CloneZilla_UEFI_Restore
Remove-Item C:\temp\$fileName

#Copy the necessary files to clonezilla partition Y:\EFI\boot
Copy-Item -Recurse -Path C:\temp\Tut142_CloneZilla_UEFI_Restore\Tut142_CloneZilla_UEFI_Restore\* -Destination Y:\EFI\boot\ -Force

# removing the temp folder
Remove-Item -Recurse -Path C:\temp -Force
