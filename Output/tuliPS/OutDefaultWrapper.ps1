# -----------------------------------------------------------------------------------------------------------------
# Wrap Out-Default
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Wraps Out-Default.
.Description
  Wraps Out-Default so we can implement custom color formatting.

  Avoids collisions if the user has a wrapped command of the same name in the session.
.Notes 
  Some parts based on New-CommandWrapper by Lee Holmes. Some based on PSColor by David Lindblad.

  Background:
  Microsoft Consoles did not support Virtual Terminal (VT) ANSI escape sequences for color output support. 
  This was changed recently with the addition of VT support in Windows 10 releases, and Powershell 5+ now supports
  VT escapes pretty well. Combining ANSI sequences with the PowerShell type formatting (format.ps1xml) allows for
  very powerful control over formatting. Check out DirColors by Dustin Howett for a fantastic example.

  However, I hate ANSI escape sequences and virtual terminal support for it. It's ancient. It's clunky. It's hard
  to read. And it needs an update. Why are we still using old hardware codes for hardware that doesn't exist to 
  tell modern software what to do? 

  So, wrapping Out-Default allows for some pretty close approximations. 

  Author: endowdly@gmail.com
  Last Update: 2018-12-15T11:09:44.8501590-05:00
#>

$Target = 'Out-Default'
$CommandType = 'Cmdlet'

# Prevents clobber
if (Test-Path function:\$Target) {
    $newTarget = $Target + '-' + [guid]::NewGuid().ToString().Replace('-', '')
    Rename-Item function:\Global:$Target function:\Global:$newTarget
    $CommandType = 'Function'
}

# Fetch original with its metadata
$OriginalCommand = Get-Command $Target -CommandType $CommandType
$MetaData = [System.Management.Automation.CommandMetadata]::new($OriginalCommand)

# Wrap the original
$ProxyString = [System.Management.Automation.ProxyCommand]::Create($MetaData)

# Inject a new process block
$newProcess = {
   # Idea: This can probably be extendable? Use a module variable here and a public function to set it? 

   if ($_ -is [System.IO.FileSystemInfo]) {
        Format-FileInfo $_
        $_ = $null
    }

    if ($_ -is [Microsoft.PowerShell.Commands.MatchInfo]) {
        Format-MatchInfo $_
        $_ = $null
    }

}

$Temp = [scriptblock]::Create($ProxyString)
$InjectPoint = $Temp.Ast.ProcessBlock.Statements.Extent.StartOffset - $Temp.Ast.Extent.StartOffSet
$BlockText = $Temp.Ast.Extent.Text.Insert($InjectPoint, $newProcess.ToString())
$Proxy = [scriptblock]::Create($BlockText)

# Set the wrapper
Write-Verbose $Proxy.ToString()
Set-Content function:\Global:$Target $Proxy

# Hide original command. Hush baby. Hush.
if ($CommandType -eq 'Cmdlet') {
    $OriginalCommand.Visibility = 'Private'
}