#Requires -Version 5.0

function Read-Version {
    $versionPath = Join-Path $BuildRoot .version

    $v = 
        try {
            Import-PowerShellDataFile $versionPath -ErrorAction Stop
        }
        catch {
            Write-Warning "Version file missing; Version pulled from Manifest"
            $Result.Warnings++

            Test-ModuleManifest "$SourceManifest"
        }
    
    $v.Version -as [Version]
}


# Test to see if x is loaded in Session or not
# obj -> bool
function Test-Module ($x) {
    try {
        if (-not (Get-Module $x)) {
            return $false
        }
        $true 
    }
    catch {
        $false 
    }
}


function Get-Fingerprint {
    # Only import the Module if it is not already in Session
    if (-not (Test-Module $ModuleName)) {
        $SourceManifest | Import-Module 
        $CanRemove = $true
    }

    $commandList = Get-Command -Module $ModuleName

    # Only remove the Module if it was not in Session
    if ($CanRemove) {
        Remove-Module $ModuleName -Force
    } 

    Write-Verbose "Calculating Fingerprint for $ModuleName"

    foreach ($command in $commandList) {
        Write-Verbose "Processing Command $( $command.Name.ToString() )"

        $parameters = $command.Parameters.Keys

        if ($parameters.Count -eq 0) {
            '{0}:<Empty>' -f $command.Name
        }
        else { 
            foreach ($parameter in $parameters) {
                '{0}:{1}' -f $command.Name, $command.Parameters.$parameter.Name 
                $command.Parameters.$parameter.Aliases.Foreach{ '{0}:{1}' -f $command.Name, $_ } 
            }
        }
    }# foreach ($command...

}

function NewFingerprint {
    $fingerprintPath = Join-Path $BuildRoot .fingerprint

    if (Test-Path $fingerprintPath) {
        Write-Verbose "Fingerprint exists"
        return
    }

    Get-Fingerprint | Out-File $fingerprintPath
}



function CompareFingerprint {
    [DependsOn('ReadFingerprint')]
    param()

    $This = @{
        BumpType = 'Patch'
        NewFingerPrint = Get-Fingerprint
        OldFingerPrint = $Fingerprint
    }

    Write-Verbose 'New Features:'

    $This.NewFingerPrint |
        Where-Object { $_ -notin $This.OldFingerPrint } | 
        ForEach-Object {
            $This.BumpType = 'Minor'
            Write-Verbose $_.ToString()
        }

    Write-Verbose 'Breaking Changes:'

    $This.OldFingerPrint |
        Where-Object { $_ -notin $This.NewFingerPrint } | 
        ForEach-Object {
            $This.BumpType = 'Major'
            Write-Verbose $_.ToString()
        }

    Write-Verbose "Bump type: $( $This.BumpType )"

    $script:Bump = $This.BumpType 
}

function ReadFingerprint {
    [DependsOn('NewFingerprint')]
    param()

    try {
        $fingerprintPath = Join-Path $BuildRoot .fingerprint 
        $script:Fingerprint = Get-Content $fingerprintPath 
    }
    catch {
        $Result.Errors++
        Write-Error $_
    }
}

function SetVersion {
    [DependsOn('CompareFingerprint')]
    param()

    $versionPath = Join-Path $BuildRoot .version 
    $v = Read-Version

    $script:Version =
        switch ($Bump) {
            Patch { [version]::new($v.Major, $v.Minor, $v.Build+1) }
            Minor { [version]::new($v.Major, $v.Minor+1, 0) }
            Major { [version]::new($v.Major+1, 0, 0) } 
        } 
    
    $content = @"
@{
    Version = '$Version'    
}
"@

    $content | Out-File $versionPath
}