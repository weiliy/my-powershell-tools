# System Check Functions

# Test if install softwares
Function Test-WinSoftwareInstallation {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [Hashtable]
        $SoftwareObj
    )
    Begin {
        $WmiWin32Product = Get-WmiObject Win32_Product
    }
    Process {
        $Software = New-Object PSObject -Property @{ 
            Name = $SoftwareObj.Name;
            Installed= $false;
            Parttern = $SoftwareObj.Parttern
        }

        $WmiWin32Product | ForEach-Object {
            if ( $_.Name -match $Software.Parttern ) {
                    $Software.Installed = $true
            }
        }
        $Software | Select-Object -Property Name,Installed
    }
}