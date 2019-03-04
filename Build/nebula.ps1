# -----------------------------------------------------------------------------------------------------------------
# Nebula
# -----------------------------------------------------------------------------------------------------------------

#Requires -Version 5.0

<#
.Description
  Build Tools.
  
  This is the initialization script.
  Nebula initializes build variables and essential functions, then invokes a task sent from Nova.
  Nebula does not return a value.
  
  Nebula creates a script variable named Result that should contain success/fail information.
.Notes
  Nova build system by endowdly, version 3.
  This Nebula was written for tuliPS. 
#>
param (
    # The task to invoke. Validated from Nova.
    [System.String] $Task)

#region Start -----------------------------------------------------------------------------------------------------

# Forbid Sourcing from outside Nova
if ($MyInvocation.PSCommandPath -notlike '*nova.ps1') {
    Write-Warning 'Nebula was called from outside Nova. This is verboten!' 
    Write-Host 'ABORT' -ForegroundColor Red

    exit 1
} 

Push-Location $PSScriptRoot

# Import Config 
$Nebula = Import-PowerShellDataFile config.psd1


<# CSharp Attribute
# Note: Keep this in case someone does not have PowerShell 5.0
$Source = @'
using System;

public class DependsOn : Attribute
{
    public string[] Task { get; set; }

    public DependsOn(string[] task) 
    {
        Task = task
    }
}
'@
Add-Type $Source
#>


# PowerShell class that creates a Custom Attribute for Dependancy
# I think I got this from Jaykul?
class DependsOn : System.Attribute {
    [System.String[]] $Task

    DependsOn([System.String[]] $task) {
        $this.Task = $task 
    }
}


# Create Output
$Result = [pscustomobject] @{
    Warnings = 0
    Errors = 0
}

#endregion

#region Common Functions ------------------------------------------------------------------------------------------


# A function that uses our custom attribute to invoke functions sequentially based on linear dependency
# string -> unit
function Invoke-Task ($Task) {
    $isReset = ((Get-PSCallStack).Command -eq $MyInvocation.MyCommand.Name).Count -eq 1
    
    if ($isReset) {
        $script:InvokedTasks = @()
    }

    $stepCommand = Get-Command $Task

    $dependencies = $stepCommand.ScriptBlock.Attributes.Where{ $_.TypeId.Name -eq 'DependsOn' }.Task

    foreach ($dependency in $dependencies) {
        if ($dependency -notin $script:InvokedTasks) {
            Write-Verbose "$Task Dependency <- $dependency"
            Invoke-Task $dependency
        }  
    }

    Write-Verbose "Invoking -> $Task" 

    & $stepCommand

    Write-Verbose "$Task Done"

    $script:InvokedTasks += $Task
}


# Tests if a string is blank
# string -> bool
function Test-String ($s) {
    [System.String]::IsNullOrEmpty($s) -or
    [System.String]::IsNullOrWhiteSpace($s)
}


# Creates a script variable from a key and value pair and logs the result to the verbose stream
# string -> obj -> unit
function New-ScriptVariable ($k, $v) {
    New-Variable $k $v -Scope Script -Force -WhatIf:$false
    Write-Verbose "$k <- $v"
}

#endregion

#region Nebula Variables ------------------------------------------------------------------------------------------

# Create and Write Nebula Variables
# These variables can be used throughout the nursery

Write-Verbose 'Setting Build Variables...'

# Take config paths and turn them into nebula vars
$Nebula.Paths.GetEnumerator() | 
    ForEach-Object {
        $k = $_.Key
        $v = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($_.Value)
        
        New-ScriptVariable $k $v
    }

# Get the Module Name 
$ModuleName = 
    if (Test-String $Nebula.ModuleName) {
        Split-Path $BuildRoot -Leaf
    }
    else {
        $Nebula.ModuleName
    }

Write-Verbose "ModuleName <- $ModuleName"

# Derived Path Variables
# Keep the values as scriptblocks to be evaluated later sequentially.
# This allows you to reference variables that don't exist or exist in this hash.
# * The values of these variables will be objects and must be cast to strings!
$Derived = [ordered] @{
    SourceModule   = { Join-Path $BuildRoot "$ModuleName.psm1" }
    SourceManifest = { Join-Path $BuildRoot "$ModuleName.psd1" }
    Destination    = { Join-Path $Output $ModuleName } 
    ModulePath     = { Join-Path $Destination "$ModuleName.psm1" }
    ManifestPath   = { Join-Path $Destination "$ModuleName.psd1" } 
}

# Take derived paths and turn them into nebula vars
$Derived.GetEnumerator() |
    ForEach-Object {
        $k = $_.Key
        $v = $_.Value.Invoke()

        New-ScriptVariable $k $v
    }

Write-Verbose 'Build Variables Set'

# Source Nursery Files
Write-Verbose 'Importing Nursery...'
Get-ChildItem $NurseryPath -Filter *.Task.ps1 | 
    ForEach-Object { 
        Write-Verbose "Importing <- $( $_.Name )"
        . $_.FullName
    }
Write-Verbose 'Nursery Imported'

#endregion

#region Exec ------------------------------------------------------------------------------------------------------

Invoke-Task $Task

#endregion

#region Cleanup ---------------------------------------------------------------------------------------------------

Pop-Location

#endregion
