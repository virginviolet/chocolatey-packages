function Get-ProcessNames {
    param (  
      [parameter(Mandatory = $true, Position = 0)]
      [string]
      $CommandLine
    )
    $commandLineEscaped = $CommandLine -replace '\\', '\\' `
      -replace ':', '\:' -replace '\(', '\(' -replace '\)', '\)'
    $processNames = Get-WmiObject Win32_Process | Where-Object {
      $_.CommandLine -match $commandLineEscaped
    } | ForEach-Object {
      Write-Output "$($_.Name)"
    }
    return $processNames
  }