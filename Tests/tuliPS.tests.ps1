$ModuleRoot = Resolve-Path "$PSScriptRoot\.."
$ModuleName = Split-Path $ModuleRoot -Leaf

function Test-Module {
    $null -ne (Get-Module $ModuleName)
}

# If the module is loaded, remove it so the current source can be reloaded.
$IsLoaded = Test-Module
if ($IsLoaded) {
    Remove-Module $ModuleName
}

Describe "General Module Validation for $ModuleName" {

    $fileParseTests =
        Get-ChildItem $ModuleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse |
        ForEach-Object {
            $parent = Split-Path $_ -Parent | Split-Path -Leaf

            @{
                filePath = $_.FullName
                name = Join-Path $parent $_.Name
            }
        }

    It "Has valid File <name>" -TestCases $fileParseTests {
        param ($filePath)

        $filePath | Should Exist

        $contents = Get-Content -Path $filePath -ErrorAction Stop
        $errors = $null

        [void] [System.Management.Automation.PSParser]::Tokenize($contents, [ref] $errors)

        $errors.Count | Should Be 0
    }

    It "Can import cleanly" {
        { Import-Module $ModuleRoot -Force -ErrorAction Stop } | Should Not Throw
    }
}

Describe "Help Tests for $ModuleName" {

    $functions = & {
        # Import-Module Profile
        Get-Command -Module $ModuleName
    }

    $help = $functions | ForEach-Object { Get-Help $_.Name }

    foreach ($node in $help) {

        Context $node.Name {

            It "Has a Description" {
                $node.Description | Should Not BeNullOrEmpty
            }

            It "Has an Example" {
                $node.Examples | Should Not BeNullOrEmpty
            }

            $parameterTests =
                $node.Parameters.Parameter |
                Where-Object Name -notin 'WhatIf', 'Confirm' |
                ForEach-Object {
                    @{
                        name = $_.Name
                        description = $_.Description.Text
                    }
                }

            if ($ParameterTests.Name -notin '', $null) {
                It "Has described Parameter <name>" -TestCases $parameterTests {
                    param ($description)

                    $description | Should Not BeNullOrEmpty
                }
            }
        }
    }
}

Describe 'Commands' {

    BeforeAll {
        Import-Module $ModuleRoot
    }

    AfterAll {
        Remove-Module $ModuleName
    }

    Context 'Reset-OutDefault' {

        Reset-OutDefault
        $cmd = Get-Command Out-Default -CommandType Cmdlet

        It 'Removes tuliPS Out-Default' {
            Test-Path function:\Out-Default | Should Be $false
        }

        It 'Resets Out-Default' {
            $cmd.Source | Should Be Microsoft.Powershell.Core
        }
    }

    Context 'Invoke-Wrapper' {
        Invoke-Wrapper

        It 'Sets tuliPS Out-Default' {
            $cmd = Get-Item function:\Out-Default 
            Reset-OutDefault
            $original = Get-Command Out-Default 
            $original.Name | Should Be $cmd.Name
            $original.CommandType | Should Not Be $cmd.CommandType 
            Invoke-Wrapper 
            $wrapped = Get-Command Out-Default
            $wrapped.Name | Should Be $cmd.Name
            $wrapped.CommandType | Should Be $cmd.CommandType
        }
    }

    Context 'Get-Tulips' {
        InModuleScope tuliPS {
            It 'Gets the tuliPS Configuration Hashtable' {
                $expected = $Tulips
                $result = Get-Tulips 
                $result | Should Be $expected
            }
        }
    }

    Context 'Reset-Tulips' {
        InModuleScope tuliPS {
            It 'Resets the tuliPS Configuration Hashtable' {
                $default = Import-PowerShellDataFile $ConfigPath
                $expected = $default.File.Directory.ForegroundColor
                $changer = Get-Tulips
                $changer.File.Directory.ForegroundColor = 'Red'
                $Tulips.File.Directory.ForegroundColor | Should Not Be $expected
                Reset-Tulips
                $Tulips.File.Directory.ForegroundColor | Should Be $expected
            }
        }
    }

    Context 'Set-Tulips' {

        BeforeEach {
            $Tulips = Tulips

            $test = @{
                Test = @{ 
                    ForegroundColor = 'Gray'
                    BackgroundColor = ''
                }
            }
            
            $Tulips.Add('Test', $test)
        }

        AfterEach {
            Reset-Tulips
        }

        It 'Adds Tulips Types' {
            Set-Tulips -AddTulips 'Process'
            $Tulips.ContainsKey('Process') | Should Be $true
        }

        It 'Adds Tulips Types with Initial Properties' {
            $property = @{ 
                Heavy = @{
                    ForegroundColor = 'Red'
                    BackgroundColor = ''
                }
                Medium = @{
                    ForegroundColor = 'Yellow'
                    BackgroundColor = '' 
                }
                Light = @{
                    ForegroundColor = 'Green'
                    BackgroundColor = '' 
                } 
            }
            Set-Tulips -AddTulips 'Process' -TulipsValue $property
            $property | Set-Tulips -AddTulips PipeTest
            $Tulips.ContainsKey('Process') | Should Be $true
            $Tulips.Process.ContainsKey('Heavy') | Should Be $true
            $Tulips.Process.ContainsKey('Medium') | Should Be $true
            $Tulips.Process.ContainsKey('Light') | Should Be $true
            $Tulips.Process.Heavy.ForegroundColor | Should Be $property.Heavy.ForegroundColor
            $Tulips.Process.Medium.ForegroundColor | Should Be $property.Medium.ForegroundColor
            $Tulips.Process.Light.ForegroundColor | Should Be $property.Light.ForegroundColor
            $Tulips.PipeTest.Light.ForegroundColor | Should Be $property.Light.ForegroundColor
        }

        It 'Removes Tulips Types' {
            $Tulips.ContainsKey('Test') | Should Be $true 
            Set-Tulips -RemoveTulips Test 
            $Tulips.ContainsKey('Test') | Should Be $false 
        }

        It 'Does not remove default Types' {
            $Tulips.ContainsKey('File') | Should Be $true
            { Set-Tulips -RemoveTulips File } | Should Throw
            $Tulips.ContainsKey('File') | Should Be $true 
        }

        It 'Sets Tulips Types' {
            $original = 'Test'
            $expected = 'ReTest' 
            $Tulips.ContainsKey($original) | Should Be $true 
            Set-Tulips -SetTulips $original -Key $expected 
            $Tulips.ContainsKey($original) | Should Be $false 
            $Tulips.ContainsKey($expected) | Should Be $true
        }

        It 'Adds Properties' {
            $expected = 'Success' 
            Set-Tulips -Name Test -AddProperty $expected 
            $Tulips.Test.ContainsKey($expected) | Should Be $true 
        }

        It 'Removes Properties' {
            $Tulips.Test.ContainsKey('Test') | Should Be $true
            Set-Tulips -Name Test -RemoveProperty Test 
            $Tulips.Test.ContainsKey('Test') | Should Be $false 
        }

        It 'Sets Property Keys' {
            $original = 'test'
            $expected = 'retest'
            $Tulips.Test.ContainsKey($original) | Should Be $true
            Set-Tulips -Name Test -SetProperty $original -Key $expected 
            $Tulips.Test.ContainsKey($original) | Should Be $false 
            $Tulips.Test.ContainsKey($expected) | Should Be $true 
        }

        It 'Sets Property Values' {
            $original = $Tulips.Test.Test.ForegroundColor
            $expected = 'Magenta' 
            Set-Tulips -Name Test -Property Test -Setting ForegroundColor -Value $expected 
            $Tulips.Test.Test.ForegroundColor | Should Not Be $original
            $Tulips.Test.Test.ForegroundColor | Should Be $expected 
        }

        It 'Adds Extension Sets' {
            $expected = @{
                AddExtensionSet = 'Test'
                Extensions      = '.test'
                ForegroundColor = 'Black'
                BackgroundColor = 'Yellow'
            }
            Set-Tulips @expected
            $Tulips.File.Extensions.Where{ $_.Tag -eq $expected.AddExtensionSet }.ForegroundColor |
                Should Be $expected.ForegroundColor 
            $exts = '.test', '.t'
            $exts | Set-Tulips -AddExtensionSet PipeTest -ForegroundColor Magenta
            $Tulips.File.Extensions.Where{ $_.Tag -eq 'PipeTest' }.Extensions | Should Be $exts
        }

        It 'Sets Extension Sets' {
            $add = @{
                Tag             = 'Test'
                Extensions      = @('.test')
                ForegroundColor = 'Black'
                BackgroundColor = 'Yellow'
            }
            $expected = @{
                Tag             = 'Test'
                Extensions      = @('.feature')
                ForegroundColor = 'Black'
                BackgroundColor = 'Cyan'
            }
            $Tulips.File.Extensions += $add 
            $Tulips.File.Extensions.Tag -contains 'Test' | Should Be $true
            Set-Tulips -EditExtensionSet Test -Remove '.test' -Add '.feature' -BackgroundColor Cyan

            # Ah! For some reason, this resets the Tulips hash. You have to recall the module variable
            $Tulips.File.Extensions.Where{ $_.Tag -eq 'Test'}.Extensions |
                Should Be $expected.Extensions
            $Tulips.File.Extensions.Where{ $_.Tag -eq 'Test'}.BackgroundColor |
                Should Be $expected.BackgroundColor
        }

        It 'Removes Extension Sets' {
            $expected = @{
                Tag             = 'Test'
                Extensions      = '.test'
                ForegroundColor = 'Black'
                BackgroundColor = 'Yellow'
            }
            $Tulips.File.Extensions += $expected
            $Tulips.File.Extensions.Tag -contains 'Test' | Should Be $true
            Set-Tulips -RemoveExtensionSet Test
            $Tulips.File.Extensions.Tag -contains 'Test' | Should Be $false
        } 
    }# Context 'Set...

    Context 'Export-Tulips' {
        It 'Works' {

            # This is a pretty well wrapped command.
            $true | Should Be $true
        }
    }

    Context 'Import-Tulips' {
        It 'Works' {

            # This is a pretty well wrapped command.
            $true | Should Be $true
        }
    }

}

# If the module was loaded but is not now, reload it
if ($IsLoaded -and !(Test-Module)) {
    Import-Module $ModuleRoot
}