$config_dirs = @(
    "gitignore.global",
    "husky"
)

$home_files = @(
    ".bashrc",
    ".gitattributes",
    ".gitconfig",
    ".profile"
)

$powershell_modules = @(
    "Terminal-Icons",
    "PSReadLine"
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

function Install-Winget-Packages {
    Write-Output "Installing winget packages"

    if (!(Get-Command winget)) {
        Write-Output "Installing winget"
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
    }

    winget import -i .\winget-packages.json --accept-package-agreements
    winget upgrade --all --accept-package-agreements
}

function Install-Scoop-Packages {
    Write-Output "Installing scoop packages"

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    if (!(Get-Command scoop)) {
        Write-Output "Installing scoop"
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }

    foreach ($scoop_bucket in $scoop_buckets) {
        scoop bucket add "$scoop_bucket"
    }

    scoop install "$scoop_packages"
    scoop update *
}

function Install-PowerShell-Modules {
    Write-Output "Installing PowerShell modules"

    foreach ($powershellModule in $powershell_modules) {
        Install-Module -Name "$powershellModule" -AllowClobber -Force -ErrorAction SilentlyContinue
    }

    Update-Module
}

# Symbolic Links
function New-SymbolicLink {
    Param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $source,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $destination
    )
    $backup = "$destination.old"

    Remove-Item -Path "$backup" -Recurse -Force -ErrorAction SilentlyContinue
    Move-Item -Path "$destination" -Destination "$backup" -Force -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path "$destination" -Target "$source" -Force -ErrorAction SilentlyContinue
}

function Install-PowerShell-Profile {
    Write-Output "Installing PowerShell profile"

    $source5 = Join-Path $PWD "config\PowerShell"
    $destination5 = Join-Path $env:HOMEPATH "Documents\WindowsPowerShell"
    New-SymbolicLink -source $source5 -destination $destination5

    Write-Output "Installing PowerShell 7 profile"

    $source7 = Join-Path $PWD "config\PowerShell"
    $destination7 = Join-Path $env:HOMEPATH "Documents\PowerShell"
    New-SymbolicLink -source $source7 -destination $destination7
}

function Install-Terminal-Profile {
    Write-Output "Installing Terminal profile"

    $source = Join-Path $PWD "config\Terminal"
    $destination = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    New-SymbolicLink -source $source -destination $destination
}

function Install-Config-Dirs {
    Write-Output "Installing config directories"

    foreach ($config_dir in $config_dirs) {
        $source = Join-Path $PWD "config\$config_dir"
        $destination = Join-Path $env:USERPROFILE ".config\$config_dir"
        New-SymbolicLink -source $source -destination $destination
    }
}

function Install-Home-Files {
    Write-Output "Installing home files"

    foreach ($home_file in $home_files) {
        $source = Join-Path $PWD "config\$home_file"
        $destination = Join-Path $env:USERPROFILE $home_file
        New-SymbolicLink -source $source -destination $destination
    }
}

function Main {
    Install-Winget-Packages
    Install-Scoop-Packages
    Install-PowerShell-Modules
    Install-PowerShell-Profile
    Install-Terminal-Profile
    Install-Config-Dirs
    Install-Home-Files
}

Main
