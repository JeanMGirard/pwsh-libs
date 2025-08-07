---
external help file: vault-help.xml
Module Name: vault
online version:
schema: 2.0.0
---

# Find-VaultSecrets

## SYNOPSIS

## SYNTAX

```
Find-VaultSecrets [[-Prefix] <String>] [-Silent] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Lists all secrets in a path

## EXAMPLES

### EXAMPLE 1
```
Find-VaultSecrets "team/dev/app/secret_name"
```

### EXAMPLE 2
```
Find-VaultSecrets  "team/dev/app/secret_name" -Silent
```

## PARAMETERS

### -Prefix
{{ Fill Prefix Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Silent
{{ Fill Silent Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [string[]] The list of secrets found
## NOTES

## RELATED LINKS
