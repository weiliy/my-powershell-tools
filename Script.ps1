<#
.SYNOPSIS
    ALM test case.
.VERSION
    draft
.DESCRIPTION
    ALM test case.
.NOTE
    Author: weiliy
#>

# Step Name: 10
<#
Description: from jump station using RDP to login to SAP server.
Use the designated username and password to login.
Expected Result: Login successful
Memo: 
#>
Function Test-Alm10 { "Test-Alm10" }

# Step Name: 20
<#
Description: In cmd command line  run command to check disks on the system
C:\> wmic logicaldisk get name
Expected Result: At the minimum, should have drive C:\
 
C:\Users\Administrator>wmic logicaldisk get 
name
A:
C:
D:
Memo: 
#>
Function Test-Alm20 { "Test-Alm20" }

# Step Name: 30
<#
Description: Step Objective: Validate correct vmwares tools were installed.
In cmd run commands:
C:\> cd C:\Program Files\VMware\VMware Tools\
C:\>  VMwareToolboxCmd.exe -v
Expected Result: 9.0.15.45013 (build-2560490)
Memo: 
#>
Function Test-Alm30 { "Test-Alm30" }

# Step Name: 40
<#
Description: Step Objective: Validate hostname & ip addr on EACH server provisioned.


Check server hostname and ip address on EACH server provisioned, by typing th following commands (prev steps asked to record these info), compare with what you have.                                                  


1. hostname - make sure the server hostname matches                                                                


2. ipconfig - make sure ip addr matches
Expected Result: Actual server hostname and ip address match with Order info.
Memo: 
#>
Function Test-Alm40 { "Test-Alm40" }

# Step Name: 50
<#
Description: Step Objective: Validate CPU, Memory and Storage on EACH server provisioned.
 
validate actual server config 
 
C:\> wmic cpu get name,CurrentClockSpeed,MaxClockSpeed
CurrentClockSpeed  MaxClockSpeed  Name 
C:\> systeminfo | findstr /C:"Total Physical Memory"
C:\> wmic diskdrive list brief /format:list
Expected Result: CPU, size of memory, HD GBs matched provision order submitted.


#### CPU EXAMPLE
# wmic cpu get name,CurrentClockSpeed,MaxClockSpeed
CurrentClockSpeed  MaxClockSpeed  Name
2200               2200           AMD Opteron(tm) Processor 6174


#### RAM EXAMPLE
# systeminfo | findstr /C:"Total Physical Memory"
Total Physical Memory:     16,384 MB


#### DISK EXAMPLE
#  wmic diskdrive list brief /format:list


Caption=VMware Virtual disk SCSI Disk Device
DeviceID=\\.\PHYSICALDRIVE0
Model=VMware Virtual disk SCSI Disk Device
Partitions=1
Size=107372805120
Memo: 
#>
Function Test-Alm50 { "Test-Alm50" }

# Step Name: 60
<#
Description: Step Objective: Validate KMS (Windows License)


1. login wjump server > Use RDP, login to provisioned Windows server use hplocaladmin/ucstexxxx credential, 


2. Open DOS command window, run: " slmgr.vbs /dti "  or "slmgr.vbs /dlv"
Expected Result: a "Windows Script host" dialog box pops up, shows a string of ~50 Chars, under "Installation ID"


The OS license should be active.
Memo: 
#>
Function Test-Alm60 { "Test-Alm60" }

# Step Name: 70
<#
Description: Step Objective: Validate Windows Patch Level  (R2)
 
run command cmd
 
C:\> systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
Expected Result: OS Name:                   Microsoft Windows Server 2012 R2 Standard
OS Version:                6.3.9600 N/A Build 9600
Memo: 
#>
Function Test-Alm70 { "Test-Alm70" }

# Step Name: 80
<#
Description: Step Objective: Verify Time Zone on provisioned server matches Timezone requested by the customer on Portal during ordering.
 
Currently this is only applicable to CM servers. It's a known issue that the Time Zone is not set correctly on HPM.
 
Login into server and verify the time zone within the system clock on the provisioned server is the same as the one selected during the ordering process.
 
Note: If in doubt what the selected time zone in QRS was, open the reservation in the portal dashboard and click View LOP Request. Look inside the section 'Config Options for OS Task' for what time zone originally selected was.
 
C:\> tzutil /g
Expected Result: Time zone on provisioned server matches the one requested by the customer on Portal during ordering


example:


Central Standard Time
Memo: If more detail is needed get it from Carl.
#>
Function Test-Alm80 { "Test-Alm80" }

# Step Name: 90
<#
Description: Step Objective: Verify HPSA Post-Install scripts orchestration step ran correctly.


1. Launch 'File Explorer' from the Desktop and navigate to C:\ECS\OS_Checks folder.
2. Open log file results_<date_of_server_provision> and examine contents of the file by looking at important functions excuted by the scripts.


Note: <date_of_server_provision> is the date when in mmddyyyy format when the server is provisioned.
Expected Result: The file should have the following entries with other lines between them (Note: the lines below are not next to each other but found in different sections of the file:


"***Managing Services***
***Modify Registry***
***Set Power to High Performance***
***Disable Virtual Network Interface***
***Changing the password of qconverge agent***
Apply OS hardening settings for SAP for Windows VM
Apply OS hardening settings for SAP for Windows VM completed
Resetting ACF .. SUCCESSFUL
Memo: 
#>
Function Test-Alm90 { "Test-Alm90" }

# Step Name: 100
<#
Description: Step Objective: Verify HP DDMi Scanner is installed on the server
# run command in cmd 
C:\> wmic product get name,version | findstr  "DDMi"
Expected Result: The program 'HP DDMi Scanner' is shown on the installed program/software list and version


HP DDMi Scanner     1.5.1
Memo: 
#>
Function Test-Alm100 { "Test-Alm100" }

# Main 
Test-Alm10
Test-Alm20
Test-Alm30
Test-Alm40
Test-Alm50
Test-Alm60
Test-Alm70
Test-Alm80
Test-Alm90
Test-Alm100
