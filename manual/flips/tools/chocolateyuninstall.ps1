﻿# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
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

# === SECTION RVBVD START ===
# === SECTION RVBVD ===
# === SECTION RVBVD ===
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
                break # In this script, we don't expect multiple values with the same data, so we can break as soon as we find the data. 
            }
            catch {
                if ($_.Exception.Message -match 'Property \(default\) does not exist at path*') {
                    $(Get-Item -Path $keyPath).OpenSubKey('', $true).DeleteValue('') # "(default)" actually just means empty string (Remove-ItemProperty does not accept empty string).
                    Write-VerboseRemovedValueData $keyPath $value $targetValueData
                    $found = $true
                    break # In this script, we don't expect multiple values with the same data, so we can break as soon as we find the data. 
                }
                else {
                    Write-Error "An ItemNotFoundException occurred: $_"
                }
            }
        }
    }
    if (-Not ($found)) {
        Write-VerboseValueDataNotFound $keyPath $targetValueData $extensionU
    }
}
# === SECTION RVBVD ===
# === SECTION RVBVD ===
# === SECTION RVBVD END ===


# === SECTION SMALL FUNCTIONS START ===
# === SECTION SMALL FUNCTIONS ===
# === SECTION SMALL FUNCTIONS ===
# path
function Test-PathBool($p) {
    return [bool](Test-Path -Path $p)
}

# path, value
function Test-ValueNameBool($p, $n) {
    return [bool](Get-ItemProperty -Path $p -Name $n -ea 0)
}

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
        $msg = $msg + " This key only gets added when a $x file has been opened."
    }
    Write-Verbose $msg
}

Function Write-VerboseValueNameNotFound($p, $n, $x, $e) {
    $msg = "NOT FOUND: value '$n' in key '$p'.$e".Replace("REGISTRY::", "")
    if ([bool]$x -ne $false) {
        $msg = $msg + " This value only gets added when a $x file has been opened."
    }
    Write-Verbose $msg
}
Function Write-VerboseValueDataNotFound($p, $d, $x, $e) {
    $msg = "NOT FOUND: value with data '$d' in key '$p'.$e".Replace("REGISTRY::", "")
    if ($x -ne "") {
        $msg = $msg + " This value only gets added when a $x file has been opened."
    }
    Write-Verbose $msg
}

Function Write-VerboseValueNameDataNotFound($p, $d, $x, $e) { # For when you looked for a value with a specifc name and specific data. Unused.
    $msg = "NOT FOUND: value with data '$d' in key '$p'.$e".Replace("REGISTRY::", "")
    if ($x -ne "") {
        $msg = $msg + " This value only gets added when a $x file has been opened."
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
        New-ItemProperty -Path $p -Name "PermissionTestRemoveMe" -Value "" -PropertyType String -Force | out-null
        Remove-ItemProperty -Path $p -Name "PermissionTestRemoveMe"
        return $true # Permission was granted!
    }
    catch {
        if ($_.Exception.Message -match "Requested registry access is not allowed.") {
            return $false
        }
        else {
            Write-Warning "Unexpected error occurred: $_"
        }
    }
}

# === SECTION SMALL FUNCTIONS ===
# === SECTION SMALL FUNCTIONS ===
# === SECTION SMALL FUNCTIONS END ===

# === SECTION TOAST START ===
# === SECTION TOAST ===
# === SECTION TOAST ===
# === SECTION TOAST ===

function Remove-AAToast($n, $extensionStr) { # file association values in `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts`
    $p = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueOk = Test-ValueNameBool $p $n
    if ($valueOk) {
        Remove-ItemProperty -Path $p -Name $n
        Write-VerboseRemovedValueName $p $n
    }
    else {
        Write-VerboseValueNameNotFound $p $n $extensionStr
    }
}

# === SECTION TOAST ===
# === SECTION TOAST ===
# === SECTION TOAST ===
# === SECTION TOAST END ===

# === SECTION CLASSES START ===
# === SECTION CLASSES ===
# === SECTION CLASSES ===
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
        }
        else {
            Write-VerboseFileHandlersStillRemaining $keyPath
        }
    }
    else {
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
# === SECTION CLASSES ===
# === SECTION CLASSES ===
# === SECTION CLASSES END ===



    # === SECTION FileExts START ===
    # === SECTION FileExts ===
    # === SECTION FileExts ===
    function Remove-FileAssocInFileExts ($extension, $exe, $id, $skipUserChoiceKey) { # in `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts`
    # TODO bugtest
    $extensionU = $extension.ToUpper() # upper-case
    
    # This key holds programs on the "Open with" context menu and the order in which each application was most recently used.
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$extension\OpenWithList"
    $targetValueData = $exe
    $pathOk = Test-PathBool $keyPath # Test if path exists
    if ($pathOk) {
        Remove-RegistryValueByValueData $keyPath $targetValueData $extensionU
        $valueCount = Get-ValueCount $keyPath
        $subkeyCount = Get-SubkeyCount $keyPath
        if (($valueCount -le 1) -And ($subkeyCount -eq 0)) { # le = "less than or equal to"; this key having subkeys would be an edge case
            # only values left: MRUList value, and plausibly the Default value (the latter is not counted by .Count)
            Write-VerboseNoFileHandlersRemaining $keyPath
            Remove-Item -Path $keyPath
            Write-VerboseRemovedKey $keyPath
        }
        else {
            $handlersRemaining = $true
            Write-VerboseFileHandlersStillRemaining $keyPath
        }
    }
    else {
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
        }
        else {
            Write-VerboseValueNameNotFound $keyPath $targetValueName $extensionU
            }
        $valueCount = Get-ValueCount $keyPath
        $subkeyCount = Get-SubkeyCount $keyPath
        if (($valueCount -eq 0) -And ($subkeyCount -eq 0)) { # Again, the (Default) value isn't counted
            Write-VerboseNoFileHandlersRemaining $keyPath
            Remove-Item -Path $keyPath
            Write-VerboseRemovedKey $keyPath
        }
        else {
            Write-VerboseFileHandlersStillRemaining $keyPath
        }
    }
    else {
        Write-VerboseKeyNotFound $keyPath $extensionU
    }

    # This key holds says which program to always be used for .$ext. This may also be controlled with keys in Classes.
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$extension\UserChoice"
    $targetValueName = "ProgId"
    $targetValueData = $id
    $pathOk = Test-PathBool $keyPath # Test if path exists
    $permissionOk = $true # Initialize the variable
    if ($pathok -And (-Not ($skipUserChoiceKey))) {
        # TODO Is the association removed in a way that the user doesn't notice if pemrission denied? Probably but needs double checking. 
        $permissionOk = Test-PathPermission $keyPath
        $valueNameOk = Test-ValueNameBool $keyPath $targetValueName # Test value name exists
        if ($valueNameOk) {
            # $valueData = Get-ValueData
            $valueDataOk = Test-ValueDataBool $keyPath $targetValueName $targetValueData # Test if value data equals the target data
        }
        else {
            # Weird edge case; key exists but not the "ProgId" value
            Write-VerboseValueNameNotFound $keyPath $targetValueName $extensionU
            $valueDataOk = $false # If the value didn't even exist, we did not find the value data we were looking for
        }
        if ($valueDataOk) {
            Write-Verbose "The default handler for $extensionU is set to '$id' in $keyPath. Will attempt to remove the key.".Replace("REGISTRY::", "")
        }
        else {
            Write-Verbose "The default handler for $extensionU is NOT set to '$id' in $keyPath. Will NOT attempt to remove the key.".Replace("REGISTRY::", "")
        }
        if (($valueDataOk) -Or ($valueNameOk -eq $false)) {
            # We don't need to remove the value, since this key only holds one handler
            # Instead, we would rather just to delete the key.
            if ($permissionOk) {
                Remove-Item -Path $p -Recurse -Force
            }
            else {
                # If Test-PathPermission gives "Unexpected error occured", the below output may be incorrect.
                Write-Verbose "Lacking permission to remove key '$keypath'. That is normal for this key. This is not a problem.".Replace("REGISTRY::", "")
            }
        }
    }
    elseif ($pathOk -eq $false) {
        Write-VerboseKeyNotFound $keyPath
    }

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext"
    $pathOk = Test-PathBool $keyPath
    if ($pathOk) {
        $subkeyCount = Get-SubkeyCount $keyPath
        $valueCount = Get-ValueCount $keyPath
        if (($subkeyCount -eq 0) -and ($valueCount -eq 0)) { # empty key
            Write-VerboseNoFileHandlersRemaining $path
            Remove-Item -Path $keyPath -Recurse -Force
            Write-VerboseRemovedKey $keyPath
        }
        # skip this section if $skipUserChoiceKey -eq $true
        if (-not ($skipUserChoiceKey)) {
            $subkeyNamesRemaining = (Get-ChildItem -Path $keyPathParent).Name
            $handlersRemaining = $false # initialize variable
            # I could optimize perfermance by nesting the if statements more, but I prefer not to,
            # and it's already very fast. Feel free to improve.
            if ($valueCount -gt 0) {
                $handlersRemaining = $true
            }
            if (($subKeyCount -gt 1) -And ($subkeyNamesRemaining[0] -ne $subkeyUc)) {
                $handlersRemaining = $true
            }
            if ($handlersRemaining) {
                Write-VerboseFileHandlersStillRemaining $keyPath $extensionU
            }
            else {
                Write-VerboseNoFileHandlersRemaining $keyPath $extensionU
            }
            if (($handlersRemaining -eq $false) -and ($permissionOk -eq $true)) { # Re-using the permission check we did for UserChoice
                Remove-Item -Path $keyPath -Recurse -Force
                Write-VerboseRemovedKey $keyPath
            }
            elseif (($handlersRemaining -eq $true) -and ($permissionOk -eq $false)) {
                # If Test-PathPermission gives "Unexpected error occured", the below output may be incorrect.
                Write-Verbose "Lacking permission to remove key '$keyPath'. That is normal for this key. This is not a problem.".Replace("REGISTRY::", "")
            }
        }
    }
    elseif (($pathOk -eq $false)-and (-not $skipUserChoiceKey)) {
        Write-VerboseKeyNotFound $keyPath $extensionU
    }
}
# === SECTION FileExts ===
# === SECTION FileExts ===
# === SECTION FileExts END ===

# === SECTION R-FASBP START ===
# === SECTION R-FASBP ===
# === SECTION R-FASBP ===
function Remove-FileAssocSetByProgram($ext) {
    # TODO Would be cool if you could just paste a list of keys somewhere in the script and some function would remove them.
    $extU = $ext.ToUpper() # upper-case
    
    Write-Verbose "Will attempt to remove file associations that may have been added through the application." # There is an option in the settings to add file extensions.
    Write-Verbose "Extension: $extU"

    progId = "FloatingIPSFile$extU"
    Remove-FileAssocInClasses $ext $progId

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "Applications\flips.exe_.$ext"
    $targetValueName = "FloatingIPSFile$extU" + "_.$ext"
    Remove-AAToast $targetValueName $extU
    
    $exe = "flips.exe"
    $id = "FloatingIPSFile$extU"
    $skipUserChoice = $true # we skip the "UserChoice" key this when removing file assoc that program made, because the program doesn't make that key
    Remove-FileAssocInFileExts $ext $targetValueName $skipUserChoice

    # HACK Mystery: Why does the permission problem occur before, but after removing the program and rebooting, there is no problem with this key?
    # TODO does adding file exts as admin create keys in HKLM?
}

function Remove-FileAssocSetByUser($ext) {
    # XXX
    # TODO: TEST
    $extU = $ext.ToUpper()
    Write-Verbose "Will attempt to remove file associations that may have been manually added." # e.g. right-click and "Open with"
    Write-Verbose "Extension: $extU."

    # Added when you add a program to the "Select an app to open this .[ext] file" popup window
    # IMPROVE It isn't necesssary to try to remove this every time the function is run. See if you can find an elegant solution.
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Applications\flips.exe"
    $pathOk = Test-PathBool $keyPath
    if ($pathOk) {
        Remove-Item -Path $keyPath -Recurse -Force
        Write-VerboseRemovedKey $keyPath
    } else {
        Write-VerboseKeyNotFound $keyPath "" " This key is only added if you manually add the program to the 'Select an app to open this .$ext file' popup window."
    }

    # Added when you select to "Always" use the program for the file type
    $progId = $ext + "_auto_file"
    Remove-FileAssocInClasses $ext $progId

    # Added when you select to "Always" use the program for the file type
    # (And maybe a file needs to opened as well. I don't know because I have
    # only tried setting this trough the "Open with" context menu, which opens the
    # file immediately afterwards.)
    $exe = "flips.exe"
    $id = $ext + "_auto_file" # we must remove this value _before_ "Applications\flips.exe_.$extU" (which is removed in the next section). If we do it in reverse order, it cannot clean up, it will say that [ext]_auto_file is not set as the default handler, which would be true, it's going to be set to "Applications\flips.exe_.[ext]", never "[ext]_auto_file" in UserChoice.
    # IMPROVE Mabye add a $skipDefaultHandlerCheck parameter to the function.
    $skipUserChoice = $false # finally!
    Remove-FileAssocInFileExts $ext $exe $id $skipUserChoice

    # Added when you select to use the program "Just once" or "Always" for the file type
    $exe = "flips.exe"
    $id = "Applications\flips.exe_.$extU"
    $skipUserChoice = $true
    Remove-FileAssocInFileExts $ext $exe $id $skipUserChoice

    # Added when you select to use the program "Just once" or "Always" for the file type
    $targetValueName = "Applications\flips.exe" + "_.$ext"
    Remove-AAToast $targetValueName $extU
    
    # TODO: Make sure this isn't removed if other programs are still using the progid.
    $targetValueName = $ext + "_auto_file_." + $ext
    Remove-AAToast $targetValueName $extU
    
}

# === SECTION R-FASBP ===
# === SECTION R-FASBP ===
# === SECTION R-FASBP END ===

# LAST FUNCTION
function Remove-MuiCacheEntry() {

    
# === SECTION MUI START ===
# === SECTION MUI ===
# === SECTION MUI ===
    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"

    # very (unless I did something wrong) slow, but finds key even if installed in another location 
    <# 
    $keyPath = $keyPath.Substring("REGISTRY::".Length) ## remove prefix
        $valueData = "flips.exe"
        
        if (Test-Path -Path $keyPath -ea 0) {
        echo "let's remove value"
        Remove-RegistryValueByValueData $keyPath $valueData
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'.".Replace("REGISTRY::","")
    } #>
    
    $valueName = Join-Path $unzipDir -ChildPath "windows-x64-gui.zip\flips.exe.FriendlyAppName"
    Write-Verbose "SEARCHING FOR: value '$valueName' in '$keyPath'.".Replace("REGISTRY::", "")
    if ($keyPath -in ((Get-Item -Path $keyPath).Property)) {
        Remove-ItemProperty -Path $keyPath -Name $value
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'.".Replace("REGISTRY::", "")
        $itemsDeleted++
    }
    else {
        Write-Verbose "NOT FOUND: value '$valueName' in key '$keyPath'.".Replace("REGISTRY::", "")
    }
    # === SECTION MUI ===
    # === SECTION MUI ===
    # === SECTION MUI END ===

}

# === SECTION POST-FUNCTION START ===
# === SECTION POST-FUNCTION ===
# === SECTION POST-FUNCTION ===

Remove-FileAssocSetByProgram "bps";Write-Verbose "`n";Write-Verbose "`n";Write-Verbose "`n"
Remove-FileAssocSetByProgram "ips";Write-Verbose "`n";Write-Verbose "`n";Write-Verbose "`n"
# pause
Remove-FileAssocSetByUser("bps");Write-Verbose "`n";Write-Verbose "`n";Write-Verbose "`n"
Remove-FileAssocSetByUser("ips");Write-Verbose "`n";Write-Verbose "`n";Write-Verbose "`n"
Remove-FileAssocSetByUser("gb");Write-Verbose "`n";Write-Verbose "`n";Write-Verbose "`n"
Remove-FileAssocSetByUser("gbc");Write-Verbose "`n";Write-Verbose "`n";Write-Verbose "`n"
Remove-FileAssocSetByUser("gba");Write-Verbose "`n";Write-Verbose "`n";Write-Verbose "`n"
Remove-FileAssocSetByUser("sfc");Write-Verbose "`n";Write-Verbose "`n";Write-Verbose "`n"
Remove-FileAssocSetByUser("smc");Write-Verbose "`n";Write-Verbose "`n";Write-Verbose "`n"

Remove-MuiCacheEntry

# === SECTION POST-FUNCTION ===
# === SECTION POST-FUNCTION ===
# === SECTION POST-FUNCTION END ===

## REMOVE FILE ASSOCIATION?
## REMOVE SHORTCUTS
## ADD REMOVE SHORTCUTS TO TEMPLATE
## ADD START MENU TO TEMPLATE

## OTHER POWERSHELL FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Remove any shortcuts you added in the install script.
