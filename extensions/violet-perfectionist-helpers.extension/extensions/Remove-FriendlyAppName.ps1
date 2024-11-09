function Remove-FriendlyAppName {
  param (
    # Path to exe
    [Alias("ExePath")]
    [parameter(Mandatory = $true, Position = 0)]
    [string]
    $Path
    # IMPROVE Option to look for only the executable part of the string.
    # IMPROVE Option to look for the value data.
  )
  Write-Verbose "Removing friendly app name..."
  $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
  $valueName = "$Path.FriendlyAppName"
  try {
    $valueExists = Test-RegKeyValue -Path $keyPath -Name $valueName
    if ($valueExists) {
      Write-Debug "Friendly app name found."
      Remove-ItemProperty -Path $keyPath -Name $valueName
      Write-Debug "Friendly app name removed."
    } else {
      Write-Debug "Friendly app name not found."
    }
  } catch {
    $message = "Could not remove friendly app name`n$_" + `
    "Could not remove the value '$Name' from the registry key '$Path'.`n$_"
    Write-Warning $message
  }  
}

## Example
# Remove-FriendlyAppName -Path "C:\Program Files (x86)\parallel-launcher\parallel-launcher.exe"
