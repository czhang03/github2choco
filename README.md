# GitHub 2 Choco

the insane way to create and manage your chocolatey package

**Please notice this package is still under development**

## Install

you can install this module from PowerShell Gallery

```
Install-Module github2choco
```

### Dependency

This module requires [PSGitHub](https://github.com/pcgeek86/PSGitHub).

you can set it up with the following command:

``` 
❯ Install-Module PSGitHub

❯ Import-Module PSGitHub

❯ Set-GitHubToken
```

## Manage Existing Package

### 1. update

```
❯ Update-GTCPackage 'rocket.chat'
```

or simply

```
❯ Update-AllGTCPackage
```

### 2. pack, test and push

```
❯ choco pack

❯ choco push
```

### 3. DONE and DONE!

## Create Package

creating a package is super easy:

### 1. Add the package detail to `profile.json` in the package root:

example:

```
{
    "rocket.chat":  {
                            "packagePath":  "~\\GithubRepos\\chocolateyPackage\\rocketchatelectron-choco",
                            "templatePath":  "~\\GithubRepos\\chocolateyPackage\\rocketchatelectron-choco\\rocket.chat",
                            "version":  "",
                            "Regex64Bit":  "rocketchat-*-win32-x64.exe",
                            "githubRepo":  "RocketChat/Rocket.Chat.Electron",
                            "installerType":  "exe",
                            "scilentArg":  "/S",
                            "packageType":  "installer"
                        }
}
```


### 2. Create the package path

```
❯ mkdir rocketchatelectron-choco
```

### 3. Create the template via `choco new`

```
❯ choco new rocket.chat
```


### 4. Edit the template

```
❯ code rocket.chat/
```

you can find my template for `rocket.chat` here: https://github.com/chantisnake/chocolateyPackage/tree/master/rocketchatelectron-choco/rocket.chat


### 5. Let GitHub magic take care of it all!

```
❯ Update-GTCPackage 'rocket.chat'
```

### 6. Pack, Test and Push

your package is lying safe and sound in `~\GithubRepos\chocolateyPackage\rocketchatelectron-choco\Versions\`

just 
```
❯ choco pack

❯ choco push
```

