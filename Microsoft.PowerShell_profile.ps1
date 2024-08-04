using namespace System.Management.Automation
using namespace System.Management.Automation.Language
 
if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadLine
}

Import-Module -Name Terminal-Icons

#opt-out of telemetry before doing anything, only if PowerShell is run as admin
if ([bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsSystem) {
    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
}

# Enhanced PowerShell Experience
Set-PSReadLineOption -Colors @{
    Command = 'Yellow'
    Parameter = 'Green'
    String = 'DarkCyan'
}

$PSROptions = @{
    ContinuationPrompt = '  '
    Colors             = @{
    Parameter          = $PSStyle.Foreground.Magenta
    Selection          = $PSStyle.Background.Black
    InLinePrediction   = $PSStyle.Foreground.BrightYellow + $PSStyle.Background.BrightBlack
    }
}
Set-PSReadLineOption @PSROptions
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Enter' -Function ValidateAndAcceptLine

$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLIneOption -EditMode Windows

##Alias##
Set-Alias -Name vim -Value nvim
Set-Alias -Name eth -Value get-netadapter
Set-Alias -Name netprofile -value Get-NetConnectionProfile
Set-Alias -Name lt -Value tree
Set-Alias -Name su -Value sudo

##Functions##
function .. {cd .. }
function ... {cd ../..}
function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }

function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }
function sha512 { Get-FileHash -Algorithm SHA512 $args }

function winutil {irm https://christitus.com/win | iex}

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.

function sudo {
     if ($args.Count -gt 0) {
        $argList = "& '$args'"
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}

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
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
    }
function pgrep($name) {
    ps $name
    }
function Get-PubIP {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}

# Clipboard Utilities
function cpy { 
    Set-Clipboard $args[0] 
}

function pst { 
    Get-Clipboard 
    }

function cclip {
    Set-Clipboard -Value $null
}

# Networking Utilities
function flushdns {
	Clear-DnsClientCache
	Write-Host "DNS has been flushed"
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
function dcopy($name) {
    type  $name | clip
    }

# Quick File Creation
function nf { 
    param($name) New-Item -ItemType "file" -Path . -Name $name 
}

# Directory Management
function mkcd { 
    param($dir) mkdir $dir -Force; Set-Location $dir
    }
# Quick Access to System Information
    function sysinfo { Get-ComputerInfo
    }

### Quality of Life Aliases

# Navigation Shortcuts
function docs { 
    Set-Location -Path $HOME\Documents 
}

function dtop { 
    Set-Location -Path $HOME\Desktop 
}

# Simplified Process Management
function k9 { 
    Stop-Process -Name $args[0] 
    }

# Enhanced Listing
function la { 
    Get-ChildItem -Path . -Force | Format-Table -AutoSize 
    }
function ll { 
    Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize 
    }

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
##function winstall($name) {
##    winget install $name --source winget 
##    }
function winstall($name){
    winget install --id=$name -e
    }
function wupgrade-all {
    winget upgrade --include-unknown
    }
function wupgrade($name) {
    winget upgrade $name --source winget
    }
function wuninstall($name) {
    winget uninstall  $name
    }

##Starship-Prompt##
Invoke-Expression (&starship init powershell)
$ENV:STARSHIP_CONFIG = "$HOME\.config\starship.toml"


# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

