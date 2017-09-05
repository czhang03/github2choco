# load all the helpers
Get-ChildItem $PSScriptRoot/Helpers | ForEach-Object {. "$PSScriptRoot/Helpers/$_"}
# load all the pakcage Writers
Get-ChildItem $PSScriptRoot/PackageWriters | ForEach-Object {. "$PSScriptRoot/PackageWriters/$_"}

function Update-GTCPackage {
    <#
    .SYNOPSIS
        Update a choco package

    .DESCRIPTION
        Update a package that is in the `profile.json` and return whether the package is updated

    .OUTPUTS
        A boolean value indicate whether the package is updated

    .PARAMETER packageName
        The name (id) of the package, it is the keys in `profile.json`

    .PARAMETER Force
        Whether to force execute the update.
        Normal update stop when the remote version matches the local version,
        but a force update will update the package to the latest release regardless of the version number
        Notice if this parameter is applied, the output of this cmdlet will always be $true

    .EXAMPLE
        PS C:\> Update-GTCPackage you-get
        update the package with name 'you-get' (if local is already on the latest release, this will just exit)

    .EXAMPLE
        PS C:\> Update-GTCPackage you-get -Force
        update the package with name 'you-get' to the latest release regardless of the version number

    .NOTES
        This will only write the latest version, so it is possible that you may miss versions.
        For example if your local version is on 1.0,
        and on github there is 2.0 and 3.0, this cmdlet will update the package to 3.0 and miss 2.0

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $packageName,
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    begin
    {
        $profile = Read-GTCProfile
    }

    process
    {
        # regular log
        Write-Host ''
        Write-Host ''

        # verbose log
        Write-Verbose "updating Package $packageName"
        Write-Verbose "the package Type is: $($profile.$packageName.packageType)"
        Write-Verbose "the package Local Version is: $($profile.$packageName.version)"
        Write-Verbose "the package github repo is: $($profile.$packageName.githubRepo)"

        try
        {
             switch ($profile.$packageName.packageType)
             {
                'installer' {$packageUpdated = Update-InstallerChocoPackage -packageName $packageName -Force $Force -ErrorAction Stop}
                'vsix' {$packageUpdated = Update-VsixChocoPackage -packageName $packageName -Force $Force -ErrorAction Stop}
                'webFile' {$packageUpdated = Update-WebFileChocoPackage -packageName $packageName -Force $Force -ErrorAction Stop}
                'zip' {$packageUpdated = Update-ZipChocoPackage -packageName $packageName -Force $Force -ErrorAction Stop}
                Default {Write-Error "Package type not valid for $packageName"}
            }
        }
        catch
        {
            Write-Host ""
            Write-Host "the following Error encounterd while updating $packageName :" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            $packageUpdated = $false
            Write-Host "package update fail, see more info using parameter verbose" -ForegroundColor Yellow
        }

    }

    end
    {
        return $packageUpdated
    }
}


function Update-AllGTCPackage {
    <#
    .SYNOPSIS
        Update all the choco package you created

    .DESCRIPTION
        Update all the package inside `profile.json` and give you a list of package name of the package that is updated

    .PARAMETER Force
        Whether to force execute the update for all package.
        See the doc for `Update-GTCPackage` for more detail

    .OUTPUTS
        A list of package names of the package that has been updated

    .EXAMPLE
        PS C:\> Update-AllChocoPackage
        This will just update all the choco package that is in your profile

    .NOTES
        This just goes through the profile and invoke `Update-GTCPackage` on each one.
        Therefore reading the doc on `Update-GTCPackage` may be helpfull

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    begin
    {
        $profile = Read-GTCProfile
        $packageNames = $profile | Get-Member -MemberType NoteProperty | ForEach-Object {$_.Name}
    }

    process
    {
        # a list contain all the name of the updated packages
        $UpdatedPackagesName = @()

        # force execute
        if ($Force)
        {
            foreach ($packageName in $packageNames)
            {
                #update package
                $packageUpdated = Update-GTCPackage -packageName $packageName -Force
                # add to the updated packages if the package is updated
                if ($packageUpdated)
                {
                    $UpdatedPackagesName += $packageName
                }
            }
        }

        # not force execute
        else
        {
            foreach ($packageName in $packageNames)
            {
                #update package
                $packageUpdated = Update-GTCPackage -packageName $packageName
                # add to the updated packages if the package is updated
                if ($packageUpdated)
                {
                    $UpdatedPackagesName += $packageName
                }
            }
        }
    }

    end
    {
        # tell the upstream which is updated
        return $UpdatedPackagesName
    }
}

function New-GTCPackage
{
    [CmdletBinding(DefaultParameterSetName = 'general')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $githubRepo,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $packageType,
        [Parameter(Mandatory = $false)]
        [string] $packageName,
        [Parameter(Mandatory = $false)]
        [string] $packagePath,
        [Parameter(Mandatory = $false)]
        [string] $templatePath,
        [Parameter(Mandatory = $false)]
        [string] $Regex32Bit,
        [Parameter(Mandatory = $false)]
        [string] $Regex64Bit,
        [Parameter(Mandatory = $false, ParameterSetName = 'zip')]
        [switch] $isSourceCode,
        [Parameter(Mandatory = $false, ParameterSetName = 'installer')]
        [string] $installerType,
        [Parameter(Mandatory = $false, ParameterSetName = 'installer')]
        [string] $silentArg
    )

    begin
    {
        $GTCProfile = Read-GTCProfile
        $GTCProfileLocation = Get-GTCProfileLocation

        $Owner, $RepoName = Split-GithubRepoName -GithubRepo $githubRepo
    }

    process
    {

        try
        {
            ###### finish the profile setup ########

            # get package name
            if (-Not ($packageName))
            {
                $packageName = $RepoName
                Write-Verbose "package name not provided using the repo name: $RepoName as the package name"
            }

            # get package path
            if (-Not ($packagePath))
            {
                $packagePath = Join-Path -Path $(Get-GTCPackagePath) -ChildPath "$packageName-choco"
                Write-Verbose "package path not provided using the Default:"
                Write-Verbose $packagePath
            }
            else
            {
                $packagePath = $(Resolve-Path -Path $packagePath).Path
            }

            # get template path
            if ( -Not ($templatePath))
            {
                $templatePath = Join-Path -Path $packagePath -ChildPath 'template'
                Write-Verbose "template path not provided using the Default:"
                Write-Verbose $templatePath
            }
            else
            {
                $templatePath = $(Resolve-Path -Path $templatePath).Path
            }

            New-ProfileItem -githubRepo $githubRepo -packageType $packageType `
                            -packageName $packageName -packagePath $packagePath `
                            -templatePath $templatePath -Regex32Bit $Regex32Bit -Regex64Bit $Regex64Bit `
                            -isSourceCode $isSourceCode -silentArg $silentArg -installerType $installerType -ErrorAction Stop

            ##### finish the new template #######

            # get the path name and the folder name
            $templateParentPath = Split-Path $templatePath -Parent
            $templateFolderName = Split-Path $templatePath -Leaf

            # create the package and template path
            Write-Verbose "creating package path and the parent folder of templatePath"
            if ($packagePath -ne $templateParentPath)
            {
                New-Item -Path $packagePath -ItemType Directory | Out-Null
                New-Item -Path $templateParentPath -ItemType Directory | Out-Null
            }
            else
            {
                New-Item -Path $packagePath -ItemType Directory | Out-Null
            }


            # create the template folder
            $CurrentLocation = Get-Location
            Set-Location $templateParentPath
            Write-Verbose "change directory to $templateParentPath"

            Write-Verbose "starts to run `choco new` command"
            choco.exe new $packageName | Out-Null
            Write-Verbose "renaming the folder $templateParentPath\$packageName to $templatePath"
            Rename-Item -LiteralPath "$templateParentPath\$packageName" -NewName $templateFolderName

            Write-Verbose "change the directory back to $CurrentLocation"
            Set-Location $CurrentLocation

            Write-Host "the template folder is sucessfully created" -ForegroundColor Green

            # complete the nuspec file
            Complete-NuspecTemplateFile `
                -NuspecFilePath "$templatePath/$packageName.nuspec" -GithubRepo $githubRepo -packageName $packageName

            Write-Host "the nuspec file is completed" -ForegroundColor Green


            ### end ###
            Write-Host "the new package creation is completed" -ForegroundColor Green
            Write-Warning "Please go to $templatePath to make sure the template is okay."
            Write-Warning "Please go to $GTCProfileLocation to make sure profile is okay."
            Write-Host "if both is okay for you, run `Update-AllChocoPackage` command to update your new package"
        }
        catch
        {
            Write-Host ""
            Write-Host "the following Error encounterd while creating package $packageName :" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            Write-Host "package creation fail, see more info using parameter verbose" -ForegroundColor Yellow
            return
        }

    }

    end
    {

    }
}

Export-ModuleMember -Function *
