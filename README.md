# my-powershell-tools

## Scripts

### ConverFrom-Alm.ps1

This script can convert a csv sheet which dowland form ALM into a powershell template.

## MyLib

### Out-MyLog

A function to print log on the screen and file and have UTC time in every line.

## Sys Check Lib

### Get-WinSoftwareInstallation

Get install softwares

#### Usage

Example:

``` PowrShell
PS > 'calibre','Evernote','ixxx' | Get-WinSoftwareInstallation | Select-Object Name,Version,InstallStatus | Format-Table -AutoSize

Name              Version    InstallStatus
----              -------    -------------
calibre 64bit     2.47.0     Installed    
Evernote v. 5.9.6 5.9.6.9494 Installed    
ixxx                         Not Installed
```

