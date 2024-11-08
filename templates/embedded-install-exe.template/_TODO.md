# Checklist for package creation

## Guide

- "Create Packages". <https://docs.chocolatey.org/en-us/create/create-packages>

## To do

1. [ ] Search the Community Repository to make sure there isn't a package for this software already: <https://community.chocolatey.org/packages>
2. [ ] Make sure the total nupkg package will be under 200MB.
3. [ ] Commit.
4. [ ] Add EXE installers to the tools directory (32-bit and/or 64-bit).
5. [ ] Make `.ignore` files for EXE installers.
6. [ ] Fill out `legal\LICENSE.txt`.
7. [ ] Remove one of the verification files in `legal/`.
8. [ ] Fill out `legal\VERIFICATION.txt`.
9. [ ] Rename the remaining verification file to `VERIFICATION.txt`.
10. [ ] Fill out `[[PackageName]].nuspec`.
11. [ ] Fill out `tools\chocolateyInstall.ps1`.
12. [ ] Fill out `tools\chocolateyUninstall.ps1` - remove if autouninstaller can automatically uninstall and you have nothing additional to do during uninstall.
13. [ ] Remove `tools\.skipAutoUninstall` if `chocolateyUninstall.ps1` is used and auto-uninstaller is not desired.
14. [ ] Fill out `tools\chocolateyBeforeModify.ps1` - remove if you have no processes or services to shut down before upgrade/uninstall.
15. [ ] Test the package to ensure install/uninstall work appropriately.
16. [ ] Commit.
17. [ ] Clean out the comments you are not using in `tools\chocolateybeforeModify.ps1`.
18. [ ] Clean out the comments and sections you are not using in `tools\chocolateyInstall.ps1`.
19. [ ] Clean out the comments and sections you are not using in `tools\chocolateyUninstall.ps1`.
20. [ ] Clean out the comments in `[[PackageName]].nuspec`.
21. [ ] Inform of default install location in description in `[[PackageName]].nuspec`.
22. [ ] Finish `legal\VERIFICATION.txt`.
23. [ ] Adjust `TODO_updating.md` if needed.
24. [ ] Delete `ReadMe.md` file once you have read over and used anything you've needed from here.
25. [ ] Test the package again to ensure install/uninstall work appropriately.
26. [ ] Commit and publish to GitHub.
27. [ ] Merge branch with main.
28. [ ] Add icon key to `[[PackageName]].nuspec`.
29. [ ] Test the package yet again to ensure install/uninstall work appropriately.
30. [ ] Delete this file.
31. [ ] Merge branch with main again.
32. [ ] Commit and publish to GitHub again.
33. [ ] Pack and push to Chocolatey Community Repository.
34. [ ] Create a meta-package if applicable.

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
