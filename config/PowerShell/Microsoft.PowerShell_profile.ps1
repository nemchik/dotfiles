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
[Environment]::SetEnvironmentVariable("FNM_COREPACK_ENABLED", "true", "User")
[Environment]::SetEnvironmentVariable("FNM_RESOLVE_ENGINES", "true", "User")
[Environment]::SetEnvironmentVariable("FNM_VERSION_FILE_STRATEGY", "recursive", "User")
&fnm env --use-on-cd | Out-String | Invoke-Expression
&fnm completions | Out-String | Invoke-Expression

# Terminal-Icons
# Import-Module Terminal-Icons

# CompletionPredictor
Import-Module -Name CompletionPredictor

# PSReadLine
$PSReadLineOptions = @{
    BellStyle                     = "None"
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    PredictionSource              = "HistoryAndPlugin"
    PredictionViewStyle           = "ListView"
    Colors                        = @{
        Command                = [ConsoleColor]::Magenta # The command token color.
        Comment                = [ConsoleColor]::DarkGray # The comment token color.
        ContinuationPrompt     = [ConsoleColor]::DarkGray # The color of the continuation prompt.
        Default                = [ConsoleColor]::DarkGray # The default token color.
        Emphasis               = [ConsoleColor]::DarkGray # The emphasis color. For example, the matching text when searching history.
        Error                  = [ConsoleColor]::DarkRed # The error color. For example, in the prompt.
        InlinePrediction       = [ConsoleColor]::Blue # The color for the inline view of the predictive suggestion.
        Keyword                = [ConsoleColor]::DarkGray # The keyword token color.
        ListPrediction         = [ConsoleColor]::DarkGray # The color for the leading > character and prediction source name.
        ListPredictionSelected = [ConsoleColor]::DarkGray # The color for the selected prediction in list view.
        Member                 = [ConsoleColor]::DarkGray # The member name token color.
        Number                 = [ConsoleColor]::DarkGray # The number token color.
        Operator               = [ConsoleColor]::DarkGray # The operator token color.
        Parameter              = [ConsoleColor]::DarkGreen # The parameter token color.
        Selection              = [ConsoleColor]::DarkGray # The color to highlight the menu selection or selected text.
        String                 = [ConsoleColor]::DarkGray # The string token color.
        Type                   = [ConsoleColor]::DarkGray # The type token color.
        Variable               = [ConsoleColor]::DarkGreen # The variable token color.
    }
}
Set-PSReadLineOption @PSReadLineOptions
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
