# Write Log to file and screen
Function Out-MyLog {
    <#
    .SYNOPSIS
           Write Log to file and screen
    #>
    Param(
        [string]$LogFileName = 'MyLog.log',
        [switch]$QuickSync
    )
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

        Function Sync-MyLog {
            try {
                $Script:MyLogBuffer | Add-Content $Script:MyLogFileName
            } catch {
                "Cannot write log into $MyLogFileName"
                Read-Host "Press Enter to exit"
                Exit
            } 
            $Script:MyLogBuffer = @()
        }
    }
    Process {
        $UtcTime = (Get-Date).ToUniversalTime() | Get-Date -UFormat '%Y-%m-%d %H:%M:%S'
        $messages = @()
        $messages += ('' + ($_ | Out-String)).TrimEnd().Split("`n")
        foreach ($message in $messages) {
            $LogMsg =  $UtcTime + ': ' + ($message -replace "`n|`r","" ).TrimEnd()
            Write-Output $LogMsg
            $Script:MyLogBuffer += $LogMsg
        }
        If ( $QuickSync.IsPresent ) {
            Sync-MyLog
        }
    }
    End {
        If ( -not $QuickSync.IsPresent ) {
            Sync-MyLog
        }
    }
}
