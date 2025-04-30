# Winget Configuration Files

* [base](./base.winget): Minimal configuration file.

## Commands

### Import & Export

```shell
winget export -o winget.json
winget import -i winget.json
```

### List packages

```shell
Get-Content ./winget.json | ConvertFrom-Json | ForEach-Object { $_.Sources.Packages }
```
