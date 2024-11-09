function Test-RegKeyValue {
  param (
    [Alias("KeyPath")]
    [Alias("Key")]
    [parameter(Mandatory = $true, Position = 0, ParameterSetName="Path")]
    [parameter(Mandatory = $true, Position = 0, ParameterSetName="Name")]
    [parameter(Mandatory = $true, Position = 0, ParameterSetName="Data")]
    [string]
    $Path,
    
    [Alias("ValueName")]
    [parameter(Mandatory = $true, Position = 1, ParameterSetName="Name")]
    [parameter(Mandatory = $true, Position = 1, ParameterSetName="Data")]
    [string]$Name,
    
    [Alias("ValueData")]
    [parameter(Mandatory = $true, Position = 2, ParameterSetName="Data")]
    $Data
  )
  try {
    # Write-Debug "Testing if the registry key '$Path' exists..."
    Get-ItemProperty -Path $Path -ErrorAction Stop > $null
    if ($Name) {
      # Write-Debug "Testing if registry key '$Path' has the value '$Name'..."
      Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop > $null
      # Write-Debug "Value found."
    }
    if ($Data) {
      # Write-Debug "Testing if the value '$name' has the data '$Data'..."
      $existingValueData = Get-RegKeyValueData -Path $Path -Name $Name -ErrorAction Stop
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