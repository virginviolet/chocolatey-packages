function Get-ProcessId {
  <#
    .SYNOPSIS
    Retrieves the ID of each process that have a certain name or command line property value.

    .DESCRIPTION
    The Get-ProcessId function retrieves the IDs of processes by either its command line property
    (the full command line string that was used to start the process) or name.  
    The function does not output anything to the console by itself.

    .PARAMETER Name
    Mandatory if CommandLine is not specified.
    Specifies an exact process name (including the file extension) to filter for.  

    .PARAMETER CommandLine
    Mandatory if Name is not specified.  
    Specifies the whole or part of a command line property value (the full command line string that
    was used to start the process) to filter for.  

    .EXAMPLE
    $notepadProcessId = Get-ProcessId -Name 'notepad.exe'
    Retrieves the process IDs of all instances of Notepad.

    .EXAMPLE
    $autoHotkeyProcessId = Get-ProcessId -CommandLine 'C:\My Scripts\hideWindow.ahk'
  
    Retrieves the process IDs of all processes whose command line property value includes the string `C:\My Scripts\hideWindow.ahk`.

    .NOTES
    This function uses the Get-CimInstance cmdlet to query the Win32_Process class for process information.
  #>
  param (
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name")]
    [string]
    $Name,
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = "CommandLine")]
    [string]
    $CommandLine
  )
  if ($Name) {
    $processIds = Get-CimInstance Win32_Process | Where-Object {
      $_.Name -like $Name
    } | ForEach-Object {
      Write-Output "$($_.ProcessId)"
    }
  } elseif ($CommandLine) {
    # Escape characters for the path (by no means complete)
    $commandLineEscaped = $CommandLine -replace '\\', '\\' `
      -replace ':', '\:' -replace '\(', '\(' -replace '\)', '\)'
    $processIds = Get-CimInstance Win32_Process | Where-Object {
      $_.CommandLine -match $commandLineEscaped
    } | ForEach-Object {
      Write-Output "$($_.ProcessId)"
    }
  }
  # Return an object containing one or many strings
  return $processIds
}
