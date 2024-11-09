function Test-RegKeyValue {
  param (
    [Alias("KeyPath")]
    [Alias("Key")]
    [parameter(Mandatory = $true, Position = 0)]
    [string]
    $Path,
    
    [Alias("ValueName")]
    [parameter(Mandatory = $true, Position = 1)]
    $Name,

    [Alias("ValueData")]
    [parameter(Mandatory = $false, Position = 2)]
    $Data
  )
  try {
    # Write-Debug "Testing if registry key '$Path' has the value '$Name'..."
    Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop > $null
    # Write-Debug "Value found."
    if ($Data) {
      # Write-Debug "Testing if the value '$name' has the data '$Data'..."
      $existingValueData = Get-RegKeyValueData -Path $Path -Name $Name
      # Write-Debug "Value data matches the input."
      if ($existingValueData -eq $Data) {
        return $true
      } else {
        return $false
      }
    }
    return $true
  } catch [System.Management.Automation.ItemNotFoundException] {
    <# $message = "Could not get registry key value data.`n" + `
      "The key '$Path' does not exist.`n$_"
    Write-Debug $message #>
    return $false
  } catch [System.Management.Automation.PSArgumentException] {
    <# $message = "Could not get registry key value data. `n" + 
      "The key '$Path' does not have the value '$Name'.`n$_"
    Write-Debug $message #>
    return $false
  } catch {
    Write-Warning $_
    return $false
  }
}

## Example
# Test-RegKeyValue -Path "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" -Name "C:\Program Files\Notepad++\notepad++.exe.FriendlyAppName"