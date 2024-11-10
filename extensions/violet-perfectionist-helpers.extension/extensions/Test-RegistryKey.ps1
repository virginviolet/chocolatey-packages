function Test-RegistryKey {
  param (
    [Alias("KeyPath")]
    [Alias("Key")]
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "Path")]
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name")]
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "Data")]
    [string]
    $Path,
    
    [Alias("ValueName")]
    [parameter(Mandatory = $true, Position = 1, ParameterSetName = "Name")]
    [parameter(Mandatory = $true, Position = 1, ParameterSetName = "Data")]
    [string]$Name,
    
    [Alias("ValueData", "Data")]
    [parameter(Mandatory = $true, Position = 2, ParameterSetName = "Data")]
    $Value
  )

  if (-not $Path.StartsWith("REGISTRY::") -and `
  $Path -ne '' -and `
  $null -ne $Path) {
    # $pathFriendly = $Path
    $Path = $Path.Insert(0, "REGISTRY::")
  } else {
    $pathFriendly = $Path.Replace("REGISTRY::", "")
  }

  # Calls to these functions need to be placed inside a try-catch block,
  # Otherwise, they aren't really testing anything.

  function Test-Values($GetValuePath) {
    $values = $(Get-RegistryKey -Path $GetValuePath -ErrorAction Stop)
    if ($null -ne $values) {
      $valueCount = $values.Length
      if ($null -ne $valueCount) {
        # Write-Debug "$valueCount values found."
      } else {
        # Write-Debug "Value found."
      }
      return $true
    } else {
      return $false
    }
  }

  try {
    # Write-Debug "Validating registry key path '$pathFriendly'..."
    # Look for key(s)
    if (-Not $Name) {
      # If 'Path' ends with '*\',
      # then '$key' will hold child keys (think "directories"),
      # otherwise, '$key' will hold values (think "files")
      if (-not $Path.EndsWith('\*') -and -not $Path.EndsWith('/*')) {
        # Look for a single key
        # Write-Debug "Looking for key '$pathFriendly'..."
        $values = $(Get-RegistryKey -Path $Path -ErrorAction Stop)
        # Write-Debug "Key found."
        return $true
      } else {
        # Look for child keys
        # Get the parent key by removing the asterisk
        $parentKeyPath = $Path.Substring(0, $Path.Length - 1)
        # $parentKeyPathFriendly = $parentKeyPath.Replace("REGISTRY::", "")
        # Write-Debug "Looking for key '$parentKeyPathFriendly'..."
        # Look for child keys and values 
        $childKeys = $(Get-ChildItem -Path $Path -ErrorAction Stop)
        # Write-Debug "Key found."
        if ($null -ne $childKeys) {
          # Write-Debug "Child keys found."
          return $true
        } else {
          # Write-Debug "No child key(s) found."
          # Write-Debug "Looking for values in key '$parentKeyPathFriendly'..."
          $valuesExist = Test-Values -GetValuePath $parentKeyPath
          if ($valuesExist) {
            return $true
          } else {
            # Write-Debug "No values found."
            return $false
          }
        }
      }
    }

    # Look for value(s)
    if (-not $Value) {
      # Get-RegistryKey -Path $Path -ErrorAction Stop > $null
      if ($Name -ne '*' -and $Name -ne '*') {
        if ($Path.Contains('*')) {
          $message = "Test-RegistryKey does not support " + `
          "matching part of a value name. You can, however, " + `
          "search for all values in a key with '-Name *'"
          Write-Warning $message
        }
        # Look for a single value
        # Write-Debug "Testing if registry key '$pathFriendly' exists and if it has the value '$Name'..."
        $value = $(Get-RegistryKey -Path $Path -Name $Name -ErrorAction Stop)
        # Write-Debug "Key exists and value found."
        return $true
      } else {
        # Look for multiple values
        $valuesExist = Test-Values -GetValuePath $Path
        if ($valuesExist) {
          return $true
        } else {
          # Write-Debug "Value not found."
          return $false
        }
      }
    }

    # Look for value data
    if ($Value) {
      if ($Value.Contains('*')) {
        Write-Warning "Test-RegistryKey does not support matching part of the value data. "
      }
      # Write-Debug "Testing if the key '$pathFriendly' exists, if it has a value named '$Name', and if the value contains the data '$Value'..."
      $existingValueData = $(Get-RegistryKey -Path $Path -Name $Name -ErrorAction Stop)
      # Write-Debug "Key exists, and the value name and data matches the input."
      if ($existingValueData -eq $Value) {
        return $true
      } else {
        return $false
      }
    }

  } catch [System.Management.Automation.ItemNotFoundException] {
    <# $message = "Could not validate registry key path.`n" + `
      "The key '$Path' does not exist.`n$_"
    Write-Debug $message #>
    return $false
  } catch [System.Management.Automation.PSArgumentException] {
    <# $message = "Could not validate registry key path.`n" + 
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