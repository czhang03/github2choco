function Start-DownloadFile {
    <#
    .SYNOPSIS
        download a file using .NET WebClient
    
    .DESCRIPTION
        Download a file from $Url to $Destination
        using agent firefox and encoding UTF-8

    .PARAMETER Url
        the Url of the file you want to download

    .PARAMETER Destination
        the Destination that you want to put the file in
    
    .EXAMPLE
        PS C:\> Start-DownloadFile -Url 'https://github.com/soimort/you-get/releases/download/v0.4.595/you-get-0.4.595-win32-full.7z' -Destination "$env:temp\test.7z""
        download the you-get release to temp dir (~/AppData/Local/Temp)
        
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Url,
        [Parameter(Mandatory = $true)]
        [String] $Destination
    )
    
    Write-Verbose "Downloading $Url" 

    # initialize
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
    Write-Verbose "setup porxy"
    $webClient = New-Object Net.WebClient
    $webClient.Headers.Add('user-agent', [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox)
    Write-Verbose 'Set the user agent to firefox' 
	$webClient.Encoding = [System.Text.Encoding]::UTF8
    Write-Verbose 'Set the encoding to UTF-8'

    # start download
    Write-Verbose "downloading $Url to $Destination"
    $webClient.DownloadFile($Url, $Destination)
    
}

function Start-DownloadString {
    <#
    .SYNOPSIS
        get a web content using .NET WebClient
    
    .DESCRIPTION
        get the content from $Url
        using agent firefox and encoding UTF-8

    .PARAMETER Url
        the url of the web content you want to get
    
    .EXAMPLE
        PS C:\> Start-DownloadString -Url 'https://api.github.com/repos/soimort/you-get/releases'
        download the you-get release api message

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Url
    )
    
    Write-Verbose "Downloading $Url" 

    # initialize
    $webClient = New-Object Net.WebClient
    $webClient.Headers.Add('user-agent', [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox)
    Write-Verbose 'Set the user agent to firefox' 
	$webClient.Encoding = [System.Text.Encoding]::UTF8
    Write-Verbose 'Set the encoding to UTF-8'

    # start download
    Write-Verbose "downloading content of $Url"
    $result = $webClient.DownloadString($Url)

    return $result
    
}


function Split-GithubRepoName {
    <#
    .SYNOPSIS
        convert the github repo name from 'Owner/Repo' to 'Owner' and 'Repo'
    
    .DESCRIPTION
        Takes input of a string with form 'Owner/Repo' and return 'Owner' and 'Repo'
        This function is to make this compatable with PSGithub
    
    .EXAMPLE
        # this makes $Owner equal 'Powershell' and $Repo equal 'vscode-powershell'
        PS C:\> $Owner, $Repo = Split-GithubRepoName 'PowerShell/vscode-powershell'
    
    .PARAMETER GithubRepo
        the repo name in the form 'Owner/Repo'

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string] $GithubRepo
    )

    return $GithubRepo -split '/'

}
