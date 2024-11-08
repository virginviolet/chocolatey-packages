# Wait for process to start
function Wait-ProcessStart {
  param
  (
    [parameter(Mandatory = $true, Position = 0)]
    [string]
    $Name,
    
    [Alias("Seconds")]
    [parameter(Mandatory = $true, Position = 1, ParameterSetName = "Seconds")]
    [double]
    $Timeout,

    [parameter(Mandatory = $false, Position = 1, ParameterSetName = "Milliseconds")]
    [int]
    $Milliseconds,

    [parameter(Mandatory = $false, Position = 3)]
    [int]
    $Interval,

    [parameter(Mandatory = $false)]
    [Switch]
    $IgnoreAlreadyRunningProcesses
  )
  if ($IgnoreAlreadyRunningProcesses) {
    $initialProcessCount = `
      (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    $currentProcessCount = $initialProcessCount
  } else {
    $initialProcessCount = 0
    $currentProcessCount = `
      (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    if ($currentProcessCount -gt $initialProcessCount) {
      Write-Debug "Process '$Name' already running."
      return
    }
  }
  # Set default Interval value
  if (-not $Interval) {
    if ($Milliseconds) {
      $Interval = 1000
    } else {
      $Interval = 1
    }
  }
  # Convert to milliseconds
  if ($Timeout) {
    $Timeout = $Timeout * 1000
    $Interval = $Interval * 1000
  }
  # Move value from $Milliseconds over to $Timeout
  if ($Milliseconds) {
    $Timeout = $Milliseconds
  }
  Write-Debug "Waiting for process '$Name' to start..."
  if (-not $Timeout) {
    while (($currentProcessCount -le $initialProcessCount)) {
      $currentProcessCount = `
        (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
      Start-Sleep -Milliseconds $Interval
    }
  } else {
    while (($currentProcessCount -le $initialProcessCount) -and
      ($Timeout -gt 0)) {
      $currentProcessCount = `
        (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
      Start-Sleep -Milliseconds $Interval
      $Timeout -= $Interval
    }
  }
  if ($currentProcessCount -gt $initialProcessCount) {
    Write-Debug "Process '$Name' started."
  } elseif ($Timeout -eq 0) {
    Write-Warning "Wait for process to start timed out."
  }
}
