function FirstBuild {
    [DependsOn('Init')]
    param()

    Invoke-Task Test
    Invoke-Task NewVersion
    Invoke-Task BuildModule
    Invoke-Task BuildManifest
}