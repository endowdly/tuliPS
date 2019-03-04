function BuildModule {
    [DependsOn('AddDependencies')]
    param()
    
    try {
        Copy-Item -Path $SourceModule -Destination "$ModulePath" -ErrorAction Stop > $null
    }
    catch {
        Write-Error $_ 
        $Result.Errors++
        return 
    }

    foreach ($dir in $Nebula.Imports) {
        $currentDir = Join-Path $BuildRoot $dir

        Write-Verbose "Importing <- $currentDir"

        if (Test-Path $currentDir) {
            $files = Get-ChildItem $currentDir -File -Filter *.ps1 
            
            foreach ($file in $files) {
                Write-Verbose "Adding <- $( $file.Name )"

                Get-Content $file.FullName |
                    Add-Content $ModulePath |
                    Out-Null
            }
        }
    }
}