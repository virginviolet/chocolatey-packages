# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## See https://docs.chocolatey.org/en-us/choco/commands/uninstall
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$toolsDir = "C:\ProgramData\chocolatey\lib\flips\tools"
$zipArchive = Join-Path $toolsDir -ChildPath 'flips-windows.zip'
$unzipDir = Join-Path $toolsDir -ChildPath 'builds'

# Check if running in administrative shell
function Test-Administrator {  
    [OutputType([bool])]
    param()
    process {
        [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}

<# Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName '$zipArchive' # Only necessary if you did not unpack to package directory - see https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

# Uninstall-ChocolateyZipPackage will remove the FILES from the archive.
# If you wish to remove the DIRECTORY they were extracted too,
# you'll additionally have to handle that in this script.
Remove-Item $unzipDir -Recurse -Force

# Remove desktop shortcut if it exists (it's plausible the user might have removed it)
$exists = Test-Path -Path "$env:UserProfile\Desktop\Zelda 3 Launcher.lnk" -ea 0
if ($exists) {
    Remove-Item "$env:UserProfile\Desktop\Zelda 3 Launcher.lnk"
}

# Check if start menu shortcut exists (it's plausible the user might have removed it)
$exists = Test-Path -Path "$env:ProgramData/Microsoft/Windows/Start Menu/Programs/Floating IPS.lnk"  -ea 0
# If administrative shell
if (Test-Administrator) {
    # Remove start menu shortcut if it exists
    if ($exists) {
        Remove-Item "$env:ProgramData/Microsoft/Windows/Start Menu/Programs/Floating IPS.lnk"
    }
} else {
    # Untested in real non-admin Choco scenario
    if ($exists) {
        Write-Warning "You are not running from an elevated shell. Start menu shortcut will not be removed.";
    }
} #>

# Remove registry keys (mostly file associations)

function Remove-RegistryValueByValueData($keyPath, $targetValueData, $extensionU) {
    # TODO Did I accidentally find a better way to do this, later in the script?
    $key = Get-Item -Path $keyPath
    $keyValues = $key.Property # easier to understand (for me at least)
    $found = $false
    foreach ($value in $keyValues) {
        $data = Get-ItemPropertyValue -Path $keyPath -Name $value # Get the data of the value

        if ($data -eq $targetValueData) {
            # Check if the data matches $targetValueData

            # Remove the value
            try {
                Remove-ItemProperty -Path $keyPath -Name $value # PowerShell bug causes error if name is '(default)' 
                Write-VerboseRemovedValueData $keyPath $value $targetValueData
                $found = $true
                return # In this script, we don't expect multiple values with the same data, so we can return as soon as we find the data. 
            } catch {
                if ($_.Exception.Message -match 'Property \(default\) does not exist at path*') {
                    $(Get-Item -Path $keyPath).OpenSubKey('', $true).DeleteValue('') # "(default)" actually just means empty string (Remove-ItemProperty does not accept empty string).
                    Write-VerboseRemovedValueData $keyPath $value $targetValueData
                    $found = $true
                    return # In this script, we don't expect multiple values with the same data, so we can return as soon as we find the data. 
                } else {
                    Write-Error "An ItemNotFoundException occurred: $_"
                }
            }
        }
    }
    if (-Not ($found)) {
        Write-VerboseValueDataNotFound $keyPath $targetValueData $extensionU
    }
}

# path
function Test-PathBool($p) {
    return [bool](Test-Path -Path $p)
}

# path, value
function Test-ValueNameBool($p, $n) {
    return [bool](Get-ItemProperty -Path $p -Name $n -ea 0)
}


function Get-ValueData($p, $n) {
    return Get-ItemPropertyValue -Path $p -Name $n
}

function Test-ValueDataBool($p, $n, $d) {
    $vD = Get-ValueData $p $n
    return ($vD -eq $d)
}

# path, extra
Function Write-VerboseRemovedKey($p, $e) {
    Write-Verbose "REMOVED: key '$p'.$e".Replace("REGISTRY::", "")
}

#path, value name, extension, extra
Function Write-VerboseRemovedValueName($p, $n, $x, $e) {
    $msg = "REMOVED: value '$n' in key '$p'.$e".Replace("REGISTRY::", "")
    Write-Verbose $msg
}

Function Write-VerboseRemovedValueData($p, $n, $d) {
    Write-Verbose "REMOVED: value '$n' with data '$d' in key '$p'.".Replace("REGISTRY::", "")
}

Function Write-VerboseKeyNotFound($p, $x, $e) {
    $msg = "NOT FOUND: key '$p'.$e".Replace("REGISTRY::", "")
    # FIXME bugtest this if statement
    if ([bool]$x -ne $false) {
        $msg = $msg + " This key only gets added when a $x file has been opened. It may have already been removed."
    }
    Write-Verbose $msg
}

Function Write-VerboseValueNameNotFound($p, $n, $x, $e) {
    $msg = "NOT FOUND: value '$n' in key '$p'.$e".Replace("REGISTRY::", "")
    if ([bool]$x -ne $false) {
        $msg = $msg + " This value only gets added when a $x file has been opened. It may have already been removed."
    }
    Write-Verbose $msg
}
Function Write-VerboseValueDataNotFound($p, $d, $x, $e) {
    $msg = "NOT FOUND: value with data '$d' in key '$p'.$e".Replace("REGISTRY::", "")
    if ($x -ne "") {
        $msg = $msg + " This value only gets added when a $x file has been opened. It may have already been removed."
    }
    Write-Verbose $msg
}

# For when you looked for a value with a specifc name and specific data. Unused.
Function Write-VerboseValueNameDataNotFound($p, $d, $x, $e) {
    $msg = "NOT FOUND: value with data '$d' in key '$p'.$e".Replace("REGISTRY::", "")
    if ($x -ne "") {
        $msg = $msg + " This value only gets added when a $x file has been opened. It may have already been removed."
    }
    Write-Verbose $msg
}


function Get-ValueCount($p) {
    return $(Get-Item -Path $p).Property.Count
}
function Get-SubkeyCount($p) {
    return $(Get-ChildItem -Path $p).Name.Count
}

function Write-VerboseNoFileHandlersRemaining($p) {
    Write-Verbose "No file handlers remaining in '$p'. Will attempt to remove empty key.".Replace("REGISTRY::", "")
}
function Write-VerboseFileHandlersStillRemaining($p) {
    Write-Verbose "File handlers remaining in key '$p'. Will NOT remove the key.".Replace("REGISTRY::", "")
}

function Test-PathPermission ($p) {
    # The UserChoice key usually has weird permissions, which will likely
    # prevent us from removing it, which is okay.
    # The original idea was to just try Remove-Item, but Remove-Item gives
    # misleading error message, "subkey does not exist"
    # (this seems like a bug in PowerShell.) New-ItemProperty gives
    # a correct message. Therefore, we try New-ItemProperty first.
    # Test permission
    try {
        New-ItemProperty -Path $p -Name "PermissionTestRemoveMe" -Value "" -PropertyType String -Force | Out-Null
        Remove-ItemProperty -Path $p -Name "PermissionTestRemoveMe"
        return $true # Permission was granted!
    } catch {
        if ($_.Exception.Message -match "Requested registry access is not allowed.") {
            return $false
        } else {
            Write-Warning "Unexpected error occurred: $_"
        }
    }
}

# See if executable matches 
function Test-AutoFileProgram($x, $executable) {
    $p = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\$x" + "_auto_file\shell\open\command"
    $pathOk = Test-PathBool($keyPath)
    $match = $false # initialize variable
    if ($pathOk) {
        $targetDataTrailEnd = $exe + '" "%1"'
        $firstValue = $(Get-Item -Path $keyPath).Property[0] # there should only be one value though
        $data = $(Get-ItemPropertyValue -Path $keyPath -Name $firstValue)
        $match = $data.EndsWith($targetDataTrailEnd)
    } else {
        Write-Verbose "NOT FOUND: key $p"
    }
    return $match
}

function Remove-AAToast($n, $extensionStr) {
    # file association values in `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts`
    $p = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueOk = Test-ValueNameBool $p $n
    if ($valueOk) {
        Remove-ItemProperty -Path $p -Name $n
        Write-VerboseRemovedValueName $p $n
    } else {
        Write-VerboseValueNameNotFound $p $n $extensionStr
    }
}

function Remove-FileAssocInClasses ($extension, $progId) {
    # Does not include the key in `HKEY_CURRENT_USER\Software\Classes\Applications`

    # IMPROVE Make a separate function to clean up empty keys, run it at the end of the end of the script, instead of cleaning as we go. However, cleaning up and check for subkeys was a practical way to check if handlers remaining.
    
    $extensionU = $extension.ToUpper()
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\.$extension"
    $pathOk = Test-PathBool($keyPath)
    if ($pathOk) {
        Remove-RegistryValueByValueData $keyPath $progId $extensionU
        $valueCount = Get-ValueCount $keyPath
        $subKeyCount = Get-SubkeyCount $keyPath
        if (($valueCount -eq 0) -And ($subKeyCount -eq 0)) {
            Write-VerboseNoFileHandlersRemaining $keyPath
            Remove-Item -Path $keyPath -Force
            Write-VerboseRemovedKey $keyPath
        } else {
            Write-VerboseFileHandlersStillRemaining $keyPath
        }
    } else {
        Write-VerboseKeyNotFound $keyPath
    }

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\$progId"
    $pathOk = Test-PathBool $keyPath
    if ($pathOk) {
        Remove-Item -Path $keyPath -Recurse -Force
        Write-VerboseRemovedKey $keyPath
    } else {
        Write-VerboseKeyNotFound $keyPath
    }
}

# Remove items in `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts`
function Remove-FileAssocInFileExts ($extension, $exe, $id) {
    # TODO bugtest
    $extensionU = $extension.ToUpper() # upper-case

    # Don't continue if this parent key doesn't exist
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$extension"
    $pathOk = Test-PathBool $keyPath # Test if path exists
    if (-not $pathOk) {
        Write-VerboseKeyNotFound $keyPath $extensionU
        return
    }
    echo hey
    
    # This key holds programs on the "Open with" context menu and the order in which each application was most recently used.
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$extension\OpenWithList"
    $targetValueData = $exe
    $pathOk = Test-PathBool $keyPath # Test if path exists
    if ($pathOk) {
        Remove-RegistryValueByValueData $keyPath $targetValueData $extensionU
        $valueCount = Get-ValueCount $keyPath
        $subkeyCount = Get-SubkeyCount $keyPath
        
        # le = "less than or equal to"; this key having subkeys would be an edge case
        if (($valueCount -le 1) -And ($subkeyCount -eq 0)) {
            # only values left: MRUList value, and plausibly the Default value (the latter is not counted by .Count)
            Write-VerboseNoFileHandlersRemaining $keyPath
            Remove-Item -Path $keyPath
            Write-VerboseRemovedKey $keyPath
        } else {
            $handlersRemaining = $true
            Write-VerboseFileHandlersStillRemaining $keyPath
        }
    } else {
        Write-VerboseKeyNotFound $keyPath $extensionU
    }

    # This key also holds handlers.
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$extension\OpenWithProgids"
    $targetValueName = $id
    $pathOk = Test-PathBool $keyPath # Test if path exists
    $valueOk = Test-ValueNameBool $keyPath $targetValueName # Test value name exists
    if ($pathOk) {
        if ($valueOk) {
            Remove-ItemProperty -Path $keyPath -Name $targetValueName
            Write-VerboseRemovedValueName $keyPath $targetValueName
        } else {
            Write-VerboseValueNameNotFound $keyPath $targetValueName $extensionU
        }
        $valueCount = Get-ValueCount $keyPath
        $subkeyCount = Get-SubkeyCount $keyPath
        
        # Again, the (Default) value isn't counted
        if (($valueCount -eq 0) -And ($subkeyCount -eq 0)) {
            Write-VerboseNoFileHandlersRemaining $keyPath
            Remove-Item -Path $keyPath
            Write-VerboseRemovedKey $keyPath
        } else {
            Write-VerboseFileHandlersStillRemaining $keyPath
        }
    } else {
        Write-VerboseKeyNotFound $keyPath $extensionU
    }
}

function Remove-FileAssocInFileExtsFinal($extension, $id) {
    $extensionU = $extension.ToUpper() # upper-case
    # Don't continue if this parent key doesn't exist

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$extension"
    $pathOk = Test-PathBool $keyPath # Test if path exists
    if (-not $pathOk) {
        Write-VerboseKeyNotFound $keyPath $extensionU
        return
    }

    # This key holds says which program to always be used for .$ext. This may also be controlled with keys in Classes.
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$extension\UserChoice"
    $targetValueName = "ProgId"
    $targetValueData = $id
    $pathOk = Test-PathBool $keyPath # Test if path exists
    $permissionOk = $true # Initialize the variable
    if ($pathok) {
        # TODO Is the association removed in a way that the user doesn't notice if pemrission denied? Probably, but needs double checking. 
        $permissionOk = Test-PathPermission $keyPath
        $valueNameOk = Test-ValueNameBool $keyPath $targetValueName # Test value name exists
        if ($valueNameOk) {
            # $valueData = Get-ValueData
            $valueDataOk = Test-ValueDataBool $keyPath $targetValueName $targetValueData # Test if value data equals the target data
        } else {
            # Weird edge case; key exists but not the "ProgId" value
            Write-VerboseValueNameNotFound $keyPath $targetValueName $extensionU
            $valueDataOk = $false # If the value didn't even exist, then we did not find the value data we were looking for
        }
        if ($valueDataOk) {
            Write-Verbose "The default handler for $extensionU is set to '$id' in $keyPath. Will attempt to remove the key.".Replace("REGISTRY::", "")
        } else {
            Write-Verbose "The default handler for $extensionU is NOT set to '$id' in $keyPath. Will NOT attempt to remove the key.".Replace("REGISTRY::", "")
        }
        if (($valueDataOk) -Or ($valueNameOk -eq $false)) { 
            # We don't need to remove the value, since this key only holds one handler.
            # Instead, we would rather just to delete the key (if it has the target data).
            # The value name is just the generic "ProgId", it would be
            # weird if this value name was gone but not the key, but
            # let's remove the key in that edge case.
            if ($permissionOk) {
                Remove-Item -Path $keyPath -Force
            } else {
                # If Test-PathPermission gives "Unexpected error occured", the below output may be incorrect.
                Write-Verbose "Lacking permission to remove key '$keyPath'. That is normal for this key. It prevents complete cleanup in registry, but it is not an issue as it makes no difference to user experience.".Replace("REGISTRY::", "")
            }
        }
    } else {
        Write-VerboseKeyNotFound $keyPath
    }

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext"
    $pathOk = Test-PathBool $keyPath
    if ($pathOk) {
        # XXX Bugtest
        $subkeyNamesRemaining = (Get-ChildItem -Path $keyPath).Name
        $subkeyCount = Get-SubkeyCount $keyPath
        $valueCount = Get-ValueCount $keyPath
        if (
            ($valueCount -gt 0) -or
        (($subKeyCount -gt 1) -And -Not ($subkeyNamesRemaining[0].EndsWith("\UserChoice"))) # if the first subkey isn't UserChoice
        ) {
            Write-VerboseFileHandlersStillRemaining $keyPath $extensionU
        }
        elseif (($subkeyCount -eq 0) -and ($valueCount -eq 0)) {
            # empty key
            Write-VerboseNoFileHandlersRemaining $path $extensionU
            Remove-Item -Path $keyPath -Recurse -Force
            Write-VerboseRemovedKey $keyPath
        } elseif ($permissionOk -eq $true) {
            # Re-using $pemissionOk value from UserChoice, no neet to test again.
            Write-VerboseNoFileHandlersRemaining $keyPath $extensionU
            Remove-Item -Path $keyPath -Recurse -Force
            Write-VerboseRemovedKey $keyPath
        }
        else {
            Write-VerboseNoFileHandlersRemaining $keyPath $extensionU # message is lying, the attempt has already been made
            # If Test-PathPermission gives "Unexpected error occured", the below output may be incorrect.
            Write-Verbose "Lacking permission to remove key '$keyPath'. That is normal for this key. It prevents complete cleanup, but it's not a real issue, because it does not affect user experience.".Replace("REGISTRY::", "")
        }
    }
    else {
        Write-VerboseKeyNotFound $keyPath $extensionU
    }
}

function Remove-FileAssocSetByProgram($ext) {
    # TODO Would be cool if you could just paste a list of keys somewhere and some function or script would remove them. But that wouldn't make much sense, because we need to programatically determine wether to remove [ext]_auto_key. It would just add a layer of complexity, to interpret that list.
    $extU = $ext.ToUpper() # upper-case
    
    Write-Verbose "Will attempt to remove file associations that may have been added through the application." # There is an option in the settings to add file extensions.
    Write-Verbose "Extension: $extU"

    $progId = "FloatingIPSFile$extU"
    Remove-FileAssocInClasses $ext $progId

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "Applications\flips.exe_.$ext"
    $targetValueName = "FloatingIPSFile$extU" + "_.$ext"
    Remove-AAToast $targetValueName $extU
    
    $exe = "flips.exe"
    $id = "FloatingIPSFile$extU"
    # TODO "NOT FOUND: value 'FloatingIPSFileIPS' in key 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ips\OpenWithProgids'. This value only gets added when a IPS file has been opened."
    # Is the second sentence true?
    Remove-FileAssocInFileExts $ext $exe $id

    # HACK Mystery: Why does the permission problem occur before, but after removing the program and rebooting, there is no problem with this key?
    # TODO does adding file exts as admin create keys in HKLM?
}

function Remove-FileAssocSetByUser($ext) {
    $extU = $ext.ToUpper()
    Write-Verbose "Will attempt to remove file associations that may have been manually added." # e.g. right-click and "Open with"
    Write-Verbose "Extension: $extU."
    $exe = "flips.exe"
    $fileExtsExtPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$ext"

    # Added when you add a program to the "Select an app to open this .[ext] file" popup window
    # IMPROVE It isn't necesssary to try to remove this every time the function is run. See if you can find an elegant solution.
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Applications\flips.exe"
    $pathOk = Test-PathBool $keyPath
    if ($pathOk) {
        Remove-Item -Path $keyPath -Recurse -Force
        Write-VerboseRemovedKey $keyPath
    } else {
        Write-VerboseKeyNotFound $keyPath "" " This key is only added if you manually add the program to the 'Select an app to open this .$ext file' popup window. It may have already been removed."
    }

    # Added when you select to use the program "Just once" or "Always" for the file type
    $targetValueName = "Applications\" + $exe + "_.$extU"
    Remove-AAToast $targetValueName $extU

    # Added when you select to use the program "Just once" or "Always" for the file type
    $exe = $exe
    $id = "Applications\" + $exe + "_.$extU"
    Remove-FileAssocInFileExts $ext $exe $id

    # We determine if the [ext]_auto_file is set to our program, and if true, we remove [ext]_auto_file in Classes, FilExts, and AAToasts.
    $ext_auto_file = $ext + "_auto_file"
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\$ext_auto_file\shell\open\command"
    $autoFileMatch = $false # initialize variable
    $pathOk = Test-PathBool($keyPath)
    if ($pathok) {
        $autoFileMatch = Test-AutoFileProgram($exe) # true if matches the exe
    } else {
        Write-VerboseKeyNotFound $keyPath
        Write-Verbose "Will attempt to remove '$ext_auto_file' in other places if found.".Replace("REGISTRY::", "") # It serves no purpose if this key doesn't exist, so we might as well clean up mentions of it it we find any.
    }
    if ($pathok -And -Not $autoFileMatch) {
        Write-Verbose "The value data in $keyPath does NOT point to $exe. Will NOT attempt to remove $ext_auto_file.".Replace("REGISTRY::", "")
    }
    elseif ($pathOk -And $autoFileMatch) {
        Write-Verbose "The value data in $keyPath does point to $exe. Will attempt to remove $ext_auto_file.".Replace("REGISTRY::", "")
    }
    if ($autoFileMatch -Or (-Not $pathOk)) {
        # Added when you select to "Always" use the program for the file type
        $progId = $ext_auto_file
        Remove-FileAssocInClasses $ext $progId
        
        # Added when you select to "Always" use the program for the file type
        # (And maybe a file needs to opened as well. I don't know because I have
        # only tried setting this trough the "Open with" context menu, which opens the
        # file immediately afterwards.)
        $targetValueName = $ext + "_auto_file_." + $ext
        Remove-AAToast $targetValueName $extU
        
        $exe = $exe
        $id = $ext_auto_file
        Remove-FileAssocInFileExts $ext $exe $id
        
        # We check if this path exists in order to avoid the same "NOT FOUND" verbose message being shown again (we ran this function recently).
        $pathOk = Test-PathBool $fileExtsExtPath # Test if path exists
        if ($pathOk) {
            # Added if [ext]_auto_file is manually modified, or perhaps if you set up file association in Windows XP and copied the key over to current Windows.
            $progId = $ext_auto_file
            Remove-FileAssocInFileExtsFinal $ext $progId
        }
    }

    # We check if this path exists in order to avoid the same "NOT FOUND" verbose message being shown again (we ran this function recently).
    $pathOk = Test-PathBool $fileExtsExtPath # Test if path exists
    if ($pathOk) {
        echo ok
        # We need to do this after removing keys and values for both `[ext]_auto_file` and `Applications\flips.exe`. If we try to bake the code from Remove-FileAssocInFileExtsFinal into Remove-FileAssociInFileExts, there will be issues, (unless we do some convoluted or perhaps clever coding). It might say that there are other file handlers left (either of the ones mentioned) and that it won't attempt to remove.
        # For normal cases on modern Windows, we could solve this by just removing `Applications\flips.exe` last. But, theoretically, you can set default program in `HKEY_CURRENT_USER\Software\Classes\[ext]_auto_file\shell\open\command`, then UserChoice will be set to [ext]_auto_file, and then, I think, we would need to remove [ext]_auto_file last.
        # Or we could bake it into Remove-FileAssociInFileExts and run it that whole function three times (e.g. first with `[ext]_auto_file`, then `Applications\flips.exe`., then `[ext]_auto_file` again), which would account for both scenarios. Splitting it up seems most reasonable.
        $progId = "Applications\" + $exe
        Remove-FileAssocInFileExtsFinal $ext $progId
    }
    
}

function Remove-MuiCacheEntry($n) {
    Write-Verbose "Will attempt to remove MUI cache entry."
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
    $targetValueName = $n
    $valueNameOk = Test-ValueNameBool $keyPath $targetValueName
    if ($valueNameOk) {
        Remove-ItemProperty -Path $keyPath -Name $targetValueName
        Write-VerboseRemovedValueName $keyPath $targetValueName
    } else {
        Write-VerboseValueNameNotFound $keyPath $targetValueName
    }

}

Write-Verbose 'You may safetly ignore "NOT FOUND" verbose messages from this uninstallation script.'; Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."

Remove-FileAssocSetByProgram "bps"; Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."
Remove-FileAssocSetByProgram "ips"; Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."

Remove-FileAssocSetByUser("bps"); Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."
Remove-FileAssocSetByUser("ips");Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."

Remove-FileAssocSetByUser("nes");Write-Verbose "...";Write-Verbose "...";Write-Verbose "..."
Remove-FileAssocSetByUser("sfc");Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."
Remove-FileAssocSetByUser("smc");Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."
Remove-FileAssocSetByUser("n64");Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."
Remove-FileAssocSetByUser("z64");Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."
Remove-FileAssocSetByUser("gb");Write-Verbose "...";Write-Verbose "...";Write-Verbose "..."
Remove-FileAssocSetByUser("gbc");Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."
Remove-FileAssocSetByUser("gba");Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."
Remove-FileAssocSetByUser("bin");Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."
Remove-FileAssocSetByUser("md");Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."
Remove-FileAssocSetByUser("gen");Write-Verbose "..."; Write-Verbose "..."; Write-Verbose "..."

$friendlyAppName = "flips.exe"
$executableDir = Join-Path $unzipDir -ChildPath "windows-x64-gui.zip"
$targetValueName = Join-Path $executableDir -ChildPath "$friendlyAppName.FriendlyAppName"
Remove-MuiCacheEntry $targetValueName

# TODO Search registry to see if there are any more keys we need to remove with this script


## TODO REMOVE FILE ASSOCIATION?
## TODO REMOVE SHORTCUTS
## TODO ADD REMOVE SHORTCUTS TO TEMPLATE
## TODO ADD START MENU TO TEMPLATE

## OTHER POWERSHELL FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Remove any shortcuts you added in the install script.
