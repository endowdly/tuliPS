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
