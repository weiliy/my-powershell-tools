<#
.SYNOPSIS
	Get ESXi host list
.VERSION
	1.0
.DESCRIPTION

.NOTE
	Author: weili.yi@hpe.com
.EXAMPLE
    1. Out Put the Matrix Report
	PowerCLI> Export-EsxCsv.ps1 vc1,vc2,vc3
#>
[CmdletBinding()]
Param(
    [parameter(Mandatory=$true,
    ValueFromPipeline=$true,
    Position=1)]
        [string[]]
        $Server
    )
Function Initialize-PowerCli {
    $error.clear()
    try {
        Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction stop | Out-null
    } catch {
        Write-Host "VMware.VimAutomation.Core Not Loaded"
    }

    if ($error) {
        Try {
                Write-Host "Trying to Load VMware.VimAutomation.Core"
                #Add Vmware SnapIn to Powershell to run this script from powershell prompt
                Add-PSSnapin VMware.VimAutomation.Core -ErrorAction Stop
                Write-Host "VMware.VimAutomation.Core Loaded"
                }
        Catch {
                Write-Host "Unable to load VMware.VimAutomation.Core"
                Write-Host "Checking if PowerCLI is installed"
                $PCli = Get-WmiObject -Class Win32_Product |?{$_.name -like "*PowerClI*"} | Select Name
                    If (@($PCli).Count -eq 0) {
                         Write-Host "PowerCLI is not installed on this server - $env:COMPUTERNAME. Quitting Script"
                         Exit 101
                    }
                    else {
                         Write-Host "PowerCLI is installed. But Unable to load VMware Snapin. Quitting Script"
                         Exit 102
                    } 
                }
    }
    $error.clear()

    #Drop any existing connection
    Try{
	    Disconnect-VIServer -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null
    }
    Catch{
    }

    # Ensure The PowerCLI is enable the Multiple, to avoid to need Enter 'Y'
    Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Scope Session -Confirm:$false | Out-Null
}

Initialize-PowerCli

$VcCredential = Get-Credential

$EsxCsv = @()
foreach ( $vc in $Server ) {
    Write-Progress "Connecting to $vc"
    Connect-VIServer $vc -Credential $VcCredential -wa 0
    $EsxCsv += Get-VMHost | select @{Name='vCenter';Expression={$global:DefaultVIServers.Name}},@{Name='ESX';Expression={$_.Name}},ConnectionState,PowerState,MemoryUsageGB,MemoryTotalGB,Version | ConvertTo-Csv | ConvertFrom-Csv
}

"Check Report $(pwd)\vcenter-esx.csv"
$EsxCsv | Export-Csv -NoTypeInformation 'vcenter-esx.csv'

