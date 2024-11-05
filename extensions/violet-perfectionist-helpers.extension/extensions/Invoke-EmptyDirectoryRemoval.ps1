function Invoke-EmptyDirectoryRemoval {
    <#
.SYNOPSIS
Removes empty directories recursively in the directory,
then removes the directory itself if it is empty.
Inform the user if files remain in the directory.

.NOTES
None

.INPUTS
None

.OUTPUTS
None

.PARAMETER Path
Specifies the directory to process.

.PARAMETER Name
Specifies what to the directory will be referred to in output messages.

.EXAMPLE
`Invoke-EmptyDirectoryRemoval "C:\Program Files (x86)\Example Program" "installation"`

.EXAMPLE
`Invoke-EmptyDirectoryRemoval "$Env:AppData\example_program" "application data"`

.LINK
Remove-EmptyDirectories

#>
    param(
        [parameter(Mandatory = $true, Position = 0)][string] $Path,
        [parameter(Mandatory = $false, Position = 1)][string] $Name
    )

    # Set string variables for the directory
    if ($Name.Length -ge 1) {
        # Name with leading upper case
        $nameUp = $Name.Substring(0, 1).ToUpper() + $Name.Substring(1)
        # New varibles with strings that end with "directory"
        $nameDirString = "$Name directory"
        $nameDirStringUp = "$nameUp directory"
    } else {
        $nameDirString = "directory"
        $nameDirStringUp = "Directory"
    }
    
    # See if directory exists
    $dirExists = Test-Path "$Path" -PathType Container
    if ($dirExists) {
        # Remove empty directories inside the installation directory
        Write-Debug "$nameDirStringUp found."
        Remove-EmptyDirectories "$Path" -Recurse
        # See if the installation directory is empty
        $installDirEmpty = -not (Test-Path "$Path\*")
        if (-not $installDirEmpty) {
            # Inform user if directory is not empty (edge case)
            $message = "Data remains in the $nameDirString. `n" + `
                "Manually remove the $nameDirString " + `
                "if you do not wish to keep the data.`n" + `
                "$nameDirStringUp" + ": '$Path'"
            Write-Warning $message
            Start-Sleep -Seconds 5 # Time to read
        } else {
            # Remove directory if it is empty
            Write-Debug "$nameDirStringUp is empty."
            Write-Verbose "Removing $nameDirString..."
            Remove-Item "$Path"
            Write-Debug "$nameDirStringUp removed."
        }
    } else {
        # Only write a debug message (edge case)
        Write-Debug "$nameDirStringUp not found."
    }
}
