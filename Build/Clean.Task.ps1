function Clean {
    if (Test-Path $Output) { 
        Remove-Item $Output -Recurse -Force -ErrorAction SilentlyContinue > $null 
    }
    else {
        Write-Verbose "$Output does not exist"
    } 
}