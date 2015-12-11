# Initialize the Env
Function Initialize-MyEnv {
    <#
    .SYNOPSIS
	    Initialize the Env
    .VERSION
	    0.1
    .EXAMPLE
        1. Load the libery
	    Initialize-MyEnv -MyScript $MyInvocation.MyCommand.Definition

        2. Load with specific lib folder name
        Initialize-MyEnv -Lib 'AnotherLib' -MyScript $MyInvocation.MyCommand.Definition
    #>
    Param (
        [string]$MyScript = $(throw "Parameter missing: -MyScript The Script Full Name"),
        [String]$Lib = 'lib',
	[switch]$NotLoadLib
    )
    $Script:MyScriptFullName = $MyScript
    $Script:MyScriptName = Split-Path $MyScriptFullName -Leaf 
    $Script:MyScriptRoot = Split-Path $MyScriptFullName -Parent
 
    # Read Libs
    If ( -not $NotLoadLib.IsPresent ) {
        $libPath =  Join-Path -ChildPath $Lib -Path $MyScriptRoot
        $Script:Libs = Get-ChildItem $libPath | Where-Object { 
            $_.Name -match '.ps1$' 
        } | foreach {
            Join-Path $libPath $_
        }
    }
}

Initialize-MyEnv -MyScript $MyInvocation.MyCommand.Definition
# Load Libs
foreach ( $Lib in $Libs ) {
    . $Lib
}