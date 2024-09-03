# TODO (meta)

## Guides

- "Create Packages". <https://docs.chocolatey.org/en-us/create/create-packages>
- "How To Create a Chocolatey Meta Package". <https://docs.chocolatey.org/en-us/guides/create/create-meta-package/>

## To do

1. [ ] Search the Community Repository to make sure there isn't a package for this already: <https://community.chocolatey.org/packages>
2. [ ] Delete the `tools` folder.
3. [ ] Fill out nuspec.
4. [ ] Test the package to ensure install/uninstall work appropriately.
5. [ ] Add nupkg to .gitignore.
6. [ ] Commit.
7. [ ] Clean out all the comments in nuspec (you may wish to leave the headers for the package vs software metadata).
8. [ ] Delete ReadMe.md file once you have read over and used anything you've needed from here.
9. [ ] Test the package again to ensure install/uninstall work appropriately.
10. [ ] Commit and publish to GitHub.
11. [ ] Merge branch with main.
12. [ ] Test the package yet again to ensure install/uninstall work appropriately.
13. [ ] Delete this file.
14. [ ] Merge branch with main again.
15. [ ] Commit and publish to GitHub again.
16. [ ] Pack and push to Chocolatey Community Repository.

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
