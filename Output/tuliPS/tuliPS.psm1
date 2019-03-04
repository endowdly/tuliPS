<#
 
 ,---------.   ___    _   .---.    .-./`) .-------.    .-'''-.  
 \          \.'   |  | |  | ,_|    \ .-.')\  _(`)_ \  / _     \ 
  `--.  ,---'|   .'  | |,-./  )    / `-' \| (_ o._)| (`' )/`--' 
     |   \   .'  '_  | |\  '_ '`)   `-'`"`|  (_,_) /(_ o _).    
     :_ _:   '   ( \.-.| > (_)  )   .---. |   '-.-'  (_,_). '.  
     (_I_)   ' (`. _` /|(  .  .-'   |   | |   |     .---.  \  : 
    (_(=)_)  | (_ (_) _) `-'`-'|___ |   | |   |     \    `-'  | 
     (_I_)    \ /  . \ /  |        \|   | /   )      \       /  
     '---'     ``-'`-''   `--------`'---' `---'       `-...-'   
                                                                
 
#>

<# 

   ___                      
  / __| ___ _  _ _ _ __ ___ 
  \__ \/ _ \ || | '_/ _/ -_)
  |___/\___/\_,_|_| \__\___|
 

#>

foreach ($folder in 'Public', 'Internal', 'Classes') {

    $folderPath = Join-Path $PSScriptRoot $folder

    if (Test-Path $folderPath) {

        $files = Get-ChildItem -Path $folderPath -Filter '*.ps1' 

        foreach ($file in $files) { 
            . $file.FullName
        }
    }    
} 

<#
 
  __   __        _      _    _        
  \ \ / /_ _ _ _(_)__ _| |__| |___ ___
   \ V / _` | '_| / _` | '_ \ / -_|_-<
    \_/\__,_|_| |_\__,_|_.__/_\___/__/
                                      
 
#>

$WrapperPath = Join-Path $PSScriptRoot OutDefaultWrapper.ps1
$ConfigPath = Join-Path $PSScriptRoot tuliPS.config.psd1
$Tulips = Import-PowerShellDataFile $ConfigPath 
$OutDefault = Get-Command Out-Default -CommandType Cmdlet


<#
 
    ___                              _    
   / __|___ _ __  _ __  __ _ _ _  __| |___
  | (__/ _ \ '  \| '  \/ _` | ' \/ _` (_-<
   \___\___/_|_|_|_|_|_\__,_|_||_\__,_/__/
                                          
 
#>

& $WrapperPath

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Reset-OutDefault
}
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
<#
 
 ███████╗██╗██╗     ███████╗██╗███╗   ██╗███████╗ ██████╗ 
 ██╔════╝██║██║     ██╔════╝██║████╗  ██║██╔════╝██╔═══██╗
 █████╗  ██║██║     █████╗  ██║██╔██╗ ██║█████╗  ██║   ██║
 ██╔══╝  ██║██║     ██╔══╝  ██║██║╚██╗██║██╔══╝  ██║   ██║
 ██║     ██║███████╗███████╗██║██║ ╚████║██║     ╚██████╔╝
 ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝ 
                                                          
 
#>

<#
.Synopsis
  Small, consumable commands for internal use.
.Description
  Small, consumable commands for internal use. Helpers for Format-FileInfo.

  Private. Should not be invoked. Should be sourced by the module only.
.Notes
  Some functions based on DirColors by David Howett.
#>


# Return the parent container of a FileSystemInfo object.
# FileSystemInfo -> string
function Get-Container ($obj) { 
    switch ($obj) {
        { $obj -is [System.IO.DirectoryInfo] } { $obj.Parent }
        { $obj -is [System.IO.FileInfo] } { $obj.Directory }
        default { $obj }   # Hack: Should be some sort of exception here
    }
} 


# Returns the target of a link.
# FileSystemInfo -> FileSystemInfo
function Get-LinkTargetInfo ($obj) {
    if ($obj.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
        if ($obj.LinkType -eq 'SymbolicLink' -or $obj.LinkType -eq 'Junction') {
            $container = Container $obj
            $targetFullName = [System.IO.Path]::Combine($container.FullName, $obj.Target)

            Get-Item $targetFullName -ErrorAction Ignore 
        }
    }
}


# Gets the color object of a link.
# FileSystemInfo -> obj
function Get-Link ($obj) {
    $colorHash = 
        if ($obj.LinkType -eq 'SymbolicLink' -or $obj.LinkType -eq 'Junction') {
            $container = Container $obj
            $targetFullName = [System.IO.Path]::Combine($container.FullName, $obj.Target)

            try {
                Get-Item $targetFullName -ErrorAction Stop > $null
                $Tulips.File.Link
            }
            catch {
                $Tulips.File.Orphan 
            } 
        }
        else {
            $Tulips.File.BlockDevice 
        }
    
    New-DefaultColor |
        Set-Foreground $colorHash.ForegroundColor | 
        Set-Background $colorHash.BackgroundColor 
}


# Returns the color object for a directory.
# unit -> obj
function Get-Directory {
    New-DefaultColor | 
        Set-Foreground $Tulips.File.Directory.ForegroundColor |
        Set-Background $Tulips.File.Directory.BackgroundColor
}


# Gets the color object for a file via a dictionary lookup. Should be faster than regex.
# FileInfo -> obj
function Get-File ($obj) {
    $ext = $obj.Extension
    $colorHash = 
        foreach ($group in $Tulips.File.Extensions) {
            if ($ext -in $group.Extensions) {
                $group
                break
            }
        }

    if (Test-Null $colorHash) { 
        return (New-DefaultColor)
    }

    New-DefaultColor | 
        Set-Foreground $colorHash.ForegroundColor | 
        Set-Background $colorHash.BackgroundColor 
}


# Returns the color object for a FileSystemInfo with a hidden attribute.
# unit -> obj
function Get-Hidden {
    New-DefaultColor | 
        Set-Foreground $Tulips.File.Hidden.ForegroundColor |
        Set-Background $Tulips.File.Hidden.BackgroundColor
}


# Determines the color code for a FileSystemInfo object.
# FileSystemInfo -> obj
function Get-FileColor ($obj) {
    switch ($obj) {
        { $obj.Attributes.HasFlag([System.IO.FileAttributes]::Hidden) } { Hidden; break }
        { $obj.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint) } { Link $obj; break }
        { $obj -is [System.IO.DirectoryInfo] } { Directory; break }
        { $obj -is [System.IO.FileInfo] } { File $obj; break }
        default { New-DefaultColor }
    }
}


# Gets the color object of a link's target.
# FileSystemInfo -> obj
function Get-LinkTargetColor ($obj) {
    
    $linkTargetInfo = LinkTargetInfo $obj

    if (Test-Exists $linkTargetInfo) {
        FileColor $linkTargetInfo
    }
    else {
        $colorHash = $Tulips.File.Missing
        
        New-DefaultColor | 
            Set-Foreground $colorHash.ForegroundColor | 
            Set-Background $colorHash.BackgroundColor
    }
}


# Rewrites a file length into a more readable format.
# Review: I'm not sure this is the best idea to hard format, because things like Humanizer do exist.
# int -> string
function Write-FileLength ($n) {
    switch ($n) {
        { $null -eq $n } { '' }
        { $n -ge 1GB } { ($n / 1GB).ToString('f') + ' GB' }
        { $n -ge 1MB } { ($n / 1MB).ToString('f') + ' MB' }
        { $n -ge 1KB } { ($n / 1KB).ToString('f') + ' KB' }
        default { $n.ToString() + '  ' }
    }
}


# Emulates the grouping header for the Table View formatter.
# obj -> string[]
<# FixMe: 
    When calling something like ls many time from the same parent location, this does not get displayed. 
    A potential solution (off the top of my head) would be to reset the module variable Directory in the end
    block of the wrapped Out-Default after incorporating the wrapper into the module.
#> 
function Format-FileInfoHeader ($obj) {
    $currentDir = (Container $Obj).FullName

    if ($Directory -ne $currentDir) {
        $script:Directory = $currentDir 
        $dirColor = Directory
        $formatString = '{0, -7} {1, 25} {2, 10} {3}'

        Write-Host
        Write-Host
        Write-Host '    Directory: ' -NoNewline
        Write-Host $currentDir $dirColor
        Write-Host
        Write-Host
        $formatString -f 'Mode', 'LastWriteTime', 'Length', 'Name' | Write-Host
        $formatString -f '----', '-------------', '------', '----' | Write-Host
    }
}

<#
 
 ███╗   ███╗ █████╗ ████████╗ ██████╗██╗  ██╗██╗███╗   ██╗███████╗ ██████╗ 
 ████╗ ████║██╔══██╗╚══██╔══╝██╔════╝██║  ██║██║████╗  ██║██╔════╝██╔═══██╗
 ██╔████╔██║███████║   ██║   ██║     ███████║██║██╔██╗ ██║█████╗  ██║   ██║
 ██║╚██╔╝██║██╔══██║   ██║   ██║     ██╔══██║██║██║╚██╗██║██╔══╝  ██║   ██║
 ██║ ╚═╝ ██║██║  ██║   ██║   ╚██████╗██║  ██║██║██║ ╚████║██║     ╚██████╔╝
 ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝ 
                                                                           
 
#>

<#
.Synopsis
  Small, consumable commands for internal use.
.Description
  Small, consumable commands for internal use. Helpers for Format-MatchInfo.

  Private. Should not be invoked. Should be sourced by the module only.
.Notes
  Idea shamefully stolen from David Lindblad (PSColor).
#> 


# Returns the color object for a match path.
# string -> obj
function Get-PathColor {
    param (
        [ValidateSet('Match', 'NoMatch')]
        [System.String] $s
    )

    New-DefaultColor |
        Set-Foreground $Tulips.$s.Path.ForegroundColor |
        Set-Background $Tulips.$s.Path.BackgroundColor 
}


# Returns the color object for a match linenumber.
# string -> obj
function Get-LineNumberColor {
    param (
        [ValidateSet('Match', 'NoMatch')]
        [System.String] $s
    )

    New-DefaultColor |
        Set-Foreground $Tulips.$s.LineNumber.ForegroundColor |
        Set-Background $Tulips.$s.LineNumber.BackgroundColor 
}


# Returns the color object for a match line.
# string -> obj
function Get-LineColor {
    param (
        [ValidateSet('Match', 'NoMatch')]
        [System.String] $s
    )

    New-DefaultColor |
        Set-Foreground $Tulips.$s.Line.ForegroundColor |
        Set-Background $Tulips.$s.Line.BackgroundColor 
}


# Writes formatted context information from a match object.
# MatchInfo -> unit
function Format-MatchContext {
    param (
        [Microsoft.PowerShell.Commands.MatchInfo] $obj,

        [ValidateSet('PreContext', 'PostContext')]
        [System.String] $type
    )

    $contexts =
        switch ($type) {
            PreContext { $obj.Context.DisplayPreContext } 
            PostContext { $obj.Context.DisplayPostContext } 
        } 
    $index =
        switch ($type) {
            PreContext { $obj.LineNumber - $obj.Context.DisplayPreContext.Count }
            PostContext { $obj.LineNumber + 1 } 
        }
    $fileName = $obj.RelativePath($PWD)

    foreach ($context in $contexts) {
        Write-Host "  $fileName" (PathColor NoMatch) -NoNewline
        Write-Host : -NoNewline
        Write-Host $index (LineNumberColor NoMatch) -NoNewline 
        Write-Host : -NoNewline
        Write-Host $context (LineColor NoMatch)
        $index++
    }
}
 
<#
 
   _  _                ___                       _    ___                         _           
  | \| |_____ __ _____|   \ _  _ _ _  __ _ _ __ (_)__| _ \__ _ _ _ __ _ _ __  ___| |_ ___ _ _ 
  | .` / -_) V  V /___| |) | || | ' \/ _` | '  \| / _|  _/ _` | '_/ _` | '  \/ -_)  _/ -_) '_|
  |_|\_\___|\_/\_/    |___/ \_, |_||_\__,_|_|_|_|_\__|_| \__,_|_| \__,_|_|_|_\___|\__\___|_|  
                            |__/                                                              
 
 By Beatcracker
 -> https://github.com/beatcracker/Powershell-Misc/blob/master/New-DynamicParameter.ps1

 Used because I am lazy.
#>

<#
.SYNOPSIS
	Helper function to simplify creating dynamic parameters

.DESCRIPTION
	Helper function to simplify creating dynamic parameters.

	Example use cases:
		Include parameters only if your environment dictates it
		Include parameters depending on the value of a user-specified parameter
		Provide tab completion and intellisense for parameters, depending on the environment

	Please keep in mind that all dynamic parameters you create, will not have corresponding variables created.
		Use New-DynamicParameter with 'CreateVariables' switch in your main code block,
		('Process' for advanced functions) to create those variables.
		Alternatively, manually reference $PSBoundParameters for the dynamic parameter value.

	This function has two operating modes:

	1. All dynamic parameters created in one pass using pipeline input to the function. This mode allows to create dynamic parameters en masse,
	with one function call. There is no need to create and maintain custom RuntimeDefinedParameterDictionary.

	2. Dynamic parameters are created by separate function calls and added to the RuntimeDefinedParameterDictionary you created beforehand.
	Then you output this RuntimeDefinedParameterDictionary to the pipeline. This allows more fine-grained control of the dynamic parameters,
	with custom conditions and so on.

.NOTES
	Credits to jrich523 and ramblingcookiemonster for their initial code and inspiration:
		https://github.com/RamblingCookieMonster/PowerShell/blob/master/New-DynamicParam.ps1
		http://ramblingcookiemonster.wordpress.com/2014/11/27/quick-hits-credentials-and-dynamic-parameters/
		http://jrich523.wordpress.com/2013/05/30/powershell-simple-way-to-add-dynamic-parameters-to-advanced-function/

	Credit to BM for alias and type parameters and their handling

.PARAMETER Name
	Name of the dynamic parameter

.PARAMETER Type
	Type for the dynamic parameter.  Default is string

.PARAMETER Alias
	If specified, one or more aliases to assign to the dynamic parameter

.PARAMETER Mandatory
	If specified, set the Mandatory attribute for this dynamic parameter

.PARAMETER Position
	If specified, set the Position attribute for this dynamic parameter

.PARAMETER HelpMessage
	If specified, set the HelpMessage for this dynamic parameter

.PARAMETER DontShow
	If specified, set the DontShow for this dynamic parameter.
	This is the new PowerShell 4.0 attribute that hides parameter from tab-completion.
	http://www.powershellmagazine.com/2013/07/29/pstip-hiding-parameters-from-tab-completion/

.PARAMETER ValueFromPipeline
	If specified, set the ValueFromPipeline attribute for this dynamic parameter

.PARAMETER ValueFromPipelineByPropertyName
	If specified, set the ValueFromPipelineByPropertyName attribute for this dynamic parameter

.PARAMETER ValueFromRemainingArguments
	If specified, set the ValueFromRemainingArguments attribute for this dynamic parameter

.PARAMETER ParameterSetName
	If specified, set the ParameterSet attribute for this dynamic parameter. By default parameter is added to all parameters sets.

.PARAMETER AllowNull
	If specified, set the AllowNull attribute of this dynamic parameter

.PARAMETER AllowEmptyString
	If specified, set the AllowEmptyString attribute of this dynamic parameter

.PARAMETER AllowEmptyCollection
	If specified, set the AllowEmptyCollection attribute of this dynamic parameter

.PARAMETER ValidateNotNull
	If specified, set the ValidateNotNull attribute of this dynamic parameter

.PARAMETER ValidateNotNullOrEmpty
	If specified, set the ValidateNotNullOrEmpty attribute of this dynamic parameter

.PARAMETER ValidateRange
	If specified, set the ValidateRange attribute of this dynamic parameter

.PARAMETER ValidateLength
	If specified, set the ValidateLength attribute of this dynamic parameter

.PARAMETER ValidatePattern
	If specified, set the ValidatePattern attribute of this dynamic parameter

.PARAMETER ValidateScript
	If specified, set the ValidateScript attribute of this dynamic parameter

.PARAMETER ValidateSet
	If specified, set the ValidateSet attribute of this dynamic parameter

.PARAMETER Dictionary
	If specified, add resulting RuntimeDefinedParameter to an existing RuntimeDefinedParameterDictionary.
	Appropriate for custom dynamic parameters creation.

	If not specified, create and return a RuntimeDefinedParameterDictionary
	Aappropriate for a simple dynamic parameter creation.

.EXAMPLE
	Create one dynamic parameter.

	This example illustrates the use of New-DynamicParameter to create a single dynamic parameter.
	The Drive's parameter ValidateSet is populated with all available volumes on the computer for handy tab completion / intellisense.

	Usage: Get-FreeSpace -Drive <tab>

	function Get-FreeSpace
	{
		[CmdletBinding()]
		Param()
		DynamicParam
		{
			# Get drive names for ValidateSet attribute
			$DriveList = ([System.IO.DriveInfo]::GetDrives()).Name

			# Create new dynamic parameter
			New-DynamicParameter -Name Drive -ValidateSet $DriveList -Type ([array]) -Position 0 -Mandatory
		}

		Process
		{
			# Dynamic parameters don't have corresponding variables created,
			# you need to call New-DynamicParameter with CreateVariables switch to fix that.
			New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

			$DriveInfo = [System.IO.DriveInfo]::GetDrives() | Where-Object {$Drive -contains $_.Name}
			$DriveInfo |
				ForEach-Object {
					if(!$_.TotalFreeSpace)
					{
						$FreePct = 0
					}
					else
					{
						$FreePct = [System.Math]::Round(($_.TotalSize / $_.TotalFreeSpace), 2)
					}
					New-Object -TypeName psobject -Property @{
						Drive = $_.Name
						DriveType = $_.DriveType
						'Free(%)' = $FreePct
					}
				}
		}
	}

.EXAMPLE
	Create several dynamic parameters not using custom RuntimeDefinedParameterDictionary (requires piping).

	In this example two dynamic parameters are created. Each parameter belongs to the different parameter set, so they are mutually exclusive.

	The Drive's parameter ValidateSet is populated with all available volumes on the computer.
	The DriveType's parameter ValidateSet is populated with all available drive types.

	Usage: Get-FreeSpace -Drive <tab>
		or
	Usage: Get-FreeSpace -DriveType <tab>

	Parameters are defined in the array of hashtables, which is then piped through the New-Object to create PSObject and pass it to the New-DynamicParameter function.
	Because of piping, New-DynamicParameter function is able to create all parameters at once, thus eliminating need for you to create and pass external RuntimeDefinedParameterDictionary to it.

	function Get-FreeSpace
	{
		[CmdletBinding()]
		Param()
		DynamicParam
		{
			# Array of hashtables that hold values for dynamic parameters
			$DynamicParameters = @(
				@{
					Name = 'Drive'
					Type = [array]
					Position = 0
					Mandatory = $true
					ValidateSet = ([System.IO.DriveInfo]::GetDrives()).Name
					ParameterSetName = 'Drive'
				},
				@{
					Name = 'DriveType'
					Type = [array]
					Position = 0
					Mandatory = $true
					ValidateSet = [System.Enum]::GetNames('System.IO.DriveType')
					ParameterSetName = 'DriveType'
				}
			)

			# Convert hashtables to PSObjects and pipe them to the New-DynamicParameter,
			# to create all dynamic paramters in one function call.
			$DynamicParameters | ForEach-Object {New-Object PSObject -Property $_} | New-DynamicParameter
		}
		Process
		{
			# Dynamic parameters don't have corresponding variables created,
			# you need to call New-DynamicParameter with CreateVariables switch to fix that.
			New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

			if($Drive)
			{
				$Filter = {$Drive -contains $_.Name}
			}
			elseif($DriveType)
			{
				$Filter =  {$DriveType -contains  $_.DriveType}
			}

			$DriveInfo = [System.IO.DriveInfo]::GetDrives() | Where-Object $Filter
			$DriveInfo |
				ForEach-Object {
					if(!$_.TotalFreeSpace)
					{
						$FreePct = 0
					}
					else
					{
						$FreePct = [System.Math]::Round(($_.TotalSize / $_.TotalFreeSpace), 2)
					}
					New-Object -TypeName psobject -Property @{
						Drive = $_.Name
						DriveType = $_.DriveType
						'Free(%)' = $FreePct
					}
				}
		}
	}

.EXAMPLE
	Create several dynamic parameters, with multiple Parameter Sets, not using custom RuntimeDefinedParameterDictionary (requires piping).

	In this example three dynamic parameters are created. Two of the parameters are belong to the different parameter set, so they are mutually exclusive.
	One of the parameters belongs to both parameter sets.

	The Drive's parameter ValidateSet is populated with all available volumes on the computer.
	The DriveType's parameter ValidateSet is populated with all available drive types.
	The DriveType's parameter ValidateSet is populated with all available drive types.
	The Precision's parameter controls number of digits after decimal separator for Free Space percentage.

	Usage: Get-FreeSpace -Drive <tab> -Precision 2
		or
	Usage: Get-FreeSpace -DriveType <tab> -Precision 2

	Parameters are defined in the array of hashtables, which is then piped through the New-Object to create PSObject and pass it to the New-DynamicParameter function.
	If parameter with the same name already exist in the RuntimeDefinedParameterDictionary, a new Parameter Set is added to it.
	Because of piping, New-DynamicParameter function is able to create all parameters at once, thus eliminating need for you to create and pass external RuntimeDefinedParameterDictionary to it.

	function Get-FreeSpace
	{
		[CmdletBinding()]
		Param()
		DynamicParam
		{
			# Array of hashtables that hold values for dynamic parameters
			$DynamicParameters = @(
				@{
					Name = 'Drive'
					Type = [array]
					Position = 0
					Mandatory = $true
					ValidateSet = ([System.IO.DriveInfo]::GetDrives()).Name
					ParameterSetName = 'Drive'
				},
				@{
					Name = 'DriveType'
					Type = [array]
					Position = 0
					Mandatory = $true
					ValidateSet = [System.Enum]::GetNames('System.IO.DriveType')
					ParameterSetName = 'DriveType'
				},
				@{
					Name = 'Precision'
					Type = [int]
					# This will add a Drive parameter set to the parameter
					Position = 1
					ParameterSetName = 'Drive'
				},
				@{
					Name = 'Precision'
					# Because the parameter already exits in the RuntimeDefinedParameterDictionary,
					# this will add a DriveType parameter set to the parameter.
					Position = 1
					ParameterSetName = 'DriveType'
				}
			)

			# Convert hashtables to PSObjects and pipe them to the New-DynamicParameter,
			# to create all dynamic paramters in one function call.
			$DynamicParameters | ForEach-Object {New-Object PSObject -Property $_} | New-DynamicParameter
		}
		Process
		{
			# Dynamic parameters don't have corresponding variables created,
			# you need to call New-DynamicParameter with CreateVariables switch to fix that.
			New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

			if($Drive)
			{
				$Filter = {$Drive -contains $_.Name}
			}
			elseif($DriveType)
			{
				$Filter = {$DriveType -contains  $_.DriveType}
			}

			if(!$Precision)
			{
				$Precision = 2
			}

			$DriveInfo = [System.IO.DriveInfo]::GetDrives() | Where-Object $Filter
			$DriveInfo |
				ForEach-Object {
					if(!$_.TotalFreeSpace)
					{
						$FreePct = 0
					}
					else
					{
						$FreePct = [System.Math]::Round(($_.TotalSize / $_.TotalFreeSpace), $Precision)
					}
					New-Object -TypeName psobject -Property @{
						Drive = $_.Name
						DriveType = $_.DriveType
						'Free(%)' = $FreePct
					}
				}
		}
	}

.Example
	Create dynamic parameters using custom dictionary.

	In case you need more control, use custom dictionary to precisely choose what dynamic parameters to create and when.
	The example below will create DriveType dynamic parameter only if today is not a Friday:

	function Get-FreeSpace
	{
		[CmdletBinding()]
		Param()
		DynamicParam
		{
			$Drive = @{
				Name = 'Drive'
				Type = [array]
				Position = 0
				Mandatory = $true
				ValidateSet = ([System.IO.DriveInfo]::GetDrives()).Name
				ParameterSetName = 'Drive'
			}

			$DriveType =  @{
				Name = 'DriveType'
				Type = [array]
				Position = 0
				Mandatory = $true
				ValidateSet = [System.Enum]::GetNames('System.IO.DriveType')
				ParameterSetName = 'DriveType'
			}

			# Create dictionary
			$DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

			# Add new dynamic parameter to dictionary
			New-DynamicParameter @Drive -Dictionary $DynamicParameters

			# Add another dynamic parameter to dictionary, only if today is not a Friday
			if((Get-Date).DayOfWeek -ne [DayOfWeek]::Friday)
			{
				New-DynamicParameter @DriveType -Dictionary $DynamicParameters
			}

			# Return dictionary with dynamic parameters
			$DynamicParameters
		}
		Process
		{
			# Dynamic parameters don't have corresponding variables created,
			# you need to call New-DynamicParameter with CreateVariables switch to fix that.
			New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

			if($Drive)
			{
				$Filter = {$Drive -contains $_.Name}
			}
			elseif($DriveType)
			{
				$Filter =  {$DriveType -contains  $_.DriveType}
			}

			$DriveInfo = [System.IO.DriveInfo]::GetDrives() | Where-Object $Filter
			$DriveInfo |
				ForEach-Object {
					if(!$_.TotalFreeSpace)
					{
						$FreePct = 0
					}
					else
					{
						$FreePct = [System.Math]::Round(($_.TotalSize / $_.TotalFreeSpace), 2)
					}
					New-Object -TypeName psobject -Property @{
						Drive = $_.Name
						DriveType = $_.DriveType
						'Free(%)' = $FreePct
					}
				}
		}
	}
#>
Function New-DynamicParameter {
	[CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'DynamicParameter')]
	Param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[ValidateNotNullOrEmpty()]
		[string]$Name,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[System.Type]$Type = [int],

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[string[]]$Alias,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[switch]$Mandatory,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[int]$Position,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[string]$HelpMessage,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[switch]$DontShow,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[switch]$ValueFromPipeline,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[switch]$ValueFromPipelineByPropertyName,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[switch]$ValueFromRemainingArguments,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[string]$ParameterSetName = '__AllParameterSets',

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[switch]$AllowNull,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[switch]$AllowEmptyString,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[switch]$AllowEmptyCollection,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[switch]$ValidateNotNull,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[switch]$ValidateNotNullOrEmpty,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[ValidateCount(2,2)]
		[int[]]$ValidateCount,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[ValidateCount(2,2)]
		[int[]]$ValidateRange,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[ValidateCount(2,2)]
		[int[]]$ValidateLength,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[ValidateNotNullOrEmpty()]
		[string]$ValidatePattern,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[ValidateNotNullOrEmpty()]
		[scriptblock]$ValidateScript,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[ValidateNotNullOrEmpty()]
		[string[]]$ValidateSet,

		[Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({
			if(!($_ -is [System.Management.Automation.RuntimeDefinedParameterDictionary]))
			{
				Throw 'Dictionary must be a System.Management.Automation.RuntimeDefinedParameterDictionary object'
			}
			$true
		})]
		$Dictionary = $false,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'CreateVariables')]
		[switch]$CreateVariables,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'CreateVariables')]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({
			# System.Management.Automation.PSBoundParametersDictionary is an internal sealed class,
			# so one can't use PowerShell's '-is' operator to validate type.
			if($_.GetType().Name -ne 'PSBoundParametersDictionary')
			{
				Throw 'BoundParameters must be a System.Management.Automation.PSBoundParametersDictionary object'
			}
			$true
		})]
		$BoundParameters
	)

	Begin
	{
		Write-Verbose 'Creating new dynamic parameters dictionary'
		$InternalDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary

		Write-Verbose 'Getting common parameters'
		function _temp { [CmdletBinding()] Param() }
		$CommonParameters = (Get-Command _temp).Parameters.Keys
	}

	Process
	{
		if($CreateVariables)
		{
			Write-Verbose 'Creating variables from bound parameters'
			Write-Debug 'Picking out bound parameters that are not in common parameters set'
			$BoundKeys = $BoundParameters.Keys | Where-Object { $CommonParameters -notcontains $_ }

			foreach($Parameter in $BoundKeys)
			{
				Write-Debug "Setting existing variable for dynamic parameter '$Parameter' with value '$($BoundParameters.$Parameter)'"
				Set-Variable -Name $Parameter -Value $BoundParameters.$Parameter -Scope 1 -Force
			}
		}
		else
		{
			Write-Verbose 'Looking for cached bound parameters'
			Write-Debug 'More info: https://beatcracker.wordpress.com/2014/12/18/psboundparameters-pipeline-and-the-valuefrompipelinebypropertyname-parameter-attribute'
			$StaleKeys = @()
			$StaleKeys = $PSBoundParameters.GetEnumerator() |
						ForEach-Object {
							if($_.Value.PSobject.Methods.Name -match '^Equals$')
							{
								# If object has Equals, compare bound key and variable using it
								if(!$_.Value.Equals((Get-Variable -Name $_.Key -ValueOnly -Scope 0)))
								{
									$_.Key
								}
							}
							else
							{
								# If object doesn't has Equals (e.g. $null), fallback to the PowerShell's -ne operator
								if($_.Value -ne (Get-Variable -Name $_.Key -ValueOnly -Scope 0))
								{
									$_.Key
								}
							}
						}
			if($StaleKeys)
			{
				[string[]]"Found $($StaleKeys.Count) cached bound parameters:" +  $StaleKeys | Write-Debug
				Write-Verbose 'Removing cached bound parameters'
				$StaleKeys | ForEach-Object {[void]$PSBoundParameters.Remove($_)}
			}

			# Since we rely solely on $PSBoundParameters, we don't have access to default values for unbound parameters
			Write-Verbose 'Looking for unbound parameters with default values'

			Write-Debug 'Getting unbound parameters list'
			$UnboundParameters = (Get-Command -Name ($PSCmdlet.MyInvocation.InvocationName)).Parameters.GetEnumerator()  |
										# Find parameters that are belong to the current parameter set
										Where-Object { $_.Value.ParameterSets.Keys -contains $PsCmdlet.ParameterSetName } |
											Select-Object -ExpandProperty Key |
												# Find unbound parameters in the current parameter set
												Where-Object { $PSBoundParameters.Keys -notcontains $_ }

			# Even if parameter is not bound, corresponding variable is created with parameter's default value (if specified)
			Write-Debug 'Trying to get variables with default parameter value and create a new bound parameter''s'
			$tmp = $null
			foreach($Parameter in $UnboundParameters)
			{
				$DefaultValue = Get-Variable -Name $Parameter -ValueOnly -Scope 0
				if(!$PSBoundParameters.TryGetValue($Parameter, [ref]$tmp) -and $DefaultValue)
				{
					$PSBoundParameters.$Parameter = $DefaultValue
					Write-Debug "Added new parameter '$Parameter' with value '$DefaultValue'"
				}
			}

			if($Dictionary)
			{
				Write-Verbose 'Using external dynamic parameter dictionary'
				$DPDictionary = $Dictionary
			}
			else
			{
				Write-Verbose 'Using internal dynamic parameter dictionary'
				$DPDictionary = $InternalDictionary
			}

			Write-Verbose "Creating new dynamic parameter: $Name"

			# Shortcut for getting local variables
			$GetVar = {Get-Variable -Name $_ -ValueOnly -Scope 0}

			# Strings to match attributes and validation arguments
			$AttributeRegex = '^(Mandatory|Position|ParameterSetName|DontShow|HelpMessage|ValueFromPipeline|ValueFromPipelineByPropertyName|ValueFromRemainingArguments)$'
			$ValidationRegex = '^(AllowNull|AllowEmptyString|AllowEmptyCollection|ValidateCount|ValidateLength|ValidatePattern|ValidateRange|ValidateScript|ValidateSet|ValidateNotNull|ValidateNotNullOrEmpty)$'
			$AliasRegex = '^Alias$'

			Write-Debug 'Creating new parameter''s attirubutes object'
			$ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute

			Write-Debug 'Looping through the bound parameters, setting attirubutes...'
			switch -regex ($PSBoundParameters.Keys)
			{
				$AttributeRegex
				{
					Try
					{
						$ParameterAttribute.$_ = . $GetVar
						Write-Debug "Added new parameter attribute: $_"
					}
					Catch
					{
						$_
					}
					continue
				}
			}

			if($DPDictionary.Keys -contains $Name)
			{
				Write-Verbose "Dynamic parameter '$Name' already exist, adding another parameter set to it"
				$DPDictionary.$Name.Attributes.Add($ParameterAttribute)
			}
			else
			{
				Write-Verbose "Dynamic parameter '$Name' doesn't exist, creating"

				Write-Debug 'Creating new attribute collection object'
				$AttributeCollection = New-Object -TypeName Collections.ObjectModel.Collection[System.Attribute]

				Write-Debug 'Looping through bound parameters, adding attributes'
				switch -regex ($PSBoundParameters.Keys)
				{
					$ValidationRegex
					{
						Try
						{
							$ParameterOptions = New-Object -TypeName "System.Management.Automation.${_}Attribute" -ArgumentList (. $GetVar) -ErrorAction Stop
							$AttributeCollection.Add($ParameterOptions)
							Write-Debug "Added attribute: $_"
						}
						Catch
						{
							$_
						}
						continue
					}

					$AliasRegex
					{
						Try
						{
							$ParameterAlias = New-Object -TypeName System.Management.Automation.AliasAttribute -ArgumentList (. $GetVar) -ErrorAction Stop
							$AttributeCollection.Add($ParameterAlias)
							Write-Debug "Added alias: $_"
							continue
						}
						Catch
						{
							$_
						}
					}
				}

				Write-Debug 'Adding attributes to the attribute collection'
				$AttributeCollection.Add($ParameterAttribute)

				Write-Debug 'Finishing creation of the new dynamic parameter'
				$Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList @($Name, $Type, $AttributeCollection)

				Write-Debug 'Adding dynamic parameter to the dynamic parameter dictionary'
				$DPDictionary.Add($Name, $Parameter)
			}
		}
	}

	End
	{
		if(!$CreateVariables -and !$Dictionary)
		{
			Write-Verbose 'Writing dynamic parameter dictionary to the pipeline'
			$DPDictionary
		}
	}
}
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
# -----------------------------------------------------------------------------------------------------------------
# Format-FileInfo
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  The formatting handler for FileSystemInfo objects.
.Description
  The formatting handler for FileSystemInfo objects. This function is injected into Out-Default. 

  It does not have much utility outside of Out-Default. But, it can be used to format any FileSystemInfo object. 
  As this formatter becomes default, it can be overridden by explicity calling a formatter. For example, 
  `Get-ChildItem | Format-Table` will output the regular output. 
.Parameter Obj
  The FileSystemInfo object to format.
.Example
  PS> Format-FileInfo ([FileInfo] $Profile) 
    Returns a colorized and formatted representation of the current user's profile file.
.Notes
  This function is really simple and, as such, does not have a cmdletbinding. 
#>
function Format-FileInfo ([System.IO.FileSystemInfo] $Obj) { 

    Format-FileInfoHeader $Obj

    $nameColor = FileColor $Obj
    $linkTarget = LinkTargetInfo $Obj
    $linkTargetColor = LinkTargetColor $Obj
    $linker = 
        if (Test-Exists $linkTarget) {
            '->'
        }
    $length = 
        if ($Obj -is [System.IO.FileInfo]) {
            $Obj.Length
        }
    
    '{0, -8}' -f $Obj.Mode | Write-Host -NoNewLine
    '{0, 15}  {1, 8}' -f $Obj.LastWriteTime.ToString('d'), $Obj.LastWriteTime.ToString('t') | Write-Host -NoNewLine
    '{0, 11}' -f (Write-FileLength $length) | Write-Host -NoNewLine

    if (Test-Exists $linker) {
        ' {0}' -f $Obj.Name | Write-Host -Color $nameColor -NoNewLine
        ' {0} ' -f $linker | Write-Host -NoNewLine
        '{0}' -f $linkTarget | Write-Host -Color $linkTargetColor
    }
    else {
        ' {0}' -f $Obj.Name | Write-Host -Color $nameColor
    }
}
# -----------------------------------------------------------------------------------------------------------------
# Format-MatchInfo
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  The formatting handler for MatchInfo objects.
.Description
  The formatting handler for MatchInfo objects. This function is injected into Out-Default. 

  It does not have much utility outside of Out-Default. But, it can be used to format any MatchInfo object. 
  As this formatter becomes default, it can be overridden by explicity calling a formatter. For example, 
  `Select-String Test $File | Format-Custom` will output the regular output. 
.Parameter Match
  The MatchInfo object to format.
.Example
  PS> Format-MatchInfo $Match
    Returns a colorized and formatted representation of the MatchInfo in Match.
.Notes
  This function is really simple and, as such, does not have a cmdletbinding. 
  It has been shamefully stolen from David Lindblad (PSColor).
#>
function Format-MatchInfo ([Microsoft.PowerShell.Commands.MatchInfo] $Match) {

    if ($Match.Context) {
        Format-MatchContext $Match PreContext
        Write-Host '> ' -NoNewLine
    }

    Write-Host $Match.RelativePath($PWD) (PathColor Match) -NoNewline
    Write-Host : -NoNewline
    Write-Host $Match.LineNumber (LineNumberColor Match) -NoNewline
    Write-Host : -NoNewline
    Write-Host $Match.Line (LineColor Match) 

    if ($Match.Context) {
        Format-MatchContext $Match PostContext
    }
} 
# -----------------------------------------------------------------------------------------------------------------
# Get-Tulips
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Returns the tuliPS configuration hashtable.
.Description
  Returns the tuliPS configuration hashtable. Allows the user to manually interact with tuliPS configuration.   

  Because the tuliPS configuration object is a hashtable, if you copy it and manipulate an entry, you will 
  manipulate the original object. If you are comfortable with hashtables, this is a nice, easy way to change
  tuliPS configuration on the fly.
.Notes
  File extension information is stored as an array of hashtables. This makes dictionary searching easier to code
  and read. However, it can make manipulating the config object by hand a little hard. There are tags added
  for some convenience. 

  Just keep in mind that the extension data is a hashtable[]. 
  This lists of extensions in each hashtable should be stored as a string[]. 
.Example
  PS> Get-Tulips

  The only way to use it.
.Example
  PS>$TuliPSConfig = Get-Tulips
  PS>$TuliPSConfig.File.Directory.ForegroundColor = 'Green'

  Changes the color of a displayed directory to Green. 
.Example
  PS>$TuliPSConfig.File.Extensions.Where{$_.Tag -eq 'Text'}.Extensions += '.json'

  Adds the '.json' file type to an existing extensions set. This example demonstrates how existing 
  extension sets can be filtered and manipulated.
.Example
  PS>$TuliPSConfig.File.Extensions +=
        @{
            Tag = 'MyExts'
            Extensions = '.iso', '.cd'
            ForegroundColor = 'DarkRed'
            BackgroundColor = 'Yellow'
        }

  This example demonstrates how to add an entire extension set by hand. Note the keys, as those SHOULD be
  copied exactly the same to ensure tuliPS can access the set properly. Currently these sets are not validated :(
  Use `Set-Tulips` to ensure extensions sets are proper.
.Inputs
  None
.Outputs
  System.Collections.Hashtable
#>
function Get-Tulips {
    return $Tulips
}
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
# -----------------------------------------------------------------------------------------------------------------
# Invoke-Wrapper
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Invokes the Out-Default command wrapper.
.Description
  Invokes the Out-Default command wrapper.

  If Reset-OutDefault is used, or if the wrapped Out-Default command is accidently removed, invoke the wrapper to
  turn tuliPS formatting back on.

  This is a simple alias function that invokes the wrapping script. It takes no parameters and returns nothing.
.Example
  PS> Invoke-Wrapper
  Only way it can be used.
#>
function Invoke-Wrapper {
    & $WrapperPath 
}
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
# -----------------------------------------------------------------------------------------------------------------
# Reset-Tulips
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Resets the tuliPS config hashtable back to the default settings.
.Description
  Resets the tuliPS config hashtable back to the default settings.

  Oh man, you jacked with the colors and everything is an eye-sore?
  You wow, you totally changed the hashtable to something nonsensical and borked the whole thing!? 
  Don't worry, I got you.
.Example
  PS> Reset-Tulips
  The only way it can be used.
#>
function Reset-Tulips {
    $script:Tulips = Import-PowerShellDataFile $ConfigPath
}
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
