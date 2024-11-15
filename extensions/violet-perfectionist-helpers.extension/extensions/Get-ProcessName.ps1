# Sometimes, a process has an automatically generated name,
# but the name can sometimes be found by looking for
# the process's Commard Line property, which is what this function does.
function Get-ProcessName {
  param (
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name")]
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "NameAndId")]
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "NameAndCommandLine")]
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "NameIdAndCommandLine")]
    [string]
    $Name,

    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "Id")]
    [parameter(Mandatory = $true, Position = 1, ParameterSetName = "NameAndId")]
    [parameter(Mandatory = $true, Position = 1, ParameterSetName = "NameIdAndCommandLine")]
    [Int32]
    $Id,

    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "CommandLine")]
    [parameter(Mandatory = $true, Position = 1, ParameterSetName = "NameAndCommandLine")]
    [parameter(Mandatory = $true, Position = 2, ParameterSetName = "NameIdAndCommandLine")]
    [string]
    $CommandLine
  )

  function ConvertTo-EscapedString {
    <#
      .SYNOPSIS
      Converts a string to an escaped string.

      .PARAMETER String
      The string to be escaped.

      .NOTES
      This function currently escapes the following characters: backslash (`\`), colon (`:`), and
      parentheses (`(` and `)`).
    #>
    param (
      [ValidateNotNullOrEmpty()]
      [parameter(Mandatory = $true, Position = 0)]
      [string]
      $String
    )
    $escapedString = $String -replace '\\', '\\' `
      -replace ':', '\:' -replace '\(', '\(' -replace '\)', '\)'
    return $escapedString
  }

  if ($CommandLine) {
  }

  if ($Name) {
    $processNames = Get-CimInstance Win32_Process | Where-Object {
      $_.Name -like $Name
    } | ForEach-Object {
      Write-Output "$($_.Name)"
    }
    if ($null -ne $processNames) {
      $nameSucceeded = $true
    }

  } if ($Id -and -not $nameSucceeded) {
    $processNames = Get-CimInstance Win32_Process | Where-Object {
      $_.ProcessId -eq $Id
    } | ForEach-Object {
      Write-Output "$($_.Name)"
    }
    if ($null -ne $processNames) {
      $idSucceeded = $true
    }

  } if ($CommandLine -and -not $nameSucceeded -and -not $idSucceeded) {
    $commandLineEscaped = ConvertTo-EscapedString -String $CommandLine
    $processNames = Get-CimInstance Win32_Process | Where-Object {
      $_.CommandLine -match $commandLineEscaped
    } | ForEach-Object {
      Write-Output "$($_.Name)"
    }
  }
  # Return an object containing one or many strings
  return $processNames
}

## Example
# $processes = (Get-ProcessName -CommandLine "C:\Program Files (x86)\parallel-launcher\unins000.exe")
# if ($processes -is [string]) {
#   # If one process matched, '$processes' will be a string
#   $process = $processes
# } else {
#   # If multiple processes matched, use the last match
#   $process = $processes[-1]
# }
# Write-Host "Process name: '$process'"

# TODO Add a parameter to pick last match, first match, or a specific number.

$processes = (Get-ProcessName -CommandLine 'matid' -Name 'Notepad++.exe')
echo $processes