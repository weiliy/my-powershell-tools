# my-powershell-tools

## Scripts

### ConverFrom-Alm.ps1

This script can convert a csv sheet which dowland form ALM into a powershell template.

## MyLib

### Out-MyLog

A function to print log on the screen and file and have UTC time in every line.

## Sys Check Lib

### Get-WinSoftwareStatus

Get install softwares Status

#### Usage

Example:

``` PowrShell
PS > 'Evernote*','SomeOther*' | Get-WinSoftwareStatus | ft -AutoSize

Name              Version    Publisher      Status     
----              -------    ---------      ------     
Evernote v. 5.9.6 5.9.6.9494 Evernote Corp. Installed  
SomeOther*        n/a        n/a            Not Install
```
### Get-WinServiceStatus

Get runing servcie status

#### Usage

Example:

``` PowrShell
PS > 'Win*','Spo*','SomeOther' | Get-WinServiceStatus | ft -AutoSize

Name                State   StartMode
----                -----   ---------
WinDefend           Running Auto     
WinHttpAutoProxySvc Running Manual   
Winmgmt             Running Auto     
WinRM               Stopped Manual   
Spooler             Running Auto     
SomeOther           n/a     n/a      
```
