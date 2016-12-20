# GitHub 2 Choco

the insane way to create and manage your chocolatey package

**Please notice this package is still under development**

## Create package

creating a package is super easy:

### 1. Add the package detail to `profile.json` in the package root:

example:

```
{
    "rocket.chat":  {
                            "packagePath":  "$HOME\\GithubRepos\\chocolateyPackage\\rocketchatelectron-choco",
                            "templatePath":  "$HOME\\GithubRepos\\chocolateyPackage\\rocketchatelectron-choco\\rocket.chat",
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
mkdir rocketchatelectron-choco
```

### 3. Create the template via `choco new`

```
❯ choco new rocket.chat
```


### 4. Edit the template

```
code rocket.chat/
```

you can find my template for `rocket.chat` here: https://github.com/chantisnake/chocolateyPackage/tree/master/rocketchatelectron-choco/rocket.chat


### 5. Let GitHub magic take care of it all!

```
❯ Update-InstallerPackage 'rocket.chat'

```

### 6. Pack, Test and Push

your package is lying safe and sound in `~\GithubRepos\chocolateyPackage\rocketchatelectron-choco\Versions\`

just 
```
❯ choco pack


❯ choco push
```


## Manage Existing package

### 1. update

```
❯ Update-InstallerPackage 'rocket.chat'

```

### 2. pack, test and push

```
❯ choco pack
Attempting to build package from 'rocket.chat.nuspec'.
Successfully created package 'rocket.chat.1.3.1.nupkg'


❯ choco push
Attempting to push rocket.chat.1.3.1.nupkg to https://chocolatey.org/
rocket.chat 1.3.1 was pushed successfully to https://chocolatey.org/

Your package may be subject to moderation. A moderator will review the
package prior to acceptance. You should have received an email. If you
don't hear back from moderators within 1-3 business days, please reply
to the email and ask for status or use contact site admins on the
package page to contact moderators.

Please ensure your registered email address is correct and emails from
chocolateywebadmin at googlegroups dot com are not being sent to your
spam/junk folder.
```

### 3. DONE and DONE!
