# Write Log to file and screen
Function Out-MyLog {
    <#
    .SYNOPSIS
           Write Log to file and screen
    #>
    Param([string]$LogFileName = '')
    Begin{
        If ( $LogFileName -ne '' ) {
            $UtcTime = (Get-Date).ToUniversalTime() | Get-Date -UFormat '%Y-%m-%d %H:%M (UTC)'
            If ( Test-Path $LogFileName ) {
                Write-Output "$LogFileName already exists, new log will append the end of it"  
            } Else {
                Write-Output "Creating logfile $LogFileName"  
                New-Item -Path $LogFileName -ItemType file | Out-Null
            }
            $Script:MyLogFileName = $LogFileName
            "Logging start at $UtcTime `n" | Add-Content $Script:MyLogFileName
        }
        If ( $Script:MyLogBuffer -eq $null ) {
            $Script:MyLogBuffer = @()
        }
    }
    Process {
        $UtcTime = (Get-Date).ToUniversalTime() | Get-Date -UFormat '%Y-%m-%d %H:%M:%S'
        $messages = '' + ($_ | Out-String)
        $messages = $messages.Split("`n")
        foreach ($message in $messages) {
            $LogMsg =  $UtcTime + ': ' + ($message -replace "`n|`r","" ).TrimEnd()
            Write-Output $LogMsg
            $Script:MyLogBuffer += $LogMsg
        }
    }
    End {
        
        try {
            $Script:MyLogBuffer | Add-Content $Script:MyLogFileName
        } catch {
            "Cannot write log into $MyLogFileName"
            Read-Host "Press Enter to exit"
            Exit
        } 
        $Script:MyLogBuffer = $null
    }
}