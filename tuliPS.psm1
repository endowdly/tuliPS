<#
 
 ,---------.   ___    _   .---.    .-./`) .-------.    .-'''-.  
 \          \.'   |  | |  | ,_|    \ .-.')\  _(`)_ \  / _     \ 
  `--.  ,---'|   .'  | |,-./  )    / `-' \| (_ o._)| (`' )/`--' 
     |   \   .'  '_  | |\  '_ '`)   `-'`"`|  (_,_) /(_ o _).    
     :_ _:   '   ( \.-.| > (_)  )   .---. |   '-.-'  (_,_). '.  
     (_I_)   ' (`. _` /|(  .  .-'   |   | |   |     .---.  \  : 
    (_(=)_)  | (_ (_) _) `-'`-'|___ |   | |   |     \    `-'  | 
     (_I_)    \ /  . \ /  |        \|   | /   )      \       /  
     '---'     ``-'`-''   `--------`'---' `---'       `-...-'   
                                                                
 
#>

<# 

   ___                      
  / __| ___ _  _ _ _ __ ___ 
  \__ \/ _ \ || | '_/ _/ -_)
  |___/\___/\_,_|_| \__\___|
 

#>

foreach ($folder in 'Public', 'Internal', 'Classes') {

    $folderPath = Join-Path $PSScriptRoot $folder

    if (Test-Path $folderPath) {

        $files = Get-ChildItem -Path $folderPath -Filter '*.ps1' 

        foreach ($file in $files) { 
            . $file.FullName
        }
    }    
} 

<#
 
  __   __        _      _    _        
  \ \ / /_ _ _ _(_)__ _| |__| |___ ___
   \ V / _` | '_| / _` | '_ \ / -_|_-<
    \_/\__,_|_| |_\__,_|_.__/_\___/__/
                                      
 
#>

$ConfigPath = Join-Path $PSScriptRoot tuliPS.config.psd1
$Tulips = Import-PowerShellDataFile $ConfigPath 
$OutDefault = Get-Command Out-Default -CommandType Cmdlet
$TypeTracker = @{
    'System.IO.FileSystemInfo'                = { Format-FileInfo $_ }
    'Microsoft.PowerShell.Commands.MatchInfo' = { Format-MatchInfo $_ } 
}
$TypeTrackerCheckpoint = $TypeTracker.Clone()
$NewProcess = Get-ProcessBlock


<#
 
    ___                              _    
   / __|___ _ __  _ __  __ _ _ _  __| |___
  | (__/ _ \ '  \| '  \/ _` | ' \/ _` (_-<
   \___\___/_|_|_|_|_|_\__,_|_||_\__,_/__/
                                          
 
#>

Invoke-Wrapper

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Reset-OutDefault
}
