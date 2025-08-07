---
external help file: packages-help.xml
Module Name: packages
online version:
schema: 2.0.0
---

# New-DynamicOption

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
New-DynamicOption [-category] <OptionCategory> [-name] <String> [-expectedType] <OptionType>
 [-isRequired] <Boolean> [[-permittedValues] <ArrayList>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -category
{{ Fill category Description }}

```yaml
Type: OptionCategory
Parameter Sets: (All)
Aliases:
Accepted values: Package, Provider, Source, Install

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -expectedType
{{ Fill expectedType Description }}

```yaml
Type: OptionType
Parameter Sets: (All)
Aliases:
Accepted values: String, StringArray, Int, Switch, Folder, File, Path, Uri, SecureString

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isRequired
{{ Fill isRequired Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -name
{{ Fill name Description }}

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

### -permittedValues
{{ Fill permittedValues Description }}

```yaml
Type: ArrayList
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
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

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
