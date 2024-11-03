# Other steps for installing spacecadetpinball with Chocolatey

# Initialization
$ErrorActionPreference = 'Stop' # Stop on all errors
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$packagePath = "$(Split-Path -Parent $toolsDirPath)"

# Preferences
$installationDirName = '3D Pinball x64'
$installationDirPath = Join-Path "$toolsDirPath" "$installationDirName"
$shortcutName = 'Pinball'
$logShortcuts = $true

# Download and unpack a zip file
# Path
$url = 'https://ia902303.us.archive.org/28/items/3d-pinball-x64/3D%20Pinball%20x64.zip'
$unzipDirPath = Split-Path $installationDirPath
# Arguments
$originalGameArgs = @{
  packageName   = 'spacecadetpinball'
  unzipLocation = $unzipDirPath
  url           = $url
  checksum      = 'AF6B1B5A3C0B9D13C58DFEFC937982A0357D209962A81003B11C8FA58EF56329'
  checksumType  = 'sha256' # Default is md5, can also be sha1, sha256 or sha512
  # checksum64    = 'AF6B1B5A3C0B9D13C58DFEFC937982A0357D209962A81003B11C8FA58EF56329'
  # checksumType64= 'sha256' # Default is checksumType
}
Install-ChocolateyZipPackage @originalGameArgs

# Extract decompilation release archive
# Paths
$zipArchiveX64Path = Join-Path $toolsDirPath -ChildPath 'SpaceCadetPinballx64Win.zip'
$zipArchiveX86Path = Join-Path $toolsDirPath -ChildPath 'SpaceCadetPinballx86Win.zip'
$zipArchiveX86XpPath = Join-Path $toolsDirPath -ChildPath 'SpaceCadetPinballx86WinXP.zip'
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
# Arguments
$decompiledArgs = @{
  PackageName    = "$($packageName)"
  FileFullPath   = "$zipArchiveX86CorrectPath"
  FileFullPath64 = "$zipArchiveX64Path"
  Destination    = "$installationDirPath"
}
# Unzip file to the specified location - auto overwrites existing content
Get-ChocolateyUnzip @decompiledArgs

# Add shortcuts
# Paths
$executableDirPath = $installationDirPath
$executablePath = Join-Path "$installationDirPath" -ChildPath 'SpaceCadetPinball.exe'
$desktopShortcutPath = "$env:UserProfile\Desktop\$shortcutName.lnk"
$startMenuShortcutPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Games\$shortcutName.lnk"
$gameDirShortcutPath = Join-Path "$installationDirPath" -ChildPath "Launch $shortcutName.lnk"
$shortcutDescription = "Begins a game of 3-D Pinball."
if ($logShortcuts) {
  $shortcutsLogPath = Join-Path "$packagePath" -ChildPath "shortcuts.txt"
}
# Add desktop shortcut
Install-ChocolateyShortcut -shortcutFilePath "$desktopShortcutPath" `
  -targetPath "$executablePath" `
  -workingDirectory "$executableDirPath" `
  -description $shortcutDescription
if ($logShortcuts) {
  "$desktopShortcutPath" | Out-File "$shortcutsLogPath" -Append
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
Install-ChocolateyShortcut @gameDirShortcutArgs -shortcutFilePath "$gameDirShortcutPath" -targetPath "$executablePath" -workingDirectory "$executableDirPath" -description $shortcutDescription
if ($logShortcuts) {
  "$gameDirShortcutPath" | Out-File "$shortcutsLogPath" -Append
}
