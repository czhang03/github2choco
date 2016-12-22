---
external help file: github2choco-help.xml
online version: 
schema: 2.0.0
---

# Update-AllChocoPackages

## SYNOPSIS
Update all the choco package you created

## SYNTAX

```
Update-AllChocoPackages [-Force] [<CommonParameters>]
```

## DESCRIPTION
Update all the package inside \`profile.json\` and give you a list of package name of the package that is updated

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Update-AllChocoPackage
```

This will just update all the choco package that is in your profile

## PARAMETERS

### -Force
{{Fill Force Description}}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A list of package names of the package that has been updated

## NOTES
This just goes through the profile and invoke \`Update-ChocoPackage\` on each one.
Therefore reading the doc on \`Update-ChocoPackage\` may be helpfull

## RELATED LINKS

