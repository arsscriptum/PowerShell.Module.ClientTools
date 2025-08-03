---
external help file: PowerShell.Module.ClientTools-help.xml
Module Name: PowerShell.Module.ClientTools
online version:
schema: 2.0.0
---

# New-RegistryValue

## SYNOPSIS
Create FULL Registry Path and add value

## SYNTAX

```
New-RegistryValue [-Path] <String> [-Name] <Object> [-Value] <Object> [-Kind] <Object> [-Publish]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Add a value in the registry, if it exists, it will replace

## EXAMPLES

### EXAMPLE 1
```
New-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" "D:\Development\CodeCastor\network\netlib" "String" -publish
>> TRUE
```

## PARAMETERS

### -Path
Path

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

### -Name
Name

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Entry

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
Value

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Kind
{{ Fill Kind Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Type

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Publish
{{ Fill Publish Description }}

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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

### SUCCESS(true) or FAILURE(false)
## NOTES

## RELATED LINKS
