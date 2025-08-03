---
external help file: PowerShell.Module.ClientTools-help.xml
Module Name: PowerShell.Module.ClientTools
online version:
schema: 2.0.0
---

# Search-Pattern

## SYNOPSIS
Cmdlet to find in files (grep)

## SYNTAX

```
Search-Pattern [-Pattern] <Object> [-Filter <String>] [-Path <String>] [-Exclude <String[]>] [-Short] [-List]
 [-NoTruncate] [-Recurse] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Cmdlet to find in files (grep)

## EXAMPLES

### EXAMPLE 1
```
Search-Pattern -Pattern 'g.png' -Extension "txt"
Search-Pattern -Pattern 'g.png' -Exclude @("_site","jekyll-metadata","bower_components","jekyll-cache")
```

## PARAMETERS

### -Pattern
What to look for in the files

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
File filter

```yaml
Type: String
Parameter Sets: (All)
Aliases: f

Required: False
Position: Named
Default value: *.*
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path for search

```yaml
Type: String
Parameter Sets: (All)
Aliases: p

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude
Exclude string array

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: x

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Short
Output short file names

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: s

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -List
Output as list of psobjects

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: l

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoTruncate
do not truncate lines

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

### -Recurse
Recurse in subdirectories

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: r

Required: False
Position: Named
Default value: True
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

## OUTPUTS

## NOTES

## RELATED LINKS
