# Other steps for installing spacecadetpinball with Chocolatey

# Initialization
$ErrorActionPreference = 'Stop' # Stop on all errors
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$packagePath = "$(Split-Path -Parent "$toolsDirPath")"

# Preferences
$installationDirName = '3D Pinball x64'
$installationDirPath = Join-Path -Path "$toolsDirPath" -ChildPath "$installationDirName" # Used for shortcut installation
$shortcutName = 'Pinball'
$logShortcuts = $true

# Download and unpack a zip file
# Path
$url = 'https://ia902303.us.archive.org/28/items/3d-pinball-x64/3D%20Pinball%20x64.zip'
$unzipDirPath = Split-Path -LiteralPath "$installationDirPath"
# Arguments
$originalGameArgs = @{
  packageName   = 'spacecadetpinball'
  unzipLocation = $unzipDirPath
  url           = $url
  checksum      = 'AF6B1B5A3C0B9D13C58DFEFC937982A0357D209962A81003B11C8FA58EF56329'
  checksumType  = 'sha256' # Default is md5, can also be sha1, sha256 or sha512
}
Install-ChocolateyZipPackage @originalGameArgs

# Extract decompilation release archive
# Paths
$zipArchiveX64Path = Join-Path -Path "$toolsDirPath" -ChildPath 'SpaceCadetPinballx64Win.zip'
$zipArchiveX86Path = Join-Path -Path "$toolsDirPath" -ChildPath 'SpaceCadetPinballx86Win.zip'
$zipArchiveX86XpPath = Join-Path -Path "$toolsDirPath" -ChildPath 'SpaceCadetPinballx86WinXP.zip'
# Select which of x86 archives to use
$userOs = $([System.Environment]::OSVersion).Platform
# Windows NT (or Win32NT) is Windows XP up to Windows 11 (as of typing)
$windowsNt = [PlatformID]::Win32NT
$userOsVersionMajor = $([System.Environment]::OSVersion).Version.Major
$userOsVersionMinor = $([System.Environment]::OSVersion).Version.Minor
$userOsIs2000 = $userOs -eq $windowsNt -and $userOsVersionMajor -eq 5 -and $userOsVersionMinor -eq 0
$userOsIsXp = $userOs -eq $windowsNt -and $userOsVersionMajor -eq 5 -and $userOsVersionMinor -eq 1
if ($userOsIsXp) {
  # Use the Zip meant for XP
  Write-Debug "Windows XP (32-bit) detected."
  $zipArchiveX86CorrectPath = $zipArchiveX86XpPath
} elseif ($userOsIs2000) {
  # Untested
  # Use the Zip meant for XP
  Write-Debug "Windows 2000 detected."
  $zipArchiveX86CorrectPath = $zipArchiveX86XpPath
} else {
  # Don't use the zip meant for XP
  Write-Debug "Will not use the Windows XP version."
  $zipArchiveX86CorrectPath = $zipArchiveX86Path
}
# Package name
$packageName = Split-Path -Path "$packagePath" -Leaf
# Arguments
$decompiledArgs = @{
  PackageName    = "$packageName"
  FileFullPath   = "$zipArchiveX86CorrectPath"
  FileFullPath64 = "$zipArchiveX64Path"
  Destination    = "$installationDirPath"
}
# Unzip file to the specified location - auto overwrites existing content
Get-ChocolateyUnzip @decompiledArgs

# Add shortcuts
# Paths
$desktopPath = Convert-Path -LiteralPath "$env:UserProfile\Desktop\"
$desktopShortcutPath = Join-Path -Path "$desktopPath" -ChildPath "$shortcutName.lnk"
$isElevated = Test-ProcessAdminRights
if ($isElevated) {
  # Make Start Menu shortcut available to all users
  $startMenuPath = Convert-Path -LiteralPath "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\"
} else {
  # Make Start Menu shortcut available to current user only
  $startMenuPath = Convert-Path -LiteralPath "$Env:AppData\Microsoft\Windows\Start Menu\Programs\"
}
$startMenuGamesPath = Join-Path -Path "$startMenuPath" -ChildPath "Games"
$startMenuShortcutPath = Join-Path -Path "$startMenuGamesPath" -ChildPath "$shortcutName.lnk"
$gameDirShortcutPath = Join-Path -Path "$installationDirPath" -ChildPath "Launch $shortcutName.lnk"
$executableDirPath = $installationDirPath
$executablePath = Join-Path -Path "$installationDirPath" -ChildPath 'SpaceCadetPinball.exe'
if ($logShortcuts) {
  $shortcutsLogPath = Join-Path -Path "$packagePath" -ChildPath "shortcuts.txt"
}
# Description
$shortcutDescription = "Begins a game of 3-D Pinball."
# Add desktop shortcut
Install-ChocolateyShortcut -shortcutFilePath "$desktopShortcutPath" `
  -targetPath "$executablePath" `
  -workingDirectory "$executableDirPath" `
  -description $shortcutDescription
if ($logShortcuts) {
  "$desktopShortcutPath" | Out-File -FilePath "$shortcutsLogPath" -Append
}
# Add start menu shortcut
Install-ChocolateyShortcut -shortcutFilePath "$startMenuShortcutPath" `
  -targetPath "$executablePath" `
  -workingDirectory "$executableDirPath" `
  -description $shortcutDescription
if ($logShortcuts) {
  "$startMenuShortcutPath" | Out-File "$shortcutsLogPath" -Append
}
# Add game directory shortcut
Install-ChocolateyShortcut -shortcutFilePath "$gameDirShortcutPath" -targetPath "$executablePath" -workingDirectory "$executableDirPath" -description $shortcutDescription
if ($logShortcuts) {
  "$gameDirShortcutPath" | Out-File -FilePath "$shortcutsLogPath" -Append
}
