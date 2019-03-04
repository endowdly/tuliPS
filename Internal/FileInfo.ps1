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

