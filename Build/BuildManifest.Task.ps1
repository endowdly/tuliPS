function BuildManifest {
    param()

    try { 
        Copy-Item $SourceManifest -Destination "$ManifestPath" -ErrorAction Stop > $null
    }
    catch {
        $Result.Errors++ 
        Write-Error $_
    }
    
    if (Test-Path "$ManifestPath") {
        Update-ModuleManifest "$ManifestPath" -ModuleVersion $Version > $null
    }
} 