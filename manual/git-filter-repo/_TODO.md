# TODO (embedded - portable - zip)

## Guides

- "Create Packages". <https://docs.chocolatey.org/en-us/create/create-packages>
- "How To Create a Zip Package". <https://docs.chocolatey.org/en-us/guides/create/create-zip-package/>

## Note

Portable packages should be possible to install without administrative rights.

## To do

1. [x] Search the Community Repository to make sure there isn't a package for this software already: <https://community.chocolatey.org/packages>
2. [x] Make sure the total nupkg package will be under 200MB.
3. [x] Add zip file(s) to the tools directory.
4. [x] Fill out LICENSE.txt
5. [x] Fill out VERIFICATION.txt
6. [x] Fill out tools\chocolateyBeforeModify.ps1 - remove if you have no processes or services to shut down before upgrade/uninstall
7. [x] Fill out tools\chocolateyInstall.ps1.
8. [x] Fill out tools\chocolateyUninstall.ps1 - remove if autouninstaller can automatically uninstall and you have nothing additional to do during uninstall.
9. [x] If you want to ignore an executable, create an empty file next to the exe named 'name.exe.ignore'.
10. [x] Test the package to ensure install/uninstall work appropriately.
11. [x] Fill out nuspec.
12. [x] Fill out tools\VERIFICATION.txt
13. [x] Commit.
14. [x] Clean out the comments you are not using in chocolateybeforeModify.ps1.
15. [x] Clean out the comments and sections you are not using in chocolateyInstall.ps1.
16. [x] Clean out the comments and sections you are not using in chocolateyUninstall.ps1.
17. [x] Clean out all the comments in nuspec (you may wish to leave the headers for the package vs software metadata).
18. [x] Delete ReadMe.md file once you have read over and used anything you've needed from here.
19. [x] Test the package again to ensure install/uninstall work appropriately.
20. [ ] Commit and publish to GitHub.
21. [ ] Merge branch with main.
22. [ ] Add icon key to nuspec.
23. [ ] Test the package yet again to ensure install/uninstall work appropriately.
24. [ ] Delete this file.
25. [ ] Merge branch with main again.
26. [ ] Commit and publish to GitHub again.
27. [ ] Pack and push to Chocolatey Community Repository.

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
