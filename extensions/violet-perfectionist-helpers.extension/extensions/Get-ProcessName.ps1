# Sometimes, a process has an automatically generated name,
# but the name can sometimes be found by looking for
# the process's Commard Line property, which is what this function does.
function Get-ProcessName {
  param (
    [parameter(Mandatory = $true, Position = 0)]
    [string]
    $CommandLine
  )
  # Escape characters for the path (by no means complete)
  $commandLineEscaped = $CommandLine -replace '\\', '\\' `
    -replace ':', '\:' -replace '\(', '\(' -replace '\)', '\)'
  $processNames = Get-WmiObject Win32_Process | Where-Object {
    $_.CommandLine -match $commandLineEscaped
  } | ForEach-Object {
    Write-Output "$($_.Name)"
  }
  # Return an object containing one or many strings
  return $processNames
}

## Example
# $processes = (Get-ProcessName -CommandLine "C:\Program Files (x86)\parallel-launcher\unins000.exe")
# if ($processes -is [string]) {
#   # If one process matched, '$processes' will be a string
#   $process = $processes
# } else {
#   # If multiple processes matched, use the last match
#   $process = $processes[-1]
# }
# Write-Host "Process name: '$process'"

# TODO Add a parameter to pick last match, first match, or a specific number.
