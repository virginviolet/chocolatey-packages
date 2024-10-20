# Checklist for maintainer updating the package for a new version of the software

# To do

- [ ] `Tools/`: Move old binaries to `archive/`.
- [ ] `pysolfc/`: Move old nupkg to `archive/`.
- [ ] `Tools/`: Move new binaries to `tools/`.
- [ ] `Nuspec`: Update `version`.
- [ ] `Nuspec`: Update `releaseNotes`.
- [ ] `legal/LICENSE.txt`: Verify license.
- [ ] `legal/VERIFICATION.txt`: Update download URLs.
- [ ] `legal/VERIFICATION.txt`: Update filenames in every place.
- [ ] `legal/VERIFICATION.txt`: Update checksum32.
- [ ] `legal/VERIFICATION.txt`: Update checksum64.
- [ ] `legal/VERIFICATION.txt`: Verify license URL.
- [ ] `chocolateyInstall.ps1`: Update `$exeInstallerPath`.
- [ ] `chocolateyInstall.ps1`: Update `checksum`.
- [ ] `chocolateyInstall.ps1`: Update `checksum64`.
- [ ] Test the package to ensure install works appropriately.
    `choco pack; choco upgrade [[PackageName]] --source .`
- [ ] Push package.
    `choco push`
