---
external help file: vault-help.xml
Module Name: vault
online version:
schema: 2.0.0
---

# Merge-VaultSecrets

## SYNOPSIS

## SYNTAX

```
Merge-VaultSecrets [-Source] <String> [-Dest] <String> [-Prefix <String>] [-Overwrite] [-Delete]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends all values from one secret to another

## EXAMPLES

### EXAMPLE 1
```
Merge-VaultSecrets "team/dev/app/secret_name" "team/dev/app/secret_name2"
Merge-VaultSecrets -Prefix "team/dev" "app/secret_name" "app/secret_name2"
Merge-VaultSecrets -Prefix "team/dev" "app/secret_name" "app/secret_name2" -Overwrite -Delete
Merge-VaultSecrets -Prefix "team/dev" "app/secret_name" "app/secret_name2" -Delete
Merge-VaultSecrets -Prefix "team/dev" "app/secret_name" "app/secret_name2" -Overwrite
```

## PARAMETERS

### -Source
{{ Fill Source Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Dest
{{ Fill Dest Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prefix
{{ Fill Prefix Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Overwrite
{{ Fill Overwrite Description }}

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

### -Delete
{{ Fill Delete Description }}

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

## NOTES

## RELATED LINKS
