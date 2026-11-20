$config_dirs = @(
    "husky"
)

$home_files = @(
    ".bashrc",
    ".claude",
    ".gitattributes",
    ".gitconfig",
    ".gitconfig-codespaces",
    ".lefthookrc",
    ".profile"
)

$powershell_modules = @(
    "PowerShellGet", # This is required to install other modules, so it should be installed first
    # "Terminal-Icons", # This constantly causes error messages when opening a new terminal
    "PSReadLine", # PSReadLine is already included in PowerShell 7
    "CompletionPredictor" # This is a plugin for PSReadLine that provides command predictions based on history and plugins
)

$scoop_buckets = @(
    "nerd-fonts"
)

$scoop_packages = @(
    "GeistMono-NF",
    "GeistMono-NF-Mono",
    "GeistMono-NF-Propo",
    "NerdFontsSymbolsOnly"
)

function Install-Packages-Winget {
    Write-Output "Installing winget packages"

    if (!(Get-Command winget)) {
        Write-Output "Installing winget"
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
    }

    winget import -i (Join-Path $PSScriptRoot "winget-packages.json") --accept-package-agreements
    winget upgrade --all --accept-package-agreements
}

function Install-Packages-Scoop {
    Write-Output "Installing scoop packages"

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    if (!(Get-Command scoop)) {
        Write-Output "Installing scoop"
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }

    foreach ($scoop_bucket in $scoop_buckets) {
        scoop bucket add $scoop_bucket
    }

    scoop install $scoop_packages
    scoop update *
}

function Install-Modules-PowerShell {
    Write-Output "Installing PowerShell modules"

    foreach ($powershellModule in $powershell_modules) {
        Install-Module -Name $powershellModule -Scope CurrentUser -AllowClobber -Force -ErrorAction SilentlyContinue
    }

    Update-Module
}

# Symbolic Links
$backup_dir = Join-Path $env:USERPROFILE ".dotfiles-backup\$(Get-Date -Format yyyyMMdd-HHmmss)"

# Copies an existing item over the repo copy, so differences show as unstaged changes,
# moves the original to the backup folder, then links.
function New-SymbolicLink {
    Param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $source,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $destination
    )
    $existing = Get-Item -LiteralPath $destination -Force -ErrorAction SilentlyContinue
    if ($existing -and @($existing.Target)[0] -eq $source) {
        return
    }
    if ($existing) {
        if ($existing.PSIsContainer) {
            # /SL and /SJ copy symbolic links and junctions as links instead of following them.
            robocopy $destination $source /E /SL /SJ /NFL /NDL /NJH /NJS | Out-Null
            if ($LASTEXITCODE -ge 8) {
                Write-Warning "Copying $destination into $source failed; the original is still in the backup"
            }
        }
        else {
            Copy-Item -LiteralPath $destination -Destination $source -Force
        }
        New-Item -ItemType Directory -Path $backup_dir -Force | Out-Null
        Move-Item -LiteralPath $destination -Destination $backup_dir
        Write-Output "Moved $destination to $backup_dir"
    }
    New-Item -ItemType SymbolicLink -Path $destination -Target $source -Force
}

function Install-Profile-PowerShell {
    Write-Output "Installing PowerShell profile"

    $documents = [Environment]::GetFolderPath("MyDocuments") # follows redirection, e.g. to OneDrive
    $source5 = Join-Path $PWD "config\PowerShell"
    $destination5 = Join-Path $documents "WindowsPowerShell"
    New-SymbolicLink -source $source5 -destination $destination5

    Write-Output "Installing PowerShell 7 profile"

    $source7 = Join-Path $PWD "config\PowerShell"
    $destination7 = Join-Path $documents "PowerShell"
    New-SymbolicLink -source $source7 -destination $destination7
}

function Install-Profile-Terminal {
    Write-Output "Installing Terminal profile"

    $source = Join-Path $PWD "config\Terminal"
    $destination = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    New-SymbolicLink -source $source -destination $destination
}

function Install-Dirs-Config {
    Write-Output "Installing config directories"

    foreach ($config_dir in $config_dirs) {
        $source = Join-Path $PWD "config\$config_dir"
        $destination = Join-Path $env:USERPROFILE ".config\$config_dir"
        New-SymbolicLink -source $source -destination $destination
    }
}

function Install-Files-Home {
    Write-Output "Installing home files"

    foreach ($home_file in $home_files) {
        $source = Join-Path $PWD "config\$home_file"
        $destination = Join-Path $env:USERPROFILE $home_file
        New-SymbolicLink -source $source -destination $destination
    }
}

function Main {
    $identity = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    if ($identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "Run setup.ps1 as yourself, not as administrator."
        exit 1
    }
    $developerMode = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -ErrorAction SilentlyContinue
    if ($developerMode.AllowDevelopmentWithoutDevLicense -ne 1) {
        Write-Error "Turn on Developer Mode (Settings > System > For developers) so symbolic links work without administrator rights."
        exit 1
    }

    Install-Packages-Winget
    Install-Packages-Scoop
    Install-Profile-PowerShell
    Install-Profile-Terminal
    Install-Modules-PowerShell
    Install-Dirs-Config
    Install-Files-Home
    Write-Output "Done!"
}

Main
