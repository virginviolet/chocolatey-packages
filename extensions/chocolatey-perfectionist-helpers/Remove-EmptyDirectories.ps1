<#
Remove-EmptyDirectories.ps1
#>


[CmdletBinding()]
Param (
    [Parameter(ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    Mandatory=$true,
      HelpMessage="`r`nWhich directory, directory or path would you like to target? `r`n`r`nPlease enter a valid file system path to a directory (a full path name of a directory (a.k.a. a directory) i.e. directory path such as C:\Windows). `r`n`r`nNotes:`r`n`t- If the path name includes space characters, please enclose the path name in quotation marks (single or double). `r`n`t- To stop entering new values, please press [Enter] at an empty input row (and the script will run). `r`n`t- To exit this script, please press [Ctrl] + C`r`n")]
    [ValidateNotNullOrEmpty()]
    [Alias("Start","Begin","Directory","From")]
    [string[]]$Path,
    [Alias("ReportPath")]
    [string]$Output = "$env:temp",
    [ValidateScript({
        # Credit: Mike F Robbins: "PowerShell Advanced Functions: Can we build them better?" http://mikefrobbins.com/2015/03/31/powershell-advanced-functions-can-we-build-them-better-with-parameter-validation-yes-we-can/
        If ($_ -match '^(?!^(PRN|AUX|CLOCK\$|NUL|CON|COM\d|LPT\d|\..*)(\..+)?$)[^\x00-\x1f\\?*:\"";|/]+$') {
                $True
        } Else {
                Throw "$_ is either not a valid filename or it is not recommended. If the filename includes space characters, please enclose the filename in quotation marks."
        }
    })]
    [Alias("File")]
    [string]$FileName = "deleted_directories.txt",
    [switch]$Recurse,
    [switch]$WhatIf,
    [switch]$Audio
)




Begin {


    # Establish some common variables.
    $ErrorActionPreference = "Stop"
    $computer = $env:COMPUTERNAME
    $separator = "---------------------"
    $empty_line = ""
    $skipped = @()
    $directories = @()
    $empty_directories = @()
    $deleted_directories = @()
    $skipped_path_names = @()
    $num_invalid_paths = 0


    # Test if the Output-path ("ReportPath") exists
    If ((Test-Path "$Output") -eq $false) {
        $invalid_output_path_was_found = $true

        # Display an error message in console
        $empty_line | Out-String
        Write-Warning "'$Output' doesn't seem to be a valid path name."
        $empty_line | Out-String
        Write-Debug "Please consider checking that the Output ('ReportPath') location '$Output', where the resulting TXT-file is ought to be written, was typed correctly and that it is a valid file system path, which points to a directory. If the path name includes space characters, please enclose the path name in quotation marks (single or double)." -verbose
        $empty_line | Out-String
        $skip_text = "Couldn't find -Output directory '$Output'..."
        Write-Warning $skip_text
        $empty_line | Out-String
        Exit
        Return

    } Else {
        # Resolve the Output-path ("ReportPath") (if the Output-path is specified as relative)
        $real_output_path = Resolve-Path -Path "$Output"
        $txt_file = "$real_output_path\$FileName"
    } # Else (If)


    # Add the user-defined path name(s) to the list of directories to process
    # Source: http://poshcode.org/2154
    # Credit: Lee Holmes: "Windows PowerShell Cookbook (O'Reilly)" (Get-FileHash script) http://www.leeholmes.com/guide
    If ($Path) {

        ForEach ($path_candidate in $Path) {

            # Test if the path exists
            If ((Test-Path "$path_candidate") -eq $false) {
                $invalid_path_was_found = $true

                # Increment the error counter
                $num_invalid_paths++

                # Display an error message in console
                $empty_line | Out-String
                Write-Warning "'$path_candidate' doesn't seem to be a valid path name."
                $empty_line | Out-String
                Write-Verbose "Please consider checking that the '-Path' variable value of '$path_candidate' was typed correctly and that it is a valid file system path, which points to a directory. If the path name includes space characters, please enclose the path name in quotation marks (single or double)." -verbose
                $empty_line | Out-String
                $skip_text = "Skipping '$path_candidate' from the directories to be processed."
                Write-Output $skip_text

                    # Add the invalid path as an object (with properties) to a collection of skipped paths
                    $skipped += $obj_skipped = New-Object -TypeName PSCustomObject -Property @{

                                'Skipped Paths'         = $path_candidate
                                'Owner'                 = ""
                                'Created on'            = ""
                                'Last Updated'          = ""
                                'Size'                  = "-"
                                'Error'                 = "The path was not found on $computer."
                                'raw_size'              = 0

                        } # New-Object

                # Add the invalid path name to a list of failed path names
                $skipped_path_names += $path_candidate

                # Return to top of the program loop (ForEach $path_candidate) and skip just this iteration of the loop.
                Continue

            } Else {

                # Resolve path (if path is specified as relative)
                $full_path = (Resolve-Path "$path_candidate").Path
                $directories += $full_path

            } # Else (If Test-Path $path_candidate)
        } # ForEach $path_candidate
    } Else {
        # Take the path names that are piped into the script
        $directories += @($input | ForEach-Object { $_.FullName })
    } # Else (If $Path)

} # begin




Process {


    # Search for the empty directories according to the user-set recurse option
    # Note: For best results against nested empty directories, please run the script iteratively until no empty directories are found.
    # Credit: Mekac: "Get directory where Access is denied" https://social.technet.microsoft.com/Forums/en-US/4d78bba6-084a-4a41-8d54-6dde2408535f/get-directory-where-access-is-denied?forum=winserverpowershell
    $unique_directories = $directories | select -Unique
    $total_number_of_directories = [int]($unique_directories.Count)

    If ($unique_directories.Count -ge 1) {

            $available_directories = Get-ChildItem $unique_directories -Recurse:$Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $true } | Select-Object FullName, @{ Label="AclDenied"; Expression={ (Get-Acl $_.FullName).AreAccessRulesProtected }} | Where-Object { $_.AclDenied -eq $false } | Sort FullName

            $unavailable_directories = Get-ChildItem $unique_directories -Recurse:$Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $true } | Select-Object FullName, @{ Label="AclDenied"; Expression={ (Get-Acl $_.FullName).AreAccessRulesProtected }} | Where-Object { $_.AclDenied -eq $null } | Sort FullName

            # Select the available directories for further processing
            If ($available_directories -eq $null) {
                $continue = $true
            } Else {

                ForEach ($directory in ($available_directories)) {

                        $total_number_of_directories++
                        $the_query_of_empty_directories = Get-ItemProperty $directory.FullName | Where-Object { ($_.GetFiles().Count -eq 0) -and ($_.GetDirectories().Count -eq 0) } | Select-Object FullName

                                If ($the_query_of_empty_directories -ne $null) {
                                        $empty_directories += New-Object -TypeName PSCustomObject -Property @{
                                                    'FullName'              = $directory.FullName
                                            } # New-Object
                                } Else {
                                        $continue = $true
                                } # Else (If $the_query_of_empty_directories)

                } # ForEach $directory

            } # Else (If $available_directories)


                                # Add the unavailable directories to the skipped path names list
                                If ($unavailable_directories -eq $null) {
                                    $continue = $true
                                } Else {
                                    $invalid_path_was_found = $true
                                    ForEach ($item in ($unavailable_directories)) {

                                        # Increment the error counter
                                        $num_invalid_paths++

                                        # Add the invalid path as an object (with properties) to a collection of skipped paths
                                        $skipped += $obj_skipped = New-Object -TypeName PSCustomObject -Property @{

                                                    'Skipped Paths'         = $item.FullName
                                                    'Owner'                 = ""
                                                    'Created on'            = ""
                                                    'Last Updated'          = ""
                                                    'Size'                  = "-"
                                                    'Error'                 = "The path could not be opened (access denied)."
                                                    'raw_size'              = 0

                                            } # New-Object

                                        # Add the invalid path name to a list of failed path names
                                        $skipped_path_names += $item
                                    } # ForEach $item
                                } # Else (If $unavailable_directories)
    } Else {
        $continue = $true
    } # Else (If $unique_directories.Count)

} # Process




End {

                # Do the background work for natural language
                If ($total_number_of_directories -gt 1) { $item_text = "directories" } Else { $item_text = "directory" }
                $empty_line | Out-String

                    # Write the operational stats in console
                    If ($skipped_path_names.Count -eq 0) {
                        $enumeration_went_succesfully = $true
                                If ($unique_directories.Count -le 4) {
                                    $stats_text = "Total $($total_number_of_directories) $item_text processed at $($unique_directories -join ', ')."
                                } Else {
                                    $stats_text = "Total $($total_number_of_directories) $item_text processed."
                                } # Else (If $unique_directories.Count)
                        Write-Verbose $stats_text
                        $empty_line | Out-String
                    } Else {

                        # Display the skipped path names and write the operational stats in console
                        $enumeration_went_succesfully = $false
                        $skipped.PSObject.TypeNames.Insert(0,"Skipped Path Names")
                        $skipped_selection = $skipped | Select-Object 'Skipped Paths','Size','Error' | Sort-Object 'Skipped Paths'
                        $skipped_selection | Format-Table -auto
                                If ($num_invalid_paths -gt 1) {
                                    If ($unique_directories.Count -eq 0) {
                                        $stats_text = "There were $num_invalid_paths skipped paths. Didn't process any directories."
                                    } ElseIf ($unique_directories.Count -le 4) {
                                        $stats_text = "Total $($total_number_of_directories) $item_text processed at $($unique_directories -join ', '). There were $num_invalid_paths skipped paths."
                                    } Else {
                                        $stats_text = "Total $($total_number_of_directories) $item_text processed. There were $num_invalid_paths skipped paths."
                                    } # Else (If $unique_directories.Count)
                                } Else {
                                    If ($unique_directories.Count -eq 0) {
                                        $stats_text = "One path name was skipped. Didn't process any directories."
                                    } ElseIf ($unique_directories.Count -le 4) {
                                        $stats_text = "Total $($total_number_of_directories) $item_text processed at $($unique_directories -join ', '). One path name was skipped."
                                    } Else {
                                        $stats_text = "Total $($total_number_of_directories) $item_text processed. One path name was skipped."
                                    } # Else (If $unique_directories.Count)
                                } # Else (If $num_invalid_paths)
                        Write-Verbose $stats_text
                        $empty_line | Out-String
                    } # Else (If $skipped_path_names.Count)


    If ($empty_directories.Count -ge 1) {

                $unique_empty_directories = $empty_directories | select -ExpandProperty FullName -Unique
                If ($unique_empty_directories.Count -gt 1) { $directory_text = "directories" } Else { $directory_text = "directory" }
                ForEach ($directory in $unique_empty_directories) {

                                        # Create a list of the empty directories
                                        $deleted_directories += $obj_deleted = New-Object -TypeName PSCustomObject -Property @{
                                                        'Deleted Empty Directories'     = $directory
                                        } # New-Object

                        # Delete the empty directories
                        Remove-Item "$directory" -Force -WhatIf:$WhatIf

                } # ForEach $directory

                                        # Test if the directories were removed
                                        If ((Test-Path $unique_empty_directories) -eq $true) {
                                                        If ($WhatIf) {
                                                            $empty_line | Out-String
                                                            $notify_text = "Found $($unique_empty_directories.Count) empty $directory_text." 
                                                            Write-Verbose $notify_text
                                                            $empty_line | Out-String
                                                            "Exit Code 1: A simulation run (the -WhatIf parameter was used), didn't touch any directories."
                                                            Return $empty_line
                                                        } Else {
                                                            "Exit Code 2: Something went wrong with the deletion procedure."
                                                            Return $empty_line
                                                        } # Else (If $WhatIf)
                                        } Else {
                                            $continue = $true
                                        } # Else (Test-Path $empty_directories)

                # Write the deleted directory paths in console
                $notify_text = "Deleted $($unique_empty_directories.Count) empty $directory_text."     
                $deleted_directories.PSObject.TypeNames.Insert(0,"Deleted Empty Directories")
                Write-Verbose $deleted_directories
                $empty_line | Out-String
                Write-Verbose $notify_text


                        # Write the deleted directory paths to a text file (located at the current temp-directory or the location is defined with the -Output parameter)
                        If ((Test-Path "$txt_file") -eq $false) {
                                $deleted_directories | Out-File "$txt_file" -Encoding UTF8 -Force
                                Add-Content -Path "$txt_file" -Value "Date: $(Get-Date -Format g)"
                        } Else {
                                $pre_existing_content = Get-Content $txt_file
                                ($pre_existing_content + $empty_line + $separator + $empty_line + ($deleted_directories | Select-Object -ExpandProperty 'Deleted Empty Directories') + $empty_line) | Out-File "$txt_file" -Encoding UTF8 -Force
                                Add-Content -Path "$txt_file" -Value "Date: $(Get-Date -Format g)"
                        } # Else (If Test-Path txt_file)

                                                        # Sound the bell if set to do so with the -Audio parameter
                                                        # Source: https://blogs.technet.microsoft.com/heyscriptingguy/2013/09/21/powertip-use-powershell-to-send-beep-to-console/
                                                        If ( -not $Audio ) {
                                                                $continue = $true
                                                        } Else {
                                                                [console]::beep(2000,830)
                                                        } # Else (If -not $Audio)

    } Else {
        If ($total_number_of_directories -ge 1) {
            $exit_text = "Didn't find any empty directories."
            Write-Verbose $exit_text
            $empty_line | Out-String
        } Else {
            $continue = $true
        } # Else (If $total_number_of_directories)
    } # Else (If $empty_directories.Count)
} # End




# [End of Line]


<#


   _____
  / ____|
 | (___   ___  _   _ _ __ ___ ___
  \___ \ / _ \| | | | '__/ __/ _ \
  ____) | (_) | |_| | | | (_|  __/
 |_____/ \___/ \__,_|_|  \___\___|


https://social.technet.microsoft.com/Forums/en-US/4d78bba6-084a-4a41-8d54-6dde2408535f/get-directory-where-access-is-denied?forum=winserverpowershell      # Mekac: "Get directory where Access is denied"
http://mikefrobbins.com/2015/03/31/powershell-advanced-functions-can-we-build-them-better-with-parameter-validation-yes-we-can/                         # Mike F Robbins: "PowerShell Advanced Functions: Can we build them better?"
http://www.leeholmes.com/guide                                                                                                                          # Lee Holmes: "Windows PowerShell Cookbook (O'Reilly)" (Get-FileHash script)


  _    _      _
 | |  | |    | |
 | |__| | ___| |_ __
 |  __  |/ _ \ | '_ \
 | |  | |  __/ | |_) |
 |_|  |_|\___|_| .__/
               | |
               |_|
#>

<#

.SYNOPSIS
Removes empty directories from a specified directory recursively or non-recursively.

.DESCRIPTION
Remove-EmptyDirectories searches for empty directories from a directory specified with the
-Path parameter. By default the search is limited to the first directory level
(i.e. the search and removal of the empty directories is done non-recursively), but
if a -Recurse parameter is added to the launching command, Remove-EmptyDirectories
will remove empty directories from the subdirectories as well (i.e. the search and
removal is done recursively).

If deletions are made, a log-file (deleted_directories.txt by default) is created to
$env:temp, which points to the current temporary file location and is set in the
system (- for more information about $env:temp, please see the Notes section). The
filename of the log-file can be set with the -FileName parameter (a filename with a
.txt ending is recommended) and the default output destination directory may be changed
with the -Output parameter. During the possibly invoked log-file creation procedure
Remove-EmptyDirectories tries to preserve any pre-existing content rather than overwrite
the specified file, so if the -FileName parameter points to an existing file, new
log-info data is appended to the end of that file.

To invoke a simulation run, where no directories would be deleted in any circumstances,
a parameter -WhatIf may be added to the launching command. If the -Audio parameter
has been used, an audible beep would be emitted after Remove-EmptyDirectories has
deleted one or more directories. Please note that if any of the parameter values (after
the parameter name itself) includes space characters, the value should be enclosed
in quotation marks (single or double) so that PowerShell can interpret the command
correctly.

.PARAMETER Path
with aliases -Start, -Begin, -Directory, and -From. The -Path parameter determines the
starting point of the empty directory analyzation. The -Path parameter also accepts a
collection of path names (separated by a comma). It's not mandatory to write -Path
in the remove empty directories command to invoke the -Path parameter, as is shown in
the Examples below, since Remove-EmptyDirectories is trying to decipher the inputted
queries as good as it is machinely possible within a 40 KB size limit.

The paths should be valid file system paths to a directory (a full path name of a
directory (i.e. directory path such as C:\Windows)). In case the path name includes
space characters, please enclose the path name in quotation marks (single or double).
If a collection of path names is defined for the -Path parameter, please separate
the individual path names with a comma. The -Path parameter also takes an array of
strings for paths and objects could be piped to this parameter, too. If no path is
defined in the command launching Remove-EmptyDirectories the user will be prompted to
enter a -Path value. How deeply the filesystem structure is analysed (and how
deeply buried empty directories are deleted) is toggled with the -Recurse parameter.

.PARAMETER Output
with an alias -ReportPath. Specifies where the log-file
(deleted_directories.txt by default, which is created or updated when deletions are
made) is to be saved. The default save location is $env:temp, which points to the
current temporary file location, which is set in the system. The default -Output
save location is defined at line 14 with the $Output variable. In case the path name
includes space characters, please enclose the path name in quotation marks (single
or double). For usage, please see the Examples below and for more information about
$env:temp, please see the Notes section below.

.PARAMETER FileName
with an alias -File. The filename of the log-file can be set with the -FileName
parameter (a filename with a .txt ending is recommended, the default filename is
deleted_directories.txt). During the possibly invoked log-file creation procedure
Remove-EmptyDirectories tries to preserve any pre-existing content rather than overwrite
the specified file, so if the -FileName parameter points to an existing file, new
log-info data is appended to the end of that file. If the filename includes space
characters, please enclose the filename in quotation marks (single or double).

.PARAMETER Recurse
If the -Recurse parameter is added to the command launching Remove-EmptyDirectories,
also each and every sub-directory in any level, no matter how deep in the directory
structure or behind how many sub-directories, is searched for empty directories and all
found empty directories regardless of the sub-level are deleted. For best results
against nested empty directories, it is recommended to run Remove-EmptyDirectories
iteratively with the -Recurse parameter until no empty directories are found.

If the -Recurse parameter is not used, the search is limited to the first directory
level (i.e. the search is done non-recursively) and only empty directories from the
first level (as indicated with the -Path parameter with the common command "dir",
for example) are deleted.

.PARAMETER WhatIf
The parameter -WhatIf toggles whether the deletion of directories is actually done or
not. By adding the -WhatIf parameter to the launching command only a simulation run
is performed. When the -WhatIf parameter is added to the command launching
Remove-EmptyDirectories, a -WhatIf parameter is also added to the underlying
Remove-Item cmdlet that is deleting the directories in Remove-EmptyDirectories. In such
case and if indeed empty directory(s) was/were detected by Remove-EmptyDirectories, a list
of directory paths that would be deleted by Remove-EmptyDirectories is displayed in
console ("What if:"). Since no real deletions aren't made, the script will return an
"Exit Code 1" (A simulation run: the -WhatIf parameter was used).

.PARAMETER Audio
If this parameter is used in the remove empty directories command, an audible beep
will occur, if any deletions are made by Remove-EmptyDirectories.

.OUTPUTS
Deletes empty directories.
Displays results about deleting empty directories in console, and if any deletions were
made, writes or updates a logfile (deleted_directories.txt) at $env:temp. The filename
of the log-file can be set with the -FileName parameter (a filename with a .txt
ending is recommended) and the default output destination directory may be changed with
the -Output parameter.


    Default values (the log-file creation/updating procedure only occurs if
    deletion(s) is/are made by Remove-EmptyDirectories):


        $env:temp\deleted_directories.txt       : TXT-file     : deleted_directories.txt


.NOTES
Please note that all the parameters can be used in one remove empty directories command
and that each of the parameters can be "tab completed" before typing them fully (by
pressing the [tab] key).

Please also note that the possibly generated log-file is created in a directory,
which is end-user settable in each remove empty directories command with the -Output
parameter. The default save location is defined with the $Output variable (at
line 14). The $env:temp variable points to the current temp directory. The default
value of the $env:temp variable is C:\Users\<username>\AppData\Local\Temp
(i.e. each user account has their own separate temp directory at path
%USERPROFILE%\AppData\Local\Temp). To see the current temp path, for instance
a command

    [System.IO.Path]::GetTempPath()

may be used at the PowerShell prompt window [PS>]. To change the temp directory for
instance to C:\Temp, please, for example, follow the instructions at
http://www.eightforums.com/tutorials/23500-temporary-files-directory-change-location-windows.html

    Homepage:           https://github.com/auberginehill/remove-empty-directories
    Short URL:          http://tinyurl.com/zbug5ep
    Version:            1.1

.EXAMPLE
./Remove-EmptyDirectories -Path "E:\chiore" -Output "C:\Scripts"
Run the script. Please notice to insert ./ or .\ before the script name.
Removes all empty directories from the first level of E:\chiore (i.e. those empty
directories, which would be listed with the "dir E:\chiore" command, and if any
deletions were made, saves the log-file to C:\Scripts with the default filename
(deleted_directories.txt). During the possibly invoked log-file creation procedure
Remove-EmptyDirectories tries to preserve any pre-existing content rather than
overwrite the file, so if the default log-file (deleted_directories.txt) already
exists, new log-info data is appended to the end of that file. Please note, that
-Path can be omitted in this example, because

    ./Remove-EmptyDirectories "E:\chiore" -Output "C:\Scripts"

will result in the exact same outcome.

.EXAMPLE
help ./Remove-EmptyDirectories -Full
Display the help file.

.EXAMPLE
./Remove-EmptyDirectories -Path "C:\Users\Dropbox", "C:\dc01" -Recurse -WhatIf
Because the -WhatIf parameter was used, only a simulation run occurs, so no directories
would be deleted in any circumstances. The script will look for empty directories from
C:\Users\Dropbox and C:\dc01 and will add all sub-directories of the sub-directories
of the sub-directories and their sub-directories as well from those directories to
the list of directories to process (the search for other directories to process is done
recursively).

If empty directories aren't found, the result would be identical regardless whether the
-WhatIf parameter was used or not. If, however, empty directories were indeed found,
only an indication of what the script would delete ("What if:") is displayed.

The Path variable value is case-insensitive (as is most of the PowerShell), and
since the path names don't contain any space characters, they don't need to be
enveloped with quotation marks. Actually the -Path parameter may be left out from
the command, too, since, for example,

    ./Remove-EmptyDirectories c:\users\dROPBOx, c:\DC01 -Recurse -WhatIf

is the exact same command in nature.

.EXAMPLE
.\Remove-EmptyDirectories.ps1 -From C:\dc01 -ReportPath C:\Scripts -File log.txt -Recurse -Audio
Run the script and search recursively for empty directories from C:\dc01 and delete all
recursively found empty directories under C:\dc01. If any deletions were made, the
log-file would be saved to C:\Scripts with the filename log.txt and an audible beep
would occur. This command will work, because -From is an alias of -Path and
-ReportPath is an alias of -Output and -File is an alias of -FileName. Furthermore,
since the path names don't contain any space characters, they don't need to be
enclosed in quotation marks.

.EXAMPLE
Set-ExecutionPolicy remotesigned
This command is altering the Windows PowerShell rights to enable script execution for
the default (LocalMachine) scope. Windows PowerShell has to be run with elevated rights
(run as an administrator) to actually be able to change the script execution properties.
The default value of the default (LocalMachine) scope is "Set-ExecutionPolicy restricted".


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


For more information, please type "Get-ExecutionPolicy -List", "help Set-ExecutionPolicy -Full",
"help about_Execution_Policies" or visit https://technet.microsoft.com/en-us/library/hh849812.aspx
or http://go.microsoft.com/fwlink/?LinkID=135170.

.EXAMPLE
New-Item -ItemType File -Path C:\Temp\Remove-EmptyDirectories.ps1
Creates an empty ps1-file to the C:\Temp directory. The New-Item cmdlet has an inherent -NoClobber mode
built into it, so that the procedure will halt, if overwriting (replacing the contents) of an existing
file is about to happen. Overwriting a file with the New-Item cmdlet requires using the Force. If the
path name includes space characters, please enclose the path name in quotation marks (single or double):

    New-Item -ItemType File -Path "C:\Directory Name\Remove-EmptyDirectories.ps1"

For more information, please type "help New-Item -Full".

.LINK
https://social.technet.microsoft.com/Forums/en-US/4d78bba6-084a-4a41-8d54-6dde2408535f/get-directory-where-access-is-denied?forum=winserverpowershell
http://mikefrobbins.com/2015/03/31/powershell-advanced-functions-can-we-build-them-better-with-parameter-validation-yes-we-can/
http://www.leeholmes.com/guide
https://gist.github.com/nedarb/840f9f0c9a2e6014d38f
https://gist.github.com/Appius/d863ada643c2ee615db9
http://www.brangle.com/wordpress/2009/08/append-text-to-a-file-using-add-content-in-powershell/
https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_functions_advanced_parameters
https://blogs.technet.microsoft.com/heyscriptingguy/2013/09/21/powertip-use-powershell-to-send-beep-to-console/
http://poshcode.org/2154

#>
