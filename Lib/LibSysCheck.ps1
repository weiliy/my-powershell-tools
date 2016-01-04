# System Check Functions

# Get install softwares status
Function Get-WinSoftwareInstallation {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [string[]]
        $Names
    )
    Begin {
        Write-Verbose "Reading registry HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

        # $WmiWin32Product = Get-WmiObject Win32_Product
        $InstalledSoftwares = @()
        $Softwares = @()

        #Define the variable to hold the location of Currently Installed Programs
        $UninstallKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"

        #Create an instance of the Registry Object and open the HKLM base key
        $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername)

        #Drill down into the Uninstall key using the OpenSubKey Method
        $regkey=$reg.OpenSubKey($UninstallKey)

        #Retrieve an array of string that contain all the subkey name
        $subkeys=$regkey.GetSubKeyNames()

        #Open each Subkey and use GetValue Method to return the required values for each
        foreach($key in $subkeys){
            $thisKey=$UninstallKey+"\\"+$key
            $thisSubKey=$reg.OpenSubKey($thisKey)

            $obj = New-Object PSObject -Property @{
                Name = $($thisSubKey.GetValue("DisplayName"));
                Version = $($thisSubKey.GetValue("DisplayVersion"));
                Publisher = $($thisSubKey.GetValue("Publisher"))
            }

            $InstalledSoftwares += $obj
        }
    }
    Process {
        foreach ( $Name in $Names ) {
            Write-Debug "Checking $Parttern"
            $Matchs = $InstalledSoftwares | Where-Object { $_.Name -like $Name}
            If ( ($Matchs | Measure-Object -Property Name ).Count -eq 0 ) {
                $Softwares += New-Object PSObject -Property @{
                    Name = "$Name";
                    Version = "n/a";
                    Publisher = "n/a";
                    InstallStatus = "Not Installed"
                }
            } else {
                $Softwares += $Matchs | Add-Member NoteProperty InstallStatus 'Installed' -PassThru
            }
        }
    }
    End {
        $Softwares | Select Name,Version,Publisher,InstallStatus
    }
}