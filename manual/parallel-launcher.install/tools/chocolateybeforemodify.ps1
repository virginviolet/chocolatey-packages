# $ErrorActionPreference = 'Stop'

# Doesn't seem like what I am trying to do is possible at the
# https://github.com/chocolatey/choco/issues/1731
# try {
#   $programRunning = Get-Process "parallel-launcher"
# } catch {
#   echo "program is NOT running"
#   echo $programRunning
#   exit 0
# }

# try {
#   throw "Parallel Launcher is running. Stop Parallel Launcher and try again."
# } catch {
#   Write-Error $_.Exception.Message
#   exit 1
# }