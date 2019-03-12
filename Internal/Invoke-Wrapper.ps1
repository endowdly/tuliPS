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

function Invoke-Wrapper {

    $target = 'Out-Default'
    $commandType = 'Cmdlet'

    # Prevents clobber
    if (Test-Path function:\$Target) {
        $newTarget = $Target + '-' + [guid]::NewGuid().ToString().Replace('-', '')
        Rename-Item function:\Global:$Target function:\Global:$newTarget
        $commandType = 'Function'
    }

    # Fetch original with its metadata
    $originalCommand = Get-Command $target -CommandType $commandType
    $metaData = [System.Management.Automation.CommandMetadata]::new($originalCommand)

    # Wrap the original
    $proxyString = [System.Management.Automation.ProxyCommand]::Create($metaData)

    # Convert to a scriptblock so we can use the AST to find the insertion point.
    $temp = [scriptblock]::Create($proxyString)
    $injectPoint = $temp.Ast.ProcessBlock.Statements.Extent.StartOffset - $temp.Ast.Extent.StartOffSet

    # Insert our process block and then create a new command.
    $blockText = $temp.Ast.Extent.Text.Insert($injectPoint, $NewProcess.ToString())                               
    $proxy = [scriptblock]::Create($blockText)

    # Set the wrapper
    Write-Verbose $proxy.ToString()
    Set-Content function:\Global:$target $proxy

    # Hide original command. Hush baby. Hush.
    if ($commandType -eq 'Cmdlet') {
        $originalCommand.Visibility = 'Private'
    }
}
