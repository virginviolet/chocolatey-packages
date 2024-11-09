function Test-RegistryKey {
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
    
    [Alias("ValueData","Data")]
    [parameter(Mandatory = $true, Position = 2, ParameterSetName="Data")]
    $Value
  )
  if (-not $Path.StartsWith("REGISTRY::") -and `
      $Path -ne '' -and `
      $null -ne $Path) {
        $Path = $Path.Insert(0,"REGISTRY::")
  }
  try {
    # Write-Debug "Testing if the registry key '$Path' exists..."
    Get-ItemProperty -Path $Path -ErrorAction Stop > $null
    if ($Name) {
      # Write-Debug "Testing if registry key '$Path' has the value '$Name'..."
      Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop > $null
      # Write-Debug "Value found."
    }
    if ($Value) {
      # Write-Debug "Testing if the value '$name' has the data '$Value'..."
      $existingValueData = Get-RegKeyValueData -Path $Path -Name $Name -ErrorAction Stop
      # Write-Debug "Value data matches the input."
      if ($existingValueData -eq $Value) {
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

New-Alias -Name Test-RegKey -Value Test-RegistryKey -Scope Global

## Example 1: Test if the specified registry key exists
# Test-RegistryKey -Path "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"

## Example 2: Test if the specified registry key has the specified value 
# Test-RegistryKey -Path "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" `
#   -Name "C:\Program Files\Notepad++\notepad++.exe.FriendlyAppName"

## Example 3: Test if the specified registry key value holds the specified value data
# Test-RegistryKey -Path "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" `
#   -Name "C:\Program Files\Notepad++\notepad++.exe.FriendlyAppName" `
#   -Data 'Parallel Launcher'