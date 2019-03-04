function Test {
    [DependsOn('Analyze')]
    param()

    # Pester does not have a WhatIf parameter, so check on the preference manually

    if ($WhatIfPreference -eq $true) {
        Write-Verbose "Skipping Tests"
    }
    else {
        $pesterParams = @{ 
            PassThru = $true 
            Quiet = $true
            Script = Join-Path $BuildRoot Tests/*
        } 
        
        if ($Nebula.CodeCoverage -gt 0.0) { 
            $pesterParams.CodeCoverage = "$SourceModule"
        } 
        
        $pester = Invoke-Pester @pesterParams
        
        function pester {
            if ($pester.FailedCount -ne 1) {
                "$( $pester.FailedCount ) Pester tests"
            }
            else {
                "$( $pester.FailedCount ) Pester test"
            }
        }
        if ($pester.FailedCount -gt 0) { 
            Write-Error "Failed $( pester )"
            $Result.Errors += $pester.FailedCount
        } 
        
        if ($pester.CodeCoverage.NumberOfCommandsAnalyzed -gt 0) { 
            $codeCoverage =
                $pester.CodeCoverage.NumberOfCommandsExecuted / $pester.CodeCoverage.NumberOfCommandsAnalyzed 
    
            if ($codeCoverage -lt $Nebula.CodeCoverage) { 
                'Code Coverage {0:P} below {1:P}' -f $codeCoverage, $Nebula.CodeCoverage | Write-Warning
                $Result.Warnings++ 
            } 
        }
    }
}