<#
.SYNOPSIS
    Convert the ALM test case to a PowerShell script template.
.VERSION
    draft
.DESCRIPTION
    Convert the ALM test case to a PowerShell script template.
.NOTE
	Author: weili.yi@hpe.com
.EXAMPLE
 
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$Path,

    [string]$Author = $env:USERNAME
)

## Helper

Function Convert-FunctionName {
Process {
    $Return = ($_ -replace '[,.!@#$%^&*()]| +',' ').Split().Trim() | foreach {
        if ($_ -ne '') {
            $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower()
        }
    }

    $Return -join ''
}
}

## Functions

Function ConvertTo-AlmStepFunction {
Begin {
    $StepTemplate = @"
# Step Name: {0}
<#
Description: {1}
Expected Result: {2}
Memo: {3}
#>
Function {4} {5}
"@

    $StepFunctonNameTemplate = "Test-Alm{0}"
}
Process {
    $AlmStep = $_
    $FunctionName = $StepFunctonNameTemplate -f ($AlmStep.Name | Convert-FunctionName)
    $FunctionStep = $StepTemplate -f (
        $AlmStep.Name,
        $AlmStep.Description,
        $ALmStep.Expected,
        $AlmStep.Memo,
        $FunctionName,
        "{ `"$FunctionName`" }"
    )

    $Return = @{}
    $Return['FunctionName'] = $FunctionName
    $Return['FunctionStep'] = $FunctionStep
    $Return
}
}

Function Get-AlmSteps {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$Path
    )
    try {
        $ImpAlm = Import-Csv $Path
    } catch {
        Write-Error "Cannot import csv $Path"
    }

    foreach( $Step in $ImpAlm ) {
        $Return = @{}
        $ReturnKeyMapping = @{ 
            Name = 'Step Name';
            Description = 'Description';
            Expected = 'Expected Result';
            Memo = 'Memo'
        }
        $Flag = $True
        foreach( $ReturnKey in $ReturnKeyMapping.GetEnumerator() ) {
            try {
                $Key1 = $ReturnKey.Name
                $Key2 = $ReturnKey.Value
                $Return[$Key1] = $Step.$Key2
            } catch {
                Write-Warning "Failed to processing $Key2 in $Step"
                $Flag = $false
                break
            }
        }
        if ( $Flag ) {
            $Return
        }
    }
    
}

Function Out-AlmScript {
Begin {
    $ScriptFile = 'Script.ps1'
    try {
        @"
<#
.SYNOPSIS
    ALM test case.
.VERSION
    draft
.DESCRIPTION
    ALM test case.
.NOTE
    Author: $Author
#>
"@ | Out-File $ScriptFile
    } catch {
        Write-Error "Cannot create $ScriptFile"
    }

    $FunctionList = @()
}
Process {
    $obj = $_
    $FunctionList += $obj.FunctionName
    "" | Add-Content $ScriptFile 
    $obj.FunctionStep | Add-Content $ScriptFile 
}
End {
    "" | Add-Content $ScriptFile 
    "# Main " | Add-Content $ScriptFile 
    foreach ( $FunctionName in $FunctionList ) {
        $FunctionName | Add-Content $ScriptFile
    }
}
}

Get-AlmSteps -Path $Path `
| ConvertTo-AlmStepFunction `
| Out-AlmScript
