# Checklist for package creation

## Guides

- "Create Packages". <https://docs.chocolatey.org/en-us/create/create-packages>
- "How To Create a Zip Package". <https://docs.chocolatey.org/en-us/guides/create/create-zip-package/>

## Note

Portable packages should be possible to install without administrative rights.

## To do

1. [ ] Search the Community Repository to make sure there isn't a package for this software already: <https://community.chocolatey.org/packages>
2. [ ] Make sure the total nupkg package will be under 200MB.
3. [ ] Commit.
4. [ ] Add zip file(s) to the tools directory.
5. [ ] Fill out `legal\LICENSE.txt`.
6. [ ] Fill out `legal\VERIFICATION.txt`.
7. [ ] Fill out `tools\chocolateyBeforeModify.ps1` - remove if you have no processes or services to shut down before upgrade/uninstall.
8. [ ] Fill out `tools\chocolateyInstall.ps1`.
9. [ ] Fill out `tools\chocolateyUninstall.ps1` - remove if autouninstaller can automatically uninstall and you have nothing additional to do during uninstall.
10. [ ] Fill out nuspec.
11. [ ] If there is a GUI executable, create an empty file next to the exe named `name.exe.gui`.
12. [ ] If you want to ignore an executable, create an empty file next to the exe named `name.exe.ignore`.
13. [ ] Test the package to ensure install/uninstall work appropriately.
14. [ ] Commit.
15. [ ] Clean out the comments you are not using in `tools\chocolateybeforeModify.ps1`.
16. [ ] Clean out the comments and sections you are not using in `tools\chocolateyInstall.ps1`.
17. [ ] Clean out the comments and sections you are not using in `tools\chocolateyUninstall.ps1`.
18. [ ] Clean out all the comments in nuspec (you may wish to leave the headers for the package vs software metadata).
19. [ ] Adjust default installation path in description in nuspec.
20. [ ] Finish `legal\VERIFICATION.txt`.
21. [ ] Adjust `TODO_updating.md` if needed.
22. [ ] Delete `ReadMe.md` file once you have read over and used anything you've needed from here.
23. [ ] Test the package again to ensure install/uninstall work appropriately.
24. [ ] Commit and publish to GitHub.
25. [ ] Merge branch with main.
26. [ ] Add icon key to nuspec.
27. [ ] Test the package yet again to ensure install/uninstall work appropriately.
28. [ ] Delete this file.
29. [ ] Merge branch with main again.
30. [ ] Commit and publish to GitHub again.
31. [ ] Pack and push to Chocolatey Community Repository.
32. [ ] Create a meta-package if applicable.

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
