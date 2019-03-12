# -----------------------------------------------------------------------------------------------------------------
# Reset-OutDefault
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Resets Out-Default to Microsoft.PowerShell.Core/Out-Default.
.Description
  Resets Out-Default to Microsoft.PowerShell.Core/Out-Default.

  Similar to a Restore, but with no Checkpoint. Since Out-Default is... well the default cmdlet in Core, this 
  function simply removes the wrapped Out-Default command and resets the visibility of the core command to Public.

  This function takes no parameters and returns nothing.
.Example
  PS> Reset-OutDefault
  The only way it can be used.
#>
function Reset-OutDefault {

    if (Test-Path function:\Out-Default) {
        Remove-Item function:\Out-Default -Force
    }

    $OutDefault.Visibility = 'Public'
}