function Add-InstallerToolsString {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $SavePath,
		[Parameter(Mandatory = $true)]
		[string] $packageName,
		[Parameter(Mandatory = $true)]
		[string] $githubRepo,
		[Parameter(Mandatory = $false)]
		[string] $Regex32bit,
		[Parameter(Mandatory = $false)]
		[string] $Regex64bit,
        [Parameter(Mandatory = $false)]
        [string] $installerType,
        [Parameter(Mandatory = $false)]
        [string] $ScilentArg
	)
	
	begin 
	{
		# set the install string
		$installStr = `
			"Install-ChocolateyPackage -packageName '$packageName' "

        if ($installerType) {
            $installStr += "-FileType $installerType "
            Write-Verbose "Add the installer type"
            Write-Verbose "the current install string is:"
            Write-Verbose "`t $installStr"
        }
        if ($ScilentArg) {
            $installStr += "-SilentArgs '$ScilentArg' "
            Write-Verbose "add the scilent args"
            Write-Verbose "the current install string is:"
            Write-Verbose "`t $installStr"
        }
	}
	
	process 
	{
		# get the url
		if ($IsSourceCode) 
		{
			$url32 = Get-DownloadUrl -GithubRepo $githubRepo -isSourceCode
		}
		else 
		{
			$url32, $url64 = Get-DownloadUrl -GithubRepo $githubRepo `
												-Regex32Bits $Regex32bit `
												-Regex64Bits $Regex64bit
		}

		# assembles the install str
		if ($url32) 
		{
			# get the hash for 32 bit assets and add it to the install str
			$hash32 = Get-DownloadFileHash -DownloadUrl $url32
			$installStr += "-Url '$url32' -checksum '$hash32' -checksumType 'sha256' "
			Write-Verbose "the 32 bit info is added to the install string"
			Write-Verbose "the current install string is:"
            Write-Verbose "`t $installStr"
		}
		else 
		{
			Read-Host 'the 32 bit download url press enter to continue and press Ctrl-C to stop'
		}
		if ($url64) 
		{
			# get the hash for 64 bit assets
			$hash64 = Get-DownloadFileHash -DownloadUrl $url64
			# add the 64 bit infomation to install str
			$installStr += "-Url64 '$url64' -checksum64 '$hash64' -checksumType64 'sha256' "
			Write-Verbose "the 64 bit info is added to the install string"
			Write-Verbose "the current install string is:"
            Write-Verbose "`t $installStr"
		}
		else 
		{
			Read-Host 'the 64 bit download url press enter to continue and press Ctrl-C to stop'
		}

		# no url found 
		if (-Not($url32 -or $url64)) {
			Write-Error -Category ResourceUnavailable -Message 'url of the download item not found in latest release'
		}
	}
	
	end 
	{
		# add the install string to the end of the chocolateyinstall file
		Write-Verbose "writing the install string to $SavePath\chocolateyinstall.ps1"
		Write-Verbose "the install String is: $installStr"
		$installStr | Add-Content "$SavePath\chocolateyinstall.ps1" -Encoding UTF8

	}
}

function New-InstallerVersionPackage  {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[psobject] $profile,
		[Parameter(Mandatory = $true)]
		[string] $GithubRepo,
		[Parameter(Mandatory = $true)]
		[string] $packageName
	)

	begin 
	{
		# load info from remote release
		$newVersion = Get-RemoteVersion -GithubRepo $GithubRepo
		$releaseNote = Get-ReleaseNote -GithubRepo $GithubRepo

		# load info from the local profile
		$Regex32bit = $profile.$packageName.Regex32bit
		$Regex64bit = $profile.$packageName.Regex64bit
		$packagePath = $profile.$packageName.packagePath
		$templatePath = $profile.$packageName.templatePath
		$installerType = $profile.$packageName.installerType
		$ScilentArg = $profile.$packageName.scilentArg
	}
	
	process 
	{
		# create the path
		$newPackagePath = "$packagePath\Versions\$newVersion"
		# use out-null to redirect the output to null. (do not show out put)
		New-Item $newPackagePath -ItemType Directory -Force -Confirm:$false | Out-Null
		Write-Verbose "creating the new package path: $newPackagePath"

		# copy everything in the template to the new packagePath
		Copy-Item -Path "$templatePath\*" -Destination $newPackagePath -Force -Recurse
		Write-Verbose "Copy all the item from template: $templatePath to the new package path: $newPackagePath"
	
	}

	end 
	{
		# create install scripts
		Add-InstallerToolsString -SavePath "$newPackagePath\tools" `
									-packageName $packageName -githubRepo $GithubRepo `
									-Regex32bit $Regex32bit -Regex64bit $Regex64bit `
									-installerType $installerType -ScilentArg $ScilentArg
									
		Write-NuspecFile -SavePath $newPackagePath -packageName $packageName -version $newVersion -releaseNote $releaseNote -templatePath $templatePath
		New-VersionLog -packagePath $packagePath -VersionNumber $newVersion
	}
	
	
}

function Update-InstallerChocoPackage {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string] $packageName,
		[Parameter(Mandatory = $false)]
		[bool] $Force
	)
	
	
	# log
	Write-Host ''
	Write-Host ''
	Write-Host "updating $packageName" -ForegroundColor Magenta

	# load variable
	$profile = Read-ChocoProfile
	$localVersion = $profile.$packageName.version
	$githubRepo = $profile.$packageName.githubRepo
	$remoteVersion = Get-RemoteVersion -GithubRepo $githubRepo

	# execute if not force
	if (-Not $Force) {
		if($remoteVersion -ne $localVersion) {
			$packageUpdated = New-InstallerVersionPackage -profile $profile -GithubRepo $githubRepo -packageName $packageName
		}
		else {
			Write-Host 'remote and local version match, exiting...' -ForegroundColor Green
			$packageUpdated = $false
		}
	}
	# force execute
	else {
		Write-Warning 'Force executing'
		$packageUpdated = New-InstallerVersionPackage -profile $profile -GithubRepo $githubRepo -packageName $packageName
	}

	# update the profile
	$profile.$packageName.version = $remoteVersion
	Save-Profile -localProfile $profile

	# tell the upstream whether the package is updated
	return $packageUpdated
}
