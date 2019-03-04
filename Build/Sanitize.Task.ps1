function Sanitize {
    [DependsOn('Clean')]
    param()

    '.version', '.fingerprint' | 
        ForEach-Object {
            Join-Path $BuildRoot $_
        } | 
        Remove-Item -Force -ErrorAction SilentlyContinue | 
        Out-Null 
}