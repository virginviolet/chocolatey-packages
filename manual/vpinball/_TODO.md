﻿# TODO

## Guides

- "Create Packages". <https://docs.chocolatey.org/en-us/create/create-packages>

## To do

1. [x] Search the Community Repository to make sure there isn't a package for this software already: <https://community.chocolatey.org/packages>
2. [x] Make sure the total nupkg package will be under 200MB.
3. [x] Commit.
4. [x] Add installer EXE to the tools directory.
5. [x] Fill out legal\LICENSE.txt
6. [x] Fill out legal\VERIFICATION.txt
7. [x] Fill out tools\chocolateyBeforeModify.ps1 - remove if you have no processes or services to shut down before upgrade/uninstall
8. [x] Fill out tools\chocolateyInstall.ps1.
9.  [x] Fill out tools\chocolateyUninstall.ps1 - remove if autouninstaller can automatically uninstall and you have nothing additional to do during uninstall.
10. [x] Remove tools\.skipAutoUninstall if chocolateyUninstall.ps1 is used and auto-uninstaller is not desired.
11. [x] Fill out nuspec.
12. [x] Test the package to ensure install/uninstall work appropriately.
13. [x] Add nupkg and installer and to .gitignore.
14. [x] Commit.
15. [x] Clean out comments you are not using in tools\chocolateybeforeModify.ps1.
16. [x] Clean out comments and sections you are not using in tools\chocolateyInstall.ps1.
17. [x] Clean out comments and sections you are not using in tools\chocolateyUninstall.ps1.
18. [x] Clean out comments in nuspec (you may wish to leave the headers for the package vs software metadata).
19. [x] Finish legal\VERIFICATION.txt
20. [x] Delete ReadMe.md file once you have read over and used anything you've needed from here.
21. [ ] Test the package again to ensure install/uninstall work appropriately.
22. [ ] Commit and publish to GitHub.
23. [ ] Merge branch with main.
24. [ ] Add icon key to nuspec.
25. [ ] Test the package yet again to ensure install/uninstall work appropriately.
26. [ ] Delete this file.
27. [ ] Merge branch with main again.
28. [ ] Commit and publish to GitHub again.
29. [ ] Pack and push to Chocolatey Community Repository.

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