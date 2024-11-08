# Checklist for package creation

## Guide

- "Create Packages". <https://docs.chocolatey.org/en-us/create/create-packages>

## Note

Portable packages should be possible to install without administrative rights.

## To do

1. [ ] Search the Community Repository to make sure there isn't a package for this software already: <https://community.chocolatey.org/packages>
2. [ ] Make sure the total nupkg package will be under 200MB.
3. [ ] Commit.
4. [ ] Fill out nuspec.
5. [ ] Fill out `tools\chocolateyInstall.ps1`.
6. [ ] Fill out `tools\chocolateyUninstall.ps1` - remove if autouninstaller can automatically uninstall and you have nothing additional to do during uninstall.
7. [ ] Remove `tools\.skipAutoUninstall` if `chocolateyUninstall.ps1` is used and auto-uninstaller is not desired.
8. [ ] Fill out `tools\chocolateyBeforeModify.ps1` - remove if you have no processes or services to shut down before upgrade/uninstall.
9. [ ] If there is a GUI executable, create an empty file next to the exe named `name.exe.gui`.
10. [ ] If you want to prevent an executable from getting shimmed, create an empty file next to the exe named `name.exe.ignore`.
11. [ ] Test the package to ensure install/uninstall work appropriately.
12. [ ] Commit.
13. [ ] Clean out the comments you are not using in `tools\chocolateybeforeModify.ps1`.
14. [ ] Clean out the comments and sections you are not using in `tools\chocolateyInstall.ps1`.
15. [ ] Clean out the comments and sections you are not using in `tools\chocolateyUninstall.ps1`.
16. [ ] Clean out all the comments in nuspec (you may wish to leave the headers for the package vs software metadata).
17. [ ] Adjust default installation path in description in nuspec.
18. [ ] Adjust `TODO_updating.md` if needed.
19. [ ] Delete `ReadMe.md` file once you have read over and used anything you've needed from here.
20. [ ] Test the package again to ensure install/uninstall work appropriately.
21. [ ] Commit and publish to GitHub.
22. [ ] Merge branch with main.
23. [ ] Add icon key to nuspec.
24. [ ] Test the package yet again to ensure install/uninstall work appropriately.
25. [ ] Delete this file.
26. [ ] Merge branch with main again.
27. [ ] Commit and publish to GitHub again.
28. [ ] Pack and push to Chocolatey Community Repository.
29. [ ] Create a meta-package if applicable.

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
