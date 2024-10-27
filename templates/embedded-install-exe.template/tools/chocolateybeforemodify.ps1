# Steps to perform before upgrading [[PackageName]] with Chocolatey

# This runs before upgrade or uninstall.
# Use this file to do things like stop services prior to upgrade or uninstall.
# NOTE: It is an anti-pattern to call chocolateyUninstall.ps1 from here. If you
#  need to uninstall an MSI prior to upgrade, put the functionality in this
#  file without calling the uninstall script. Make it idempotent in the
#  uninstall script so that it doesn't fail when it is already uninstalled.
# NOTE: For upgrades - like the uninstall script, this script always runs from
#  the currently installed version, not from the new upgraded package version.

# Terminate process
# This helper function requires chocolatey-core extension
# Documentation - https://community.chocolatey.org/packages/chocolatey-core.extension#description
# Source code - https://github.com/chocolatey-community/chocolatey-extensions/blob/master/src/chocolatey-core.extension/extensions/Remove-Process.ps1
$terminateArgs = @{
    # RegEx expression of process name, returned by Get-Process function
    NameFilter = "executable"
    ## RegEx expression of process path, returned by Get-Process function
    # $PathFilter = "C:\tools\software\" # Untested
    ## Wait for process to start number of seconds
    # $WaitFor = 5
    ## Close/Kill child processes
    # $WithChildren = $true # Untested
}
Remove-Process @terminateArgs
