# Checklist for maintainer updating the package for a new version of the software

# To do

1. [ ] `Tools/`: Move old binaries to `archive/<version>/`.
2. [ ] `pysolfc/`: Move old nupkg to `archive/<version>/`.
3. [ ] `Tools/`: Move new binaries to `tools/`.
4. [ ] `Nuspec`: Update `version`.
5. [ ] `Nuspec`: Update `releaseNotes`.
6. [ ] `legal/LICENSE.txt`: Verify license.
7. [ ] `legal/VERIFICATION.txt`: Update download URL.
8. [ ] `legal/VERIFICATION.txt`: Update filenames in every place.
9. [ ] `legal/VERIFICATION.txt`: Update checksums.
10. [ ] `legal/VERIFICATION.txt`: Verify license URL.
11. [ ] Test the package to ensure upgrade/uninstall/install works appropriately.
    `choco pack; choco upgrade spacecadetpinball --source .`
    `choco pack; choco uninstall spacecadetpinball; choco install spacecadetpinball --source .`
12. [ ] Push package to Chocolatey Community Repository.
    `choco push`
