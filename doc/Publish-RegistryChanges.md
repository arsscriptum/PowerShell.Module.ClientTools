---
external help file: PowerShell.Module.ClientTools-help.xml
Module Name: PowerShell.Module.ClientTools
online version:
schema: 2.0.0
---

# Publish-RegistryChanges

## SYNOPSIS
Simulates like the Windows UI : sends a WM_SETTINGCHANGE broadcast to all Windows notifying them of the change to settings so they can refresh their config and you can do it too!

## SYNTAX

```
Publish-RegistryChanges [[-Timeout] <Int32>] [[-Flags] <Int32>] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Simulates like the Windows UI : sends a WM_SETTINGCHANGE broadcast to all Windows notifying them of the change to settings so they can refresh their config and you can do it too!

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Timeout
Timeout

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 1000
Accept pipeline input: False
Accept wildcard characters: False
```

### -Flags
SMTO_ABORTIFHUNG 0x0002
The function returns without waiting for the time-out period to elapse if the receiving thread appears to not respond or "hangs."
SMTO_BLOCK 0x0001
Prevents the calling thread from processing any other requests until the function returns.
SMTO_NORMAL0x0000
The calling thread is not prevented from processing other requests while waiting for the function to return.
SMTO_NOTIMEOUTIFNOTHUNG 0x0008
The function does not enforce the time-out period as long as the receiving thread is processing messages.
SMTO_ERRORONEXIT 0x0020
The function should return 0 if the receiving window is destroyed or its owning thread dies while the message is being processed.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 2
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
