# Preparing the system for clonezilla recovery partition

After install windows and application

Launch the powershell script *"clonezilla_recovery_partition_creator.bat"* located inclonezilla_recovery/powershell.

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

👿 In HP Pc we dont have the option add the UEFI menu via BIOS, we need to do using BOOTICE. In order to add the item to UEFI boot menu the partition needs to visible not hidden. Please clear the Hidded attribute using diskpart , keep restarting the pc and add the item to the UEFI menu via BOOTICE until the clonezilla partition appears in UEFI boot menu list.

At the end you need to hide the partition *clonezilla* and *images* so that partitions are not exposed to the user.

Using the #DISKPART# command hide the partitions

```
diskpart
# In my case the volume 1 is clonezilla , so please select the appropriate volume for your scenario
SELECT VOL 1 
ATTRIBUTE VOL SET HIDDEN
#Select the volume images
SELECT VOL 2 
ATTRIBUTE VOL SET HIDDEN
```

To inverse the hidden partition

```
diskpart
# In my case the volume 1 is clonezilla , so please select the appropriate volume for your scenario
SELECT VOL 1 
ATTRIBUTE VOL CLEAR HIDDEN
#Select the volume images
SELECT VOL 2 
ATTRIBUTE VOL CLEAR HIDDEN
```


# To automate the restoration from samba server to the client

create a clonezilla live usb:
  * Format the USB drive in FAT32 and copy the contents of the ISO to the root.

Replace the grub.cfg in /boot/grub.cfg with the following code:

Please fill the appropriate credentials to connect to the sambashare, UNC path, also the image filename.

![image](https://user-images.githubusercontent.com/1507737/214266408-4facc71b-3f90-428d-b8de-31cdfa9ded75.png)

![image](https://user-images.githubusercontent.com/1507737/214266539-d11f81b9-457c-4843-b069-0c48adab9c6d.png)


```
#Automate Restore of clonezilla from samba share
insmod cifs
#set the username for samba share ex: set cifsusername=test
set cifsusername=
#set the password for samba share ex: set cifspasswd=test
set cifspasswd=
#set the UNC for samba share ex: set cifsshare=//192.168.1.10/wim-backups/clonezilla
set cifsshare=

set pref=/boot/grub
set default="0"
set timeout="30"
# For grub 2.04, a workaround to avoid boot failure is to add "rmmod tpm": https://bugs.debian.org/975835. However, it might fail in secure boot uEFI machine, and the error is like:
# error: verification requested but nobody cares: /live/vmlinuz.
# Out of range pointer 0x3000000004040
# Aborted. Press any key to exit. 
# rmmod tpm

# To set authentication, check
# https://www.gnu.org/software/grub/manual/grub/grub.html#Authentication-and-authorisation
# ‘password’ sets the password in plain text, requiring grub.cfg to be secure; ‘password_pbkdf2’ sets the password hashed using the Password-Based Key Derivation Function (RFC 2898), requiring the use of grub-mkpasswd-pbkdf2 (see Invoking grub-mkpasswd-pbkdf2) to generate password hashes.
# Example:
# set superusers="root"
# password_pbkdf2 root grub.pbkdf2.sha512.10000.biglongstring
# password user1 insecure
# 
# menuentry "May be run by any user" --unrestricted {
# 	set root=(hd0,1)
# 	linux /vmlinuz
# }
# 
# menuentry "Superusers only" --users "" {
# 	set root=(hd0,1)
# 	linux /vmlinuz single
# }
# 
# menuentry "May be run by user1 or a superuser" --users user1 {
# 	set root=(hd0,2)
# 	chainloader +1
# }

# Load graphics (only correspoonding ones will be found)
# (U)EFI
insmod efi_gop
insmod efi_uga
# legacy BIOS
# insmod vbe

if loadfont $pref/unicode.pf2; then
  set gfxmode=auto
  insmod gfxterm
  # Set the language for boot menu prompt, e.g., en_US, zh_TW...
  set lang=en_US
  terminal_output gfxterm
fi
set hidden_timeout_quiet=false

insmod png
if background_image $pref/ocswp-grub2.png; then
  set color_normal=black/black
  set color_highlight=magenta/black
else
  set color_normal=cyan/blue
  set color_highlight=white/blue
fi

# Uncomment the following for serial console
# The command serial initializes the serial unit 0 with the speed 38400bps.
# The serial unit 0 is usually called ‘COM1’. If COM2, use ‘--unit=1’ instead.
#serial --unit=0 --speed=38400
#terminal_input serial
#terminal_output serial

# Decide if the commands: linux/initrd (default) or linuxefi/initrdefi
set linux_cmd=linux
set initrd_cmd=initrd
export linux_cmd initrd_cmd
if [ "${grub_platform}" = "efi" -a -e "/amd64-release.txt" ]; then
  # Only amd64 release we switch to linuxefi/initrdefi since it works better with security boot (shim)
  set linux_cmd=linuxefi
  set initrd_cmd=initrdefi
fi

insmod play
#play 960 440 1 0 4 440 1

# Since no network setting in the squashfs image, therefore if ip=, the network is disabled.

menuentry "Restore Image BIB-HP-Probook-Pret-Etudiant" --id live-default {
  search --set -f /live/vmlinuz
  $linux_cmd /live/vmlinuz boot=live union=overlay username=user config components quiet loglevel=0 noswap edd=on nomodeset noprompt enforcing=0 noeject locales=fr_FR.UTF-8 keyboard-layouts=fr ocs_live_run="ocs-sr -g auto -e1 auto -e2 -r -j2 -c -k0 -scr -p reboot restoredisk 2023-01-18-12-hp-pret-portable-etud-hp-probook nvme0n1" ocs_prerun1="dhclient -v eth0" ocs_prerun2="sleep 2" ocs_prerun3="mount -t cifs -o user=${cifsusername},password=${cifspasswd} ${cifsshare} /home/partimag" ocs_prerun4="sleep 2" vga=788 ip= net.ifnames=0  nosplash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1
  $initrd_cmd /live/initrd.img
}
```
