function Get-RegistryKey {
  param (
    [Alias("KeyPath")]
    [Alias("Key")]
    [parameter(Mandatory = $true, Position = 0)]
    [string]
    $Path,
    
    [Alias("ValueName")]
    [parameter(Mandatory = $false, Position = 1)]
    [string]$Name
  )
  try {
    if (-not $Name) {
      # Write-Debug "Getting the registry key '$Path'..."
      $key = Get-ItemProperty -Path $Path -ErrorAction Stop
      # Write-Debug "Registry key retrieved"
      return $key
    }
  } catch [System.Management.Automation.ItemNotFoundException] {
    $message = "Could not get registry key.`n" + `
      "The key '$Path' does not exist.`n$_"
    Write-Error $message
    return
  } catch {
    Write-Error "Could not get registry key.`n$_"
    return
  }
  # If 'Name' parameter was supplied:
  try {
    # Write-Debug "Getting the value '$Name' from the key '$Path'..."
    $value = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop
    # Write-Debug "Value found."
    # Write-Debug "Getting the value data..."
    $valueData = $value.$Name
    # Write-Debug "Value data found."
    return $valueData
  } catch [System.Management.Automation.ItemNotFoundException] {
    $message = "Could not get registry key value data.`n" + `
      "The key '$Path' does not exist.`n$_"
    Write-Error $message
  } catch [System.Management.Automation.PSArgumentException] {
    # Write-Warning "Value not found."
    $message = "Could not get registry key value data. `n" + 
    "The key '$Path' does not have the value '$Name'.`n$_"
    Write-Error $message
  } catch {
    Write-Error "Could not get registry key value data.`n$_"
  }
}

New-Alias -Name Get-RegKey -Value Get-RegistryKey

## Example: Get the value data from a registry key value
# Get-RegistryKey -Path "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" -Name "C:\Program Files\Notepad++\notepad++.exe.FriendlyAppName"