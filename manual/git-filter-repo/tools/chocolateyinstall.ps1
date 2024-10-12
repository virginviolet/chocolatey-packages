# Check if running in administrative shell
function Test-Administrator {  
  [OutputType([bool])]
  param()
  process {
    [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
    return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
  }
}

# Install a file
# First tries to symlink, and if that fails, tries to copy
function Install-File {
  param (
    [string]$Path,
    [string]$Destination,
    [string]$SuccessMessage,
    [string]$FailMessage,
    [bool]$ThrowOnFailure = $false
  )
  # Check if admininstrator
  if ($null -eq $script:isAdmin) {
    if (Test-Administrator) {
      # [x] Test
      Write-Debug "Elevated instance detected."
      # Set variable in the Script scope so that we do not need to run Test-Administrator every time Install-File is run 
      $script:isAdmin = $true
    } else {
      # [x] Test
      Write-Debug "Instance does not seem to be elevated."
      $script:isAdmin = $false
    }
  }
  # Remove file if it exists first, so don't get an error if it exists
  $exists = [bool](Test-Path -Path $Destination)
  if ($exists) {
    # [x] Test
    Write-Warning "File already exists: '$Destination'.`n$_"
    try {
      # [x] Test
      Remove-Item -Path $Destination
    } catch {
      if ($ThrowOnFailure) {
        # [x] Test
        Write-Error $_
      } else {
        # [x] Test
        Write-Warning "Cannot remove file '$Destination'.`n$_"
        if ("" -ne $FailMessage) {
          Write-Warning $FailMessage
        }
        return
      }
    }
  }
  # Install file
  if ($isAdmin) {
    # [x] Test
    # Create symlink
    # Creating symlinks natively with PowerShell is only available in PowerShell >= 5.0
    & cmd /c mklink "$Destination" "$Path" 1>$null 2>&1 # suppress success stream; use cmd's error output as error
    Write-Debug "Symlink created for '$Destination' <<===>> '$Path'."
    if ("" -ne $SuccessMessage) {
      Write-Host $SuccessMessage
    }
  } else {
    try {
      # [x] Test
      # Create symlink
      # (Admin rigths is not required to make symlinks on Windows >= 10 build 14972 with Developer Mode enabled)
      Write-Debug "Attempting to make a symlink for '$Destination' <<===>> '$Path'."
      & cmd /c mklink "$Destination" "$Path" 1>$null 2>&1
      Write-Debug "Symlink created for '$Destination' <<===>> '$Path'."
      if ("" -ne $SuccessMessage) {
        Write-Host $SuccessMessage
      }
    } catch {
      $message = "$_`n" + $_.ScriptStackTrace
      Write-Debug $message
      try {
        # [x] Test
        # If we cannot make a symlink, try copy instead
        Write-Debug "Will attempt to copy '$Path' to '$Destination'."
        Copy-Item -Path "$Path" -Destination "$Destination"
        Write-Debug "Copied '$Path' to '$Destination'."
        if ("" -ne $SuccessMessage) {
          Write-Host $SuccessMessage
        }
      } catch {
        if ($ThrowOnFailure) {
          # [x] Test
          Write-Error $_
        } else {
          # [x] Test
          Write-Warning $_
          if ("" -ne $FailMessage) {
            Write-Warning $FailMessage
          }
        }
      }
    }
  }
}

# Extract archive
$ErrorActionPreference = 'Stop' # stop on all errors
$packageToolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$packageTarXzArchive = Join-Path $packageToolsDir -ChildPath 'git-filter-repo-2.45.0.tar.xz'
$packaceTarArchive = Join-Path $packageToolsDir -ChildPath 'git-filter-repo-2.45.0.tar'
$packagePyScriptDir = Join-Path $packageToolsDir -ChildPath 'git-filter-repo-2.45.0'
$packagePyScript = Join-Path $packagePyScriptDir -ChildPath "git-filter-repo"
$packageContribDir = Join-Path $packagePyScriptDir "contrib"
$packageContribDemosDir = Join-Path $packageContribDir "filter-repo-demos"
$contribDemosDirShortcutName = "git-filter-repo contrib scripts"
$packageUnzipArgsTarXz = @{
  FileFullPath = $packageTarXzArchive
  Destination  = $packageToolsDir
}
$packageUnzipArgsTar = @{
  FileFullPath = $packaceTarArchive
  Destination  = $packageToolsDir
}
## Extract tar.xz file to the specified location
Get-ChocolateyUnzip @packageUnzipArgsTarXz
## Extract tar file to the specified location
Get-ChocolateyUnzip @packageUnzipArgsTar
# Remove one of the two copies of the archive
Remove-Item $packaceTarArchive

# Install as Git program
Write-Debug "------------------------------"
Write-Debug "Will attempt to install $packageName as a Git program."
# Destination
$installGitExecPath = & git --exec-path
$installGitPyScript = Join-Path $installGitExecPath -ChildPath 'git-filter-repo'
# Messages
$messageSuccess = "Installed $packageName as a Git program at '$installGitPyScript'."
$messageFail = "Colud not install $packageName as a Git program. This needs to be installed to run $packageName with ""git filter-repo""."
# Arguments
$installFileArgs = @{
  Path           = $packagePyScript
  Destination    = $installGitPyScript
  SuccessMessage = $messageSuccess
  FailMessage    = $messageFail
  ThrowOnFailure = $true
}
# Install file
try {
  # [x] Test
  Install-File @installFileArgs
} catch {
  Write-Host $messageFail
  <# # Not working
  Write-Debug "------------------------------"
  Write-Debug "Will attempt to create a shim for $packageName."
  Install-BinFile -Name "git_filter_repo.py" -Path "$packagePyScript" #>
  Write-Debug "------------------------------"
  Write-Debug "Will add $packageName to the PATH."
  # Message
  # IMPROVE Check PATHEXT variable
  $messageSuccess = "Added $packageName to the PATH variable.`nYou will be able to be able to run $packageName with ""git_filter_repo"" (as long as the PATHEXT variable has "".PY"".)."
  # Add script directory to the path
  if ($isAdmin) {
    # [x] Test
    Install-ChocolateyPath "$packagePyScriptDir" "Machine" # Machine will assert administrative rights
  } else {
    Install-ChocolateyPath "$packagePyScriptDir" "User"
  }
  Write-Host $messageSuccess
}

# Install as Python module/library
Write-Debug "------------------------------"
Write-Debug "Will attempt to install $packageName as a Python module/library."
# Destination
# IMPROVE Warn if this fails or is $null
$installPythonSitePackages = Convert-Path -Path "$(& python -c "import site; print(site.getsitepackages()[1])")"
$installPythonPyScript = Join-Path $installPythonSitePackages -ChildPath 'git-filter-repo.py'
# Messages
$messageSuccess = "Installed $packageName as a Python module/library at '$installPythonPyScript'."
$messageFail = "Colud not install $packageName as a Python module/library, which is however *not needed* for using git-filter-repo.`nYou will be able to use git-filter-repo normally, but not create your own Python filtering scripts using git-filter-repo as a module,`nnor make use of some of the scripts in '$packageContribDemosDir'."
# Arguments for shortcut installation
$shortcut = "$env:UserProfile\Desktop\$contribDemosDirShortcutName.lnk"
$contribDemosDirShortcutArgs = @{
  shortcutFilePath = $shortcut
  targetPath       = $packageContribDemosDir
  description      = "Examples showing the breadth of what can be done with git-filter-repo as a library."
}
# Install file
try {
  # [x] Test
  Install-File -Path $packagePyScript `
    -Destination $installPythonPyScript `
    -SuccessMessage $messageSuccess `
    -ThrowOnFailure $true
  # [x] Test
  # Add desktop shortcut to the contrib demos directory
  Write-Debug "Will attempt to add desktop shortcut for '$shortcut' --> '$packageContribDemosDir'."
  Install-ChocolateyShortcut @contribDemosDirShortcutArgs
  Write-Debug "Shortcut added for '$shortcut' --> '$packageContribDemosDir'."
} catch {
  if ($null -ne $env:PYTHONPATH) {
    # [x] Test
    Write-Debug "PYTHONPATH variable found."
    $installPythonPyScript = Join-Path $env:PYTHONPATH -ChildPath 'git-filter-repo.py'
    $messageSuccess = "Installed $packageName as a Python module/library at '$installPythonPyScript'."
    Install-File -Path $packagePyScript `
      -Destination $installPythonPyScript `
      -SuccessMessage $messageSuccess `
      -FailMessage $messageFail
    # [x] Test
    # Add desktop shortcut to the contrib demos directory
    Write-Debug "Will attempt to add desktop shortcut for '$shortcut' --> '$packageContribDemosDir'."
    Install-ChocolateyShortcut @contribDemosDirShortcutArgs
    Write-Debug "Shortcut added for '$shortcut' --> '$packageContribDemosDir'."
  } else {
    # [x] Test
    Write-Debug "PYTHONPATH variable not found."
    Write-Warning $messageFail
  }
}

# Install man page for Git
Write-Debug "------------------------------"
Write-Debug "Will attempt to install $packageName's man page for Git."
# Path
$packageDocumentationDir = Join-Path $packagePyScriptDir -ChildPath 'Documentation'
$packageMan1Dir = Join-Path $packageDocumentationDir -ChildPath 'man1'
$packageManPage = Join-Path $packageMan1Dir -ChildPath 'git-filter-repo.1'
# Destination
$installManPath = [System.IO.Path]::GetFullPath($(& git --man-path)) # Convert-Path only works on real existing paths, so we do this
$installMan1Path = Join-Path $installManPath -ChildPath 'man1'
$installManPage = Join-Path $installMan1Path -ChildPath 'git-filter-repo.1'
# Messages
$messageSuccess = "Installed $packeName's man page for Git."
$messageFail = "Colud not install $packageName's man page for Git. This needs to be installed if you want ""git filter-repo --help"" to succeed in displaying the manpage, when help.format is ""man"" (not the default on Windows).`nNote that ""git filter-repo -h"" will show a more limited built-in set of instructions even if the manpage isn't installed."
# Arguments
$installFileArgs = @{
  Path           = $packageManPage
  Destination    = $installManPage
  SuccessMessage = $messageSuccess
  FailMessage    = $messageFail
}
# Install file
try {
  # [x] Test
  # Create necessary directories if missing
  New-Item -Path $installMan1Path -ItemType Directory -Force > $null
  Install-File @installFileArgs
} catch {
  # [x] Test
  Write-Warning "Could not create directories.`n$_"
  Write-Warning $messageFail
}

# Install html documentation
Write-Debug "------------------------------"
Write-Debug "Will attempt to install $packageName's html documentation file for Git."
# Path
$packageHtmlDir = Join-Path $packageDocumentationDir -ChildPath 'html'
$packageHtmlFile = Join-Path $packageHtmlDir -ChildPath 'git-filter-repo.html'
# Destination
$installHtmlDocumentationDir = Convert-Path -Path $(& git --html-path)
$installHtmlDocumentation = Join-Path $installHtmlDocumentationDir -ChildPath 'git-filter-repo.html'
# Messages
$messageSuccess = "Installed $packageName's html documentation file for Git."
$messageFail = "Colud not install $packageName's html documentation file for Git. This needs to be installed if you want ""git filter-repo --help"" to succeed in displaying the html version of the help, when help.format is set to ""html"" (the default on Windows).`nNote that ""git filter-repo -h"" will show a more limited built-in set of instructions even if the manpage isn't installed."
# Arguments
$installFileArgs = @{
  Path           = $packageHtmlFile
  Destination    = $installHtmlDocumentation
  SuccessMessage = $messageSuccess
  FailMessage    = $messageFail
}
# Install file
# [x] Test
Install-File @installFileArgs
