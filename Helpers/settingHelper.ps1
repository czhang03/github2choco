function Read-GTCSetting {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $chocoSettingPath = "$PSScriptRoot/../github2chocoSetting.json"
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


function Save-GTCSetting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [System.Object] $ChocoSettings
    )
    
    begin 
    {
        $chocoSettingPath = "$PSScriptRoot/../github2chocoSetting.json"
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


function New-GTCSetting {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $chocoSettingPath = "$PSScriptRoot/../github2chocoSetting.json"
        Write-Verbose "the github2choco setting path is: $([System.IO.Path]::GetFullPath($chocoSettingPath))"
    }
    
    process 
    {
        $setting = @{}
        
        # chocolatey package path
        $chocolateyPackagePath = Read-Host "Please input your chocolatey package path"
        $setting.Add('chocolateyPackagePath', $chocolateyPackagePath)

        # chocolatey package repo url
        $chocolateyPackageRepoUrl = Read-Host "Please input your chocolatey package repo url"
        $setting.Add('chocolateyPackageRepoUrl', $chocolateyPackageRepoUrl)

        # github2choco Profile location
        $GTCProfileLocation = Read-Host "Please input your github2choco profile location (full name of the profile)"
        $setting.Add('GTCProfileLocation', $GTCProfileLocation)

        # chocolatey id, (for the owner field)
        $chocolateyId = Read-Host "Please input your chocolatey id"
        $setting.Add('chocolateyId', $chocolateyId)



    }
    
    end 
    {
        Save-GTCSetting -ChocoSettings $setting
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
        $chocoSettings = Read-GTCSetting
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


function Get-GTCPackageRepoUrl {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $chocoSettings = Read-GTCSetting
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


function Get-GTCProfileLocation {
    [CmdletBinding()]
    param (
        
    )
    
    begin 
    {
        $chocoSettings = Read-GTCSetting
        $defualtGTCProfileLocation = "$(Get-GTCPackagePath)/github2chocoProfile.json" 
    }
    
    process 
    {

    }
    
    end 
    {
        if ($chocoSettings.GTCProfileLocation) 
        {
            Write-Verbose "get choco profile location successful, the profile location is: $($chocoSettings.GTCProfileLocation)"
            return $chocoSettings.GTCProfileLocation
        }
        else 
        {
            Write-Warning 'get choco package path unsuccessful, use the defualt choco package path'
            Write-Verbose "the defualt value is $defualtGTCProfileLocation"
            return  $defualtGTCProfileLocation
        }
        
    }
}
