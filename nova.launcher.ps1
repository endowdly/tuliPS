#Requires -Version 5.0

# --------------------------------------------------------------------------------------------------
# Nova Script
# --------------------------------------------------------------------------------------------------

<#
.Synopsis
  Launcher that uses Nova.
.Description
  Launcher that uses Nova. This script does not let you source it. It can only be invoked. 
.Link
  ./nova.ps1
#>

#region Startup ---------------------------------------------------------------------------------------------------

# Forbid Sourcing
if ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq '') { 
    Write-Warning 'Nova was sourced! This is verboten to prevent session pollution!' 
    
    'ABORT'
    exit 1
} 


# Dangit!
# unit -> unit
function Oops {
    'ABORT'
    exit 0
}


# Invokes a task
# string -> unit
function Invoke-Task ($s) {
    & $PSScriptRoot/nova.ps1 -Task $s
}


# Creates a new Host.ChoiceDescription object
# string -> char -> hashtable -> ChoiceDescription
# string -> char -> string -> ChoiceDescription
function New-Choice {
    param (
        [string] $Name,
        [char] $Token,
        [hashtable] $Dictionary,
        [string] $Message = ''
    )

    $label = $Name.Insert($Name.IndexOf($Token), '&')

    $msg = 
        if ($null -ne $Dictionary) {
            $Dictionary.$Name
        }
        else {
            $Message
        }

    [System.Management.Automation.Host.ChoiceDescription]::new($label, $msg)
}


# Prompts the host for choices
# string -> string -> ChoiceDescription[] -> int -> int
function Read-Prompt {
    param (
        [string] $Title = '',
        [string] $Prompt,
        [array] $Choices,
        [int] $DefaultChoice = 0
    )

    $Host.UI.PromptForChoice($Title, $Prompt, $Choices, $DefaultChoice)
}


# hashtable -> ChoiceDescription[]
function Get-Choice ($x) {
    $tokens = @{
        Key = ''
        TokenIndex = 0
        Token = ''
        TokenCollection = [System.Collections.ArrayList]::new()
    }

    foreach ($k in $x.Keys) {
        $tokens | 
            Set-Key $k |
            Set-TokenIndex 0 |
            Add-Token

        New-Choice -Name $k -Token $tokens.Token -Dictionary $x
    }
}


# Set the TokenIndex property on a token obj
# obj -> obj
filter Set-TokenIndex ($i) {
    $_.TokenIndex = $i
    $_
}


# Set the Key property on a token obj
# obj -> obj
filter Set-Key ($s) {
    $_.Key = $s
    $_
}

# Add a Token property to a collection on a token obj
# Tries not to allow repeat tokens
# obj -> unit
filter Add-Token {
    $_.Token = $_.Key.Substring($_.TokenIndex, 1)

    if ($_.Token -in $_.TokenCollection) {
        $_.TokenIndex++
        $_ | Add-Token
    }

    [void] $_.TokenCollection.Add($_.Token)
}


#endregion

#region Exeq ------------------------------------------------------------------------------------------------------

@"
 
            _                          
           ' )    )                    
           //   /'                     
         /'/  /' ____   .     ,   ____ 
       /' / /' /'    )--|    /  /'    )
     /'  //' /'    /'   |  /' /'    /' 
 (,/'    (_,(___,/'    _|/(__(___,/(__ 
                                       
                                       
"@

$Choices = [Ordered] @{
    Default    = 'Execute default build task'
    Build      = 'Executes the standard build task'
    FirstBuild = 'Executes the initial build task, resetting the version'
    Install    = 'Installs the output to the local module folder'
    Sanitize   = 'Removes the output path and any build files in the build root'
    Exit       = 'Aborts this Process'
}
$ContinueChoices = [Ordered] @{
    Yes = 'Continue to complete another Action'
    No  = 'End this Process' 
}
$Actions = @{
    Prompt  = 'Choose Action'
    Choices = Get-Choice $Choices
    Default = 0 
}
$Continue = @{
    Prompt  = 'Would you like to run another Action?' 
    Choices = Get-Choice $ContinueChoices
    Default = 1 
}

do {
    $result = Read-Prompt -Prompt $Actions.Prompt -Choices $Actions.Choices -DefaultChoice $Actions.Default
    
    switch ($result) {
        0 { Invoke-Task Default }
        1 { Invoke-Task Build } 
        2 { Invoke-Task FirstBuild }
        3 { Invoke-Task Install }
        4 { Invoke-Task Sanitize }
        default { Oops }
    }

    $canContinue = Read-Prompt -Prompt $Continue.Prompt -Choices $Continue.Choices -DefaultChoice $Continue.Default
} until ($canContinue -eq 1)

#endregion