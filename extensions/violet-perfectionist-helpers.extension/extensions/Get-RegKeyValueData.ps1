function Get-RegKeyValueData {
  param (
    [Alias("KeyPath")]
    [Alias("Key")]
    [parameter(Mandatory = $true, Position = 0)]
    [string]
    $Path,
    
    [Alias("ValueName")]
    [parameter(Mandatory = $true, Position = 1)]
    [string]$Name
  )
  try {
    # Write-Debug "Testing if registry key '$Path' has the value '$Name'..."
    $value = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop
    # Write-Debug "Value found."
    # Write-Debug "Getting the value data..."
    $valueData = $value.$Name
    # echo $value
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

## Example
# Get-RegKeyValueData -Path "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" -Name "C:\Program Files\Notepad++\notepad++.exe.FriendlyAppNamea"