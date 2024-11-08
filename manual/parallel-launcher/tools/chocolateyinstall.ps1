# Initialization
$ErrorActionPreference = 'Stop'
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

# Preferences
$pdfManualInstallDirPath = 'C:\Program Files (x86)\parallel-launcher'

# Install program
$filePath = Join-Path "$toolsDirPath" 'parallel-launcher_setup_win32.exe'
$file64Path = Join-Path "$toolsDirPath" 'parallel-launcher_setup_win64.exe'
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDirPath
  fileType       = 'EXE'
  file           = $filePath
  file64         = $file64Path
  softwareName   = 'Parallel Launcher*'
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
# Instead, we use Remove-Process after the installation.
# Run installer
Install-ChocolateyInstallPackage @packageArgs

# The installer automatically launches the program,
# so we should to close the program.
Write-Verbose "Terminating 'parallel-launcher' process..."
try {
  Remove-Process "parallel-launcher" -WaitFor 900 > $null # 15 minutes
  Write-Debug "Process 'parallel-launcher' terminated."
} catch {
  Write-Warning "Could not terminate 'parallel-launcher' process.`n$_"
}

# Install manual
$pdfManualPath = Join-Path "$toolsDirPath" -ChildPath 'Manual.pdf'
# Only copy if the program seems to be installed in the expected location.
$exists = Test-Path $pdfManualInstallDirPath -PathType Container
$empty = -not (Test-Path $pdfManualInstallDirPath\*)
if ($exists -and -not $empty) {
  try {
    Write-Verbose "Installing manual..."
    Copy-Item $pdfManualPath $pdfManualInstallDirPath
    Write-Debug "Manual installed."
  } catch {
    Write-Warning "Could not install manual.`n$_"
  }
} else {
  Write-Warning "Could not find installation directory. Manual will not be installed."
}