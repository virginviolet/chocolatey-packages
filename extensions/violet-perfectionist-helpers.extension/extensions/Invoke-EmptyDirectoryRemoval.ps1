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

#>
    param(
        [parameter(Mandatory = $true, Position = 0)][string[]] $Path,
        [parameter(Mandatory = $false, Position = 1)][string] $Name
    )

    # Set string variables for the directory
    if ($Name.Length -ge 1) {
        $Name = "directory"
    }
    # Name with leading upper case
    $nameUp = $Name.Substring(0, 1).ToUpper() + $Name.Substring(1).ToLower()
    # New varibles with strings that end with "directory"
    $nameDirString = "$Name directory"
    $nameDirStringUp = "$nameUp directory"

    # See if directory exists
    $dirExists = Test-Path "$Path" -PathType Container
    if ($dirExists) {
        # Remove empty directories inside the installation directory
        Write-Debug "$nameDirStringUp found."
        $scriptRootPath = Split-Path $MyInvocation.MyCommand.Definition
        $RemoveEmptyDirs = Join-Path $scriptRootPath -ChildPath 'Remove-EmptyDirectories'
        . $RemoveEmptyDirs "$Path" -Recurse
        # See if the installation directory is empty
        $installDirEmpty = -not (Test-Path "$Path\*")
        if (-not $installDirEmpty) {
            # Inform user if directory is not empty (edge case)
            $message = "Data remains in the $nameDirString directory. `n" + `
                "Manually remove the $nameDirString directory " + `
                "if you do not wish to keep the data.`n" + `
                "$nameDirStringUp directory: '$Path'"
            Write-Warning $message
            Start-Sleep -Seconds 5 # Time to read
        } else {
            # Remove directory if it is empty
            Write-Debug "$nameDirStringUp directory is empty."
            Write-Debug "Removing $nameDirString directory..."
            Remove-Item "$Path"
            Write-Debug "$nameDirStringUp directory removed."
        }
    } else {
        # Only write a debug message (edge case)
        Write-Debug "$nameDirStringUp directory not found."
    }
}
