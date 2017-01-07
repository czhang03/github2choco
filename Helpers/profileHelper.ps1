function Read-ChocoProfile {
	<#
	.SYNOPSIS
		This cmdlet reads your local profile
	
	.DESCRIPTION
		This function reads your local profile and convert it from a json string to a psobject
		the profile is loacted in the module root, and the file name is `profile.json`
		when the profile does not exist, this function will return a empty psobject
	
	.EXAMPLE
		PS C:\> Read-ChocoProfile
		This will give you a PSobject converted from profile data
	
	.NOTES
		The profile is in the form that the PackageName maps to package properties,
		the package property is also stored in a dictionary where property name maps to property value
		Here is an example:
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
	
	#>
	[CmdletBinding()]
	param(
		
	)
	
	begin 
	{
		Write-Host ''
		$profileFullName = Get-ChocoProfileLocation
		Write-Verbose "The profile's full name is $profileFullName"

	}
	
	process
	{
		if (Test-Path $profileFullName) 
		{
			Write-Verbose 'profile found'
			$profile = Get-Content $profileFullName | ConvertFrom-Json
		}
		else 
		{
			Write-Verbose 'Profile Not Found, starting with an empty profile'
			$profile = New-Object -TypeName psobject
		}	
	}
	
	end
	{
		return $profile	
	}
}


function Save-Profile {
	<#
	.SYNOPSIS
		This function takes a profile and save it
	
	.DESCRIPTION
		This cmdlet takes a profile object (PSCustomObject) and then convert it to json and save it in the profile file (ModuleRoot/profile.json)
	
	.PARAMETER localProfile
		the Profile Object (PSCustomObject) that is converted from profile file (a json file indicating all the property of the packages)

	.EXAMPLE
		PS C:\> Save-Profile -localProfile $profile
		this converts the $profile to json and write to the profile file
	
	.NOTES
		
	
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object] $localProfile
	)
	
	begin 
	{
		$profileFullName = Get-ChocoProfileLocation
		Write-Verbose "The profile's full name is $profileFullName"
	}
	
	process 
	{
		ConvertTo-Json $localProfile | Out-File $profileFullName -Encoding utf8
	}
	
	end 
	{
		Write-Host 'Profile Successfully saved' -ForegroundColor Yellow
	}
}


function New-VersionLog {
	<#
	.SYNOPSIS
		This function saves the version number in a file
	
	.DESCRIPTION
		This cmdlet saves the version number of a package to that package's package path to make accessing the version package more easily

	.PARAMETER packagePath
		The path of the chocolatey package

	.PARAMETER VersionNumer
		The version number of the software

	.EXAMPLE
		PS C:\> New-VersionLog -PackagePath '~/packageName' -VersionNumber '1.0.0'
		This will create a file 'latestVersion' in path '~/packageName/' with content '1.0.0'
	
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[String] $PackagePath,
		[Parameter(Mandatory = $true)]
		[string] $VersionNumber
	)
	
	begin 
	{
		$LogPath = Join-Path -Path $packagePath -ChildPath 'latestVersion'
	}
	
	process
	{
		# log
		Write-Host 'logging the latest version in the folder for you to access the latest version programatically' -ForegroundColor Green
		Write-Host "version log location will be $LogPath" -ForegroundColor Green

		# create the version number log
		$newVersion | Out-File $LogPath -Encoding utf8
	
	}
	
	end
	{
		Write-Host 'log saved' -ForegroundColor Green	
	}
}

