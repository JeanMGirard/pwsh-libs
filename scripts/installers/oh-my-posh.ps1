

winget install  --scope machine -s winget JanDeDobbeleer.OhMyPosh

# oh-my-posh init pwsh --config "~/.oh-my-posh.theme.omp.json" | Invoke-Expression
# oh-my-posh config export --output ~/.oh-my-posh.theme.omp.json
# oh-my-posh font install # meslo 
# Get-PoshThemes  # grandpa-style 
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/grandpa-style.omp.json" | Invoke-Expression
#   clean-detailed   craver 
#   jblab_2021 amro  night-owl  sonicboom_dark sonicboom_light
#  kushal  grandpa-style blue-owl



# Import-Module Terminal-Icons
# Import-Module oh-my-posh
# Set-PoshPrompt -Theme Aliens

mkdir -p ~/.config ~/.config/oh-my-posh ~/.config/oh-my-posh/themes


oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/grandpa-style.omp.json" | Invoke-Expression
oh-my-posh config export --output ~/.config/oh-my-posh/themes/grandpa-style.omp.json
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/sonicboom_light.omp.json" | Invoke-Expression
oh-my-posh config export --output ~/.config/oh-my-posh/themes/sonicboom_light.omp.json
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/sonicboom_dark.omp.json" | Invoke-Expression
oh-my-posh config export --output ~/.config/oh-my-posh/themes/sonicboom_dark.omp.json



oh-my-posh init pwsh --config ~/.config/oh-my-posh/theme.omp.json | Invoke-Expression