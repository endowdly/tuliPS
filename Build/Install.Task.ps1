# Gets the local Module path, if it exists
# unit -> string
function Get-LocalModulePath { 
    $env:PSModulePath -split ';' | 
        Where-Object { $_.StartsWith($env:USERPROFILE) -and $_.Contains('WindowsPowerShell') } | 
        Convert-Path 
}

function Install {
    $from = "$Destination"
    $to = Get-LocalModulePath

    try {
        Copy-Item $from $to -Recurse -Force -ErrorAction Stop
    }
    catch {
        Write-Warning $_
        $Result.Warnings++ 
    } 
}