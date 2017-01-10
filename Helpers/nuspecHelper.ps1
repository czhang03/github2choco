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
		$absoluteNuspecFullName = [System.IO.Path]::GetFullPath("$SavePath\$packageName.nuspec")		
		$nuspecFile.Save($absoluteNuspecFullName)
	}
}


function Add-XmlContent 
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[System.Object] $hashMap,
		[Parameter(Mandatory = $true, Position = 1)]
		[string] $xmlFilePath
	)
	
	begin 
	{
		$xmlContent = [xml] (Get-Content $xmlFilePath)
	}
	
	process 
	{
		# write info to the nuspec file
		foreach ($node in $hashMap.GetEnumerator()) 
		{
			$elementName = $node.Name
			$elementValue = $node.Value

			Write-Verbose "processing node '$elementName', with value '$elementValue'"

			if ($xmlContent.package.metadata.$elementName) 
			{
				Write-Verbose "Node found in the nuspec file"
				$xmlContent.package.metadata.$elementName = $elementValue
			}
			else 
			{
				Write-Verbose "Node not found in nuspec file"

				# creating a new node
				$NewNode = $xmlContent.CreateElement($elementName, $xmlContent.DocumentElement.NamespaceURI)
				$xmlContent.package.metadata.AppendChild($NewNode) | Out-Null

				Write-Verbose "New Node successfully created"
				$xmlContent.package.metadata.$elementName = $elementValue
			}
		} 
	}
	
	end 
	{
		$absoluteNupecPath = Resolve-Path -Path $xmlFilePath
		$xmlContent.Save($absoluteNupecPath)
		Write-Verbose "nuspec file saved in $absoluteNupecPath"
	}
}


function Complete-NuspecTemplateFile 
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
		[string] $NuspecFilePath,
		[Parameter(Mandatory = $true, Position = 1)]
		[string] $GithubRepo,
		[Parameter(Mandatory = $true, Position = 2)]
		[string] $packageName
	)
	
	begin 
	{
		$Owner, $RepoName = Split-GithubRepoName $GithubRepo

		# get the information about the repo
		$GithubRepoInfo = Get-GitHubRepository -Owner $Owner -Repository $RepoName
		$GithubLicenseInfo = Get-GitHubRepository -Owner $Owner -Repository $RepoName -License
		$GithubReadmeInfo = Get-GitHubRepository -Owner $Owner -Repository $RepoName -ReadMe

		# load local setting info
		$chocolateyId = Get-ChocolateyID
		$packageUrl = Get-GTCPackageRepoUrl

	}
	
	process 
	{
		# extract information:
		$RepoUrl = $GithubRepoInfo.html_url
		$licenseUrl = $GithubLicenseInfo.html_url
		$ReadmeContent = Start-DownloadString -Url $GithubReadmeInfo.download_url

		# consturct the hashMap
		$NuspecInfo = @{
			id = $packageName
			version = ''
			packageSourceUrl = $packageUrl
			owners = $chocolateyId
			title = $packageName
			authors = $GithubRepoInfo.owner.login
			licenseUrl = $licenseUrl
			requireLicenseAcceptance = 'true'  # defaulted to true
			projectSourceUrl = $RepoUrl
			projectUrl = $RepoUrl
			summary = $GithubRepoInfo.description
			description = $ReadmeContent
			releaseNotes = ''
		}

		if ($GithubRepoInfo.has_issues) 
		{
			$NuspecInfo.Add('bugTrackerUrl', "$RepoUrl/issues")
		}
		if ($GithubRepoInfo.has_wiki) 
		{
			$NuspecInfo.Add('docsUrl', "$RepoUrl/wikis")
		}
		
		
	}
	
	end 
	{
		# add the info in the hashMap to nuspec file
		Add-XmlContent -hashMap $NuspecInfo -xmlFilePath $NuspecFilePath
	}
}