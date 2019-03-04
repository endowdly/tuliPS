<#
 
  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
 ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
 ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
 ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
 ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 
                                                
 
#>

<# !!! WARNING !!! #> 
<#
    This file is loaded as the default color settings for this module. This file should NOT be modified. 
    To change settings, use `Set-Tulips`. To save settings use `Export-Tulips`. 
    To load settings use `Import-Tulips`. 
#>

@{
    File    = @{
        Directory = @{
            ForegroundColor = 'Blue'
            BackgroundColor = ''
        } 
        Link = @{
            ForegroundColor = 'Cyan'
            BackgroundColor = ''
        } 
        Orphan = @{
            ForegroundColor = 'Cyan'
            BackgroundColor = 'White'
        }
        Missing = @{
            ForegroundColor = 'Black'
            BackgroundColor = ''
        }
        Hidden = @{
            ForegroundColor = 'DarkGray'
            BackgroundColor = ''
        }
        Extensions = @(
            @{
                Tag = 'Code'
                Extensions = @( 
                    '.java'
                    '.c'
                    '.cpp'
                    '.cs'
                    '.js'
                    '.ts'
                    '.fs'
                    '.css'
                    '.html'
                )
                ForegroundColor = 'Magenta'
                BackgroundColor = ''
            }
            @{
                Tag = 'Executable'
                Extensions = @( 
                    '.exe'
                    '.bat'
                    '.cmd'
                    '.py'
                    '.ps1'
                    '.psm1'
                    '.rb'
                )
                ForegroundColor = 'Red'
                BackgroundColor = ''
            }
            @{
                Tag = 'Text'
                Extensions = @( 
                    '.txt'
                    '.cfg'
                    '.conf'
                    '.ini'
                    '.csv'
                    '.log'
                    '.config'
                    '.xml'
                    '.yml'
                    '.md'
                    '.markdown'
                    '.adoc'
                    '.asciidoc' 
                    '.psd1'
                )
                ForegroundColor = 'Yellow'
                BackgroundColor = ''
            }
            @{
                Tag = 'Compressed'
                Extensions = @( 
                    '.zip'
                    '.tar'
                    '.gz'
                    '.rar'
                    '.jar'
                    '.war'
                    '.7z'
                    '.7zip'
                )
                ForegroundColor = 'Green'
                BackgroundColor = ''
            }
        )
    }
    Match   = @{ 
        Path       = @{ 
            ForegroundColor = 'Cyan'
            BackgroundColor = ''
        } 
        LineNumber = @{ 
            ForegroundColor = 'Yellow'
            BackgroundColor = ''
        }
        Line       = @{ 
            ForegroundColor = 'Green'
            BackgroundColor = ''
        }
    }
    NoMatch = @{ 
        Path       = @{ 
            ForegroundColor = 'DarkGray'
            BackgroundColor = ''
        } 
        LineNumber = @{ 
            ForegroundColor = 'DarkGray'
            BackgroundColor = ''
        }
        Line       = @{ 
            ForegroundColor = 'White'
            BackgroundColor = ''
        }
    }
}