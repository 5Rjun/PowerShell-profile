using namespace System.Management.Automation
using namespace System.Management.Automation.Language
 
if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadLine
}

##Starship-Prompt##
Invoke-Expression (&starship init powershell)
$ENV:STARSHIP_CONFIG = "$HOME\.config\starship.toml"



Import-Module -Name Terminal-Icons

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLIneOption -EditMode Windows

##Alias##
Set-Alias -Name vim -Value nvim
Set-Alias -Name eth -Value get-netadapter
Set-Alias -Name netprofile -value Get-NetConnectionProfile
Set-Alias -Name refresh -value refreshenv

##Functions##
function .. {cd .. }
function ... {cd ../..}
function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }


function winenv {
    rundll32.exe sysdm.cpl,EditEnvironmentVariables
    }
function find-file($name) {
    ls -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
        $place_path =$_.directory 
        echo "${palce_path}\${_}"
        }
                }
function reload-profile {
        & $profile
        }
function pkill($name) {
    ps $name -ErrorAction SilentlyContinue | kill
    }
function pgrep($name) {
    ps $name
    }
function Get-PubIP {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}

# Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
function dirs {
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
    } else {
        Get-ChildItem -Recurse | Foreach-Object FullName
    }
}

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

# To Copy Contents of a text file
function dcopy($name) {type  $name | clip}

##Scoop Functions##
function cleanup { 
    scoop cleanup *
    }
function install($name) {
    scoop install $name
    }
function update($name) { 
    scoop update $name
    }
function search($name) {
    scoop search $name
    }
function uninstall($name) {
    scoop uninstall $name
    }

##Winget Functions##
function wsearch($name) {
    winget search $name
    }
function winstall($name) {
    winget install $name --source winget
    }
function wupgrade-all {
    winget upgrade --include-unknown
    }
function wupgrade($name) {
    winget upgrade $name
    }
function wuninstall($name) {
    winget uninstall  $name
    }



# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
