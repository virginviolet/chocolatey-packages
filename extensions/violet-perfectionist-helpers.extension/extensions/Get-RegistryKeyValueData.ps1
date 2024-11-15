function Get-RegistryKeyValueData {
  #region Help

  <#
  .SYNOPSIS
  Retrieves the value data from a value in a registry key, or an array of all value data in a registry key.

  .DESCRIPTION
  The Get-RegistryKeyValueData function retrieves the data of a specified value from a key in the
  Windows Registry. If no value name is provided, it retrieves all values from the specified
  registry key.

  .PARAMETER Path
  MANDATORY - The path of the registry key from which to retrieve the value data.

  .PARAMETER Name
  OPTIONAL - The name of the value within the registry key to retrieve.  
  If not specified, all values within the registry key will be retrieved.

  .EXAMPLE
  PS> $notepadPlusPlusValueData = Get-RegistryKeyValueData -Path "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" -Name "C:\Program Files\Notepad++\notepad++.exe.FriendlyAppName"
  PS> Write-Output "The friendly name for 'notepad++.exe' is '$notepadPlusPlusValueData'."

  Retrieve the value data from a specific registry key value
  
  .EXAMPLE
  $data = Get-RegistryKeyValueData -Path "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" | ForEach-Object { Write-Host "$_" }

  Retrieve all data from a registry key.

  .NOTES
  If the specified registry key or value does not exist, an error message will be displayed.
  #>

  #endregion
  
  #region Parameters
  param (
    [Alias("KeyPath")]
    [Alias("Key")]
    [ValidateNotNullOrEmpty()]
    [parameter(Mandatory = $true, Position = 0)]
    [string]
    $Path,
    
    [Alias("ValueName")]
    [ValidateNotNullOrEmpty()]
    [parameter(Mandatory = $false, Position = 1)]
    [string]
    $Name
  )
  #endregion

  #region Sub-function
  function Get-ValueData {
    <#
      .SYNOPSIS
      Retrieves the data of a value from a registry key.

      .DESCRIPTION
      The Get-ValueData function retrieves the data of a specified value from a key in the registry.
    #>
    param (
      # Key path
      [parameter(Mandatory = $true, Position = 0)]
      [string]
      $KeyPath,
      
      # Value in key
      [parameter(Mandatory = $true, Position = 1)]
      [string]
      $ValueName,
      
      [parameter(Mandatory = $true, Position = 2)]
      [string]
      $KeyPathFriendly
    )
    try {
      # Write-Debug "Retrieving the value '$ValueName' from the key '$KeyPathFriendly'..."
      $value = Get-ItemProperty -Path $KeyPath -Name $ValueName -ErrorAction Stop
      # Write-Debug "Value found."
      # Write-Debug "Retrieving the value data..."
      $valueData = $value.$ValueName
      # Write-Debug "Value data '$valueData' found."
      return $valueData
    } catch [System.Management.Automation.ItemNotFoundException] {
      $message = "Could not retrieve registry key value data.`n" + `
        "The key '$KeyPathFriendly' does not exist.`n$_"
      Write-Error $message
    } catch [System.Management.Automation.PSArgumentException] {
      Write-Warning "Value not found."
      $message = "Could not retrieve registry key value data. `n" + 
      "The key '$KeyPathFriendly' does not have the value '$ValueName'.`n$_"
      Write-Error $message
    } catch {
      Write-Error "Could not retrieve registry key value data.`n$_"
    }
  }
  #endregion


  try {
    #region Preparations
    # Write-Debug "Get-RegistryKeyValueData started."
    # $hasFinishedMessage = "Get-RegistryKeyValueData has finished."

    Write-Debug "Validating the registry key path '$Path'."
    if (-not $Path.StartsWith("REGISTRY::")) {
      $Path = $Path.Insert(0,"REGISTRY::")
    }
    $pathResolved = (Resolve-Path -Path $Path -ErrorAction Stop).Path
    Write-Debug "Path validated"

    # Set pretty path for output messages.
    $pathFriendly = $Path.Replace("REGISTRY::", "")
    $pathFriendly = $pathFriendly.Replace("HKEY_LOCAL_MACHINE", "HKLM")
    $pathFriendly = $pathFriendly.Replace("HKEY_CURRENT_USER", "HKCU")
    $pathFriendly = $pathFriendly.Replace("HKEY_CLASSES_ROOT", "HKCR")
    $pathFriendly = $pathFriendly.Replace("HKEY_USERS", "HKU")
    $pathFriendly = $pathFriendly.Replace("HKEY_CURRENT_CONFIG", "HKCC")
    Write-Debug "Key '$pathFriendly' found."
    #endregion

    #region Main
    if ($Name) {
      $valueData = Get-ValueData -KeyPath $pathResolved -ValueName $Name -KeyPathFriendly $pathFriendly
      # Write-Debug $hasFinishedMessage
      return $valueData
    } else {
      Write-Debug "Retrieving all data from the registry key '$pathFriendly'..."
      $keyValuesObject = Get-ItemProperty -Path $pathResolved -ErrorAction Stop
      $keyData = @()
      $valueNamesCollection = $keyValuesObject.PSObject.Members
      # $keyValuesObject.PSObject.Members | ForEach-Object { $valueName = $_.Name; Write-Output "value $valueName"; Pause; $valueData = Get-ValueData -Path $pathResolved -Name $value; $keyData += $valueData; Pause; }
      $badNames = @("PSPath", "PSParentPath", "PSChildName", "PSProvider")
      foreach ($member in $valueNamesCollection) {
        $memberType = $member.MemberType
        if ($memberType -eq "NoteProperty") {
          $valueName = $member.Name
          if (-not ($badNames -contains $valueName)) {
            # Write-Debug "VALUE NAME: '$valueName'`n"
            $valueData = Get-ValueData -KeyPath $pathResolved -ValueName $valueName -KeyPathFriendly $pathFriendly
            $keyData += $valueData
          }
        }
      }
      Write-Debug "Registry key values retrieved."
      # Write-Debug $hasFinishedMessage
      return $keyData
    }
    #endregion

    #region Error Handling
  } catch [System.Management.Automation.ItemNotFoundException] {
    $message = "Could not retrieve registry key value.`n" + `
    "The key '$pathFriendly' does not exist.`n$_"
    Write-Error $message
    Write-Debug $hasFinishedMessage
  } catch {
    Write-Error "Could not retrieve registry key value.`n$_"
    # Write-Debug $hasFinishedMessage
  }
  #endregion
}

#region Aliases
New-Alias -Name Get-RegKeyValueData -Value Get-RegistryKeyValueData -Scope Global
New-Alias -Name Get-RegistryKeyData -Value Get-RegistryKeyValueData -Scope Global
New-Alias -Name Get-RegKeyData -Value Get-RegistryKeyValueData -Scope Global
New-Alias -Name Get-RegistryKeyValueDatum -Value Get-RegistryKeyValueData -Scope Global
New-Alias -Name Get-RegKeyValueDatum -Value Get-RegistryKeyValueData -Scope Global
New-Alias -Name Get-RegistryKeyDatum -Value Get-RegistryKeyValueData -Scope Global
New-Alias -Name Get-RegKeyDatum -Value Get-RegistryKeyValueData -Scope Global
#endregion
