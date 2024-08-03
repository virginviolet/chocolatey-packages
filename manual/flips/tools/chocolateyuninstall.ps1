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

enum AutoFile {
    Unset
    OnlyFlips
    NotOnlyFlips
}

# variables for better readability
$Unset = [AutoFile]::Unset
$OnlyFlips = [AutoFile]::OnlyFlips
$NotOnlyFlips = [AutoFile]::NotOnlyFlips


function Remove-RegistryValuesByValueData($keyPath, $valueData) {
    $key = Get-Item -Path $keyPath
    $keyValues = $key.Property # easier to understand (for me at least)
    $found = $false
    foreach ($value in $keyValues) {
        $data = Get-ItemPropertyValue -Path $keyPath -Name $value # Get the data of the value

        if ($data -eq $valueData) { # Check if the data matches $valueData

            # Remove the value
            try {
                Remove-ItemProperty -Path $keyPath -Name $value # PowerShell bug causes error if name is '(default)' 
                Write-Verbose "REMOVED: value '$value' with data '$data' in key '$keyPath'.".Replace("REGISTRY::","")
                $found = $true
            }
            catch {
                if ($_.Exception.Message -match 'Property \(default\) does not exist at path*') {
                    $(Get-Item -Path $keyPath).OpenSubKey('', $true).DeleteValue('') # "(default)" actually just means empty string (Remove-ItemProperty does not accept empty string).
                    Write-Verbose "REMOVED: value '$value' with data '$data' in key '$keyPath'.".Replace("REGISTRY::","")
                    $found = $true
                }
                else {
                    Write-Error "An ItemNotFoundException occurred: $_"
                }
            }
        }
    }
    if ($found -eq $false) {
        Write-Verbose "NOT FOUND: value with data '$valueData' in key '$keyPath' .".Replace("REGISTRY::","")
    }
}

function Write-Report($itemsDeleted, $itemsSufficient, $extraItems, $extraItemsMax) {
    Write-Verbose "Removed $itemsDeleted/$itemsSufficient sufficient items and $extraItems/$extraItemsMax extra items."
}

function Clear-FileAssocPatchFile($ext) {
    $extUC = $ext.ToUpper() # upper-case

    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose "Attempting to remove Flips file association for $extUC..."

    Write-Verbose "`n"
    Write-Verbose "Searching HKCR..."
    $itemsDeleted = 0
    $itemsSufficient = 2
    $extraItems = 0
    $extraItemsMax = 1

    $keyPath = "REGISTRY::HKEY_CLASSES_ROOT\.$ext"
    if (Test-Path -Path $keyPath -ea 0) {
        Remove-RegistryValuesByValueData $keyPath "FloatingIPSFile$extUC"
        $itemsDeleted++
        $key = Get-Item -Path $keyPath
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -eq 0) {
            Write-Verbose "There does NOT seem to be other programs associated with $extUC files."
            try {
                # Remove the key
                Remove-Item -Path $keyPath -Force
                Write-Verbose "REMOVED: key '$keyPath'.".Replace("REGISTRY::","")
                $extraItems++
            }
            catch {
                Write-Verbose "Attempt to tidy up by deleting the key '$keyPath' failed, possibly due to lacking permissions (if Chocolatey is not running in an elevated shell). This is not an issue.".Replace("REGISTRY::","")
            }
        } else {
            Write-Verbose "There DOES seem to be other program(s) associated with $extUC files. Will NOT remove key '$keyPath'.".Replace("REGISTRY::","")
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'.".Replace("REGISTRY::","")
    }

    $keyPath = "REGISTRY::HKEY_CLASSES_ROOT\FloatingIPSFile$extUC"
    if (Test-Path -Path $keyPath -ea 0) {
        Remove-Item -Path $keyPath -Recurse -Force
        Write-Verbose "REMOVED: key '$keyPath'.".Replace("REGISTRY::","")
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'.".Replace("REGISTRY::","")
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax

    Write-Verbose "`n"
    Write-Verbose "Searching HKCU..."
    $itemsDeleted = 0
    $itemsSufficient = 4
    $extraItems = 0
    $extraItemsMax = 5

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "Applications\flips.exe_.$ext"
    if (Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPath -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
    }

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "FloatingIPSFile$extUC" + "_.$ext"
    if (Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPath -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
    }

    $keyPathChild1 = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext\OpenWithList"
    $valueData = "flips.exe"
    if (Test-Path -Path $keyPathChild1 -ea 0) {
        Remove-RegistryValuesByValueData $keyPathChild1 $valueData
        $itemsDeleted++
        $key = Get-Item -Path $keyPathChild1
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -le 1) { # only MRUList value left
            Write-Verbose "There does NOT seem to be other programs on the ""Open with"" context menu for $extUC files."
            Remove-Item -Path $keyPathChild1
            Write-Verbose "REMOVED: key '$keyPathChild1'.".Replace("REGISTRY::","")
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT remove key '$keyPathChild1'.".Replace("REGISTRY::","")
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPathChild1'.".Replace("REGISTRY::","")
    }

    $keyPathChild2 = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext\OpenWithProgids"
    $valueName = "FloatingIPSFile$extUC"
    if ((Test-Path -Path $keyPathChild2 -ea 0) -And ` #if key exists and
        (Get-ItemProperty -Path $keyPathChild2 -Name $valueName -ea 0)) { # has this value
        # Remove the value
        Remove-ItemProperty -Path $keyPathChild2 -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPathChild2'.".Replace("REGISTRY::","")
        $itemsDeleted++
        $key = Get-Item -Path $keyPathChild2
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -le 1) { # only MRUList value left
            Write-Verbose "There does NOT seem to be other programs on the ""Open with"" context menu for $extUC files."
            # Remove key
            Remove-Item -Path $keyPathChild2
            Write-Verbose "REMOVED: key '$keyPathChild2'.".Replace("REGISTRY::","")
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT remove key '$keyPathChild2'.".Replace("REGISTRY::","")
        }
    } else {
         if (Test-Path -Path $keyPathChild2 -ea 0) {
            Write-Verbose "NOT FOUND: key '$keyPathChild2'.".Replace("REGISTRY::","")
        }
        if (Get-ItemProperty -Path $keyPathChild2 -Name $valueName -ea 0) {
            Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPathChild2'.".Replace("REGISTRY::","")
        }
    }

    $keyPathChild3 = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext\UserChoice"
    $valueName = "ProgId"
    $valueData = "Applications\flips.exe"
    # if key exists and the value name "ProgId" has data that directs to Flips, which means Flips is the preferred program by the user for this file extension.
    if ((Test-Path -Path $keyPathChild3 -ea 0) -And ((Get-ItemPropertyValue -Path $keyPathChild3 -name $valueName -ea 0) -eq $valueData)) {
        try {
            # Remove the key
            Remove-Item -Path $keyPathChild3 -Force
            Write-Verbose "REMOVED: key '$keyPathChild3'.".Replace("REGISTRY::","")
            $extraItems++
        }
        catch {
            Write-Verbose "Attempt to tidy up by deleting the key '$keyPathChild3' failed, possibly due to lacking permissions (if Chocolatey is not running in an elevated shell). This is not an issue.".Replace("REGISTRY::","")
        }
    } elseif (-Not (Test-Path -Path $keyPathChild3 -ea 0)) {
            Write-Verbose "NOT FOUND: key '$keyPathChild3'.".Replace("REGISTRY::","")
    } elseif ((Get-ItemPropertyValue -Path $keyPathChild3 -name "ProgId" -ea 0) -ne "Applications\flips.exe") {
        Write-Verbose "Value '$valueName' in key '$keyPathChild3' does not have the data '$valueData', because $extUC files are not set to always run with Flips.".Replace("REGISTRY::","")
        $extraItems++
    }
    
    $keyPathParent = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext"
    $keyPathChild1 = $keyPathChild1.Substring("REGISTRY::".Length) ## remove prefix
    $keyPathChild2 = $keyPathChild2.Substring("REGISTRY::".Length) ## remove prefix
    if (Test-Path -Path $keyPathParent -ea 0) {
        $subKeyNames = (Get-ChildItem -Path $keyPathParent).Name
        if (-Not ($keyPathChild1 -in ($subKeyNames)) -And -Not ($keyPathChild2 -in $subKeyNames)) {
            Write-Verbose "There does NOT seem to be any other program(s) on the ""Open with"" context menu for $extUC files."
            try {
                # Remove the key
                Remove-Item -Path $keyPathParent -Recurse -Force
                Write-Verbose "REMOVED: parent key '$keyPathParent' recursively.".Replace("REGISTRY::","")
                $extraItems++
            }
            catch {
                Write-Verbose "Attempt to tidy up by deleting the key '$keyPathParent' failed, possibly due to lacking permissions (if Chocolatey is not running in an elevated shell). This is not an issue.".Replace("REGISTRY::","")
            }
        } else {
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT remove key '$keyPathParent'.".Replace("REGISTRY::","")
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPathParent'.".Replace("REGISTRY::","")
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax

    Write-Verbose "`n"
    Write-Verbose "Searching HKU..."
    $itemsDeleted = 0
    $itemsSufficient = 3
    $extraItems = 0
    $extraItemsMax = 2

    $user = New-Object System.Security.Principal.NTAccount($env:UserName)
    $SID = $user.Translate([System.Security.Principal.SecurityIdentifier]).value
    $SIDClasses = $($sid) + '_Classes'

    $keyPath = "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "FloatingIPSFile$extUC" + "_.$ext"
    if (Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPath -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
    }

    $keyPath = "REGISTRY::HKEY_USERS\$SID\Software\Classes\.$ext"
    if (Test-Path -Path $keyPath -ea 0) {
        Remove-RegistryValuesByValueData $keyPath "FloatingIPSFile$extUC"
        $itemsDeleted++
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -eq 0) {
            Write-Verbose "There does NOT seem to be other programs associated with $extUC files."
            Remove-Item -Path $keyPath
            Write-Verbose "REMOVED: key '$keyPath'.".Replace("REGISTRY::","")
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) associated with $extUC files. Will NOT remove key '$keyPath'.".Replace("REGISTRY::","")
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'.".Replace("REGISTRY::","")
    }

    $keyPath = "REGISTRY::HKEY_USERS\$SIDClasses\.$ext"
    if (Test-Path -Path $keyPath -ea 0) {
        Remove-RegistryValuesByValueData $keyPath "FloatingIPSFile$extUC"
        $itemsDeleted++
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -eq 0) {
            Write-Verbose 'There does NOT seem to be other programs associated with $extUC files.'
            Remove-Item -Path $keyPath
            Write-Verbose "REMOVED: key '$keyPath'.".Replace("REGISTRY::","")
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) associated with $extUC files. Will NOT remove key '$keyPath'.".Replace("REGISTRY::","")
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'.".Replace("REGISTRY::","")
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax

}


function Clear-FileAssocRomFile($ext) {
    $extUC = $ext.ToUpper() # upper-case
    $autoFileItem1 = $Unset # initialize variable; refers to '"REGISTRY::HKEY_CURRENT_USER\Software\Classes\[.ext]_auto_file"'; if both 1 and 2 turn true, that means it's safe to remove certain items
    $autoFileItem2 = $Unset # initialize variable; refers to 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\[.ext]\'; if both 1 and 2 turn true, that means it's safe to remove certain items
    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose "Attempting to remove Flips file association for $extUC..."

    Write-Verbose "`n"
    Write-Verbose "Searching HKCU..."
    $itemsDeleted = 0
    $itemsSufficient = 5
    $extraItems = 0
    $extraItemsMax = 5

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "Applications\flips.exe_.$ext"
    if (Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPath -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
    }

    $keyPath         = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\" + $ext + "_auto_file\shell\open\command"
    $keyPath2        = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\" + $ext + "_auto_file"
    $valueData       = '"C:\ProgramData\chocolatey\lib\flips\tools\builds\windows-x64-gui.zip\flips.exe" "%1"'
    if (Test-Path -Path $keyPath -ea 0) {
        $key = Get-Item -Path $keyPath
        $keyValues = $key.Property # easier to understand (for me at least)
        $found = $false
        foreach ($value in $keyValues) { # interate values
            # Get the data of the value
            $data = Get-ItemPropertyValue -Path $keyPath -Name $value

            # Check if the data matches $valueData
            if ($data -eq $valueData) {
                
                # Remove its parent keys
                $found = $true
                Write-Verbose "Found data '$valueData' in key '$keyPath2'.".Replace("REGISTRY::","")
                Remove-Item -Path $keyPath2 -Recurse -Force
                Write-Verbose "REMOVED: parent key '$keyPath2' recursively.".Replace("REGISTRY::","")
                $autoFileItem1 = $OnlyFlips # this is actually binary here, $autoFileItem1 cannot be NotOnlyFlips; I could use boolean, but I'm trying to make the code as readable
                $itemsDeleted++
                break
            }
        }
        if ($found -eq $false) {
            Write-Verbose "NOT FOUND: value with data '$valueData' in key '$keyPath' .".Replace("REGISTRY::","")
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'.".Replace("REGISTRY::","")
    }

    $keyPathChild1   = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext\OpenWithList"
    $valueData = "flips.exe"
    if (Test-Path -Path $keyPathChild1 -ea 0) {
        # Remove this value in this key
        Remove-RegistryValuesByValueData $keyPathChild1 $valueData
        $itemsDeleted++
        $key = Get-Item -Path $keyPathChild1
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -le 1) { # only MRUList value left
            Write-Verbose "There does NOT seem to be other programs on the ""Open with"" context menu for $extUC files."
            # Remove the key
            Remove-Item -Path $keyPathChild1
            Write-Verbose "REMOVED: key '$keyPathChild1'.".Replace("REGISTRY::","")
            $autoFileItem2 = $OnlyFlips # it seems like only Flips was using the auto_file handler
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT remove key '$keyPathChild1'.".Replace("REGISTRY::","")
            $autoFileItem2 = $NotOnlyFlips
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPathChild1'.".Replace("REGISTRY::","")
    }

    $keyPathChild2 = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext\OpenWithProgids"
    $valueName = $ext + "_auto_file"
    $pathOk = [bool](Test-Path -Path $keyPathChild2 -ea 0)
    $foundValue = [bool](Get-ItemProperty -Path $keyPathChild2 -Name $valueName -ea 0)
    
    # Because this section only removes the generic auto_file handler, we only continue if Flips was the last and only program on the "Open With" context menu.
    # OnlyFlips - Keys no longer important and (unless something went wrong) have been removed - safe to continue 
    # Unset - OpenWithList key doesn't exist - safe to continue
    # NotOnlyFlips - Keys still relevant for other programs - don't continue
    if (-Not ($pathOk)) {
        Write-Verbose "NOT FOUND: key '$keyPathChild2'.".Replace("REGISTRY::","")
    }
    if (($autoFileItem2 -eq $NotOnlyFlips) -And ($pathOk)) {
        Write-Verbose "Will NOT remove key '$keyPathChild2', because it seems to be associated with another program.".Replace("REGISTRY::","")
    }
    if (($autoFileItem2 -ne $NotOnlyFlips) -And ($pathOk) -And ($foundValue)) { # found value $valueName in $keyPathChild2
        # Remove the value we found
        Remove-ItemProperty -Path $keyPathChild2 -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPathChild2'.".Replace("REGISTRY::","")
        $itemsDeleted++
        $key = Get-Item -Path $keyPathChild2
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -eq 0) { # if there are no values left here (because we removed the last one)
            Write-Verbose "There does NOT seem to be any other program(s) on the ""Open with"" context menu for $extUC files."
            # Remove the now empty key
            Remove-Item -Path $keyPathChild2
            Write-Verbose "REMOVED: key '$keyPathChild2'.".Replace("REGISTRY::","")
            $extraItems++
        } else { # other handlers than auto_file found
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT remove key '$keyPathChild2'.".Replace("REGISTRY::","")
            # I guess we can still go ahead and remove the auto_ips handler, so let's set $autoFileItem2 = OnlyFlips, which means "ok to remove (or removed, if removed)" (sorry for confusion).
            # @TODO Better name for the states
            
        }
    }

    $keyPathChild3 = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext\UserChoice"
    $valueName = "ProgId"
    $valueData = "Applications\flips.exe"
    # if key exists and the value name "ProgId" has data that links to Flips, i.e. Flips is the preferred program by the user for this file extension.
    if ((Test-Path -Path $keyPathChild3 -ea 0) -And `
    ((Get-ItemPropertyValue -Path $keyPathChild3 -name $valueName -ea 0) -eq $valueData)) {
        try {
            # Remove the key
            Remove-Item -Path $keyPathChild3 -Force
            Write-Verbose "REMOVED: key '$keyPathChild3'.".Replace("REGISTRY::","")
            $extraItems++
        }
        catch {
            Write-Verbose "Attempt to tidy up by deleting the key '$keyPathChild3' failed, possibly due to lacking permissions (if Chocolatey is not running in an elevated shell). This is not an issue."
        }
    } elseif (-Not (Test-Path -Path $keyPathChild3 -ea 0)) {
            Write-Verbose "NOT FOUND: key '$keyPathChild3'.".Replace("REGISTRY::","")
    } elseif ((Get-ItemPropertyValue -Path $keyPathChild3 -name "ProgId" -ea 0) -ne "Applications\flips.exe") {
        Write-Verbose "Value '$valueName' in key '$keyPathChild3' does not have the data '$valueData', because $extUC files are set to always run with another program than Flips.".Replace("REGISTRY::","")
        $extraItems++
    }

    $keyPathParent = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext"
    $keyPathChild1 = $keyPathChild1.Substring("REGISTRY::".Length) ## remove prefix
    $keyPathChild2 = $keyPathChild2.Substring("REGISTRY::".Length) ## remove prefix
    $pathOk = (Test-Path -Path $keyPathParent -ea 0)

    # We clean up by removing this key if it is empty
    # OnlyFlips - Subkeys no longer important and (unless something went wrong) have been removed - safe to continue
    # Unset - Subkeys didn't exist in the first place - safe to continue
    # NotOnlyFlips - Key still relevant for other programs - don't continue
    if (($autoFileItem2 -ne $NotOnlyFlips) -And ` # If only Flips was using these keys
    ($pathOk)) {
        $subKeyNames = (Get-ChildItem -Path $keyPathParent).Name #  Should only have one, two, or all three of these: OpenWithList, OpenWithProgids, UserChoice
        if (-Not ($keyPathChild1 -in ($subKeyNames)) -And ` # if this subkey doesn't exist (because we removed it) 
        -Not ($keyPathChild2 -in $subKeyNames)) { # and neither this one (because we removed it)
            Write-Verbose "There does NOT seem to be any other program(s) on the ""Open with"" context menu for $extUC files."
            try {
                # Remove the parent key (autoFileItem2), because it serves no purpose anymore
                Remove-Item -Path $keyPathParent -Recurse -Force
                Write-Verbose "REMOVED: parent key '$keyPathParent' recursively.".Replace("REGISTRY::","")
                $extraItems++
            }
            catch {
                Write-Verbose "Attempt to tidy up by deleting the key '$keyPathParent' failed, possibly due to lacking permissions (if Chocolatey is not running in an elevated shell). This is not an issue.".Replace("REGISTRY::","")
            }
        } else { # I don't know if it's actually possible to get here, unless something goes wrong. I _think_ the $autoFileItem2 check should have been enough.
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files."
            Write-Verbose "Will NOT remove parent key '$keyPathParent', because it still has the subkeys '$keyPathChild1' and '$keyPathChild2'.".Replace("REGISTRY::","")
        }
    } elseif ($autoFileItem2 -eq $NotOnlyFlips) {
        Write-Verbose "Will NOT remove key '$keyPathParent', because other program(s) are still associated with it.".Replace("REGISTRY::","")
    } elseif (-Not ($pathOk)){
        Write-Verbose "NOT FOUND: key '$keyPathParent'.".Replace("REGISTRY::","")
    } else { # I think it is logically impossible to get here.
        Write-Warning "Something unexpected happen. autoFileItem2: '$autoFileItem2'. pathOk: '$pathOk'."
    }

    # TODO: DON'T remove THIS VALUE IF AUTO FILE IS USED BY OTHER PROGRAM
    # TODO elseif
    $keyPath   = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = $ext + "_auto_file_." + $ext
    $found = $false # initialize the variable
    # OnlyFlips - Handler no longer in use and (unless something went wrong) have been removed - safe to continue
    # Unset - Handler didn't exist in the first place - safe to continue
    # NotOnlyFlips - The auto_file handler is still relevant for other programs - don't continue
    if (($autoFileItem1 -ne $NotOnlyFlips) -And ` # Unless we found that this and...
    ($autoFileItem2 -ne $NotOnlyFlips)) {
        $found = [bool](Get-ItemProperty -Path $keyPath -Name $valueName -ea 0)
    } else {
        Write-Verbose "Will NOT remove value '$valueName' in key '$keyPath', because other program(s) are still associated with that value."
    }
    if ($found) {
        Remove-ItemProperty -Path $keyPath -Name $valueName # Remove the value
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax
}

function Clear-RemainingKeys() {
    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose 'Attempting to remove flips.exe from the "Open with" digalog...'
    Write-Verbose "`n"
    Write-Verbose "Searching HKCR..."
    $auto
    $itemsDeleted = 0
    $itemsSufficient = 1
    $extraItems = 0
    $extraItemsMax = 0
    $keyPath = "REGISTRY::HKEY_CLASSES_ROOT\Applications\flips.exe"
    if (Test-Path -Path $keyPath -ea 0) {
        Remove-Item -Path $keyPath -Recurse -Force
        Write-Verbose "REMOVED: key '$keyPath'.".Replace("REGISTRY::","")
        $itemsDeleted++
    }
    else {
        Write-Verbose "NOT FOUND: key '$keyPath'.".Replace("REGISTRY::","")
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax

    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose 'Attempting to remove flips.exe the MUI Cache...'
    Write-Verbose "`n"
    Write-Verbose "Searching HKCR..."
    $itemsDeleted = 0
    $itemsSufficient = 1
    $extraItems = 0
    $extraItemsMax = 0

    $keyPath = "REGISTRY::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"

    # very (unless I did something wrong) slow, but finds key even if installed in another location 
    <# 
    $keyPath = $keyPath.Substring("REGISTRY::".Length) ## remove prefix
        $valueData = "flips.exe"
        
        if (Test-Path -Path $keyPath -ea 0) {
        echo "let's remove value"
        Remove-RegistryValuesByValueData $keyPath $valueData
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'.".Replace("REGISTRY::","")
    } #>
    
    $valueName = Join-Path $unzipDir -ChildPath "windows-x64-gui.zip\flips.exe.FriendlyAppName"
    Write-Verbose "SEARCHING FOR: value '$valueName' in '$keyPath'.".Replace("REGISTRY::","")
    if ($keyPath -in ((Get-Item -Path $keyPath).Property)) {
        Remove-ItemProperty -Path $keyPath -Name $value
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value '$valueName' in key '$keyPath'.".Replace("REGISTRY::","")
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax

    Write-Verbose "`n"
    Write-Verbose "Attempting to remove remaining file type handler..."
    Write-Verbose "`n"
    Write-Verbose "Searching HKCU..."
    $itemsDeleted = 0
    $itemsSufficient = 2
    $extraItems = 0
    $extraItemsMax = 0

    # Not included in Clean-FileAssocPatchFile because I haven't seen 'bps_auto_file' in this location, only 'ips_auto_file'.
    $keyPathChild = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\ips_auto_file\shell\open\command"
    $valueData = '"C:\ProgramData\chocolatey\lib\flips\tools\builds\windows-x64-gui.zip\flips.exe" "%1"'
    $keyPathParent = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\ips_auto_file"
    $autoFile1 = 'unset'  # initialize variable
    if (Test-Path -Path $keyPathChild -ea 0) {
        $key = Get-Item -Path $keyPathChild
        $keyValues = $key.Property # easier to understand (for me at least)
        foreach ($value in $keyValues) {
            $data = Get-ItemPropertyValue -Path $keyPathChild -Name $value # Get the data of the value
            if ($data -eq $valueData) { # Check if the data matches $valueData
                Write-Verbose "Found data '$valueData' in key '$keyPathChild'.".Replace("REGISTRY::","")
                Remove-Item -Path $keyPathParent -Recurse -Force # Remove relevant parent keys
                Write-Verbose "REMOVED: parent key '$keyPathChild' recursively.".Replace("REGISTRY::","")
                $autoFile1 = 'flips'
                $itemsDeleted++
                break
            }
        }
        if ($removeAutoFile -eq $false) {
            Write-Verbose "NOT FOUND: value with data '$valueData' in key '$keyPathChild.".Replace("REGISTRY::","")
            $autoFile1 = 'not_flips'
        }
    } else {
        if (-Not (Test-Path -Path $keyPathParent -ea 0)){
            Write-Verbose "NOT FOUND: key '$keyPathParent'. Will NOT attempt to investigate its non-existing subkey '$keyPathChild'.".Replace("REGISTRY::","")
        }
        else {
            Write-Verbose "NOT FOUND: key '$keyPathChild'.".Replace("REGISTRY::","")
        }
    }
    
    $keyPathAutoFile2 = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "ips_auto_file_.ips"
    if (($autoFile1 -ne 'not_flips') -And ` # Don't continue if another application is using the aute_file key, and
    (Get-ItemProperty -Path $keyPathAutoFile2 -Name $valueName -ea 0)) { # this key has this value
        Remove-ItemProperty -Path $keyPathAutoFile2 -Name $valueName # Remove the value
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPathAutoFile2'.".Replace("REGISTRY::","")
        $itemsDeleted++
    } elseif ($autoFile1 -eq 'not_flips') {
        Write-Verbose "Will NOT remove because it seems to be associated with another program: key '$keyPathAutoFile2'.".Replace("REGISTRY::","")
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPathAutoFile2'.".Replace("REGISTRY::","") # Did not find autoFile1 nor autoFlie2
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax

}


Clear-FileAssocPatchFile "bps"
Clear-FileAssocPatchFile "ips"
# pause
Clear-FileAssocRomFile "gb"
Clear-FileAssocRomFile "gbc"
Clear-FileAssocRomFile "gba"
Clear-FileAssocRomFile "sfc"
Clear-FileAssocRomFile "smc"
Clear-RemainingKeys

## REMOVE FILE ASSOCIATION?
## REMOVE SHORTCUTS
## ADD REMOVE SHORTCUTS TO TEMPLATE
## ADD START MENU TO TEMPLATE

## OTHER POWERSHELL FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Remove any shortcuts you added in the install script.
