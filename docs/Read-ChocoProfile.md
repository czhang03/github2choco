---
external help file: github2choco-help.xml
online version: 
schema: 2.0.0
---

# Read-ChocoProfile

## SYNOPSIS
This cmdlet reads your local profile

## SYNTAX

```
Read-ChocoProfile
```

## DESCRIPTION
This function reads your local profile and convert it from a json string to a psobject
the profile is loacted in the module root, and the file name is \`profile.json\`
when the profile does not exist, this function will return a empty psobject

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Read-ChocoProfile
```

This will give you a PSobject converted from profile data

## PARAMETERS

## INPUTS

## OUTPUTS

## NOTES
The profile is in the form that the PackageName maps to package properties,
the package property is also stored in a dictionary where property name maps to property value
Here is an example:
\`\`\` json
{
	'PackageName1': {
		'PackagePropertyName1': 'PackagePropertyValue1',
		'PackagePropertyName2' : 'PackagePropertyValue2'
	},

	'PackageName2': {
		'PackagePropertyName1': 'PackagePropertyValue1',
		'PackagePropertyName2' : 'PackagePropertyValue2'
	}
}
\`\`\`

## RELATED LINKS

