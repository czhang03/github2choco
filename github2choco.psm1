# load all the helpers
Get-ChildItem ./Helpers | ForEach-Object {. "./Helpers/$_"}
# load all the pakcage Writers
Get-ChildItem ./PackageWriters | ForEach-Object {. "./PackageWriters/$_"}


function Update-ChocoPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $packageName,
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )
    
    begin 
    {
        $profile = Read-ChocoProfile
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
                Default {Write-Error "Package type not valid"}
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


function Update-AllChocoPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )
    
    begin 
    {
        $profile = Read-ChocoProfile
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
                $packageUpdated = Update-ChocoPackage -packageName $packageName -Force
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
                $packageUpdated = Update-ChocoPackage -packageName $packageName 
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