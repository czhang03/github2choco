function Read-ChocoSetting {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $chocoSettingPath = "$PSScriptRoot/../.."
        Write-Verbose "the github2choco setting path is: $([System.IO.Path]::GetFullPath($chocoSettingPath))"
    }
    
    process 
    {
        if (Test-Path $chocoSettingPath) 
        {
            Write-Verbose 'setting file found'
            $settings = Get-Content $chocoSettingPath -Encoding UTF8 | ConvertFrom-Json
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


function Save-ChocoSetting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [System.Object] $ChocoSettings
    )
    
    begin 
    {
        $chocoSettingPath = "$PSScriptRoot/../.."
        Write-Verbose "the github2choco setting path is: $([System.IO.Path]::GetFullPath($chocoSettingPath))"
    }
    
    process 
    {
        ConvertTo-Json $ChocoSettings | Out-File $chocoSettingPath -Encoding utf8
    }
    
    end 
    {
        Write-Verbose "the chocolatey profile is successfully saved to $([System.IO.Path]::GetFullPath($chocoSettingPath))"
    }
}


function New-ChocoSetting {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $chocoSettingPath = "$PSScriptRoot/../.."
        Write-Verbose "the github2choco setting path is: $([System.IO.Path]::GetFullPath($chocoSettingPath))"
    }
    
    process 
    {
        $setting = @{}
        
        # chocolatey package path
        $chocolateyPackagePath = Read-Host "Please input your chocolatey package path: "
        $setting.Add('chocolateyPackagePath', $chocolateyPackagePath)

        # chocolatey package repo url
        $chocolateyPackageRepoUrl = Read-Host "Please input your chocolatey package repo url: "
        $setting.Add('chocolateyPackageRepoUrl', $chocolateyPackageRepoUrl)

        # github2choco Profile location
        $chocoProfileLocation = Read-Host "Please input your github2choco profile location (full name of the profile): "
        $setting.Add('chocoProfileLocation', $chocoProfileLocation)

    }
    
    end 
    {
        Save-ChocoSetting -ChocoSettings $setting
    }
}


function Get-ChocoPackagePath {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $chocoSettings = Read-ChocoSetting
        $defaultChocolateyPackagePath =  "$HOME/chocolateyPackage"
    }
    
    process 
    {

    }
    
    end 
    {
        if ($chocoSettings.chocolateyPackagePath) 
        {
            Write-Verbose "get choco package path successful, the path is: $($chocoSettings.chocolateyPackagePath)"
            return $chocoSettings.chocolateyPackagePath
        }
        else 
        {
            Write-Warning 'get choco package path unsuccessful, use the defualt choco package path'
            Write-Verbose "the defualt value is $defaultChocolateyPackagePath"
            return $defaultChocolateyPackagePath
        }
        
    }
}


function Get-ChocoPackageRepoUrl {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $chocoSettings = Read-ChocoSetting
    }
    
    process 
    {

    }
    
    end 
    {
        if ($chocoSettings.chocolateyPackageRepoUrl) 
        {
            Write-Verbose "get choco package repo url successful, the repo url is: $($chocoSettings.chocolateyPackagePath)"
            return $chocoSettings.chocolateyPackageRepoUrl
        }
        else 
        {
            Write-Warning 'get choco package path unsuccessful, use the defualt choco package path'
            Write-Verbose "the defualt value is empty"
            return $null
        }
        
    }
}


function Get-ChocoProfileLocation {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $chocoSettings = Read-ChocoSetting
        $defualtChocoProfileLocation = "$(Get-ChocoPackagePath)/github2chocoProfile.json" 
    }
    
    process 
    {

    }
    
    end 
    {
        if ($chocoSettings.chocoProfileLocation) 
        {
            Write-Verbose "get choco profile location successful, the profile location is: $($chocoSettings.chocoProfileLocation)"
            return $chocoSettings.chocoProfileLocation
        }
        else 
        {
            Write-Warning 'get choco package path unsuccessful, use the defualt choco package path'
            Write-Verbose "the defualt value is $defualtChocoProfileLocation"
            return  $defualtChocoProfileLocation
        }
        
    }
}
