function Get-ProcessId {
  param (
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name")]
    [string]
    $Name,
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "CommandLine")]
    [string]
    $CommandLine
  )
  if ($Name) {
    $processIds = Get-WmiObject Win32_Process | Where-Object {
      $_.Name -like $Name
    } | ForEach-Object {
      Write-Output "$($_.ProcessId)"
    }
  } elseif ($CommandLine) {
    # Escape characters for the path (by no means complete)
    $commandLineEscaped = $CommandLine -replace '\\', '\\' `
      -replace ':', '\:' -replace '\(', '\(' -replace '\)', '\)'
    $processIds = Get-WmiObject Win32_Process | Where-Object {
      $_.CommandLine -match $commandLineEscaped
    } | ForEach-Object {
      Write-Output "$($_.ProcessId)"
    }
  }
  # Return an object containing one or many strings
  return $processIds
}
