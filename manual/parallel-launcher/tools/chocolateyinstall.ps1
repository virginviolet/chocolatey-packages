$ErrorActionPreference = 'Stop'
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

# Extract archive
# Documantation - https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip
# Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Get-ChocolateyUnzip.ps1
# Paths
# Outputs the bitness of the OS (either "32" or "64")
# Documantation - https://docs.chocolatey.org/en-us/create/functions/get-osarchitecturewidth
# Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Get-OSArchitectureWidth.ps1
$osBitness = Get-ProcessorBits
if ($osBitness -eq 32) {
  $zipArchivePath = Join-Path "$toolsDirPath" -ChildPath 'parallel-launcher-v7.8.0-windows32'
} elseif ($osBitness -eq 64) {
  $zipArchivePath = Join-Path "$toolsDirPath" -ChildPath 'parallel-launcher-v7.8.0-windows32'
} else {
  Write-Error "Get-ProcessorBits returned neither 32 or 64."
}
# Arguments
$unzipArgs = @{
  PackageName  = "$($packageName)"
  FileFullPath = "$zipArchivePath"
  Destination  = "$toolsDirPath"
}
# Unzip file to the specified location (auto overwrites existing content)
Get-ChocolateyUnzip @unzipArgs

$filePath = Join-Path "$toolsDirPath" 'parallel-launcher_setup_win32.exe'
$file64Path = Join-Path "$toolsDirPath" 'parallel-launcher_setup_win64.exe'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDirPath
  fileType       = 'EXE'
  file           = $filePath
  file64         = $file64Path
  softwareName   = 'Parallel Launcher'
  checksum       = '185916205B2C1D2513296D64816F201AD295AB2D3FF40365EF9531EB14310DF0'
  checksumType   = 'sha256'
  checksum64     = '0692E3F857D91BA99C068CBE2A993201E41630977D57128F5A20830AB9EC89AE'
  checksumType64 = 'sha256'
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  validExitCodes = @(0) # Inno Setup
}
# The installer automatically launches the program on completion,
# so we should to close the program.
# 'Start-WaitandStop' does not work (pull request pending).
# Start-WaitandStop "parallel-launcher"
# Instead, we use Stop-Process after the installation.
Install-ChocolateyInstallPackage @packageArgs

# The installer automatically launches the program,
# so we should to close the program.
Write-Verbose "Terminating 'parallel-launcher' process..."
try {
  Stop-Process -Name "parallel-launcher"
  Write-Debug "Process 'parallel-launcher' terminated."
} catch {
  Write-Warning "Could not terminate 'parallel-launcher' process.`n$_"
}

# Install manual
$manualPath = Join-Path "$toolsDirPath" 'Manual.pdf'
$manualInstallDirPath = 'C:\Program Files (x86)\parallel-launcher'
# Only copy if the program seems to be installed in the expected location.
$exists = Test-Path $manualInstallDirPath -PathType Container
$empty = -not (Test-Path $manualInstallDirPath\*)
if ($exists -and -not $empty) {
  try {
    Write-Verbose "Installing manual..."
    Copy-Item $manualPath $manualInstallDirPath
    Write-Debug "Manual installed."
  } catch {
    Write-Warning "Could not install manual.`n$_"
  }
} else {
  Write-Warning "Could not find installation directory. Manual will not be installed."
}
