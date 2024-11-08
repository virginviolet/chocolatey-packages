# Checklist for maintainer updating the package for a new version of the software

## To do

1. [ ] `Tools/`: Move old binaries to `archive/`.
2. [ ] `[[PackageName]]/`: Move old nupkg to `archive/`.
3. [ ] `Tools/`: Move new binaries to `tools/`.
4. [ ] `[[PackageName]].nuspec`: Update `version`.
5. [ ] `[[PackageName]].nuspec`: Update `releaseNotes`.
6. [ ] `[[PackageName]].nuspec`: Verify URLs.
7. [ ] `legal/LICENSE.txt`: Verify license.
8. [ ] `legal/VERIFICATION.txt`: Update download URLs.
9. [ ] `legal/VERIFICATION.txt`: Update filenames in every place.
10. [ ] `legal/VERIFICATION.txt`: Update checksum32.
11. [ ] `legal/VERIFICATION.txt`: Update checksum64.
12. [ ] `legal/VERIFICATION.txt`: Verify license URL.
13. [ ] `chocolateyInstall.ps1`: Update `$exeInstallerPath`.
14. [ ] `chocolateyInstall.ps1`: Update `$exeInstaller64Path`.
15. [ ] `chocolateyInstall.ps1`: Update `checksum`.
16. [ ] `chocolateyInstall.ps1`: Update `checksum64`.
17. [ ] Test the package to ensure upgrade/uninstall/install works appropriately.
    `choco pack; choco upgrade [[PackageName]] --source .`
    `choco pack; choco uninstall [[PackageName]]; choco install [[PackageName]] --source .`
18. [ ] Push package to Chocolatey Community Repository.
    `choco push`
19. [ ] Update meta-package if applicable.
