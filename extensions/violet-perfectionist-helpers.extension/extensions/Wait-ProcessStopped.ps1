# Wait-Process with error handling and output messages
function Wait-ProcessStopped {
    param (
        [parameter(Mandatory = $false, Position = 0)]
        [string]
        $Name,

        [Alias("Seconds")][parameter(Mandatory = $false, Position = 1)]
        [string]
        $Timeout
    )
    try {
        Write-Verbose "Wating for uninstaller to finish..."
        Wait-Process $Name -Timeout $Timeout
        Write-Debug "Uninstaller seems to have finished."
    } catch [System.Management.Automation.SessionStateUnauthorizedAccessException] {
        Write-Output "Waiting for process '$Name' timed out.`n$_"
    } catch [Microsoft.PowerShell.Commands.ProcessCommandException] {
        Write-Debug "Process '$Name' not found.`n$_"
    } catch {
        Write-Warning "Could not find process '$Name'.`n$_"
    }
}

## Example
# Wait-ProcessStopped "Notepad++" 3