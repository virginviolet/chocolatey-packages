<#
.SYNOPSIS
Removes empty directories from a specified directory recursively or non-recursively.

.DESCRIPTION
Remove-EmptyDirectories searches for empty directories from a directory specified with the Path
parameter.  

By default, the search is limited to the first directory level (i.e. the search and removal of the
empty directories is done non-recursively), but if the Recurse parameter is specified, then the search
Remove-EmptyDirectories will remove empty directories from subdirectories as well (i.e. the search
and removal is done recursively).

If directories are found and deleted, a log file is made. By default it is saved to the Temp
directory (`$Env:TEMP`) with the file name `deleted_directories.txt`. If the function has been run
before and it the file already exists, it will be appendend to, not replaced.

.PARAMETER Path
The Path parameter determines the starting point of the empty directory search.

A collection of paths (separated by a comma), or an array of paths in strings, may be used instead
of a single path. Objects piped to Remove-EmptyDirectories will be sent to the Path parameter.

Aliases: Start, Begin, Directory, From

.PARAMETER Output
The Output parameter specifies the directory where the log file is to be saved.  
The default value of Output is `$Env:TEMP`, which means that the log file will be saved to the Temp
directory.

A log file is only created (or appended to) if any empty directories are found.

Alias: ReportPath

.PARAMETER FileName

The FileName parameter specifies the file name of the log.  
It is recommended that it ends with `.txt`.

The default file name is `deleted_directories.txt`

If a file with the same name is found, it will appended to, rather than overwritten.

Alias: File

.PARAMETER Recurse
If the Recurse parameter is used, then each and every sub-directory, on all levels below the Path
directory, (no matter how deep in the directory structure or behind how many sub-directories), are
searched for empty directories, and all empty directories found (regardless of the sub-level) are
deleted.

In some cases, it might be necessary to run Remove-EmptyDirectories iteratively with the Recurse
parameter until no empty directories are found.

If the Recurse parameter is *not* used, the search is limited to the first directory level (the
directory specified with Path).  
For example, if the Path is `C:\My Files\`, and one of the directories in that folder (let's say
`C:\My Files\Scripts\`), has itself an empty folder (perhaps `C:\My Files\Scripts\Old\`), then the
Old directory will not be found, and the Script directory will be considered non-empty and will not
be deleted. But if the Recurse parameter *is* used, then the Scripts directory will be searched and
the Old directory will be found and deleted. You might then have to run Remove-EmptyDirectories
again to have the Scripts directory deleted.

.PARAMETER WhatIf
When the WhatIf parameter is provided, a WhatIf parameter is also added to the underlying
Remove-Item cmdlet, so only a simulation run will be performed. No directories will actually be
deleted in this case, even if it appears so from the debug messages.

.PARAMETER Audio
If the Audio parameter is specified, an audible beep will be made if any directories have been
deleted when the operation is complete.

.OUTPUTS
Deletes empty directories.  
Displays information about the process in the Debug and Verbose streams, and if any deletions are
made, a log file will be created or appended to.

.EXAMPLE
Remove-EmptyDirectories -Path 'C:\My Files\' -Output 'C:\My Logs\'

Removes all empty directories from the first level of `C:\My Files\` (i.e. the same directories that
would be listed with `Get-ChildItem 'C:\My Files\'`), and if any deletions are made, it logs to a
file in `C:\My Logs\` with the default file name (`deleted_directories.txt`).

.EXAMPLE
Get-Help Remove-EmptyDirectories -Full

Displays help for the Remove-EmptyDirectories function.

.EXAMPLE
Remove-EmptyDirectories -Path 'C:\Program Files\Notepad++\', "$Env:AppData\Notepad++\" -Recurse -WhatIf

Because the WhatIf parameter was used, only a simulation run is made. No directories will be deleted
in any circumstance.  
The script will look for empty directories in `C:\Program Files\Notepad++\` and
`C:\Users\<user name>\AppData\Roaming\Notepad++` and will add all sub-directories of the
sub-directories of the sub-directories and their sub-directories (and so on) to the list of
directories to process (the search for other directories to process is done recursively).  
If empty directories are found, and the `$debugPreference` varible is set to 'Continue', messages
will displayed in console as if the directories are being deleted.

.EXAMPLE
Remove-EmptyDirectories -Path 'D:\Downloads\' -Output 'D:\' -File 'log.txt' -Recurse -Audio

Search recursively, starting at `D:\Downloads\`, and delete all empty directories found. When the
operation is complete, and if any directories were found and deleted during the process, a log file
will be saved to `D:\` with the file name `log.txt`, and a beep sound is played.

.LINK
https://community.chocolatey.org/packages/violet-perfectionist-helpers.extension/
https://github.com/virginviolet/chocolatey-packages/tree/main/extensions/violet-perfectionist-helpers.extension/
https://gist.github.com/nedarb/840f9f0c9a2e6014d38f
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
https://web.archive.org/web/20170310083256/http://poshcode.org:80/2154
#>

function Remove-EmptyDirectories {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true,
            HelpMessage = "`n" + `
                "Which directory or path would you like to target? `n" + `
                "`n" + `
                "Please enter a valid file system path to a directory (a full path of a " + `
                "directory (a.k.a. a folder) i.e. directory path such as C:\Windows). `n" + `
                "`n" + `
                "Notes: `n" + `
                "`t- If the path includes space characters, please enclose the path in single " + `
                "or double quotation marks. `n" + `
                "`t- To stop entering new values, please press [Enter] at an empty input row " + `
                "(and the script will run). `n" + `
                "`t- To exit this script, please press [Ctrl] + C." + `
                "`n"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Start", "Begin", "Directory", "From")]
        [string[]]$Path,
        
        [ValidateNotNullOrEmpty()]
        [Alias("ReportPath")]
        [string]$Output = "$Env:temp",

        [Alias("File")]
        [string]$FileName = "deleted_directories.txt",

        [switch]$Recurse,

        [switch]$WhatIf,
        
        [switch]$Audio
    )

    # TODO Remove help message from the Param block.

    #region Begin
    Begin {
        # Establish some common variables.
        $ErrorActionPreference = "Stop"
        $computer = $env:COMPUTERNAME
        $separator = "---------------------"
        $emptyLine = ""
        $skippedPath = @()
        $directories = @()
        $emptyDirectories = @()
        $deletedDirectories = @()
        $skippedPathNames = @()
        $invalidPathCount = 0

        Write-Debug "Write-EmptyDirectories started."
        # $emptyLine | Out-String
        
        # Test if the specified Path exists
        $pathExists = Test-Path -Path "$Path"
        If (-not $pathExists) {
            # $emptyLine | Out-String
            $message = "Cannot find path '$Path' because it does not exist. `n" + `
                # "`n" `
                "Please verify that the path specified with the Path parameter was typed " + `
                "correctly and that it is a valid file system path that points to a directory. " + `
                "If the path includes spaces, please enclose the path in single or double " + `
                "quotation marks." + `
                # "`n" + `
                "Path specified: '$Output'."
            Write-Error $message
            throw
        } # Else (If -not $pathExists)
        $outputPathExists = Test-Path -Path "$Output"
        If ($outputPathExists) {
            # Resolve Output ("ReportPath") path
            $outputPathResolved = Resolve-Path -Path "$Output"
            $txtFile = "$outputPathResolved\$FileName"
        } Else {
            # $emptyLine | Out-String
            $message = "Cannot find path '$Output' because it does not exist. `n" + `
                # "`n" `
                "Please verify that the path specified with the Output (or ReportPath)" + `
                "parameter was typed correctly and that it is a valid file system path that " + `
                "points to a directory. If the path includes spaces, please enclose the path in " + `
                "single or double quotation marks." + `
                # "`n" + `
                "Output path specified: '$Output'."
            Write-Error $message
            throw
        } # Else (If $outputPathExists)

        # Add the user-defined path(s) to the list of directories to process
        
        If (-not $Path) {
            # Take the paths that are piped into the script
            $directories += @($input | ForEach-Object { $_.FullName })
            Write-Debug "Piped input detected."
        }
        Else {
            ForEach ($pathCandidate in $Path) {
                # Test if the path cadidate exists
                $pathCandidateExists = Test-Path "$pathCandidate"
                If ($pathCandidateExists) {
                    # Resolve path (if path is specified as relative)
                    $fullPath = (Resolve-Path "$pathCandidate").Path
                    $directories += $fullPath # Note: This causes Path to be counted in `$directoryCount`
                } Else {
                    $invalidPathWasFound = $true

                    # Increment the error counter
                    $invalidPathCount++

                    # Display an error message in console
                    # $emptyLine | Out-String
                    Write-Warning "Cannot find path '$pathCandidate' because it does not exist."
                    # $emptyLine | Out-String

                    $message = "Please verify that the path specified with the Path " + `
                        "parameter was typed correctly and that it is a valid file system path " + `
                        "that points to a directory. If the path includes spaces, please enclose " + `
                        "the path in single or double quotation marks."
                    Write-Verbose $message

                    # $emptyLine | Out-String
                    $skipText = "Skipping '$pathCandidate' from the directories to be processed."
                    Write-Verbose $skipText

                    # Add the invalid path as an object (with properties) to a collection of
                    # skipped paths
                    $skippedPath += $skippedPathObject = New-Object -TypeName PSCustomObject -Property @{
                        'Skipped Paths' = $pathCandidate
                        'Owner'         = ""
                        'Created on'    = ""
                        'Last Updated'  = ""
                        'Size'          = "-"
                        'Error'         = "The path was not found on $computer."
                        'raw_size'      = 0
                    } # New-Object

                    # Add the invalid path to a list of failed paths
                    $skippedPathNames += $pathCandidate

                    # Return to top of the program loop (ForEach $pathCandidate) and skip just this
                    # iteration of the loop.
                    Continue
                } # Else (If $pathCandidateExists)
            } # ForEach $pathCandidate
        } # Else (If -not $Path)
    } # begin
    #endregion

    #region Process
    Process {
        # Search for the empty directories according to the user-set recurse option
        # Note: For best results against nested empty directories, please run the script iteratively
        # until no empty directories are found.
        # Source: Mekac
        $uniqueDirectories = $directories | Select-Object -Unique
        $directoryCount = [int]($uniqueDirectories.Count)

        If ($uniqueDirectories.Count -ge 1) {
            # Source: nedarb
            foreach ($directory in $uniqueDirectories) {
                <# $currentItemName is the current item #>
            }

            $availableDirectories =
            (
                Get-ChildItem $uniqueDirectories -Recurse:$Recurse `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Where-Object { $_.PSIsContainer -eq $true } |
                    Select-Object FullName, `
                    @{
                        Label      = "AclDenied";
                        Expression = { (Get-Acl $_.FullName).AreAccessRulesProtected }
                    } |
                    Where-Object { $_.AclDenied -eq $false } |
                    Sort-Object FullName
            )

            $unavailableDirectories =
            (
                Get-ChildItem $uniqueDirectories -Recurse:$Recurse `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Where-Object { $true -eq $_.PSIsContainer } |
                    Select-Object FullName, `
                    @{
                        Label      = "AclDenied";
                        Expression = { (Get-Acl $_.FullName).AreAccessRulesProtected } 
                    } |
                    Where-Object { $null -eq $_.AclDenied } |
                    Sort-Object FullName
            )

            # Select the available directories for further processing
            If ($null -eq $availableDirectories) {
                $continue = $true
            } Else {
                ForEach ($directory in ($availableDirectories)) {
                    $directoryCount++
                    $directoryQuery = Get-ItemProperty $directory.FullName |
                        Where-Object { ($_.GetFiles().Count -eq 0) -and ($_.GetDirectories().Count -eq 0) } |
                        Select-Object FullName
                    If ($null -ne $directoryQuery ) {
                        $emptyDirectories += New-Object -TypeName PSCustomObject `
                            -Property @{
                            'FullName' = $directory.FullName
                        } # New-Object
                    } Else {
                        $continue = $true
                    } # Else (If $directoryQuery)
                } # ForEach $directory
            } # Else (If $availableDirectories)

            # Add the unavailable directories to the skipped paths list
            If ($null -eq $unavailableDirectories) {
                $continue = $true
            } Else {
                $invalidPathWasFound = $true
                ForEach ($item in ($unavailableDirectories)) {

                    # Increment the error counter
                    $invalidPathCount++

                    # Add the invalid path as an object (with properties) to a collection of skipped
                    # paths
                    $skippedPath += $skippedPathObject = New-Object -TypeName PSCustomObject -Property @{
                        'Skipped Paths' = $item.FullName
                        'Owner'         = ""
                        'Created on'    = ""
                        'Last Updated'  = ""
                        'Size'          = "-"
                        'Error'         = "The path could not be opened (access denied)."
                        'raw_size'      = 0
                    } # New-Object

                    # Add the invalid path to a list of failed paths
                    $skippedPathNames += $item
                } # ForEach $item
            } # Else (If $unavailableDirectories)
        } Else {
            $continue = $true
        } # Else (If $uniqueDirectories.Count)
    } # Process
    #endregion

    #region End
    End {
        # Do the background work for natural language
        If ($directoryCount -eq 1) {
            $directoryLabel = "directory"
        } Else {
            $directoryLabel = "directories" 
        }
        # $emptyLine | Out-String

        # Write the operational stats in console
        If ($skippedPathNames.Count -eq 0) {
            $enumerationSuccesful = $true
            If ($uniqueDirectories.Count -le 4) {
                $skippedReport = "$($directoryCount) $directoryLabel processed " + `
                    "at '$($uniqueDirectories -join ', ')'."
            } Else {
                $skippedReport = "$($directoryCount) $directoryLabel processed."
            } # Else (If $uniqueDirectories.Count)
            Write-Debug $skippedReport
            # $emptyLine | Out-String
        } Else {
            # Display the skipped paths and write the operational stats in console
            $enumerationSuccesful = $false
            $skippedPath.PSObject.TypeNames.Insert(0, "Skipped paths")
            $skippedPathSelection = $skippedPath |
                Select-Object 'Skipped Paths', 'Size', 'Error' |
                Sort-Object 'Skipped Paths'
            $skippedPathSelection | Format-Table -auto
            If ($invalidPathCount -gt 1) {
                If ($uniqueDirectories.Count -eq 0) {
                    $skippedReport = "$invalidPathCount paths skipped. No directories were processed."
                } ElseIf ($uniqueDirectories.Count -le 4) {
                    $skippedReport = "$($directoryCount) $directoryLabel processed " + `
                        "at $($uniqueDirectories -join ', '). There were $invalidPathCount skipped paths."
                } Else {
                    $skippedReport = "$($directoryCount) $directoryLabel processed. " + `
                        "There were $invalidPathCount skipped paths."
                } # Else (If $uniqueDirectories.Count)
            } Else {
                If ($uniqueDirectories.Count -eq 0) {
                    $skippedReport = "One path was skipped. No directories were processed."
                } ElseIf ($uniqueDirectories.Count -le 4) {
                    $skippedReport = "$($directoryCount) $directoryLabel processed " + `
                        "at $($uniqueDirectories -join ', '). One path was skipped."
                } Else {
                    $skippedReport = "$($directoryCount) $directoryLabel processed." + `
                        "One path was skipped."
                } # Else (If $uniqueDirectories.Count)
            } # Else (If $invalidPathCount)
            Write-Debug $skippedReport
            # $emptyLine | Out-String
        } # Else (If $skippedPathNames.Count)

        If ($emptyDirectories.Count -lt 1) {
            If ($directoryCount -ge 1) {
                $exitText = "No empty directories were found."
                Write-Verbose $exitText
                # $emptyLine | Out-String
            } Else {
                $continue = $true
            } # Else (If $directoryCount)
        } Else {
            # Create a list of the empty directories
            $UniqueEmptyDirectories = $emptyDirectories | Select-Object -ExpandProperty FullName -Unique
            If ($UniqueEmptyDirectories.Count -eq 1) {
                $directoryLabel = "directory"
            } Else {
                $directoryLabel = "directories"
            }
            ForEach ($directory in $UniqueEmptyDirectories) {
                # Create a list of the empty directories
                $deletedDirectories += $deletedDirectoryObject = New-Object -TypeName PSCustomObject -Property @{
                    'Empty directories' = $directory
                } # New-Object

                # Delete the empty directories
                Write-Verbose "Deleting empty directory '$directory'..."
                Remove-Item "$directory" -Force -WhatIf:$WhatIf
                Write-Debug "Empty directory '$directory' deleted."
            } # ForEach $directory
            
            # Test if the directories were removed
            If ((Test-Path $UniqueEmptyDirectories) -eq $true) {
                If ($WhatIf) {
                    # $emptyLine | Out-String
                    $emptyFoundReport = "$($UniqueEmptyDirectories.Count) empty $directoryLabel found." 
                    Write-Verbose $emptyFoundReport
                    # $emptyLine | Out-String
                    "Exit Code 1: A simulation run (the -WhatIf parameter was used), didn't touch any directories."
                    # Return $emptyLine
                } Else {
                    "Exit Code 2: Something went wrong with the deletion procedure."
                    # Return $emptyLine
                } # Else (If $WhatIf)
            } Else {
                $continue = $true
            } # Else (Test-Path $emptyDirectories)

            # Write the deleted directory paths to a text file (located at the current
            # temp-directory or the location is defined with the Output parameter)
            If ((Test-Path "$txtFile") -eq $false) {
                $deletedDirectories | Out-File "$txtFile" -Encoding UTF8 -Force
                Add-Content -Path "$txtFile" -Value "Date: $(Get-Date -Format g)"
            } Else {
                $preExistingContent = Get-Content $txtFile
                $deletedDirectoriesLines = $deletedDirectories | Select-Object -ExpandProperty 'Empty Directories'
                $newContent = $preExistingContent + `
                    $emptyLine + `
                    $separator + `
                    $emptyLine + `
                    $deletedDirectoriesLines + `
                    $emptyLine
                $newContent | Out-File "$txtFile" -Encoding UTF8 -Force
                Add-Content -Path "$txtFile" -Value "Date: $(Get-Date -Format g)"
            } # Else (If Test-Path txt_file)

            # Sound the bell if set to do so with the Audio parameter
            If ( -not $Audio ) {
                $continue = $true
            } Else {
                [console]::beep(2000, 830)
            } # Else (If -not $Audio)
        } # Else (If $emptyDirectories.Count)
        # $emptyLine | Out-String
        Write-Debug "Write-EmptyDirectories ended."
    } # End
    #endregion

#region Sources
<#
# Sources

auberginehill. “Remove-EmptyFolders.ps1.” GitHub, February 2, 2013. Accessed November 10, 2024.  
https://github.com/auberginehill/remove-empty-folders/tree/master.

Mekac. “Get Directory Where Access Is Denied.” Microsoft TechNet Forums, n.d.  
https://social.technet.microsoft.com/Forums/en-US/4d78bba6-084a-4a41-8d54-6dde2408535f/get-directory-where-access-is-denied?forum=winserverpowershell.

nedarb. “RemoveEmptyFolders.Ps1.” GitHub Gist, January 28, 2016.  
https://gist.github.com/nedarb/840f9f0c9a2e6014d38f.

#>
#endregion
}
