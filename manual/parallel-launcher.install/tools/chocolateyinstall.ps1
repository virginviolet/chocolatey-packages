$ErrorActionPreference = 'Stop'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$file = Join-Path $toolsDir 'parallel-launcher_setup_win32.exe'
$file64 = Join-Path $toolsDir 'parallel-launcher_setup_win64.exe'
$fileManual = Join-Path $toolsDir 'Manual.pdf'
$fileManualInstallDir = 'C:\Program Files (x86)\parallel-launcher'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'EXE'
  file          = $file
  file64        = $file64

  softwareName  = 'Parallel Launcher'

  checksum      = '2F3AAE6C3F209DD77F2D084FD73B5C577D9FD53BB9632FDFD0E721089837811A'
  checksumType  = 'sha256'
  checksum64    = 'D29D5AF0D3A5726D20F09D0BBA0E4927D4EE4E4EBC50A20BE83584C66749D65C'
  checksumType64= 'sha256'

  validExitCodes= @(0, 3010, 1641)

silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
}


Install-ChocolateyInstallPackage @packageArgs

# The installer automatically launches the program, se we the program instantly.
Stop-Process -Name "parallel-launcher" 2> $null

# Only copy the manual if the program is installed in the expected location.
$FolderNotEmpty = Test-Path -Path $fileManualInstallDir\*
if ($FolderNotEmpty){
  Copy-Item $fileManual $fileManualInstallDir 2> $null
}