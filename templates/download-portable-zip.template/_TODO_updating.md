# Checklist for maintainer updating the package for a new version of the software

## To do

1. [ ] `[[PackageName]].nuspec`: Update `version`.
2. [ ] `[[PackageName]].nuspec`: Update `releaseNotes`.
3. [ ] `[[PackageName]].nuspec`: Verify URLs.
4. [ ] `chocolateyInstall.ps1`: Update `url`.
5.  [ ] `chocolateyInstall.ps1`: Update `url64`.
6.  [ ] `chocolateyUninstall.ps1`: Update `ZipFileName`.
7.  [ ] Test the package to ensure upgrade/uninstall/install works appropriately.
    `choco pack; choco upgrade [[PackageName]] --source .`
    `choco pack; choco uninstall [[PackageName]]; choco install [[PackageName]] --source .`
8.  [ ] Push package to Chocolatey Community Repository.
    `choco push`
9.  [ ] Update meta-package if applicable.
