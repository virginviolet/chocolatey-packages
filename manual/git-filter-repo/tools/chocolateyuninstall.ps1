# Uninstall git-filter-repo

# Package directory will be removed automatically

# Unnstall settings
$ErrorActionPreference = 'Stop' # stop on all errors
$contribDemosDirShortcutName = "git-filter-repo contrib scripts"

# Uninstall Git program
# Path
$installGitExecPath = & git --exec-path
$installGitPyScript = Join-Path $installGitExecPath -ChildPath 'git-filter-repo'
# Remove if it exists
$exists = [bool](Test-Path $installGitPyScript -PathType leaf)
if ($exists) {
    Write-Debug "$packageName Git program found."
    Remove-Item $installGitPyScript
    Write-Debug "Removed '$installGitPyScript'."
} else {
    Write-Debug "$packageName Git program not found."
}

# Uninstall Python module/library
# Path
$installPythonSitePackages = Convert-Path -Path "$(& python -c "import site; print(site.getsitepackages()[1])")"
$installPythonPyScript = Join-Path $installPythonSitePackages -ChildPath 'git_filter_repo.py'
# Remove from site-packages if it exists
$exists = [bool](Test-Path $installPythonPyScript -PathType leaf)
if ($exists) {
    Write-Debug "$packageName Python module/library found in site-packages."
    Remove-Item $installPythonPyScript
    Write-Debug "Removed '$installPythonPyScript'."
} else {
    Write-Debug "$packageName Python module/library not found in site-packages."
}
# Uninstall from PYTHONPATH
if ($null -ne $env:PYTHONPATH) {
    Write-Debug "PYTHONPATH variable found."
    $installPythonPyScript = Join-Path $env:PYTHONPATH -ChildPath 'git_filter_repo.py'
    $exists = [bool](Test-Path $installPythonPyScript -PathType leaf)
    if ($exists) {
        Write-Debug "$packageName Python module/library found in PYTHONPATH."
        Remove-Item $installPythonPyScript
        Write-Debug "Removed '$installPythonPyScript'."
    } else {
        Write-Debug "$packageName Python module/library not found in PYTHONPATH."
    }
} else {
    Write-Debug "PYTHONPATH variable not found."
}

# Uninstall desktop shortcut to the contrib demos directory if it exists
# Shortcut target path
$shortcut = "$env:UserProfile\Desktop\$contribDemosDirShortcutName.lnk"
# Remove if it exists
$exists = [bool](Test-Path $shortcut)
if ($exists) {
    Write-Debug "Desktop shortcut to the contrib demos directory found."
    try {
        Remove-Item $shortcut
        Write-Debug "Removed '$shortcut'."
    } catch {
        Write-Warning "Could not remove desktop shortcut to the contrib demos directory.`n$_"
    }
} else {
    Write-Debug "Desktop shortcut to the contrib demos directory not found."
}

# Uninstall man page for Git
# Path
$installManPath = [System.IO.Path]::GetFullPath($(& git --man-path)) # Convert-Path only works on real existing paths, so we do this
$installMan1Path = Join-Path $installManPath -ChildPath 'man1'
$installManPage = Join-Path $installMan1Path -ChildPath 'git-filter-repo.1'
# Remove if it exists
$exists = [bool](Test-Path $installManPage)
if ($exists) {
    Write-Debug "$packageName's man page for Git found."
    Remove-Item $installManPage
    Write-Debug "Removed '$installManPage'."
    # Remove man1 directory if empty
    $empty = -not ([bool](Test-Path $installMan1Path\*))
    if ($exists -and $empty) {
        Remove-Item $installMan1Path
    }
    # Remove man directory if empty
    $empty = -not ([bool](Test-Path $installManPath\*))
    if ($exists -and $empty) {
        Remove-Item $installManPath
    }
} else {
    Write-Debug "$packageName's man page for Git not found."
}

# Uninstall html documentation
# Destination
# Path
$installHtmlDocumentationDir = Convert-Path -Path $(& git --html-path)
$installHtmlDocumentation = Join-Path $installHtmlDocumentationDir -ChildPath 'git-filter-repo.html'
# Remove if it exists
$exists = [bool](Test-Path $installHtmlDocumentation)
if ($exists) {
    Write-Debug "$packageName's html documentation file for Git found."
    Remove-Item $installHtmlDocumentation
    Write-Debug "Removed '$installHtmlDocumentation'."
} else {
    Write-Debug "$packageName's html documentation file for Git not found."
}
