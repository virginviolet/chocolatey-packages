﻿# Checklist for package creation

## Guides

- "Create Packages". <https://docs.chocolatey.org/en-us/create/create-packages>
- "How To Create a Zip Package". <https://docs.chocolatey.org/en-us/guides/create/create-zip-package/>

## Note

Portable packages should be possible to install without administrative rights.

## To do

1. [ ] Search the Community Repository to make sure there isn't a package for this software already: <https://community.chocolatey.org/packages>
2. [ ] Make sure the total nupkg package will be under 200MB.
3. [ ] Commit.
4. [ ] Add zip file(s) to the `tools` directory (32-bit and/or 64-bit).
5. [ ] Fill out `legal\LICENSE.txt`.
6. [ ] Remove one of the verification files in `legal/`.
7. [ ] Fill out `legal\VERIFICATION.txt`.
8. [ ] Rename the remaining verification file to `VERIFICATION.txt`.
9. [ ] Fill out `[[PackageName]].nuspec`.
10. [ ] Fill out `tools\chocolateyInstall.ps1`.
11. [ ] Fill out `tools\chocolateyUninstall.ps1` - remove if autouninstaller can automatically uninstall and you have nothing additional to do during uninstall.
12. [ ] Remove `tools\.skipAutoUninstall` if `chocolateyUninstall.ps1` is used and auto-uninstaller is not desired.
13. [ ] Fill out `tools\chocolateyBeforeModify.ps1` - remove if you have no processes or services to shut down before upgrade/uninstall.
14. [ ] If there is a GUI executable, create an empty file next to the exe named `name.exe.gui`.
15. [ ] If you want to ignore an executable, create an empty file next to the exe named `name.exe.ignore`.
16. [ ] Test the package to ensure install/uninstall work appropriately.
17. [ ] Commit.
18. [ ] Clean out the comments you are not using in `tools\chocolateybeforeModify.ps1`.
19. [ ] Clean out the comments and sections you are not using in `tools\chocolateyInstall.ps1`.
20. [ ] Clean out the comments and sections you are not using in `tools\chocolateyUninstall.ps1`.
21. [ ] Clean out the comments in `[[PackageName]].nuspec`.
22. [ ] Adjust default installation path in description in `[[PackageName]].nuspec`.
23. [ ] Finish `legal\VERIFICATION.txt`.
24. [ ] Adjust `TODO_updating.md` if needed.
25. [ ] Delete `ReadMe.md` file once you have read over and used anything you've needed from here.
26. [ ] Test the package again to ensure install/uninstall work appropriately.
27. [ ] Commit and publish to GitHub.
28. [ ] Merge branch with main.
29. [ ] Add icon key to `[[PackageName]].nuspec`.
30. [ ] Test the package yet again to ensure install/uninstall work appropriately.
31. [ ] Delete this file.
32. [ ] Merge branch with main again.
33. [ ] Commit and publish to GitHub again.
34. [ ] Pack and push to Chocolatey Community Repository.
35. [ ] Create a meta-package if applicable.

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
