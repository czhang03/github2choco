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
Update-AllChocoPackages [-Force]
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

## INPUTS

## OUTPUTS

### A list of package names of the package that has been updated

## NOTES
This just goes through the profile and invoke \`Update-ChocoPackage\` on each one.
Therefore reading the doc on \`Update-ChocoPackage\` may be helpfull

## RELATED LINKS

