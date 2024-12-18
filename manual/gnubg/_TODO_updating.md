# Checklist for maintainer updating the package for a new version of the software

# To do

1. [ ] `Tools/`: Move old binaries to `archive/`.
2. [ ] `pysolfc/`: Move old nupkg to `archive/`.
3. [ ] `Tools/`: Move new binaries to `tools/`.
4. [ ] `Nuspec`: Update `version`.
5. [ ] `Nuspec`: Update `releaseNotes`.
6. [ ] `legal/LICENSE.txt`: Verify license.
7. [ ] `legal/VERIFICATION.txt`: Update download URLs.
8. [ ] `legal/VERIFICATION.txt`: Update filenames in every place.
9. [ ] `legal/VERIFICATION.txt`: Update checksum32.
    <!-- 10. [ ] `legal/VERIFICATION.txt`: Update checksum64. -->
10. [ ] `legal/VERIFICATION.txt`: Verify license URL.
11. [ ] `chocolateyInstall.ps1`: Update `$exeInstallerPath`.
12. [ ] `chocolateyInstall.ps1`: Update `checksum`.
13. [ ] `chocolateyInstall.ps1`: Update `checksum62`.
14. [ ] Test the package to ensure upgrade/uninstall/install works appropriately.
    `choco pack; choco upgrade [[PackageName]] --source .`
    `choco pack; choco uninstall [[PackageName]]; choco install [[PackageName]] --source .`
15. [ ] Push package to Chocolatey Community Repository.
    `choco push`
