function Invoke-Starship-PreCommand {
  $host.ui.RawUI.WindowTitle = "$env:USERNAME@$env:COMPUTERNAME`: $pwd `a"
}
function Invoke-Starship-TransientFunction {
  &starship module character
}
Invoke-Expression (&starship init powershell)
Enable-TransientPrompt

# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/tokyonight_storm.omp.json" | Invoke-Expression
# oh-my-posh font install GeistMono
# oh-my-posh font install NerdFontsSymbolsOnly

# scoop bucket add nerd-fonts
# scoop install GeistMono-NF
# scoop install GeistMono-NF-Mono
# scoop install GeistMono-NF-Propo
# scoop install NerdFontsSymbolsOnly

fnm env --use-on-cd --version-file-strategy=recursive | Out-String | Invoke-Expression
fnm completions --version-file-strategy=recursive | Out-String | Invoke-Expression

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
