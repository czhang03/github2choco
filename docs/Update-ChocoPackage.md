---
external help file: github2choco-help.xml
online version: 
schema: 2.0.0
---

# Update-ChocoPackage

## SYNOPSIS
Update a choco package

## SYNTAX

```
Update-ChocoPackage [-packageName] <String> [-Force]
```

## DESCRIPTION
Update a package that is in the \`profile.json\` and return whether the package is updated

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Update-ChocoPackage you-get
```

update the package with name 'you-get' (if local is already on the latest release, this will just exit)

### -------------------------- EXAMPLE 2 --------------------------
```
Update-ChocoPackage you-get -Force
```

update the package with name 'you-get' to the latest release regardless of the version number

## PARAMETERS

### -packageName
The name (id) of the package, it is the keys in \`profile.json\`

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force
Whether to force execute the update.
Normal update stop when the remote version matches the local version,
but a force update will update the package to the latest release regardless of the version number
Notice if this parameter is applied, the output of this cmdlet will always be $true

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

### A boolean value indicate whether the package is updated

## NOTES
This will only write the latest version, so it is possible that you may miss versions.
For example if your local version is on 1.0,
and on github there is 2.0 and 3.0, this cmdlet will update the package to 3.0 and miss 2.0

## RELATED LINKS

