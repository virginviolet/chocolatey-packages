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
  Write-Debug "Setting frinedly app name..."
  $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
  $valueName = "$Path" + ".FriendlyAppName"
  $newValueData = $Name
  $keyExists = Test-Path -Path "$keyPath" # key exists;
  if (-not $keyExists) {
    # This shouldn't happen. Perhaps in a future version of Windows.
    $message = "MUI cache key not found! `n" + `
      "Path: $keyPath"
    Write-Warning $message
  } else {
    $existingValueData = '' # Initialize variable
    try {
      $existingValue = Get-ItemProperty -Path $keyPath -Name $valueName -ErrorAction Stop
      $valueExists = $true
      $existingValueData = $existingValue.$valueName
    } catch [System.Management.Automation.PSArgumentException] {
      $valueExists = $false
    } catch {
      Write-Warning $_
    }
    # Try to create/set value
    try {
      if ($valueExists) {
        if ($existingValueData -eq $newValueData) {
          Write-Debug "The friendly app name is already set to '$newValueData'."
        } else {
          Write-Debug "Changing the value data of value '$valueName' from '$existingValueData' to '$newValueData' in registry key '$keyPath'...."
          Set-ItemProperty -Path $keyPath -Name $valueName -Value $newValueData -Type STRING
          Write-Debug "Value set."
          Write-Debug "Friendly app name set."
        }
      } else {
        Write-Debug "Creating value '$valueName' with value data '$newValueData' in registry key '$keyPath'..."
        New-ItemProperty -Path $keyPath -Name $valueName -Value $newValueData -Type STRING
        Write-Debug "Value created."
        Write-Debug "Friendly app name set."
      }
    } catch {
      Write-Warning "Could not set a friendly app name`n$_"
    }
  }
}

New-Alias -Name New-FriendlyAppName -Value Set-FriendlyAppName

## Example
# Set-FriendlyAppName -Path "C:\Program Files (x86)\parallel-launcher\parallel-launcher.exe.FriendlyAppName" -Name "Parallel Launcher"
