function Get-RemoteVersion {
	<#
	.SYNOPSIS
		this gives the latest version of the github package
	
	.DESCRIPTION
		this command uses github api to get the latest version of the package, assume the tag is in the form: "v$version"
	
	.EXAMPLE
		PS C:\> Get-RemoteVersion -GithubRepo 'Powershell/powershell-vscode'
		this gives the latest version of 'Powershell/powershell-vscode
	
	.PARAMETER GithubRepo
		the github repo name in the form 'Owner/Repo'

	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string] $GithubRepo
	)

	begin {
		# split the name to be compatiable with PSGithub
		$Owner, $RepoName = Split-GithubRepoName -GithubRepo $GithubRepo
	}

	process {
		# get the latest repo via github api
		$remoteRelease = Get-GitHubRelease -Owner $Owner -Repository $RepoName -Latest	
	}

	end {
		# get the tagname
 		$tag = $remoteRelease.tag_name.toLower()
		Write-Verbose "got the tag of the latest release the tag name is $tag"

		# remove the leading v in the tag name
		$version = $tag.Replace('v', '')

		return $version
	}
	
}

function Get-ReleaseNote {
	<#
	.SYNOPSIS
		this gives the latest release note of the github package
	
	.DESCRIPTION
		this command uses github api to get the latest release not of the package
	
	.EXAMPLE
		PS C:\> Get-ReleaseNote -GithubRepo 'Powershell/powershell-vscode'
		this gives the latest release note of 'Powershell/powershell-vscode
	
	.PARAMETER GithubRepo
		the github repo name in the form 'Owner/Repo'

	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string] $GithubRepo
	)

	begin {
		# split the name to be compatiable with PSGithub
		$Owner, $RepoName = Split-GithubRepoName -GithubRepo $GithubRepo
	}

	process {
		# get the latest repo via github api
		$remoteRelease = Get-GitHubRelease -Owner $Owner -Repository $RepoName -Latest	
	}

	end {
		return $remoteRelease.body.replace("\n", "`r`n")
	}
	
}



function Get-AssetsDownloadUrl {
	<#
	.SYNOPSIS
		this get the download url of the assets, which the name matches the regex provided

	.DESCRIPTION
		This cmdlet get the download url (browser_download_url of the release assets), the regex matching uses '-like' parameter of powershell

	.EXAMPLE
		explaination
		PS C:\> example usage

	.PARAMETER GithubRepo
		the github repo name in the form of 'Owner/Repo'

	.PARAMETER Regex
		the regular expression for the assets' name to match

	.NOTES 
		Helper for `Get-DownloadUrl`
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string] $GithubRepo,
		[Parameter(Mandatory = $true)]
		[string] $Regex
	)

	begin {
		# split the repo name to compatiable with PSGithub
		$Owner, $RepoName = Split-GithubRepoName -GithubRepo $GithubRepo

		# get the release
		$Release = Get-GitHubRelease -Owner $Owner -Repository $RepoName -Latest

		# get the assets
		$Assets = $Release.assets
		Write-Verbose 'Gets the following assets'
		foreach ($Asset in $Assets) 
		{
			Write-Verbose "name is $($Asset.name)"
			Write-Verbose "uploaded by $($Asset.uploader.login)"
			Write-Verbose "created at is  $($Asset.created_at)"
			Write-Verbose "updated at $($Asset.updated_at)"
			Write-Verbose "download url is $($Asset.browser_download_url)"
			Write-Verbose ""
		}
	}

	process {
		$matchedAssets = $Assets | Where-Object {$_.name -like $Regex}
		Write-Verbose "here is all the assets matched the regex."
		foreach ($Asset in $matchedAssets) 
		{
			Write-Verbose "name is $($Asset.name)"
			Write-Verbose "uploaded by $($Asset.uploader.login)"
			Write-Verbose "created at is  $($Asset.created_at)"
			Write-Verbose "updated at $($Asset.updated_at)"
			Write-Verbose "download url is $($Asset.browser_download_url)"
			Write-Verbose ""
		}

	}

	end {
		# check the number of the matchedAssets
		if(-Not ($matchedAssets))
		{
			# there is no assets' name matches the regex
			Write-Error `
				-Message "No assets found match the regex you provided, here is the regex you provide: $Regex" `
				-Category InvalidArgument 
		}
		elseif ($matchedAssets.Count -gt 1) 
		{
			# there is more than one assets matches the regex
			Write-Error `
				-Message "More than one assets matches the regex you provided, here is the regex you provide: $Regex" `
				-Category InvalidArgument 
		}
		else {
			# only one assets match the regex 
			Write-Verbose "Only one assets matches the regex you provide: $Regex"
			Write-Verbose "the download Url of that asset is: $($matchedAssets[0].browser_download_url)"
			return $matchedAssets[0].browser_download_url
		}
	}
}


function Get-SourceDownloadUrl {
	<#
	.SYNOPSIS
		This get the download url for the source code
	
	.DESCRIPTION
		This cmdlet will the zipball_url (source code in zip) of the latest release for a given GithubRepo
	
	.EXAMPLE
		PS C:\> Get-SourceDownloadUrl -GithubRepo 'WheatonCS/Lexos'
		this will get the latest zipball_url of 'WheatonCS/Lexos'
	
	.PARAMETER GithubRepo
		the github repo in the form: 'Owner/RepoName'

	.NOTES
		This is a helper for `Get-DownloadUrl`
	
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[String] $GithubRepo
	)
	
	begin 
	{
		# get the owner and the repo name of the repo
		$Owner, $RepoName = Split-GithubRepoName $GithubRepo
		# get the github release
		$release = Get-GitHubRelease -Owner $Owner -Repository $RepoName -Latest
	}
	
	process
	{
		$sourceCodeUrl = $release.zipball_url
		Write-Verbose "the sourse code Url is $sourceCodeUrl"	
	}
	
	end
	{
		return $sourceCodeUrl
	}
}


function Get-DownloadUrl {
	<#
	.SYNOPSIS
		This cmdlet gets all the download Url you need.
	
	.DESCRIPTION
		This cmdlet does one of the following 2 things:
		1. if you want the source code, it will return the source code download url as the 32 bits download url
		2. if you want the asstes, this cmdlet 	will give a url32 for the asset matches Regex32bit
												will give a url64 for the asset matches	Regex64bit

	.PARAMETER GithubRepo
		The name of the github repo in the form: 'Owner/RepoName'

	.PARAMETER Regex32bit
		The regex for 32 bit assets

	.PARAMETER Regex64bit
		The regex for 64 bit assets

	.PARAMETER isSourceCode
		A switch to indicate whether the download needed is the source code 
		(this would be a package that only need to exract the source code)

	.EXAMPLE
		PS C:\>	Get-DownloadUrl -GithubRepo 'shadowsocks/shadowsocks-windows' -Regex32Bits shadowsocks-*.zip
		This will return download url of shadowsocks as $url32, and $url64 will be $null, because we did not provide a 64bit assets url.

	.EXAMPLE
		PS C:\> Get-DownloadUrl -GithubRepo 'WheatonCS/Lexos' -isSourceCode
		This will return the source code url of the latest Lexos release as $Url32, and $url64 will be $null
	
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string] $GithubRepo,
		[Parameter(Mandatory = $false, ParameterSetName = 'assets')]
		[string] $Regex32Bits,
		[Parameter(Mandatory = $false, ParameterSetName = 'assets')]
		[string] $Regex64Bits,
		[Parameter(ParameterSetName = 'source')]
		[switch] $isSourceCode
	)
	
	process
	{
		if ($isSourceCode) 
		{
			# return the source code download url
			$url32 = Get-SourceDownloadUrl -GithubRepo $GithubRepo
		}	

		else 
		{
			# return the assets download url
			# get the 32bit download url
			if ($Regex32Bits) 
			{
				# if Regex32bit is provided
				Write-Verbose "the 32 bits regex is: $Regex32Bits"
				$url32 = Get-AssetsDownloadUrl -GithubRepo $GithubRepo -Regex $Regex32Bits
			}
			else 
			{
				Write-Verbose "the 32 bit is not provided" 
			}

			# get the 64 bits download url
			if ($Regex64Bits) {
				# if Regex64bit is provided
				Write-Verbose "the 64 bits regex is: $Regex64Bits"
				$url64 = Get-AssetsDownloadUrl -GithubRepo $GithubRepo -Regex $Regex64Bits
			}
			else 
			{
				Write-Verbose "the 64 bit regex is not provided"
			}
		}
	}
	
	end
	{
		return $url32, $url64
	}
}


function Get-DownloadFileHash {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string] $DownloadUrl
	)
	begin 
	{		
		# set the download destination
		$DownloadDestination = "$env:TEMP\installer"

		# Start downloading
		Write-Host "Starting download file from: $DownloadUrl"
		Start-DownloadFile -Url $DownloadUrl -Destination $DownloadDestination
		Write-Host "Download File finished" -ForegroundColor Green
	}

	process
	{
		# get the file hash
		$hash = (Get-FileHash -Path $DownloadDestination -Algorithm SHA256).hash
		Write-Host "the SHA256 hash of the file is: $hash"
	}
	
	end
	{
		return $hash
	}
}
