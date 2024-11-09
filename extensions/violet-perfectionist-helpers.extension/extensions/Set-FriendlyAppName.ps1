# Add friendly app name (default is 'flips.exe')
# for current user only, because... I don't know, then I won't have to rewrite a function in removeregistrykeys.ps1 and make it more complicated.

function Set-FriendlyAppName {
  param (
    # Path to EXE
    [Alias("ExePath")]
    [Parameter(Mandatory = $true, Position = 0)]
    [string]
    $Path,

    # Friendly app name
    [Alias("FriendlyAppName")]
    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    $Name
  )
  $newValueData = $Name
  Write-Verbose "Setting friendly app name to '$newValueData'..."
  $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
  $valueName = $Path + ".FriendlyAppName"
  $keyExists = Test-Path -Path $keyPath # key exists;
  if (-not $keyExists) {
    # This shouldn't happen. Perhaps in a future version of Windows.
    $message = "MUI cache key not found! `n" + `
      "Path: $keyPath"
    Write-Warning $message
    return
  }
  # Try to create/set value
  try {
    $valueExists = Test-RegKeyValue -Path $keyPath -Name $valueName
    if (-not $valueExists) {
      Write-Debug "Creating value '$valueName' with value data '$newValueData' in registry key '$keyPath'..."
      New-ItemProperty -Path $keyPath -Name $valueName -Value $newValueData -Type STRING -ErrorAction Stop > $null
      Write-Debug "Value created."
      Write-Debug "Friendly app name set."
      return
      
    } else {
      $existingValueData = Get-RegKeyValueData -Path $keyPath -Name $valueName -ErrorAction Stop
      if ($existingValueData -eq $newValueData) {
        Write-Debug "The friendly app name is already set to '$newValueData'."
        return
      }
      Write-Debug "Changing the value data of value '$valueName' from '$existingValueData' to '$newValueData' in registry key '$keyPath'...."
      Set-ItemProperty -Path $keyPath -Name $valueName -Value $newValueData -Type STRING -ErrorAction Stop > $null
      Write-Debug "Value set."
      Write-Debug "Friendly app name set."
      return
    }
  } catch {
    Write-Warning "Could not set a friendly app name`n$_"
    return
  }
}

## Example
# Set-FriendlyAppName -Path "C:\Program Files (x86)\parallel-launcher\parallel-launcher.exe.FriendlyAppName" -Name "Parallel Launcher"
