# TODO (embedded - portable - zip)

## Guides

- "Create Packages". <https://docs.chocolatey.org/en-us/create/create-packages>
- "How To Create a Zip Package". <https://docs.chocolatey.org/en-us/guides/create/create-zip-package/>

## Note

Portable packages should be possible to install without administrative rights.

## To do

1. [ ] Search the Community Repository to make sure there isn't a package for this software already: <https://community.chocolatey.org/packages>
2. [ ] Make sure the total nupkg package will be under 200MB.
3. [ ] Add zip file(s) to the tools directory.
4. [ ] Fill out LICENSE.txt
5. [ ] Fill out VERIFICATION.txt
6. [ ] Fill out tools\chocolateyBeforeModify.ps1 - remove if you have no processes or services to shut down before upgrade/uninstall
7. [ ] Fill out tools\chocolateyUninstall.ps1 - remove if autouninstaller can automatically uninstall and you have nothing additional to do during uninstall.
8. [ ] Fill out tools\chocolateyInstall.ps1.
9. [ ] If you want to ignore an executable, create an empty file next to the exe named 'name.exe.ignore'.
10. [ ] Test the package to ensure install/uninstall work appropriately.
11. [ ] Add nupkg to .gitignore.
12. [ ] Fill out nuspec.
13. [ ] Fill out tools\VERIFICATION.txt
14. [ ] Commit.
15. [ ] Clean out the comments you are not using in chocolateybeforeModify.ps1.
16. [ ] Clean out the comments and sections you are not using in chocolateyInstall.ps1.
17. [ ] Clean out the comments and sections you are not using in chocolateyUninstall.ps1.
18. [ ] Clean out all the comments in nuspec (you may wish to leave the headers for the package vs software metadata).
19. [ ] Delete ReadMe.md file once you have read over and used anything you've needed from here.
20. [ ] Test the package again to ensure install/uninstall work appropriately.
21. [ ] Commit and publish to GitHub.
22. [ ] Merge branch with main.
23. [ ] Add icon key to nuspec.
24. [ ] Test the package yet again to ensure install/uninstall work appropriately.
25. [ ] Delete this file.
26. [ ] Merge branch with main again.
27. [ ] Commit and publish to GitHub again.
28. [ ] Pack and push to Chocolatey Community Repository.

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
- Advanced packaging techniques when installers are not friendly to
   automation
