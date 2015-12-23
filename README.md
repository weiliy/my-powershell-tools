# my-powershell-tools

## Scripts

### ConverFrom-Alm.ps1

This script can convert a csv sheet which dowland form ALM into a powershell template.

## MyLib

### Out-MyLog

A function to print log on the screen and file and have UTC time in every line.

## Sys Check Lib

### Test-WinSoftwareInstallation

Test if install softwares

#### Usage

Example:

``` PowrShell
$Softwares = @( 
    @{Name = ".NET Framework 4.5"; Parttern = "^Microsoft .NET Framework 4.5"},
    @{Name = "Visual C++ 2012 Runtime"; Parttern = "^Microsoft Visual C\+\+ 2013 .* Runtime"}
)
$Softwares | Test-WinSoftwareInstallation
```

Output:

```
Name                                                                  Installed
----                                                                  ---------
.NET Framework 4.5                                                         True
Visual C++ 2012 Runtime                                                    True
```

