@{
    # Defaults to the name of the build root directory if empty string
    ModuleName = ''

    # Use either absolute paths or paths relative to nebula.ps1
    Paths = @{
        BuildRoot = '..'
        Source = '..'
        Output = '../Output'
        Nursery = '.'        
    }

    # Folders in source to import non-recursively
    Imports = 'Internal', 'Public' 

    # Copies these files to the destination folder 
    Dependencies = '../tulips.config.psd1'

    # Use FirstBuild to use this version
    BuildVersion = '1.0.0'

    # Use if you require test to cover a specific amount 
    CodeCoverage = 0.0
}