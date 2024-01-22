# WARNING: This does not work without admin access. 
    # The files must be installed manually from File explorer or Powershell if admin access is lacking.
    # Even so it might not work properly. Fonts should always be installed as admin.

#Requires -RunAsAdministrator

# Force use of TLS 1.2 for all downloads.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Saves the current working directory in memory (via a directory stack) so it can be returned to at any time,
# places the new filepath at the top of the stack, and changes to the new filepath.
# The Pop-Location command returns to the path at the top of the directory stack.
Push-Location $PSScriptRoot


Write-Host "List current Powershell version" -ForegroundColor DarkYellow
$PSVersionTable
Write-Host "List current Powershell Core version"  -ForegroundColor DarkYellow
pwsh {$PSVersionTable}


Write-Host "Step 1: Installing Oh-My-Posh" # (https://ohmyposh.dev/docs/)

try{
    $OMP_installScriptPath = "https://raw.githubusercontent.com/gabriel-vanca/Powershell/main/Install_Oh-My-Posh.ps1"
    $OMP_deploymentScript = Invoke-RestMethod $OMP_installScriptPath
    Invoke-Expression $OMP_deploymentScript
}
catch {
    Write-Error "Fonts deployment failed due to OMP installation failure"
    throw "Fonts deployment failed due to OMP installation failure"
}

Write-Host "Refreshing terminal"
.$PROFILE

if($IsWindows) {
    # Expected path of the choco.exe file.
    $chocoInstallPath = "$Env:ProgramData/chocolatey/choco.exe"
    if(Test-Path "$chocoInstallPath") {
        # Make `refreshenv` available right away, by defining the $env:ChocolateyInstall
        # variable and importing the Chocolatey profile module.
        $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   
        Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
        Update-SessionEnvironment
        refreshenv
    }
}


Write-Host "Step 2: Installing Fonts via Oh-my-posh"
# Font source: https://github.com/ryanoasis/nerd-fonts

oh-my-posh font install CascadiaCode
oh-my-posh font install Cousine
oh-my-posh font install FiraCode
oh-my-posh font install Go-Mono
oh-my-posh font install Hack
oh-my-posh font install Hasklig
oh-my-posh font install JetBrainsMono
oh-my-posh font install LiberationMono
oh-my-posh font install Meslo
oh-my-posh font install Monoid
oh-my-posh font install NerdFontsSymbolsOnly
oh-my-posh font install ProFont
oh-my-posh font install RobotoMono
oh-my-posh font install SourceCodePro


Write-Host "Step 3: Additional tech fonts installation"
Write-Host "Downloading \Fonts and preparing them for installation"

$repoDownloadLocalPath  = "$env:Temp\Fonts_to_install"
#Ensure folder is empty
if(Test-Path -path $repoDownloadLocalPath)
{ 
    Remove-Item $repoDownloadLocalPath -Recurse -Force
}

$repoUrl = "https://github.com/gabriel-vanca/Powershell"  
git clone $repoUrl $repoDownloadLocalPath --depth 1 --progress -v
Get-ChildItem $repoDownloadLocalPath -Recurse | Unblock-File

$gitRepoPath = $repoDownloadLocalPath + "\.git"
Remove-Item $gitRepoPath -Recurse -Force


Write-Host "Installing content of the \Fonts directory"

if($IsWindows) {
    $fontsDownloadPath = $repoDownloadLocalPath + "\Fonts"

    $scriptPath = "https://raw.githubusercontent.com/gabriel-vanca/PowerShell_Library/main/Scripts/Windows/Fonts/Install-Fonts.ps1"
    $WebClient = New-Object Net.WebClient
    $deploymentScript = $WebClient.DownloadString($scriptPath)
    $deploymentScript = [Scriptblock]::Create($deploymentScript)
    Invoke-Command -ScriptBlock $deploymentScript -ArgumentList ($fontsDownloadPath) -NoNewScope
} else {
    Write-Error "Operating System font install not implemented"
}

if(Test-Path -path $repoDownloadLocalPath)
{ 
    Remove-Item $repoDownloadLocalPath -Recurse -Force
}

Write-Host "Step 4: Refreshing terminal"

.$PROFILE

if($IsWindows) {
    # Expected path of the choco.exe file.
    $chocoInstallPath = "$Env:ProgramData/chocolatey/choco.exe"
    if(Test-Path "$chocoInstallPath") {
        # Make `refreshenv` available right away, by defining the $env:ChocolateyInstall
        # variable and importing the Chocolatey profile module.
        $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   
        Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
        Update-SessionEnvironment
        refreshenv
    }
}


Write-Host "Step 5: "
