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

### Setup

all you need to do is just:

```
❯ New-GTCSetting 
```

## Manage Existing Package

### 1. update

```
❯ Update-GTCPackage dnspy
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

### 1. create the package template
```
❯ New-GTCPackage -githubRepo 0xd4d/dnSpy -packageType zip -Regex32Bit dnSpy.zip
```

then make sure the template is okay (version and release note should be left blank in the nuspec file)

I personally will leave the install script nearly empty and deletes all the other files


### 2. update the package

```
❯ Update-GTCPackage dnspy 
```

### 3. pack test and push

```
❯ choco pack

❯ choco push
```


## see it in action

creating a new package template
![](https://github.com/chantisnake/github2choco/raw/master/assets/readme_image/new_package.gif)


update a single package
![](https://github.com/chantisnake/github2choco/raw/master/assets/readme_image/update_package.gif)
