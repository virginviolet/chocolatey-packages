# Checklist for maintainer updating the package for a new version of the software

# To do

1. [ ] `Nuspec`: Update `version`.
2. [ ] `Nuspec`: Update `releaseNotes`.
3. [ ] `legal/LICENSE.txt`: Verify license.
4. [ ] `legal/VERIFICATION.txt`: Update download URLs.
5. [ ] `legal/VERIFICATION.txt`: Update filenames in every place.
6. [ ] `legal/VERIFICATION.txt`: Update checksum32.
7. [ ] `legal/VERIFICATION.txt`: Update checksum64.
8. [ ] `legal/VERIFICATION.txt`: Verify license URL.
9. [ ] `chocolateyInstall.ps1`: Update `$zipArchivePath`.
10. [ ] `chocolateyUninstall.ps1`: Update `ZipFileName`.
11. [ ] Test the package to ensure install works appropriately.
    `choco pack; choco upgrade [[PackageName]] --source .`
12. [ ] Push package to Chocolatey Community Repository.
    `choco push`
13. [ ] Update meta-package if applicable.
