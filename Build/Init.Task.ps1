function Init {
    [DependsOn('Clean')]
    param()

    if (Test-Path $Destination) {
        Write-Verbose "$Destination exists"
    }
    else { 
        try {
            New-Item -ItemType Directory -Path $Destination -ErrorAction Stop > $null
        }
        catch {
            Write-Error $_
            $Result.Errors++
        }
    } 
}