# Unable to get this to work.

# get zelda3 process
$process = Get-Process "zelda3" -ea 0

# stop the process
if ($process) {
    $process | Stop-Process -Force
}

# get launcher process
$process = Get-Process "Zelda 3 Launcher" -ea 0

# stop the process
if ($process) {
    $process | Stop-Process -Force
}