function Read-GTCSetting {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $GTCSettingPath = "$PSScriptRoot/../../github2chocoSetting.json"
        Write-Verbose "the github2choco setting path is: $([System.IO.Path]::GetFullPath($GTCSettingPath))"
    }
    
    process 
    {
        if (Test-Path $GTCSettingPath) 
        {
            Write-Verbose 'setting file found'
            $settings = Get-Content $GTCSettingPath -Encoding UTF8 | ConvertFrom-Json
        }
        else 
        {
            Write-Warning 'setting file not found, the everything will use the defualt value'
        }
        
    }
    
    end 
    {
        return $settings
    }
}


function Save-GTCSetting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [System.Object] $GTCSettings
    )
    
    begin 
    {
        $GTCSettingPath = "$PSScriptRoot/../../github2chocoSetting.json"
        Write-Verbose "the github2choco setting path is: $([System.IO.Path]::GetFullPath($GTCSettingPath))"
    }
    
    process 
    {
        ConvertTo-Json $GTCSettings | Out-File $GTCSettingPath -Encoding utf8
    }
    
    end 
    {
        Write-Verbose "the chocolatey profile is successfully saved to $([System.IO.Path]::GetFullPath($GTCSettingPath))"
    }
}


function New-GTCSetting {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $GTCSettingPath = "$PSScriptRoot/../../github2chocoSetting.json"
        Write-Verbose "the github2choco setting path is: $([System.IO.Path]::GetFullPath($GTCSettingPath))"
    }
    
    process 
    {
        $setting = @{}
        
        # chocolatey package path
        $chocolateyPackagePath = Read-Host "Please input your chocolatey package path"
        $setting.Add('chocolateyPackagePath', $(Resolve-Path -Path $chocolateyPackagePath).Path)

        # chocolatey package repo url
        $chocolateyPackageRepoUrl = Read-Host "Please input your chocolatey package repo url"
        $setting.Add('chocolateyPackageRepoUrl', $chocolateyPackageRepoUrl)

        # github2choco Profile location
        $GTCProfileLocation = Read-Host "Please input your github2choco profile location (full name of the profile)"
        $setting.Add('GTCProfileLocation', $(Resolve-Path -Path $GTCProfileLocation).Path)

        # chocolatey id, (for the owner field)
        $chocolateyId = Read-Host "Please input your chocolatey id"
        $setting.Add('chocolateyId', $chocolateyId)



    }
    
    end 
    {
        Save-GTCSetting -GTCSettings $setting
    }
}


function Get-ChocolateyID 
{
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $Settings = Read-GTCSetting
    }
    
    process 
    {
    }
    
    end 
    {
        return $Settings.chocolateyId
    }
}


function Get-GTCPackagePath {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $GTCSettings = Read-GTCSetting
        $defaultChocolateyPackagePath =  "$HOME/chocolateyPackage"
    }
    
    process 
    {

    }
    
    end 
    {
        if ($GTCSettings.chocolateyPackagePath) 
        {
            Write-Verbose "get choco package path successful, the path is: $($GTCSettings.chocolateyPackagePath)"
            return $GTCSettings.chocolateyPackagePath
        }
        else 
        {
            Write-Warning 'get choco package path unsuccessful, use the defualt choco package path'
            Write-Verbose "the defualt value is $defaultChocolateyPackagePath"
            return $defaultChocolateyPackagePath
        }
        
    }
}


function Get-GTCPackageRepoUrl {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $GTCSettings = Read-GTCSetting
    }
    
    process 
    {

    }
    
    end 
    {
        if ($GTCSettings.chocolateyPackageRepoUrl) 
        {
            Write-Verbose "get choco package repo url successful, the repo url is: $($GTCSettings.chocolateyPackagePath)"
            return $GTCSettings.chocolateyPackageRepoUrl
        }
        else 
        {
            Write-Warning 'get choco package path unsuccessful, use the defualt choco package path'
            Write-Verbose "the defualt value is empty"
            return $null
        }
        
    }
}


function Get-GTCProfileLocation {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $GTCSettings = Read-GTCSetting
        $defualtGTCProfileLocation = "$(Get-GTCPackagePath)/github2chocoProfile.json" 
    }
    
    process 
    {

    }
    
    end 
    {
        if ($GTCSettings.GTCProfileLocation) 
        {
            Write-Verbose "get choco profile location successful, the profile location is: $($GTCSettings.GTCProfileLocation)"
            return $GTCSettings.GTCProfileLocation
        }
        else 
        {
            Write-Warning 'get choco package path unsuccessful, use the defualt choco package path'
            Write-Verbose "the defualt value is $defualtGTCProfileLocation"
            return  $defualtGTCProfileLocation
        }
        
    }
}
