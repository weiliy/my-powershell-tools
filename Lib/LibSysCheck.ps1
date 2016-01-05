# System Check Functions

# Get install softwares status
Function Get-WinSoftwareStatus {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [string[]]
        $Names
    )
    Begin {
        Write-Verbose "Reading registry HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
        $WmiWin32Product = Get-WmiObject Win32_Product | Select-Object Name,Version,@{Name='Publisher';Expression={$_.Vendor}}
        $HklmSoftwares = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
        | Select-Object @{Name="Name"; Expression = {$_.DisplayName}},@{Name="Version";Expression={$_.DisplayVersion}},Publisher
        $Softwares = @()
    }
    Process {
        foreach ( $Name in $Names ) {
            Write-Debug "Checking $Name"
            $Matchs = $WmiWin32Product | Where-Object { $_.Name -like $Name}
            If ( ($Matchs | Measure-Object -Property Name ).Count -eq 0 ) {
                $Matchs = $HklmSoftwares | Where-Object { $_.Name -like $Name}
            }
            If ( ($Matchs | Measure-Object -Property Name ).Count -eq 0 ) {
                $Softwares += New-Object PSObject -Property @{
                    Name = "$Name";
                    Version = "n/a";
                    Publisher = "n/a";
                    Status = "Not Install"
                }
            } else {
                $Softwares += $Matchs | Select-Object Name,Version,Publisher,@{Name="Status";Expression={"Installed"}}
            }
        }
    }
    End {
        $Softwares | Select Name,Version,Publisher,Status
    }
}

Function Get-WinServiceStatus {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [string[]]
        $Names
    )
    Begin {
        Write-Verbose "Get Win32_Service"
        $AllServers = Get-WmiObject -Class Win32_Service
        $ServcieStatus = @()
    }
    Process {
        foreach ( $Name in $Names ) {
            Write-Verbose "Check $Name"
            $Matchs = $AllServers | Where-Object { $_.Name -like $Name }
            If (($Matchs | Measure-Object -Property Name).Count -eq 0) {
                $ServcieStatus += New-Object PSObject -Property @{
                    Name = "$Name";
                    State = "n/a";
                    StartMode = "n/a";
                }
            } else {
                $ServcieStatus += $Matchs | Select Name,State,StartMode
            }
        }
    }
    End {
        $ServcieStatus | Select Name,State,StartMode
    }
}

# Get OS Arch

Function Test-IsVM {
    $SystemModel = (Get-WmiObject win32_ComputerSystem).Model
    If ($SystemModel -match "Virtual|VMWare") {
        return $true
    } else {
        return $false
    }
}