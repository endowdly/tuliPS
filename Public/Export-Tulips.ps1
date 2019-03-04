# -----------------------------------------------------------------------------------------------------------------
# Export-Tulips
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Exports current tuliPS settings to a configuration file.
.Description
  Wraps `Export-CliXml` to export tuliPS settings. If a Path is not set, saves a file in the current user's home
  directory.

  Most `Export-CliXml` parameters are available, except -Depth.
  Depth is hard-coded to 3 to ensure all settings are captured.
.Example
  PS> Export-Tulips
  Saves the settings to the default path.
.Example
  PS> Export-Tulips $Path
  Saves the settings to a given Path.
.Example
  PS> $Path | Export-Tulips 
  $Path can be piped to Export-Tulips. This behavior differs from `Export-CliXml`.
.Example
  PS> Export-Tulips -LiteralPath 'C:\path\to\file.xml'
  Supporting LiteralPaths.
.Notes
  Background:
    Since Tulips settings are set in the session as a hashtable, it's better to use Export-CliXml than it is to 
    use Export-Csv or converting the hashtable to Json. ConvertTo-Json tranforms anything it gets that is not
    a string, boolean, or number to an object. That's not good because it will break our `Get-Tulips` trick.

    Export-CliXml preserves hashtable type information. The best option, in my opinion, would be to use 
    Joel Bennett's Configuration module and his sweet Metadata converters. PowerShell data files are first class
    objects in PowerShell, why is that not built in!? However, I did not want to add a dependency. And I will
    never be able to write anything half as good as Jaykul's module. That thing is sweet.

    We lose a little readability. Oh well. It's very quick, and works well.
.Inputs
  System.String
.Outputs
  System.IO.FileInfo
.Link
  Export-CliXml
#>
function Export-Tulips {
    [CmdletBinding(DefaultParameterSetName = 'Path', SupportsShouldProcess)]
    param (
        # Specifies the path to export the settings to. Default: $HOME/tuliPS.xml
        [Parameter(Position = 0,
                   ParameterSetName = 'Path',
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]
        $Path,

        # Specifies the literalpath to export the settings to.
        [Parameter(Mandatory,
                   ParameterSetName = 'LiteralPathInput',
                   ValueFromPipelineByPropertyName,
                   HelpMessage = 'Literal path to one or more locations.')]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [string]
        $LiteralPath,

        # Force run without confirmation.
        [Parameter()]
        [switch]
        $Force,

        # Ensure the function does not overwrite an existing file. Default behavior is to overwrite.
        [Parameter()]
        [switch]
        $NoClobber,

        # Specifies the encoding for the target file. Default: Unicode.
        [Parameter()]
        [System.Text.Encoding]
        $Encoding
    )
    
    begin {
        if (Test-Null $Path) {
            $PSBoundParameters.Path = Join-Path $HOME tuliPS.xml
        }

        $PSBoundParameters.Depth = 3 
    }
    
    process {
        $Tulips | Export-Clixml @PSBoundParameters
    }
    
    end {
        <# Empty #>
    }
}