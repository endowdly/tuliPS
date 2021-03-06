# -----------------------------------------------------------------------------------------------------------------
# Reset-Tulips
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Resets tuliPS to the default settings.
.Description
  Resets the tuliPS config hashtable back to the default settings.
  Resets the tuliPS formatters back to the default settings.

  Oh man, you jacked with the colors and everything is an eye-sore?
  You screwed with the formatters and you can't fix it?
  You wow, you totally changed the hashtable to something nonsensical and borked the whole thing!? 
  Don't worry, I got you.
.Example
  PS> Reset-Tulips
  The only way it can be used.
#>
function Reset-Tulips {
    $script:Tulips = Import-PowerShellDataFile $ConfigPath
    $script:TypeTracker = $TypeTrackerCheckpoint
    $script:NewProcess = Get-ProcessBlock

    Reset-OutDefault
    Invoke-Wrapper
}