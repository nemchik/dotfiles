# Starship
function Invoke-Starship-PreCommand {
    $host.ui.RawUI.WindowTitle = "$env:USERNAME@$env:COMPUTERNAME`: $pwd `a"
}
function Invoke-Starship-TransientFunction {
    &starship module character
}
Invoke-Expression (&starship init powershell)
Enable-TransientPrompt

# fnm
&fnm env --use-on-cd --version-file-strategy=recursive --corepack-enabled --resolve-engines | Out-String | Invoke-Expression
&fnm completions --version-file-strategy=recursive --corepack-enabled --resolve-engines | Out-String | Invoke-Expression

# Terminal-Icons
# Import-Module Terminal-Icons

# PSReadLine
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
