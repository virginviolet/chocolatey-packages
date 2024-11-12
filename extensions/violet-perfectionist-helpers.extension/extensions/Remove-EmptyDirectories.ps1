#region Help
<#
.SYNOPSIS
Removes empty directories from a specified directory recursively or non-recursively.

.DESCRIPTION
Remove-EmptyDirectories searches for empty directories from a directory specified with the -Path
parameter. By default the search is limited to the first directory level (i.e. the search and
removal of the empty directories is done non-recursively), but if a -Recurse parameter is added to
the launching command, Remove-EmptyDirectories will remove empty directories from the subdirectories
as well (i.e. the search and removal is done recursively).

If deletions are made, a log-file (deleted_directories.txt by default) is created to $env:temp,
which points to the current temporary file location and is set in the system (- for more information
about $env:temp, please see the Notes section). The filename of the log-file can be set with the
-FileName parameter (a filename with a .txt ending is recommended) and the default output
destination directory may be changed with the -Output parameter. During the possibly invoked
log-file creation procedure Remove-EmptyDirectories tries to preserve any pre-existing content
rather than overwrite the specified file, so if the -FileName parameter points to an existing file,
new log-info data is appended to the end of that file.

To invoke a simulation run, where no directories would be deleted in any circumstances, a parameter
-WhatIf may be added to the launching command. If the -Audio parameter has been used, an audible
beep would be emitted after Remove-EmptyDirectories has deleted one or more directories. Please note
that if any of the parameter values (after the parameter name itself) includes space characters, the
value should be enclosed in quotation marks (single or double) so that PowerShell can interpret the
command correctly.

.PARAMETER Path
with aliases -Start, -Begin, -Directory, and -From. The -Path parameter determines the starting
point of the empty directory analyzation. The -Path parameter also accepts a collection of path
names (separated by a comma). It's not mandatory to write -Path in the remove empty directories
command to invoke the -Path parameter, as is shown in the Examples below, since
Remove-EmptyDirectories is trying to decipher the inputted queries as good as it is machinely
possible within a 40 KB size limit.

The paths should be valid file system paths to a directory (a full path of a directory (i.e.
directory path such as C:\Windows)). In case the path includes space characters, please enclose
the path in quotation marks (single or double). If a collection of paths is defined for
the -Path parameter, please separate the individual paths with a comma. The -Path parameter
also takes an array of strings for paths and objects could be piped to this parameter, too. If no
path is defined in the command launching Remove-EmptyDirectories the user will be prompted to enter
a -Path value. How deeply the filesystem structure is analysed (and how deeply buried empty
directories are deleted) is toggled with the -Recurse parameter.

.PARAMETER Output
with an alias -ReportPath. Specifies where the log-file (deleted_directories.txt by default, which
is created or updated when deletions are made) is to be saved. The default save location is
$env:temp, which points to the current temporary file location, which is set in the system. The
default -Output is $env:temp. includes space characters, please enclose the path in quotation
marks (single or double). For usage, please see the Examples below and for more information about
$env:temp, please see the Notes section below.

.PARAMETER FileName
with an alias -File. The filename of the log-file can be set with the -FileName parameter (a
filename with a .txt ending is recommended, the default filename is deleted_directories.txt). During
the possibly invoked log-file creation procedure Remove-EmptyDirectories tries to preserve any
pre-existing content rather than overwrite the specified file, so if the -FileName parameter points
to an existing file, new log-info data is appended to the end of that file. If the filename includes
space characters, please enclose the filename in quotation marks (single or double).

.PARAMETER Recurse
If the -Recurse parameter is added to the command launching Remove-EmptyDirectories, also each and
every sub-directory in any level, no matter how deep in the directory structure or behind how many
sub-directories, is searched for empty directories and all found empty directories regardless of the
sub-level are deleted. For best results against nested empty directories, it is recommended to run
Remove-EmptyDirectories iteratively with the -Recurse parameter until no empty directories are
found.

If the -Recurse parameter is not used, the search is limited to the first directory level (i.e. the
search is done non-recursively) and only empty directories from the first level (as indicated with
the -Path parameter with the common command "dir", for example) are deleted.

.PARAMETER WhatIf
The parameter -WhatIf toggles whether the deletion of directories is actually done or not. By adding
the -WhatIf parameter to the launching command only a simulation run is performed. When the -WhatIf
parameter is added to the command launching Remove-EmptyDirectories, a -WhatIf parameter is also
added to the underlying Remove-Item cmdlet that is deleting the directories in
Remove-EmptyDirectories. In such case and if indeed empty directory(s) was/were detected by
Remove-EmptyDirectories, a list of directory paths that would be deleted by Remove-EmptyDirectories
is displayed in console ("What if:"). Since no real deletions aren't made, the script will return an
"Exit Code 1" (A simulation run: the -WhatIf parameter was used).

.PARAMETER Audio
If this parameter is used in the remove empty directories command, an audible beep will occur, if
any deletions are made by Remove-EmptyDirectories.

.OUTPUTS
Deletes empty directories.  
Displays results about deleting empty directories in console, and if any deletions were made, writes
or updates a logfile (deleted_directories.txt) at $env:temp. The filename of the log-file can be set
with the -FileName parameter (a filename with a .txt ending is recommended) and the default output
destination directory may be changed with the -Output parameter.

    Default values (the log-file creation/updating procedure only occurs if deletion(s) is/are made
    by Remove-EmptyDirectories):

        $env:temp\deleted_directories.txt       : TXT-file     : deleted_directories.txt

.NOTES
Please note that all the parameters can be used in one remove empty directories command and that
each of the parameters can be "tab completed" before typing them fully (by pressing the [tab] key).

Please also note that the possibly generated log-file is created in a directory, which is end-user
settable in each remove empty directories command with the -Output parameter.

.EXAMPLE
./Remove-EmptyDirectories -Path "E:\chiore" -Output "C:\Scripts"  
Run the script. Please notice to insert ./ or .\ before the script name. Removes all empty
directories from the first level of E:\chiore (i.e. those empty directories, which would be listed
with the "dir E:\chiore" command, and if any deletions were made, saves the log-file to C:\Scripts
with the default filename (deleted_directories.txt). During the possibly invoked log-file creation
procedure Remove-EmptyDirectories tries to preserve any pre-existing content rather than overwrite
the file, so if the default log-file (deleted_directories.txt) already exists, new log-info data is
appended to the end of that file. Please note, that -Path can be omitted in this example, because

    ./Remove-EmptyDirectories "E:\chiore" -Output "C:\Scripts"

will result in the exact same outcome.

.EXAMPLE
help ./Remove-EmptyDirectories -Full
Display the help file.

.EXAMPLE
./Remove-EmptyDirectories -Path "C:\Users\Dropbox", "C:\dc01" -Recurse -WhatIf  
Because the -WhatIf parameter was used, only a simulation run occurs, so no directories would be
deleted in any circumstances. The script will look for empty directories from C:\Users\Dropbox and
C:\dc01 and will add all sub-directories of the sub-directories of the sub-directories and their
sub-directories as well from those directories to the list of directories to process (the search for
other directories to process is done recursively).

If empty directories aren't found, the result would be identical regardless whether the -WhatIf
parameter was used or not. If, however, empty directories were indeed found, only an indication of
what the script would delete ("What if:") is displayed.

The Path variable value is case-insensitive (as is most of the PowerShell), and since the paths
don't contain any space characters, they don't need to be enveloped with quotation marks. Actually
the -Path parameter may be left out from the command, too, since, for example,

    ./Remove-EmptyDirectories c:\users\dROPBOx, c:\DC01 -Recurse -WhatIf

is the exact same command in nature.

.EXAMPLE
.\Remove-EmptyDirectories.ps1 -From C:\dc01 -ReportPath C:\Scripts -File log.txt -Recurse -Audio  
Run the script and search recursively for empty directories from C:\dc01 and delete all recursively
found empty directories under C:\dc01. If any deletions were made, the log-file would be saved to
C:\Scripts with the filename log.txt and an audible beep would occur. This command will work,
because -From is an alias of -Path and -ReportPath is an alias of -Output and -File is an alias of
-FileName. Furthermore, since the paths don't contain any space characters, they don't need to
be enclosed in quotation marks.

.EXAMPLE
Set-ExecutionPolicy remotesigned  
This command is altering the Windows PowerShell rights to enable script execution for the default
(LocalMachine) scope. Windows PowerShell has to be run with elevated rights (run as an
administrator) to actually be able to change the script execution properties. The default value of
the default (LocalMachine) scope is "Set-ExecutionPolicy restricted".

    Parameters:

    Restricted      Does not load configuration files or run scripts. Restricted is the default
                    execution policy.

    AllSigned       Requires that all scripts and configuration files be signed by a trusted
                    publisher, including scripts that you write on the local computer.

    RemoteSigned    Requires that all scripts and configuration files downloaded from the Internet
                    be signed by a trusted publisher.

    Unrestricted    Loads all configuration files and runs all scripts. If you run an unsigned
                    script that was downloaded from the Internet, you are prompted for permission
                    before it runs.

    Bypass          Nothing is blocked and there are no warnings or prompts.

    Undefined       Removes the currently assigned execution policy from the current scope.
                    This parameter will not remove an execution policy that is set in a Group
                    Policy scope.

For more information, please type  
"Get-ExecutionPolicy -List",  
"help Set-ExecutionPolicy -Full",  
"help about_Execution_Policies"  
or visit https://technet.microsoft.com/en-us/library/hh849812.aspx  
or http://go.microsoft.com/fwlink/?LinkID=135170.

.EXAMPLE
New-Item -ItemType File -Path C:\Temp\Remove-EmptyDirectories.ps1  
Creates an empty ps1-file to the C:\Temp directory. The New-Item cmdlet has an inherent -NoClobber
mode built into it, so that the procedure will halt, if overwriting (replacing the contents) of an
existing file is about to happen. Overwriting a file with the New-Item cmdlet requires using the
Force. If the path includes space characters, please enclose the path in quotation marks
(single or double):

    New-Item -ItemType File -Path "C:\Directory Name\Remove-EmptyDirectories.ps1"

For more information, please type "help New-Item -Full".

.LINK
https://community.chocolatey.org/packages/violet-perfectionist-helpers.extension/
https://github.com/virginviolet/chocolatey-packages/tree/main/extensions/violet-perfectionist-helpers.extension/
https://gist.github.com/nedarb/840f9f0c9a2e6014d38f
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
https://web.archive.org/web/20170310083256/http://poshcode.org:80/2154
#>
#endregion

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
        [string]$Output = "$env:temp",
        [Alias("File")]
        [string]$FileName = "deleted_directories.txt",

        [switch]$Recurse,

        [switch]$WhatIf,
        
        [switch]$Audio
    )

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
            # temp-directory or the location is defined with the -Output parameter)
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

            # Sound the bell if set to do so with the -Audio parameter
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
