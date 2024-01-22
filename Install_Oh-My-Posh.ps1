<#
.SYNOPSIS
    Installs Oh-my-posh
.DESCRIPTION
	Installs Oh-my-posh on Windows/Linux/MacOS via Winget/Chocolatey/Homebrew/script, as appropiate.
    Winget and Homebrew have priority, with Chocolatey having second-priority and script being last resort.
.EXAMPLE
	PS> ./Install_Oh-My-Posh
.LINK
	https://github.com/gabriel-vanca/Powershell
.NOTES
	Author: Gabriel Vanca
#>


#Requires -RunAsAdministrator

# Force use of TLS 1.2 for all downloads.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


Write-Host "Uninstall old version if installed"

pwsh -NoProfile -NonInteractive -Command {
    if (Get-Module oh-my-posh) {
        try {
            Uninstall-Module oh-my-posh -AllVersions -Force
        } catch {
            Write-Host "Old Oh-My-Posh not present. Nothing to uninstall."
        }
    }
}

if($IsWindows) {
    powershell -NoProfile -NonInteractive -Command {
        if (Get-Module oh-my-posh) {
            try {
                Uninstall-Module oh-my-posh -AllVersions -Force
            } catch {
                Write-Host "Old Oh-My-Posh not present. Nothing to uninstall."
            }
        }
    }
}


Write-Host "Proceeding with installation"

if($IsWindows) {
    $wingetBasedInstall = $False
    $chocoBasedInstall = $False
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    if($osInfo.ProductType -eq 1) {
        Write-Host "Windows workstation (Windows 10/11) deployment detected."
        $wingetBasedInstall = $True
    } else {
        Write-Host "Windows Server deployment detected."

        if (Get-AppPackage -name "Microsoft.DesktopAppInstaller") {
            Write-Host "WinGet present" -ForegroundColor DarkGreen
            $wingetBasedInstall = $True
        } else {
            Write-Host "WinGet missing"  -ForegroundColor DarkYellow
            $wingetBasedInstall = $False
            # Expected path of the choco.exe file.
            $chocoInstallPath = "$Env:ProgramData/chocolatey/choco.exe"
            if (Test-Path "$chocoInstallPath") {
                Write-Host "Chocolatey is present."  -ForegroundColor DarkGreen
                $chocoBasedInstall = $True
            } else {
                Write-Host "Chocolatey is missing."  -ForegroundColor DarkMagenta
                $chocoBasedInstall = $False
            }
        }
    }

    if($wingetBasedInstall) {
        Write-Host "Installing oh-my-posh via WinGet" -ForegroundColor DarkYellow
        winget install -e --accept-source-agreements --accept-package-agreements JanDeDobbeleer.OhMyPosh -s winget
    } else {
        if($chocoBasedInstall) {
            Write-Host "Installing oh-my-posh via Chocolatey" -ForegroundColor DarkYellow
            choco install oh-my-posh -y
        } else {
            Write-Host "Installing oh-my-posh manually via script" -ForegroundColor DarkYellow
            Start-Sleep -Seconds 5
            Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
        }
    }

} else {
    if($IsLinux) {
        Write-Host "Linux deployment detected."
        try {
            Write-Host "Installing via Homebrew" -ForegroundColor DarkYellow
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
            brew update && brew upgrade oh-my-posh
        }
        catch {
            Write-Error "Installing via Homebrew failed"
            Write-Host "Installing manually" -ForegroundColor DarkYellow
            curl -s https://ohmyposh.dev/install.sh | bash -s
        }
    } else {
        if($IsMacOS) {
            Write-Host "MacOS deployment detected."
            Write-Host "Installing via Homebrew" -ForegroundColor DarkYellow
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
            brew update && brew upgrade oh-my-posh
        }
    }
}


Write-Host "Testing installation" -ForegroundColor DarkYellow

try{
    oh-my-posh version
    Write-Host "Oh-my-posh installation succesful." -ForegroundColor DarkGreen
}
catch {
    Write-Error "Oh-my-posh installallation failed"
    throw "Oh-my-posh installallation failure"
}