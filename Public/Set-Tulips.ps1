# -----------------------------------------------------------------------------------------------------------------
# Set-Tulips
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Set tuliPS settings.
.Description
  The Set-Tulips command sets the configuration module variable for Tulips. While the variable can be copied and 
  manipulated by hand, the variable can be altered in a way that introduces serious errors. 

  This command sets the configuration variable with validation to ensure both the expected structure and values.

  Set-Tulips does not expose the configuration variable to the user; it is generally smarter and easier to 
  alter tulips settings with this command.
.Example
  PS> Set-Tulips -AddTulips Process
  Creates a new top level configuration for the user to access.
.Example
  PS> $Property = @{
        Heavy = @{
            ForegroundColor = 'Red'
            BackgroundColor = ''
        }
        Medium = @{
            ForegroundColor = 'Yellow'
            BackgroundColor = ''
        }
        Light = @{
            ForegroundColor = 'Green'
            BackgroundColor = ''
        }
    }
  PS> Set-Tulips -AddTulips Process -TulipsValue $Property
  Creates a new top level configuration for the user to access with intial values.
.Notes
  This is a monster command, in my opinion. I could have easily broken this down into other commands.
  -AddExtension becomes Add-ExtensionSet (internal) and gets called here. But, most of these sub-commands
  are very short so they will sit in the begin block. Most of this is parameters set up; there is 
  probably a better way to do all this in one command.

  Background: 
    I thought the easiest way to do this was to expose the configuration variable to the global scope and
    manipulate it. After I made my first error, I realised that as the creator if I could make a mistake,
    a general user would make a lot. And that could be frustrating. So I wrote this to help ease 
    configuration. 
#>
function Set-Tulips {
    [CmdletBinding()]
    param (
        # The name of the top level setting to add.
        [Parameter(ParameterSetName = 'AddTulips', Position = 0,
                   Mandatory, HelpMessage = 'Provide a key to add')]
        [System.String]
        $AddTulips,

        # The property of the top level setting to add.
        [Parameter(ParameterSetName = 'AddTulips', Position = 1, ValueFromPipeline)]
        $TulipsValue,

        # Adds an extension set to file level settings.
        [Parameter(ParameterSetName = 'AddExtensionSet',
                   Mandatory, HelpMessage = 'Provide a tag for the Extension Set')]
        [System.String]
        $AddExtensionSet,

        # The extensions to add to an extensions set.
        [Parameter(ParameterSetName = 'AddExtensionSet',
                   ValueFromPipeline)]
        [ValidatePattern('\.\w+')]
        [System.String[]]
        $Extensions = @(),

        # The background color.
        [Parameter(ParameterSetName = 'AddExtensionSet')]
        [Parameter(ParameterSetName = 'EditExtensionSet')]
        [System.ConsoleColor]
        $ForegroundColor,

        # The background color.
        [Parameter(ParameterSetName = 'AddExtensionSet')]
        [Parameter(ParameterSetName = 'EditExtensionSet')]
        [System.ConsoleColor]
        $BackgroundColor,

        # One or more extensions to add to an extension set.
        [Parameter(ParameterSetName = 'EditExtensionSet')]
        [ValidatePattern('\.\w+')]
        [System.String[]]
        $Add,

        # One or more extensions to remove from an extension set.
        [Parameter(ParameterSetName = 'EditExtensionSet')]
        [ValidatePattern('\.\w+')]
        [System.String[]]
        $Remove,

        # Returns the settings.
        [switch]
        $PassThru 
    )
    
    dynamicParam { 

        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary 
        $DefaultTulips = Import-PowerShellDataFile $ConfigPath
        $DefaultTypes = $DefaultTulips.Keys
        $CurrentTypes = $Tulips.Keys
        $AvailableTypes = $Tulips.Keys.Where{ $_ -notin $DefaultTypes } 
        $ExtensionSets = $Tulips.File.Extensions.Tag


        $DynamicParameters = @(
            @{ 
                Name = 'EditExtensionSet'
                Type = [System.String]
                ParameterSetName = 'EditExtensionSet'
                Mandatory = $true
                HelpMessage = 'Enter a tag to edit'
                Position = 0
                ValidateSet = $ExtensionSets
            }
            @{ 
                Name = 'RemoveExtensionSet'
                Type = [System.String[]]
                ParameterSetName = 'RemoveExtensionSet'
                Mandatory = $true
                HelpMessage = 'Enter tags to edit'
                Position = 0
                ValidateSet = $ExtensionSets
            }
            @{
                Name = 'Name'
                Type = [System.String]
                ParameterSetName = 'AddProperty'
                Mandatory = $true
                HelpMessage = 'Enter a Tulips to add a property key to.'
                Position = 0 
                ValidateSet = $CurrentTypes
            }
            @{
                Name = 'Name'
                Type = [System.String]
                ParameterSetName = 'RemoveProperty'
                Mandatory = $true
                HelpMessage = 'Enter a Tulips to remove a property from.'
                Position = 0 
                ValidateSet = $CurrentTypes
            }
            @{
                Name = 'Name'
                Type = [System.String]
                ParameterSetName = 'SetProperty'
                Mandatory = $true
                HelpMessage = 'Enter a Tulips.'
                Position = 0 
                ValidateSet = $CurrentTypes
            }
            @{
                Name = 'Name'
                Type = [System.String]
                ParameterSetName = 'SetPropertyValue'
                Mandatory = $true
                HelpMessage = 'Enter a property key to change.'
                Position = 0 
                ValidateSet = $CurrentTypes
            }
            @{
                Name = 'AddProperty'
                Type = [System.String[]]
                ParameterSetName = 'AddProperty'
                Position = 1 
            }
            @{
                Name = 'RemoveProperty'
                Type = [System.String[]]
                ParameterSetName = 'RemoveProperty'
                Position = 1 
            }
            @{
                Name = 'SetProperty'
                Type = [System.String]
                ParameterSetName = 'SetProperty'
                Position = 1 
            }
            @{
                Name = 'Key'
                Type = [System.String]
                ParameterSetName = 'SetProperty'
                Position = 2
            }
            @{
                Name = 'Property'
                Type = [System.String]
                ParameterSetName = 'SetPropertyValue'
                Position = 1
            }
            @{
                Name = 'Setting'
                Type = [System.String]
                ParameterSetName = 'SetPropertyValue'
                Position = 2
            }
            @{
                Name = 'Value'
                Type = [System.String]
                ParameterSetName = 'SetPropertyValue'
                Position = 3
            }
        )

        if ($AvailableTypes.Count -gt 0) {
            $DynamicParameters += @(
                @{ 
                    Name = 'RemoveTulips'
                    Type = [System.String]
                    ParameterSetName = 'RemoveTulips'
                    Mandatory = $true
                    HelpMessage = 'Enter a type key to remove'
                    Position = 0 
                    ValidateSet = $AvailableTypes
                }
                @{
                    Name = 'SetTulips'
                    Type = [System.String]
                    ParameterSetName = 'SetTulips'
                    Mandatory = $true
                    HelpMessage = 'Enter a type key to change'
                    Position = 0
                    ValidateSet = $AvailableTypes
                }
                @{
                    Name = 'Key'
                    Type = [System.String]
                    ParameterSetName = 'SetTulips'
                    Mandatory = $true
                    HelpMessage = 'Enter a new type Key'
                    Position = 1 
                } 
            ) 
        }

        $DynamicParameters |
            ForEach-Object { [PSCustomObject] $_ } |
            New-DynamicParameter -Dictionary $Dictionary

        $Dictionary
    }

    begin {
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

        # Adds a top level hashtable to Tulips.
        # unit -> unit
        function Add-Tulips {
            $Tulips.Add($AddTulips, $TulipsValue)
        }


        # Removes a top level hashtable from Tulips.
        # unit -> unit
        function Remove-Tulips {
            $Tulips.Remove($RemoveTulips)
        }


        # Changes a top level hashtable (key only) in Tulips.
        # unit -> unit
        function Set-Tulips {
            $copyCat = $Tulips.$SetTulips.Clone()
            $Tulips.Add($Key, $copyCat)
            $Tulips.Remove($SetTulips) 
        }


        # Adds a second-level property to a top-level property.
        # unit -> unit
        function Add-Property { 
            foreach ($property in $AddProperty) {
                $Tulips.$Name.Add($property, @{})
            }
        } 


        # Removes a second-level property to a top-level property.
        # unit -> unit
        function Remove-Property {
            foreach ($property in $RemoveProperty) {
                $Tulips.$Name.Remove($property)
            }
        }


        # Sets a second-level property.
        # unit -> unit
        function Set-Property {
            $copyCat = $Tulips.$Name.$SetProperty.Clone() 
            $Tulips.$Name.Add($Key, $copyCat)
            $Tulips.$Name.Remove($SetProperty)
        }


        # Sets a second-level property.
        # unit -> unit
        function Set-PropertyValue {
            $Tulips.$Name.$Property.$Setting = $Value
        }


        # Converts the enum value for foregroundcolor to string.
        # unit -> string
        function Get-ForegroundColor { 
            if (Test-Null $ForegroundColor) {
                ''
            }
            else {
                $ForegroundColor.ToString()
            }
        }


        # Converts the enum value for backgroundcolor to string.
        # unit -> string
        function Get-BackgroundColor { 
            if (Test-Null $BackgroundColor) {
                ''
            }
            else {
                $BackgroundColor.ToString()
            }
        }


        # Adds a well formated extension set to Tulips.
        # unit -> unit 
        function Add-ExtensionSet {
            $value = @{
                Tag = $AddExtensionSet
                Extensions = $Extensions
                ForegroundColor = ForegroundColor
                BackgroundColor = BackgroundColor
            }
            $Tulips.File.Extensions += $value
        }


        # Removes an extension set from Tulips via filtering.
        # unit -> unit
        function Remove-ExtensionSet {
            $Tulips.File.Extensions = $Tulips.File.Extensions.Where{ $_.Tag -notin $RemoveExtensionSet }
        }


        # Edits an extension set from Tulips via filtering and array shadowing
        # unit -> unit
        function Set-ExtensionSet {
            $set = $Tulips.File.Extensions.Where{ $_.Tag -eq $EditExtensionSet }
            $newSet = @{
                Tag = $EditExtensionSet
                Extensions = (@($set.Extensions) + @($Add)).Where{ $_ -notin $Remove }
                ForegroundColor = 
                    if (Test-Null $ForegroundColor) {
                        $set.ForegroundColor
                    }
                    else {
                        $ForegroundColor.ToString()
                    }
                BackgroundColor = 
                    if (Test-Null $BackgroundColor) {
                        $set.BackgroundColor
                    }
                    else {
                        $BackgroundColor.ToString()
                    }
            }
                    
            $Tulips.File.Extensions = $Tulips.File.Extensions.Where{ $_.Tag -notin $EditExtensionSet }
            $Tulips.File.Extensions += $newSet
        }
    }
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            AddTulips { Add-Tulips }
            RemoveTulips { Remove-Tulips }
            SetTulips { Set-Tulips }
            AddProperty { Add-Property }
            RemoveProperty { Remove-Property }
            SetProperty { Set-Property }
            SetPropertyValue { Set-PropertyValue }
            AddExtensionSet { Add-ExtensionSet }
            RemoveExtensionSet { Remove-ExtensionSet }
            EditExtensionSet { Set-ExtensionSet }
        }
    }
    
    end {
        if ($PassThru) {
            $Tulips
        }
    }
}