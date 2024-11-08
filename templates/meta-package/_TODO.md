# Checklist for package creation

## Guides

- "Create Packages". <https://docs.chocolatey.org/en-us/create/create-packages>
- "How To Create a Chocolatey Meta Package". <https://docs.chocolatey.org/en-us/guides/create/create-meta-package/>

## To do

1. [ ] Search the Community Repository to make sure there isn't a package for this already: <https://community.chocolatey.org/packages>
2. [ ] Commit.
3. [ ] Fill out `[[PackageName]].nuspec`.
4. [ ] Clean out the comments in `[[PackageName]].nuspec`.
5. [ ] Test the package to ensure install/uninstall work appropriately.
6. [ ] Delete `ReadMe.md` once you have read over and used anything you've needed from here.
7. [ ] Delete this file.
8.  [ ] Commit and publish to GitHub.
9.  [ ] Merge branch with main.
10. [ ] Commit and publish to GitHub.
11. [ ] Pack and push package to Chocolatey Community Repository.

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
