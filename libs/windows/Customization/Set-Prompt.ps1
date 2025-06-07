function prompt {
    # Your non-prompt logic here
    $prompt = Write-Prompt "$(hostname)`n" -ForegroundColor ([ConsoleColor]::Green)
    $prompt += & $GitPromptScriptBlock
    $prompt += Write-Prompt "`n"

    if ($prompt) { "$prompt " } else { " " }
}
