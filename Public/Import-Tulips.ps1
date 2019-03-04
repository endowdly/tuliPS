# -----------------------------------------------------------------------------------------------------------------
# Import-Tulips
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Imports tuliPS settings data from a file to the current tulips settings.
.Description
  Wraps `Import-CliXml` to export tuliPS settings. If a Path is not set, saves a file in the current user's home
  directory. 

  Import-CliXml optional parameters are not available in order to maintain data integrity. 
  The piping behavior of Import-Tulips is identical to Import-CliXml. 
  Unlike Import-CliXml, Import-Tulips does not accept multiple paths. Only one path can be imported at a time.
  Import-Tulips sets the imported data and normally does not return anything. To return the imported 
  settings, set the -PassThru switch. 
.Example
  PS> Import-Tulips $Path
  Imports the settings from the explicit path.
.Example
  PS> $Path | Import-Tulips
  Imports the settings from the explicit path. 
.Example
  PS> Import-Tulips -LiteralPath 'C:\path\to\file.xml'
  Supporting LiteralPaths.
.Inputs
  System.String
.Outputs
  PSObject

  If -PassThru is set, returns the PSObject from Import-CliXml.
.Link
  Import-CliXml
#>
function Import-Tulips {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')] # Handled by Import-CliXml
    [CmdletBinding(DefaultParameterSetName = 'Path', SupportsShouldProcess)]
    param (
        # Specifies the path to import the settings from.
        [Parameter(Position = 0,
                   Mandatory,
                   ParameterSetName = 'Path',
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)] 
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        # Specifies the literalpath to import the settings from.
        [Parameter(Mandatory,
                   ParameterSetName = 'LiteralPathInput',
                   ValueFromPipelineByPropertyName,
                   HelpMessage = 'Literal path to one or more locations.')]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [string]
        $LiteralPath,

        # Pass the settings out.
        [Parameter()]
        [switch]
        $PassThru
    )
    
    begin {
        if ($PSBoundParameters.ContainsKey('PassThru')) {
            [void] $PSBoundParameters.Remove('PassThru')
        }
    }
    
    process {
        <# Empty #>
    }
    
    end {
        $script:Tulips = Import-Clixml @PSBoundParameters
        
        if ($PassThru) {
            $Tulips 
        } 
    }
}