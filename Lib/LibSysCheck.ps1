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
        if ( -not $WmiWin32Product ) {
            $Script:WmiWin32Product = Get-WmiObject Win32_Product | Select-Object Name,Version,@{Name='Publisher';Expression={$_.Vendor}}
        }
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

# Account

function Test-LocalCredential {
    [CmdletBinding()]
    Param
    (
        [string]$UserName,
        [string]$ComputerName = $env:COMPUTERNAME,
        [string]$Password
    )
    if (!($UserName) -or !($Password)) {
        Write-Warning 'Test-LocalCredential: Please specify both user name and password'
    } else {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$ComputerName)
        $DS.ValidateCredentials($UserName, $Password)
    }
}

Function Get-LoacalAccount {
    [CmdletBinding()]
    Param(
        [Parameter(Position=1)]
        [string[]]$UserName,
        [Parameter(Position=2)]
        [string[]]$Password
    )

    Write-Debug "UserName = $UserName (Type: $($UserName.GetTypeCode()))"
    Write-Debug "Password = $Password (Type: $($Password.GetTypeCode()))"
    $IsVarifyPassword = $true
    if (!($UserName) -or !($Password)) {
        Write-Debug 'Get-LoacalAccount: Not varifiy the Password'
        $IsVarifyPassword = $false
    }

    $LocalAccounts = Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" `
    | Select Name, @{Name='AccountStatus';Expression={$_.Status}}, Disabled, AccountType, Lockout, PasswordRequired, PasswordChangeable `
    | ConvertTo-Csv | ConvertFrom-Csv

    foreach ( $LocalAccount in $LocalAccounts ) {
        switch ( $LocalAccount.AccountType ) {
            256 { $LocalAccount.AccountType = 'UF_TEMP_DUPLICATE_ACCOUNT' }
            512 { $LocalAccount.AccountType = 'UF_NORMAL_ACCOUNT' }
            2048 { $LocalAccount.AccountType = 'UF_INTERDOMAIN_TRUST_ACCOUNT' }
            4096 { $LocalAccount.AccountType = 'UF_WORKSTATION_TRUST_ACCOUNT' }
            8192 { $LocalAccount.AccountType = 'UF_SERVER_TRUST_ACCOUNT' }
        }
    }

    If ( $IsVarifyPassword ) {
        $LocalAccounts = $LocalAccounts | Select-Object Name, AccountStatus, Disabled, AccountType, Lockout, PasswordRequired, PasswordChangeable, PasswordExpect, PasswordVarify
        foreach ($VarifyAccount in  $LocalAccounts) {
            if ( $VarifyAccount.Name -in $UserName ) {
                If ( $Password.Count -eq 1 ) {
                    $VarifyPassword = $Password[0]
                } else {
                    try {
                        $VarifyPassword = $Password.Get($UserName.IndexOf($VarifyAccount.Name))
                    } catch {
                        Write-Warning "Get-LoacalAccount: No input password for ${VarifyAccount.Name}"
                        continue
                    }
                }

                $VarifyAccount.PasswordExpect = $VarifyPassword
                $VarifyAccount.PasswordVarify = Test-LocalCredential -UserName $VarifyAccount.Name -Password $VarifyAccount.PasswordExpect
            }
        }
    }

    return $LocalAccounts
}