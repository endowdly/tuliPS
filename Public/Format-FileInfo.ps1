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
