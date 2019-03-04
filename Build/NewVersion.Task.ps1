function NewVersion {
    $content = @"
@{
    Version = '$( $Nebula.BuildVersion )'
}
"@

    $versionPath = Join-Path $BuildRoot .version 

    $content | Out-File $versionPath 

    $script:Version = $Nebula.BuildVersion -as [Version]
}