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

function Install-File {
  param (
    [string]$Path,
    [string]$Destination,
    [string]$SuccessMessage,
    [string]$FailMessage,
    [bool]$ThrowOnFailure = $false
  )
  # Remove file if it exists first, so don't get an error if it exists
  $exists = [bool](Test-Path -Path $Destination)
  if ($exists) {
    # [x] Test
    Write-Warning "File already exists: '$Destination'.`n$_"
    try {
      # [ ] Test
      Remove-Item -Path $Destination
    } catch {
      if ($ThrowOnFailure) {
        # [x] Test
        Write-Error $_
      } else {
        # [x] Test
        Write-Warning "Cannot remove file '$Destination'.`n$_"
        Write-Warning $FailMessage
        return
      }
    }
  }
  # Check if admininstrator
  # [ ] Test
  if ($null -eq $script:isAdmin) {
    if (Test-Administrator) {
      Write-Debug "Elevated instance detected."
      # Set variable in the Script scope so that we do not need to run Test-Administrator every time Install-File is run 
      $script:isAdmin = $true
    } else {
      Write-Debug "Process does not seem to be elevated."
      $script:isAdmin = $false
    }
  }
  # Install file
  if ($isAdmin) {
    # [x] Test
    # Create symlink
    # Creating symlinks natively with PowerShell is only available in Windows PowerShell >= 5.0
    & cmd /c mklink "$Destination" "$Path" 1>$null 2>&1 # suppress success stream; use cmd's error output as error
    Write-Debug "Symlink created for '$Destination' <<===>> '$Path'."
    Write-Host $SuccessMessage
  } else {
    try {
      # [x] Test
      # Create symlink
      # (Admin rigths is not required to make symlinks on Windows >= 10 build 14972 with Developer Mode enabled)
      Write-Debug "Attempting to make a symlink for '$Destination' <<===>> '$Path'."
      & cmd /c mklink "$Destination" "$Path" 1>$null 2>&1
      Write-Debug "Symlink created for '$Destination' <<===>> '$Path'."
      Write-Host $SuccessMessage
    } catch {
      $message = "$_`n" + $_.ScriptStackTrace
      Write-Debug $message
      try {
        # [x] Test
        # If we cannot make a symlink, try copy instead
        Write-Debug "Will attempt to copy '$Path' to '$Destination'."
        Copy-Item -Path "$Path" -Destination "$Destination"
        Write-Debug "Copied '$Path' to '$Destination'."
        Write-Host $SuccessMessage
      } catch {
        if ($ThrowOnFailure) {
          # [ ] Test
          Write-Error $_
        } else {
          # [ ] Test
          Write-Warning $_
          Write-Warning $FailMessage
        }
      }
    }
  }
}

# Install as Git program
Write-Debug "------------------------------"
Write-Debug "Will attempt to install $packageName as a Git program."
$execPath = & git --exec-path
$scriptGit = Join-Path $execPath -ChildPath 'git-filter-repo'
$messageSuccess = "Installed $packageName as a Git program at '$scriptGit'."
$messageFail = "Colud not install $packageName as a Git program."
$installFileArgs = @{
  Path           = $script
  Destination    = $scriptGit
  SuccessMessage = $messageSuccess
  FailMessage    = $messageFail
}
Install-File @installFileArgs

# Install as Python module/library
Write-Debug "------------------------------"
Write-Debug "Will attempt to install $packageName as a Python module/library."
# IMPROVE Warn if this fails or is $null
$pythonSitePackages = Convert-Path -Path "$(& python -c "import site; print(site.getsitepackages()[1])")"
$scriptPython = Join-Path $pythonSitePackages -ChildPath 'git-filter-repo.py'
# Success message
$messageSuccess = "Installed $packageName as a Python module/library at '$scriptPython'."
# Fail message
$messageFail = "Colud not install $packageName as a Python module/library, which is however _not needed_ for using git-filter-repo.`nYou will be able to use git-filter-repo normally, but not create your own Python filtering scripts using git-filter-repo as a module,`nnor make use of some of the scripts in '$contribDemosDir'."
try {
  # [x] Test
  Install-File -Path $script `
    -Destination $scriptPython `
    -SuccessMessage $messageSuccess `
    -ThrowOnFailure $true
} catch {
  if ($null -ne $env:PYTHONPATH) {
    # [x] Test
    Write-Debug "PYTHONPATH variable found."
    $scriptPython = Join-Path $env:PYTHONPATH -ChildPath 'git-filter-repo.py'
    $messageSuccess = "Installed $packageName as a Python module/library at '$scriptPython'."
    Install-File -Path $script `
      -Destination $scriptPython `
      -SuccessMessage $messageSuccess `
      -FailMessage $messageFail
  } else {
    # [x] Test
    Write-Debug "PYTHONPATH variable not found."
    Write-Warning $messageFail
  }
}

# Install man page for Git
Write-Debug "------------------------------"
Write-Debug "Will attempt to install $packageName's man page for Git."
$documentationDir = Join-Path $scriptDir -ChildPath 'Documentation'
$manPage = Join-Path $documentationDir -ChildPath 'git-filter-repo.1'
$manPath = [System.IO.Path]::GetFullPath($(& git --man-path)) # Convert-Path only works on real existing paths, so we do this
$man1Path = Join-Path $manPath -ChildPath 'man1'
$manPageGit = Join-Path $man1Path -ChildPath 'git-filter-repo.1'
$messageSuccess = "Installed $packeName's man page for Git."
$messageFail = "Colud not install $packageName's man page for Git."
$installFileArgs = @{
  Path = $manPage
  Destination = $manPageGit
  SuccessMessage = $messageSuccess
  FailMessage = $messageFail
}
try {
  # [x] Test
  # Create necessary directories if missing
  New-Item -Path $man1Path -ItemType Directory -Force > $null
  Install-File @installFileArgs
}
catch {
  # [x] Test
  Write-Warning "Could not create directories.`n$_"
  Write-Warning $messageFail
}

# TODO Install help patch

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
