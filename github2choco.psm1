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
        $UpdatedPackagesName = New-Object System.Collections.ArrayList

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
                    $UpdatedPackagesName.Add($packageName)
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
                    $UpdatedPackagesName.Add($packageName)
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

Export-ModuleMember -Function *