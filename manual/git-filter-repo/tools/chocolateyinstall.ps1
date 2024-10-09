# Check if running in administrative shell
function Test-Administrator {  
  [OutputType([bool])]
  param()
  process {
    [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
    return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
  }
}

$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
# $tarXzArchive = Join-Path $toolsDir -ChildPath 'git-filter-repo-2.45.0.zip'
$tarXzArchive = Join-Path $toolsDir -ChildPath 'git-filter-repo-2.45.0.tar.xz'
$tarArchive = Join-Path $toolsDir -ChildPath 'git-filter-repo-2.45.0.tar'
$scriptDir = Join-Path $toolsDir -ChildPath 'git-filter-repo-2.45.0'
$script = Join-Path $scriptDir -ChildPath "git-filter-repo"
$contribDir = Join-Path $scriptDir "contrib"
$contribDemosDir = Join-Path $contribDir "filter-repo-demos"

$unzipArgsTarXz = @{
  FileFullPath = $tarXzArchive
  Destination  = $toolsDir
}

$unzipArgsTar = @{
  FileFullPath = $tarArchive
  Destination  = $toolsDir
}

## Helper functions - these have error handling tucked into them already
## see https://docs.chocolatey.org/en-us/create/functions

## Unzip file to the specified location - auto overwrites existing content
## - https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip
# Get-ChocolateyUnzip @unzipArgsTarXz
# Remove-Item $tarArchive
# Get-ChocolateyUnzip @unzipArgsTar

## To avoid quoting issues, you can also assemble your -Statements in another variable and pass it in
#$appPath = "$env:ProgramFiles\appname"
##Will resolve to C:\Program Files\appname
#$statementsToRun = "/C `"$appPath\bin\installservice.bat`""
#Start-ChocolateyProcessAsAdmin $statementsToRun cmd -validExitCodes $validExitCodes

## add specific folders to the path - any executables found in the chocolatey package
## folder will already be on the path.
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateypath
#Install-ChocolateyPath 'LOCATION_TO_ADD_TO_PATH' 'User_OR_Machine' # Machine will assert administrative rights



# Add script to the path
<# if (Test-Administrator) {
  Install-ChocolateyPath "$scriptDir" "Machine" # Machine will assert administrative rights
} else {
  Install-ChocolateyPath "$scriptDir" "User"
} #>

if (Test-Administrator) {
  Write-Debug "Elevated instance detected."
  $isAdmin = $true
} else {
  Write-Debug "Process does not seem to be elevated."
  $isAdmin = $false
}

# TODO Install man
# TODO Install help patch

# Install as Git program

$execPath = & git --exec-path
$scriptGit = Join-Path $execPath -ChildPath 'git-filter-repo'
# Success message
$messageInstalledAsGit = "Installed $packageName as a Git program at '$scriptGit'."
if ($isAdmin) {
  # Creating symlinks natively with PowerShell is only available in Windows PowerShell >= 5.0
  & cmd /c mklink "$scriptGit" "$script" 1>$null 2>&1 # suppress success stream; use cmd's error output as error
  Write-Host $messageInstalledAsGit
} else {
  try {
    # Try to make symlink
    # (Admin rigths is not required to make symlinks on Windows >= 10 build 14972 with Developer Mode enabled)
    Write-Debug "Attempting to make a symlink for '$scriptGit' <<===>> '$script'."
    & cmd /c mklink "$scriptGit" "$script" 1>$null 2>&1
    Write-Debug "Symlink created for '$scriptGit' <<===>> '$script'."
    Write-Host $messageInstalledAsGit
  } catch {
    $message = "$_`n" + $_.ScriptStackTrace
    Write-Debug $message
    try {
      # [x] Test
      # If we cannot make a symlink, try copy instead
      Copy-Item -Path "$script" -Destination "$scriptGit"
      Write-Host $messageInstalledAsGit
    } catch {
      # [x] Test
      Write-Warning $_
      Write-Warning "Colud not install $packageName as a Git program."
    }
  }
}

# Install as Python module/library

# Success message
$messageInstalledAsPython = "Installed $packageName as a Python module/library at '$scriptPython'."
# IMPROVE Warn if this fails or is $null
$pythonSitePackages = Convert-Path -Path "$(& python -c "import site; print(site.getsitepackages()[1])")"
$scriptPython = Join-Path $pythonSitePackages -ChildPath 'git-filter-repo.py'
if ($isAdmin) {
  & cmd /c mklink "$scriptPython" "$script" 1>$null 2>&1
  Write-Host $messageInstalledAsPython
} else {
  try {
    # [x] Test
    # Try to make symlink
    Write-Debug "Attempting to make a symlink for '$scriptPython' <<===>> '$script'."
    & cmd /c mklink "$scriptPython" "$script" 1>$null 2>&1
    # [x] Test
    Write-Debug "Symlink created for '$scriptPython' <<===>> '$script'."
    $installedToPythonSitePackages = $true
    Write-Host $messageInstalledAsPython
  } catch {
    # [x] Test
    $message = "$_`n" + $_.ScriptStackTrace
    Write-Debug $message
    try {
      Copy-Item -Path "$script" -Destination "$scriptPython"
      $installedToPythonSitePackages = $true
      Write-Host $messageInstalledAsPython
      } catch {
        # [x] Test
        $message = "$_`n" + $_.ScriptStackTrace
        Write-Debug $message
        $installedToPythonSitePackages = $false
      }
    }
  # If previous step failed
  # Try install to PYTHONPATH
  # Message that will be displayed if this also fails
  $messageCouldNotInstallAsPython = "Colud not install $packageName as a Python module/library, which is however _not needed_ for using git-filter-repo.`nYou will be able to use git-filter-repo normally, but not create your own Python filtering scripts using git-filter-repo as a module,`nnor make use of some of the scripts in '$contribDemosDir'."
  # echo $installedToPythonSitePackages
  # $installedToPythonSitePackages = $false
  # If PYTHONPATH is set
  # 1 0
  # [x] Test
  if ($null -ne $env:PYTHONPATH -and -not $installedToPythonSitePackages) {
    Pause
    Write-Debug "PYTHONPATH variable found."
    $scriptPython = Join-Path $env:PYTHONPATH -ChildPath 'git-filter-repo.py'
    # Message to display if it succeeds
    $messageInstalledAsPython = "Installed $packageName as a Python module/library at '$scriptPython'."
    try {
      # [x] Test
      # Try to make symlink
      Write-Debug "Attempting to make a symlink for '$scriptPython' <<===>> '$script'."
      & cmd /c mklink "$scriptPython" "$script" 1>$null 2>&1
      # [x] Test
      Pause
      Write-Debug "Symlink created for '$scriptPython' <<===>> '$script'."
      Write-Host $messageInstalledAsPython
    } catch {
      # [x] Test
      $message2 = "$_`n" + $_.ScriptStackTrace
      Write-Debug $message2
      try {
        # [x] Test
        # If we cannot make a symlink, try copy instead
        Copy-Item -Path "$script" -Destination "$scriptPython"
        Write-Host $messageInstalledAsPython
      }
      catch {
        # [x] Test
        Write-Warning $message
        Write-Warning $_
        Write-Warning $messageCouldNotInstallAsPython
      }
    }
  }
  # If PYTHONPATH is *not* set
  # 0 0
  # [x] Test
  elseif ($null -eq $env:PYTHONPATH -and -not $installedToPythonSitePackages) {
    Write-Warning $message
    Write-Warning "PYTHONPATH variable not found."
    Write-Warning $messageCouldNotInstallAsPython
  }
  # If PYTHONPATH is set and previous step didn't actually fail
  # 1 1
  # [x] Test
  elseif ($null -ne $env:PYTHONPATH) {
    Write-Debug "PYTHONPATH variable found."
  }
  # If PYTHONPATH is *not* set, but the previous step didn't actually fail, so it's ok
  # 0 1
  # [x] Test
  elseif ($null -eq $env:PYTHONPATH) {
    Write-Debug "PYTHONPATH variable not found."
  }
}

# Install man page for Git

$documentationDir = Join-Path $scriptDir -ChildPath 'Documentation'
$manPage = Join-Path $documentationDir -ChildPath 'git-filter-repo.1'
$manPath = [System.IO.Path]::GetFullPath($(& git --man-path)) # Convert-Path only works on existing paths, so we do this
$man1Path = Join-Path $manPath -ChildPath 'man1'
$manPageGit = Join-Path $man1Path -ChildPath 'git-filter-repo.1'
if ($isAdmin) { 
  & cmd /c mklink "$manPage" "$script" 1>$null 2>&1
} else {

}

# TODO Shortcut to demo scripts dir

## Outputs the bitness of the OS (either "32" or "64")
## - https://docs.chocolatey.org/en-us/create/functions/get-osarchitecturewidth
#$osBitness = Get-ProcessorBits

## Set persistent Environment variables
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyenvironmentvariable
#Install-ChocolateyEnvironmentVariable -variableName "SOMEVAR" -variableValue "value" [-variableType = 'Machine' #Defaults to 'User']

## Adding a shim when not automatically found - Chocolatey automatically shims exe files found in package directory.
## - https://docs.chocolatey.org/en-us/create/functions/install-binfile
## - https://docs.chocolatey.org/en-us/create/create-packages#how-do-i-exclude-executables-from-getting-shims
# Install-BinFile -Name "git_filter_repo.py" -Path "$script"

## Other needs: use regular PowerShell to do so or see if there is a function already defined
## - https://docs.chocolatey.org/en-us/create/functions
## There may also be functions available in extension packages
## - https://community.chocolatey.org/packages?q=id%3A.extension for examples and availability.
