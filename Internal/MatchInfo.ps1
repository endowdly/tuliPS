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