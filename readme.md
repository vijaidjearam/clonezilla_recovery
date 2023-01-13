# Preparing the system for clonezilla recovery partition

After install windows and application

Launch the batch script *"clonezilla_recovery_partition_creator.bat"* located inclonezilla_recovery/powershell.

This script would create two partitions 

  1. CLONEZILLA, 500MB, FAT32 which will contain all the files necessary to boot to clonezilla and perform capture/recovery
  2. backup, NTFS, filesize is calculated 1/3 of the used space in windows partition C:. This partition will hold the backups.

We need to add the clonezilla to the UEFI Boot menu, this can be done in many ways as described [here](https://sites.google.com/rmprepusb.com/www/tutorials/142---windows-restore-uefi)

The easiest method with out using any thirdparty application is using the dell bios.

Boot into Dell Bios via F12

Goto Bios Setup -> Boot Configuration -> Add Boot Option

![image](https://user-images.githubusercontent.com/1507737/212342057-ff562598-eeda-4961-8d1f-213bee11a704.png)

Click on Browse for file

![image](https://user-images.githubusercontent.com/1507737/212342483-2f2bd30a-cebf-4d6b-bdb1-21b353d97088.png)

In the File Explorer, select the CLONEZILLA partition

![image](https://user-images.githubusercontent.com/1507737/212343015-842e4a54-9da6-44d5-a603-66124180b564.png)

You can find a file clonezilla.tag  which confirm that you are in the correct partition

![image](https://user-images.githubusercontent.com/1507737/212343581-07955e46-ecc2-4802-90b6-40b9c84ca942.png)

Select the EFI in the list

![image](https://user-images.githubusercontent.com/1507737/212343692-26c137b6-6639-49de-84ce-1bfcc2e1f846.png)

Select boot in the list

![image](https://user-images.githubusercontent.com/1507737/212343809-f8b0a97a-2888-40b5-b341-39116287a6d6.png)

Select the file *bootx64.efi* click on submit

![image](https://user-images.githubusercontent.com/1507737/212343932-af3728f8-500f-41fd-8aec-039f8a26aebf.png)

You will be taken back to the Boot configuration windows, in the boot option name type clonezilla and click on the button Add Boot option

![image](https://user-images.githubusercontent.com/1507737/212344220-79dd03f7-b566-4751-8797-9ff41681c390.png)

Click on the Apply changes button

![image](https://user-images.githubusercontent.com/1507737/212344624-3d927cd7-24f9-494a-a0c2-8671e44df291.png)

Click OK on the confirmation window

![image](https://user-images.githubusercontent.com/1507737/212344747-b81244e8-b8c3-410b-9323-69ef7c530175.png)

You will find the clonezilla in the boot sequence 

![image](https://user-images.githubusercontent.com/1507737/212344900-29f4a12c-3e5a-476c-be07-e2bd18cb2cb9.png)

Reboot the PC, you will find the clonezilla in the UEFI Boot devices menu

![image](https://user-images.githubusercontent.com/1507737/212345145-a494d31e-4473-49b7-909c-33d01065c435.png)

Boot into clonezilla and you will find the clonezilla menu as below

![image](https://user-images.githubusercontent.com/1507737/212345553-97c3d2c6-6ae6-4183-ac88-c444014155c4.png)

select the option [W] Auto-Backup windows to the partition *Backup/images*

![image](https://user-images.githubusercontent.com/1507737/212345728-736662d6-fd15-4b64-bdb8-79c96b78de13.png)

To restore from backup, select [Q] Auto-Restore Windows from backup stored in the partition *Backup/images*











