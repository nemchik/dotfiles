$config_dirs = @(
    "git",
    "husky"
)

$home_files = @(
    ".bashrc",
    ".claude",
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
# moves the original to the backup folder, then links. Leaves the item alone if the copy fails.
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
            # /SJ keeps junctions as junctions. Symbolic links are copied as their contents,
            # because robocopy can't create them without administrator rights.
            # /R:0 /W:0 fail at once instead of retrying.
            robocopy $destination $source /E /SJ /R:0 /W:0 /NFL /NDL /NJH /NJS | Out-Null
            $copied = $LASTEXITCODE -lt 8
        }
        else {
            Copy-Item -LiteralPath $destination -Destination $source -Force -ErrorAction SilentlyContinue
            $copied = $?
        }
        if (!$copied) {
            Write-Warning "Copying $destination into $source failed; left it in place"
            return
        }
        New-Item -ItemType Directory -Path $backup_dir -Force | Out-Null
        Move-Item -LiteralPath $destination -Destination $backup_dir
        Write-Output "Moved $destination to $backup_dir"
    }
    New-Item -ItemType SymbolicLink -Path $destination -Target $source -Force
}

function Install-Profile-PowerShell {
    Write-Output "Installing PowerShell 5 and 7 profiles"

    $source = Join-Path $PSScriptRoot "config\PowerShell"
    $documents = [Environment]::GetFolderPath("MyDocuments") # follows redirection, e.g. to OneDrive
    foreach ($profile_dir in @("WindowsPowerShell", "PowerShell")) {
        New-SymbolicLink -source $source -destination (Join-Path $documents $profile_dir)
    }
}

function Install-Profile-Terminal {
    Write-Output "Installing Terminal profile"

    $source = Join-Path $PSScriptRoot "config\Terminal"
    $destination = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    New-SymbolicLink -source $source -destination $destination
}

function Install-Dirs-Config {
    Write-Output "Installing config directories"

    foreach ($config_dir in $config_dirs) {
        $source = Join-Path $PSScriptRoot "config\$config_dir"
        $destination = Join-Path $env:USERPROFILE ".config\$config_dir"
        New-SymbolicLink -source $source -destination $destination
    }
    # Git writes --global changes to ~/.gitconfig only if it exists, otherwise into the repo (docs/adr/0001).
    $gitconfig = Join-Path $env:USERPROFILE ".gitconfig"
    if (!(Get-Item -LiteralPath $gitconfig -Force -ErrorAction SilentlyContinue)) { New-Item -ItemType File -Path $gitconfig | Out-Null }
}

function Install-Files-Home {
    Write-Output "Installing home files"

    foreach ($home_file in $home_files) {
        $source = Join-Path $PSScriptRoot "config\$home_file"
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
