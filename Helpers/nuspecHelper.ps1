function Get-NuspecTemplate 
{
	<#
	.SYNOPSIS
		Get the nuspec template file
	
	.DESCRIPTION
		Get the nuspec template file from $templatePath and convert it to a xml object
	
	.PARAMETER templatePath
		the template path for the current package

	.PARAMETER packageName
		the package name of the current package		

	.OUTPUTS
		a xml object converted from your template nuspec file
	
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $templatePath,
		[Parameter(Mandatory = $true)]
		[string] $packageName
	)
	
	begin 
	{
		$xml = [xml] $(Get-Content "$templatePath\$packageName.nuspec")
    	Write-Verbose 'successfull get the template file'
	}
	
	end 
	{
		return $xml
	}
}

function Write-NuspecFile 
{
	<#
	.SYNOPSIS
		This cmdlet writes the information you need to a nuspec file and save it
	
	.DESCRIPTION
		This cmdlet will write the version and releaseNotes to the nuspec file and save it in $SavePath
	
	.PARAMETER savePath
		The path to save the new nuspec file
	
	.PARAMETER packageName
		The name of the current package
	
	.PARAMETER templatePath
		the path of the current package's template

	.PARAMETER version
		the latest version of the current package

	.PARAMETER releaseNote
		the release note of the latest version of the current package

	.OUTPUTS
		None
	
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[String] $savePath,
		[Parameter(Mandatory = $true)]
		[string] $packageName,
		[Parameter(Mandatory = $true)]
		[string] $templatePath,
		[Parameter(Mandatory = $true)]
		[string] $version,
		[Parameter(Mandatory = $true)]
		[string] $releaseNote
	)
	
	begin 
	{
		# read the nuspec file
		$nuspecFile = Get-NuspecTemplate -packageName $packageName -templatePath $templatePath
	}
	
	process
	{
		# set releaseNotes
		$nuspecFile.package.metadata.releaseNotes = $releaseNote
		# set version
		$nuspecFile.package.metadata.version = $version
	}
	
	end
	{
		# save the nuspec file
		$nuspecFile.Save("$SavePath\$packageName.nuspec")
	}
}
