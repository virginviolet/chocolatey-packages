# Checklist for maintainer updating the package for a new version of the software

## To do

1. [ ] Move old nupkg to `archive/<version>`.
2. [ ] `Tools/`: Move old binaries to `archive/<version>`.
3. [ ] `Tools/`: Move new binaries to `tools/`.
4. [ ] `Nuspec`: Update `version`.
5. [ ] `Nuspec`: Update `releaseNotes`.
6. [ ] `Nuspec`: Verify URLs.
7. [ ] `legal/LICENSE.txt`: Verify license.
8. [ ] `legal/VERIFICATION.txt`: Verify license URL.
9. [ ] `legal/VERIFICATION.txt`: Update download URL.
10. [ ] `legal/VERIFICATION.txt`: Update checksum32.
11. [ ] `legal/VERIFICATION.txt`: Verify license URL.
12. [ ] `chocolateyInstall.ps1`: Update `checksum`.
13. [ ] Test the package to ensure upgrade/uninstall/install works appropriately.
    `choco pack; choco upgrade windows-frotz.install --source .`
    `choco pack; choco uninstall windows-frotz.install; choco install windows-frotz.install --source .`
14. [ ] Push package to Chocolatey Community Repository.
    `choco push`
15. [ ] Update meta-package if it exists.
