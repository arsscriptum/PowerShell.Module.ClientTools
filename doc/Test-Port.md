---
external help file: PowerShell.Module.ClientTools-help.xml
Module Name: PowerShell.Module.ClientTools
online version:
schema: 2.0.0
---

# Test-Port

## SYNOPSIS
Tests port on computer.

## SYNTAX

```
Test-Port [-computer] <Array> [-port] <Array> [-TCPtimeout <Int32>] [-UDPtimeout <Int32>] [-TCP] [-UDP]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Tests port on computer.

## EXAMPLES

### EXAMPLE 1
```
Test-Port -computer 'server' -port 80  
Checks port 80 on server 'server' to see if it is listening
```

### EXAMPLE 2
```
'server' | Test-Port -port 80  
Checks port 80 on server 'server' to see if it is listening
```

### EXAMPLE 3
```
Test-Port -computer @("server1","server2") -port 80  
Checks port 80 on server1 and server2 to see if it is listening
```

## PARAMETERS

### -computer
Name of server to test the port connection on.

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -port
Port to test

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TCPtimeout
Sets a timeout for TCP port query.
(In milliseconds, Default is 1000)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1000
Accept pipeline input: False
Accept wildcard characters: False
```

### -UDPtimeout
Sets a timeout for UDP port query.
(In milliseconds, Default is 1000)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1000
Accept pipeline input: False
Accept wildcard characters: False
```

### -TCP
Use tcp port

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

### -UDP
Use udp port

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
