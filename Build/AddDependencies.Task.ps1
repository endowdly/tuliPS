function AddDependencies {
    try {
        $Nebula.Dependencies | Copy-Item -Destination "$Destination" -ErrorAction Stop > $null
    }
    catch {
        Write-Error $_
        $Result.Errors++
    }
}