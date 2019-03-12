# -----------------------------------------------------------------------------------------------------------------
# Nova
# -----------------------------------------------------------------------------------------------------------------

#Requires -Version 5.0

[CmdletBinding()]

<#

.Description
  Build script.

  This script is the overall control for the build.
  Nova validates available tasks for the build and allows for both testing and logging.
  Nova sources Nebula and its nursery, or task, files and tasks are invoked from Nebula.
  Nova cannot be sourced and can only be invoked. 
.Notes
  Nova build system by endowdly, version 3.
  This Nova was written for tuliPS. 
#> 
param (
    # Outputs the a summary of the result.
    [switch] $Summary,

    # Sets the Verbose Stream to 'Continue' for visibility or redirection.
    [switch] $Log,

    # Does not perform altering actions; add -WhatIf where possible.
    [switch] $Test)

dynamicParam { 
    $name = 'Task'
    $type = [System.String]

    # New parameter attribute
    $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute] 
    $taskAttribute = New-Object System.Management.Automation.ParameterAttribute
    $taskAttribute.Position = 0

    # New validation set attribute
    $nurseryPath = Join-Path $PSScriptRoot Build
    $nurseryFiles = Get-ChildItem $nurseryPath -Filter *Task.ps1 
    $tasks = $nurseryFiles.BaseName -replace '.Task*', '' 
    $validationSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute $tasks

    # Add our custom attributes to attribute collection
    $attributeCollection.Add($taskAttribute)
    $attributeCollection.Add($validationSetAttribute)

    # Add our paramater using collection
    $paramArgs = $name, $type, $attributeCollection
    $taskParam = New-Object System.Management.Automation.RuntimeDefinedParameter $paramArgs

    # Expose the parameter to the runtime
    $dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    $dictionary.Add($name, $taskParam)

    $dictionary
}

begin {
    
    # Forbid Sourcing
    if ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq '') {
        Write-Warning 'Nova was sourced! This is verboten to prevent session pollution' 
        # Write-Host 'TIP: To invoke Nova, use the call operator: &' -ForegroundColor Yellow
        Write-Host 'ABORT' -ForegroundColor Red

        exit 1
    } 

    Push-Location $PSScriptRoot

    if ($Log) { 
        $VerbosePreference = 'Continue'
    }

    if ($Test) {
        $WhatIfPreference = $true
    }

    $Task = 
        if ($PSBoundParameters.ContainsKey('Task')) {
            $PSBoundParameters.Task
        } 
        else {
            'Default'
        } 

    . $PSScriptRoot/Build/nebula.ps1 -Task $Task
}

end {
    Pop-Location
    
    if ($Result.Errors) {
        # $Error[-1].ScriptStackTrace.ToString()
        Write-Host 'NOVA FAIL' -ForeddgroundColor Red
        exit 1
    }

    if ($Summary) {
        $Result | Format-Table -AutoSize 
    }

    Write-Host "$Task DONE" -ForegroundColor Green

    exit 0
}