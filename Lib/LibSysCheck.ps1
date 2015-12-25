# System Check Functions

# Get install softwares status
Function Get-WinSoftwareInstallation {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [string]
        $Partterns
    )
    Begin {
        Write-Progress "Geting Win32_Product"
        $WmiWin32Product = Get-WmiObject Win32_Product
        $Softwares = @()
    }
    Process {
        foreach ( $Parttern in $Partterns ) {
            Write-Progress "Checking $Parttern"
            $Matchs = $WmiWin32Product | Where-Object { $_.Name -match $Parttern } 
            If ( ($Matchs | Measure-Object -Property Name ).Count -eq 0 ) {
                $Softwares += New-Object PSObject -Property @{
                    Name = "$Partterns";
                    InstallStatus = "Not Installed";
                }
            } else {
                $Softwares += $Matchs | Add-Member NoteProperty InstallStatus 'Installed' -PassThru
            }
        }
    }
    End {
        $Softwares
    }
}