
# Wait for process to start
function Wait-ProcessStart {
  param
  (
    [parameter(Mandatory = $true, Position = 0)][string]$Name,
    [Alias("Seconds")][parameter(Mandatory = $false, Position = 1, ParameterSetName = "Seconds")][int]$Timeout,
    [parameter(Mandatory = $false, Position = 2)][int]$Milliseconds,
    [parameter(Mandatory = $false, Position = 3)][int]$Interval,
    [parameter(Mandatory = $false)][Switch]$IgnoreAlreadyRunningProcesses
  )
  if ($IgnoreAlreadyRunningProcesses) {
    $initialProcessCount = (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    $currentProcessCount = $initialProcessCount
  } else {
    $initialProcessCount = 0
    $currentProcessCount = (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    if ($currentProcessCount -gt $initialProcessCount) {
      Write-Debug "Process '$Name' already running."
      return
    }
  }
  if ($Interval -lt 1) { $interval = 1 }
  Write-Debug "Waiting for process '$Name' to start..."
  while (($currentProcessCount -le $initialProcessCount) -and
    ($Timeout -gt 0)) {
    $currentProcessCount = (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    Start-Sleep 1
    $Timeout--
  }
  if ($currentProcessCount -gt $initialProcessCount) {
    Write-Debug "Process '$Name' started."
  } elseif ($Timeout -eq 0) {
    Write-Warning "Wait for process to start timed out."
  }
}