function Get-ProcessId {
  <#
    .SYNOPSIS
    Retrieves the ID of each process that have a certain name and/or command line property value.

    .DESCRIPTION
    The Get-ProcessId function retrieves the IDs of processes by its command line property
    (the full command line string that was used to start the process) and/or name.  
    The function does not output anything to the console by itself.

    .PARAMETER Name
    Mandatory if CommandLine is not specified.
    Specifies an exact process name (including the file extension) to filter for.  

    .PARAMETER CommandLine
    Mandatory if Name is not specified.  
    Specifies the whole or part of a command line property value (the full command line string that
    was used to start the process) to filter for.  
    
    .EXAMPLE
    $autoHotkeyProcessId = Get-ProcessId -CommandLine 'C:\My Scripts\hideWindow.ahk'
    Retrieves the process IDs of all processes whose command line property value includes the string
    `C:\My Scripts\hideWindow.ahk`.

    .EXAMPLE
    $notepadProcessId = Get-ProcessId -Name 'notepad.exe'
    Retrieves the process IDs of all instances of Notepad.

    .EXAMPLE
    $notepadProcessId = Get-ProcessId -Name 'notepad.exe' -CommandLine 'C:\My Scripts\hideWindow.ahk'
    Retrieves the process IDs of all processes whose name is `notepad.exe` and whose command line
    property value includes the string `C:\My Scripts\hideWindow.ahk`.

    .NOTES
    - This function uses the Get-CimInstance cmdlet to query the Win32_Process class for process
      information.
    - No error will occur if no processes are found.
  #>

  param (
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name")]
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "NameAndCommandLine")]
    [string]
    $Name,

    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "CommandLine")]
    [parameter(Mandatory = $true, Position = 1, ParameterSetName = "NameAndCommandLine")]
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
    $commandLineEscaped = ConvertTo-EscapedString -String $CommandLine
  }

  if ($Name -and $CommandLine) {
    $processIds = Get-CimInstance Win32_Process |
      Where-Object { $_.Name -like $Name -and $_.CommandLine -match $commandLineEscaped } |
      ForEach-Object { Write-Output "$($_.ProcessId)" }

  } elseif ($CommandLine) {
    $processIds = Get-CimInstance Win32_Process |
      Where-Object { $_.CommandLine -match $commandLineEscaped } |
      ForEach-Object { Write-Output "$($_.ProcessId)" }

  } elseif ($Name) {
    $processIds = Get-CimInstance Win32_Process |
      Where-Object { $_.Name -like $Name } |
      ForEach-Object { Write-Output "$($_.ProcessId)" }
  }

  # Return an object containing one or many strings
  return $processIds
}
