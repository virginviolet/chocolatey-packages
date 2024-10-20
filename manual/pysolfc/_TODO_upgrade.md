# TODO on updating the package for a new version of the software

- [ ] `Tools/`: Move binary to `archive/`.
- [ ] `pysolfc/`: Move nupkg to `archive/`.
- [ ] `Tools/`: Move new binary to `tools/`.
- [ ] `Nuspec`: Update `version`.
- [ ] `Nuspec`: Update `releaseNotes`.
- [ ] `legal/LICENSE.txt`: Verify license.
- [ ] `legal/VERIFICATION.txt`: Update download URL.
- [ ] `legal/VERIFICATION.txt`: Update filenames in the two places.
- [ ] `legal/VERIFICATION.txt`: Verify license URL.
- [ ] `chocolateyInstall.ps1`: Change `$exeInstallerPath`.
- [ ] `chocolateyInstall.ps1`: Change `checksum`.
- [ ] Test the package to ensure install works appropriately.
    `choco pack; choco upgrade pysofc --source .`
- [ ] Push package.
    `choco push`