<#
 
  ██████╗ ██████╗ ███╗   ███╗███╗   ███╗ ██████╗ ███╗   ██╗
 ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔═══██╗████╗  ██║
 ██║     ██║   ██║██╔████╔██║██╔████╔██║██║   ██║██╔██╗ ██║
 ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██║   ██║██║╚██╗██║
 ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║╚██████╔╝██║ ╚████║
  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
                                                           
 
#>

<#
.Synopsis
  Small, consumable commands for internal use.
.Description
  Small, consumable commands for internal use. Helpers used throughout the module.
  
  Private. Should not be invoked. Should be sourced by the module only.
#>

# Quick Test.
# obj -> bool
function Test-Exists ($obj) {
    if ($obj -is [System.String] -and [string]::IsNullOrEmpty($obj)) {
        return $false
    }

    if ($null -eq $obj) {
        return $false
    }

    $true
}


# Quick Anti-Test.
# obj -> bool
function Test-Null ($obj) {
    !(Test-Exists $obj)
}


# Creates a new pipeable color object.
# unit -> obj
function New-Color {
    [PSCustomObject]@{
        ForegroundColor = ''
        BackgroundColor = ''
    }
}


# Sets the foreground property on a color object if the s is not null or empty.
# obj -> string -> obj
filter Set-Foreground ($s) {
    if (Test-Exists $s) { 
        $_.ForegroundColor = $s -as [System.ConsoleColor]
    }
    $_ 
}


# Sets the background property on a color object if the s is not null or empty.
# obj -> string -> obj
filter Set-Background ($s) {
    if (Test-Exists $s) { 
        $_.BackgroundColor = $s -as [System.ConsoleColor]
    }
    $_ 
}


# Test the current host for the required properties.
# unit -> bool
function Test-Host {
    ($null -ne $Host.UI) -and 
    ($null -ne $Host.UI.RawUI) -and
    ($null -ne $Host.UI.RawUI.ForegroundColor) -and 
    ($null -ne $Host.UI.RawUI.BackgroundColor) 
}


# Creates a new color object with default properties based on the host if they can be.
# unit -> obj
function New-DefaultColor {
    if (Test-Host) {
        $fg = $Host.UI.RawUI.ForegroundColor
        $bg = $Host.UI.RawUI.BackgroundColor
    } 
    else {
        $fg = 'White'
        $bg = 'Black'
    }

    New-Color |
        Set-Foreground $fg |
        Set-Background $bg
}


# Wraps Write-Host to more easily consume color objects.
# obj -> obj -> switchParameter -> unit
function Write-Host {
    param (
        [Parameter(ValueFromPipeline, Position = 0)]
        $Object,

        [Parameter(Position = 1)]
        $Color,

        [switch] $NoNewLine 
    )

    if ($PSBoundParameters.ContainsKey('Color')) {
        $PSBoundParameters.Remove('Color') > $null
        $PSBoundParameters += @{
            ForegroundColor = $Color.ForegroundColor
            BackgroundColor = $Color.BackgroundColor 
        }
    } 

    Microsoft.PowerShell.Utility\Write-Host @PSBoundParameters
}