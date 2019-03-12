# -----------------------------------------------------------------------------------------------------------------
# Add-TulipsFormatter
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Adds an formatter to tuliPS.
.Description
  This cmdlet adds an extension to tuliPS.

  Only one formatter per type is allowed. Override existing formatters with Set-TulipsFormatter.

  It allows the user to pass scriptblocks that are added as formatting functions to tuliPS.
  The user must specify a type to allow tuliPS to properly process the objects.

  It is very important that the formatter follows two rules:
  1. The incoming object is the current pipeline object, $_ or $PSItem and
  2. The scriptblock should in some way, write to the host! 

  If the formatter fails to do these:
  1. The object will be never be acted upon and not passed out of Out-Default or 
  2. The user will have to manually write to the host in some way.

  Any helper functions called by the formatter must be available in the local process.

  Your best friends will be the format operator (-f) and the Write-Host cmdlet. 
  Remember that the Write-Host cmdlet will just be determining the appearance of the object in the host.

  Does not accept piped input.
.Example
  PS> Add-TulipsFormatter -Type System.String -Scriptblock { Write-Host $_ -Foreground Red }
    Writes all incoming string to host with a red foreground color using an inline scriptblock. 
.Example
  PS> Add-TulipsFormatter -Type System.Int -Scriptblock { '{0:P} -f $_ | Write-Host }
    Writes all incoming integers as a percentage.
.Link
  Set-TulipsFormatter
#>
function Add-TulipsFormatter {
    [CmdletBinding()]
    param (
        # The Type to format.
        [Parameter(Mandatory,
                   HelpMessage = 'You must provide a type to format',
                   Position = 0)]
        [System.Type]  
        $Type,

        # The formatter to add. Must be a scriptblock.
        [Parameter(Mandatory,
                   HelpMessage = 'Provide a scriptblock to format type (lambda function).',
                   Position = 1)]
        [scriptblock]
        $ScriptBlock)
    
    begin {
        $script:TypeTracker += @{
            $Type.ToString() = $ScriptBlock
        }
    }
    
    process { <# empty #> }
    
    end {
        $script:NewProcess = Get-ProcessBlock

        Reset-OutDefault
        Invoke-Wrapper
    }
}