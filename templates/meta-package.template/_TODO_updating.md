# Checklist for maintainer updating the package for a new version of the software

# To do

1. [ ] `[[PackageName]].nuspec`: Update `version`.
2. [ ] `[[PackageName]].nuspec`: Update `releaseNotes`.
3. [ ] `[[PackageName]].nuspec`: Verify URLs.
4. [ ] `legal/LICENSE.txt`: Verify license.
5. [ ] `legal/VERIFICATION.txt`: Update download URLs.
6. [ ] `legal/VERIFICATION.txt`: Update filenames in every place.
7. [ ] `legal/VERIFICATION.txt`: Update checksum32.
8. [ ] `legal/VERIFICATION.txt`: Update checksum64.
9. [ ] `legal/VERIFICATION.txt`: Verify license URL.
10. [ ] `chocolateyInstall.ps1`: Update `$zipArchivePath`.
11. [ ] `chocolateyUninstall.ps1`: Update `ZipFileName`.
12. [ ] Test the package to ensure upgrade works appropriately.
    `choco pack; choco upgrade [[PackageName]] --source .`
13. [ ] Push package to Chocolatey Community Repository.
    `choco push`
14. [ ] Update meta-package if applicable.
