# Runs PSScriptAnaylzer

function Analyze {
    $AnalyzeParams = @{
        IncludeDefaultRules = $true
        Path                = "$BuildRoot/*"
        Settings            = Join-Path $BuildRoot PSScriptAnalyzerSettings.psd1
    }

    $analysis = Invoke-ScriptAnalyzer @AnalyzeParams
    $warnings = $analysis.Where{ $_.Severity -eq 'Warning' }.Count
    $errors = $analysis.Where{ $_.Severity -eq 'Error' }.Count 
    $Result.Warnings += $warnings
    $Result.Errors += $errors

    function warnings {
        if ($warnings -ne 1) {
            "$warnings warnings"
        }
        else {
            "$warnings warning"
        }
    }

    function errors {
        if ($errors -ne 1) {
            "$errors errors"
        }
        else {
            "$errors error"
        }
    }
    
    if ($analysis.Count -gt 0) {
        Write-Verbose "PSScriptAnalyzer returned $( warnings ) and $( errors )"
    }
}