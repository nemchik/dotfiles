# WinGet Packages
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue

$wingetPackages = @(
  "Schniz.fnm",
  "Git.Git",
  "GitHub.cli",
  "Microsoft.OpenSSH.Beta",
  "Microsoft.PowerShell",
  "koalaman.shellcheck",
  "mvdan.shfmt",
  "Starship.Starship",
  "Microsoft.WindowsTerminal"
)

foreach ($wingetPackage in $wingetPackages) {
  winget.exe install --id "$wingetPackage" --exact --source winget --accept-source-agreements --silent --disable-interactivity
}

# Scoop Packages
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

scoop bucket add nerd-fonts
scoop install GeistMono-NF GeistMono-NF-Mono GeistMono-NF-Propo NerdFontsSymbolsOnly

scoop update *

# PowerShell Modules
Install-Module -Name Terminal-Icons -Repository PSGallery -AllowClobber -Force -ErrorAction SilentlyContinue
Install-Module -Name PSReadLine -SkipPublisherCheck -AllowClobber -Force -ErrorAction SilentlyContinue

Update-Module

# PowerShell
$source = Join-Path $PWD "config\PowerShell"
$destination = Join-Path $env:HOMEPATH "Documents\WindowsPowerShell"
$backup = "$destination.bak"

Remove-Item -Path "$backup" -Recurse -Force -ErrorAction SilentlyContinue
Move-Item -Path "$destination" -Destination "$backup" -Force -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path "$destination" -Target "$source" -Force -ErrorAction SilentlyContinue

# PowerShell 7
$source = Join-Path $PWD "config\PowerShell"
$destination = Join-Path $env:HOMEPATH "Documents\PowerShell"
$backup = "$destination.bak"

Remove-Item -Path "$backup" -Recurse -Force -ErrorAction SilentlyContinue
Move-Item -Path "$destination" -Destination "$backup" -Force -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path "$destination" -Target "$source" -Force -ErrorAction SilentlyContinue

# Terminal
$source = Join-Path $PWD "config\Terminal"
$destination = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$backup = "$destination.bak"

Remove-Item -Path "$backup" -Recurse -Force -ErrorAction SilentlyContinue
Move-Item -Path "$destination" -Destination "$backup" -Force -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path "$destination" -Target "$source" -Force -ErrorAction SilentlyContinue

# Config
$toolPaths = @(
  "gitignore.global",
  "husky"
)

foreach ($toolPath in $toolPaths) {
  $source = Join-Path $PWD "config\$toolPath"
  $destination = Join-Path $env:USERPROFILE ".config\$toolPath"
  $backup = "$destination.bak"

  Remove-Item -Path "$backup" -Recurse -Force -ErrorAction SilentlyContinue
  Move-Item -Path "$destination" -Destination "$backup" -Force -ErrorAction SilentlyContinue
  New-Item -ItemType SymbolicLink -Path "$destination" -Target "$source" -Force -ErrorAction SilentlyContinue
}

# Home
$homePaths = @(
  ".bashrc",
  ".gitattributes",
  ".gitconfig",
  ".profile"
)

foreach ($homePath in $homePaths) {
  $source = Join-Path $PWD "config\$homePath"
  $destination = Join-Path $env:USERPROFILE $homePath
  $backup = "$destination.bak"

  Remove-Item -Path "$backup" -Force -ErrorAction SilentlyContinue
  Move-Item -Path "$destination" -Destination "$backup" -Force -ErrorAction SilentlyContinue
  New-Item -ItemType SymbolicLink -Path "$destination" -Target "$source" -Force -ErrorAction SilentlyContinue
}
