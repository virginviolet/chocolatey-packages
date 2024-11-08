# Checklist for package creation

## Guide

- "Create Packages". <https://docs.chocolatey.org/en-us/create/create-packages>

## To do

1. [x] Search the Community Repository to make sure there isn't a package for this software already: <https://community.chocolatey.org/packages>
2. [x] Make sure the total nupkg package will be under 200MB.
3. [x] Commit.
4. [x] Add EXE installers to the tools directory (32-bit and/or 64-bit).
5. [x] Fill out `legal\LICENSE.txt`.
6. [x] Remove one of the verification files in `legal/`.
7. [x] Fill out `legal\VERIFICATION.txt`.
8. [x] Rename the remaining verification file to `VERIFICATION.txt`.
9. [x] Fill out nuspec.
10. [x] Fill out `tools\chocolateyInstall.ps1`.
11. [x] Fill out `tools\chocolateyUninstall.ps1` - remove if autouninstaller can automatically uninstall and you have nothing additional to do during uninstall.
12. [x] Remove `tools\.skipAutoUninstall` if `chocolateyUninstall.ps1` is used and auto-uninstaller is not desired.
13. [x] Fill out `tools\chocolateyBeforeModify.ps1` - remove if you have no processes or services to shut down before upgrade/uninstall.
14. [x] Test the package to ensure install/uninstall work appropriately.
15. [x] Commit.
16. [x] Clean out the comments you are not using in `tools\chocolateybeforeModify.ps1`.
17. [ ] Clean out the comments and sections you are not using in `tools\chocolateyInstall.ps1`.
18. [ ] Clean out the comments and sections you are not using in `tools\chocolateyUninstall.ps1`.
19. [ ] Clean out all the comments in nuspec (you may wish to leave the headers for the package vs software metadata).
20. [ ] Inform of default install location in description in nuspec.
21. [ ] Finish `legal\VERIFICATION.txt`.
22. [ ] Adjust `TODO_updating.md` if needed.
23. [ ] Delete `ReadMe.md` file once you have read over and used anything you've needed from here.
24. [ ] Test the package again to ensure install/uninstall work appropriately.
25. [ ] Commit and publish to GitHub.
26. [ ] Merge branch with main.
27. [ ] Add icon key to nuspec.
28. [ ] Test the package yet again to ensure install/uninstall work appropriately.
29. [ ] Delete this file.
30. [ ] Merge branch with main again.
31. [ ] Commit and publish to GitHub again.
32. [ ] Pack and push to Chocolatey Community Repository.
33. [ ] Create a meta-package if applicable.

## Learn more

To learn more about Chocolatey packaging, go through the workshop at <https://github.com/chocolatey/chocolatey-workshop>
You will learn about

- General packaging
- Customizing package behavior at runtime (package parameters)
- Extension packages
- Custom packaging templates
- Setting up an internal Chocolatey.Server repository
- Adding and using internal repositories
- Reporting
- Advanced packaging techniques when installers are not friendly to automation
