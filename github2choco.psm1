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
        $profile = Read-LocalProfile
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
        
        switch ($profile.$packageName.packageType) {
            'installer' {Update-InstallerChocoPackage -packageName $packageName -Force $Force}
            'vsix' {Update-VsixChocoPackage -packageName $packageName -Force $Force}
            'webFile' {Update-WebFileChocoPackage -packageName $packageName -Force $Force}
            'zip' {Update-ZipChocoPackage -packageName $packageName -Force $Force}
            Default {Write-Error "Package type not valid"}
        }
    }
    
    end
    {
        
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
        $profile = Read-LocalProfile
        $packageNames = $profile | Get-Member -MemberType NoteProperty | ForEach-Object {$_.Name}
    }
    
    process
    {
        # force execute
        if ($Force) 
        {
            foreach ($packageName in $packageNames) 
            {
                Update-ChocoPackage -packageName $packageName -Force
            }
        }
        
        # not force execute
        else 
        {
            foreach ($packageName in $packageNames) 
            {
                # regular log
                Write-Host ''
                Write-Host ''

                # verbose log
                Write-Verbose "updating Package $packageName" 
                Write-Verbose "the package Type is: $($profile.$packageName.packageType)"
                Write-Verbose "the package Local Version is: $($profile.$packageName.version)"
                Write-Verbose "the package github repo is: $($profile.$packageName.githubRepo)"

                switch ($profile.$packageName.packageType) {
                    'installer' { Update-InstallerChocoPackage -packageName $packageName}
                    'vsix' {Update-VsixChocoPackage -packageName $packageName}
                    'webFile' {Update-WebFileChocoPackage -packageName $packageName}
                    'zip' {Update-ZipChocoPackage -packageName $packageName}
                    Default {Write-Error "Package type not valid"}
                }
            }
        }
        
        
    }
    
    end
    {
        
    }
}