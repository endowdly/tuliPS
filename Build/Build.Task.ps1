function Build {
    [DependsOn('Init')]
    param()

    Invoke-Task SetVersion
    Invoke-Task BuildModule
    Invoke-Task BuildManifest
}
