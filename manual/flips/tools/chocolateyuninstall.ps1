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

function Remove-RegistryKeyPropertiesByvalueData($keyPath, $valueData) {
    $key = Get-Item -Path $keyPath
    $keyValues = $key.Property # easier to understand (for me at least)
    $found = $false
    foreach ($value in $keyValues) {
        # Get the data of the value
        $data = Get-ItemPropertyValue -Path $keyPath -Name $value

        # Check if the data matches $valueData
        if ($data -eq $valueData) {
            # Remove the value
            try {
                Remove-ItemProperty -Path $keyPath -Name $value # PowerShell bug causes error if name is '(default)' 
                Write-Verbose "REMOVED: value '$value' with data '$data' in key '$keyPath'."
                $found = $true
            }
            catch {
                if ($_.Exception.Message -match 'Property \(default\) does not exist at path*') {
                    $(Get-Item -Path $keyPath).OpenSubKey('', $true).DeleteValue('') # "(default)" actually just means empty string (Remove-ItemProperty does not accept empty string).
                    Write-Verbose "REMOVED: value '$value' with data '$data' in key '$keyPath'."
                    $found = $true
                }
                else {
                    Write-Error "An ItemNotFoundException occurred: $_"
                }
            }
        }
    }
    if ($found -eq $false) {
        Write-Verbose "NOT FOUND: value with data '$valueData' in key '$keyPath' ."
    }
}

function Write-Report($itemsDeleted, $itemsSufficient, $extraItems, $extraItemsMax) {
    Write-Verbose "Removed $itemsDeleted/$itemsSufficient sufficient items and $extraItems/$extraItemsMax' extra items."
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
        Remove-RegistryKeyPropertiesByvalueData $keyPath "FloatingIPSFile$extUC"
        $itemsDeleted++
        $key = Get-Item -Path $keyPath
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -eq 0) {
            Write-Verbose "There does NOT seems to be other programs associated with $extUC files."
            try {
                # Remove the key
                Remove-Item -Path $keyPath -Force
                Write-Verbose "REMOVED: key '$keyPath'."
                $extraItems++
            }
            catch {
                Write-Verbose "Attempt to tidy up by deleting the key '$keyPath' failed, possibly due to lacking administrative permissions. This is not an issue."
            }
        } else {
            Write-Verbose "There DOES seem to be other program(s) associated with $extUC files. Will NOT delete key '$keyPath'."
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'."
    }

    $keyPath = "REGISTRY::HKEY_CLASSES_ROOT\FloatingIPSFile$extUC"
    if (Test-Path -Path $keyPath -ea 0) {
        Remove-Item -Path $keyPath -Recurse -Force
        Write-Verbose "REMOVED: key '$keyPath'."
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'."
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax

    Write-Verbose "`n"
    Write-Verbose "Searching HKCU..."
    $itemsDeleted = 0
    $itemsSufficient = 4
    $extraItems = 0
    $extraItemsMax = 3

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "Applications\flips.exe_.$ext"
    if (Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPath -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'."
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'."
    }

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "FloatingIPSFile$extUC" + "_.$ext"
    if (Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPath -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'."
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'."
    }


    $keyPathChild1 = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext\OpenWithList"
    if (Test-Path -Path $keyPathChild1 -ea 0) {
        Remove-RegistryKeyPropertiesByvalueData $keyPathChild1 "flips.exe"
        $itemsDeleted++
        $key = Get-Item -Path $keyPathChild1
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -le 1) { # only MRUList value left
            Write-Verbose "There does NOT seems to be other programs on the ""Open with"" context menu for $extUC files."
            Remove-Item -Path $keyPathChild1
            Write-Verbose "REMOVED: key '$keyPathChild1'."
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT delete key '$keyPathChild1'."
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPathChild1'."
    }

    $keyPathChild2 = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext\OpenWithProgids"
    $valueName = "FloatingIPSFile$extUC"
    if ((Test-Path -Path $keyPathChild2 -ea 0) -And (Get-ItemProperty -Path $keyPathChild2 -Name $valueName -ea 0)) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPathChild2 -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPathChild2'."
        $itemsDeleted++
        $key = Get-Item -Path $keyPathChild2
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -le 1) { # only MRUList value left
            Write-Verbose "There does NOT seems to be other programs on the ""Open with"" context menu for $extUC files."
            # Remove key
            Remove-Item -Path $keyPathChild2
            Write-Verbose "REMOVED: key '$keyPathChild2'."
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT delete key '$keyPathChild2'."
        }
    } else {
         if (Test-Path -Path $keyPathChild2 -ea 0) {
            Write-Verbose "NOT FOUND: key '$keyPathChild2'."
        }
        if (Get-ItemProperty -Path $keyPathChild2 -Name $valueName -ea 0) {
            Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPathChild2'."
        }
    }

    $keyPathParent = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext"
    $keyPathChild1 = $keyPathChild1.Substring("REGISTRY::".Length) ## remove prefix
    $keyPathChild2 = $keyPathChild2.Substring("REGISTRY::".Length) ## remove prefix
    if (Test-Path -Path $keyPathParent -ea 0) {
        $subKeyNames = (Get-ChildItem -Path $keyPathParent).Name
        if (-Not ($keyPathChild1 -in ($subKeyNames)) -And -Not ($keyPathChild2 -in $subKeyNames)) {
            Write-Verbose "There does NOT seem to be any other program on the ""Open with"" context menu for $extUC files."
            Remove-Item -Path $keyPathParent -Recurse -Force
            Write-Verbose "REMOVED: parent key '$keyPathParent' recursively."
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT delete key '$keyPathParent'."
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPathParent'."
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax

    Write-Verbose "`n"
    Write-Verbose "Searching HKU..."
    $itemsDeleted = 0
    $itemsSufficient = 1
    $extraItems = 0
    $extraItemsMax = 1

    $user = New-Object System.Security.Principal.NTAccount($env:UserName)
    $SID = $user.Translate([System.Security.Principal.SecurityIdentifier]).value
    $SIDClasses = $($sid) + '_Classes'

    $keyPath = "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "FloatingIPSFile$extUC" + "_.$ext"
    if (Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPath -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'."
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'."
    }

    $keyPath = "REGISTRY::HKEY_USERS\$SID\Software\Clasess.$ext"
    if (Test-Path -Path $keyPath -ea 0) {
        Remove-RegistryKeyPropertiesByvalueData $keyPath "FloatingIPSFile$extUC"
        $itemsDeleted++
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -eq 0) {
            Write-Verbose "There does NOT seems to be other programs associated with $extUC files."
            Remove-Item -Path $keyPath
            Write-Verbose "REMOVED: key '$keyPath'."
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) associated with $extUC files. Will NOT delete key '$keyPath'."
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'."
    }

    $keyPath = "REGISTRY::HKEY_USERS\$SIDClasses\.$ext"
    if (Test-Path -Path $keyPath -ea 0) {
        Remove-RegistryKeyPropertiesByvalueData $keyPath "FloatingIPSFile$extUC"
        $itemsDeleted++
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -eq 0) {
            Write-Verbose 'There does NOT seems to be other programs associated with $extUC files.'
            Remove-Item -Path $keyPath
            Write-Verbose "REMOVED: key '$keyPath'."
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) associated with $extUC files. Will NOT delete key '$keyPath'."
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'."
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax

    Pause

}


function Clear-FileAssocRomFile($ext) {
    $extUC = $ext.ToUpper() # upper-case
    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose "Attempting to remove Flips file association for $extUC..."

    Write-Verbose "`n"
    Write-Verbose "Searching HKCU..."
    $itemsDeleted = 0
    $itemsSufficient = 3
    $extraItems = 0
    $extraItemsMax = 0

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "Applications\flips.exe_.$ext"
    if (Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPath -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'."
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'."
    }

    $keyPath   = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\" + $ext + "_auto_file\shell\open\command"
    $keyPath2  = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\" + $ext + "_auto_file"
    $valueData = '"C:\ProgramData\chocolatey\lib\flips\tools\builds\windows-x64-gui.zip\flips.exe" "%1"'
    if (Test-Path -Path $keyPath -ea 0) {
        $key = Get-Item -Path $keyPath
        $keyValues = $key.Property # easier to understand (for me at least)
        $found = $false
        foreach ($value in $keyValues) {
            # Get the data of the value
            $data = Get-ItemPropertyValue -Path $keyPath -Name $value

            # Check if the data matches $valueData
            if ($data -eq $valueData) {
                
                # Remove its parent keys
                $found = $true
                Write-Verbose "Found data '$valueData' in key '$keyPath2'."
                Remove-Item -Path $keyPath2 -Recurse -Force
                Write-Verbose "REMOVED: parent key '$keyPath2' recursively."
                $itemsDeleted++

            }
        }
        if ($found -eq $false) {
            Write-Verbose "NOT FOUND: value with data '$valueData' in key '$keyPath' ."
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'."
    }
    
    $keyPath   = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = $ext + "_auto_file_." + $ext
    if (Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPath -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'."
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'."
    }


    $keyPathChild1 = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext\OpenWithList"
    if (Test-Path -Path $keyPathChild1 -ea 0) {
        # Remove this value in this key
        Remove-RegistryKeyPropertiesByvalueData $keyPathChild1 "flips.exe"
        $itemsDeleted++
        $key = Get-Item -Path $keyPathChild1
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -le 1) { # only MRUList value left
            Write-Verbose "There does NOT seems to be other programs on the ""Open with"" context menu for $extUC files."
            # Remove the key
            Remove-Item -Path $keyPathChild1
            Write-Verbose "REMOVED: key '$keyPathChild1'."
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT delete key '$keyPathChild1'."
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPathChild1'."
    }

    $keyPathChild2 = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext\OpenWithProgids"
    $valueName = $ext + "_auto_file"
    if ((Test-Path -Path $keyPathChild2 -ea 0) -And (Get-ItemProperty -Path $keyPathChild2 -Name $valueName -ea 0)) {
        # Remove this value in this key
        Remove-ItemProperty -Path $keyPathChild2 -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPathChild2'."
        $itemsDeleted++
        $key = Get-Item -Path $keyPathChild2
        $keyValues = $key.Property
        $valueCount = $($keyValues.Count)
        if ($valueCount -le 1) { # only MRUList value left
            Write-Verbose "There does NOT seem to be any other program on the ""Open with"" context menu for $extUC files."
            # Remove the key
            Remove-Item -Path $keyPathChild2
            Write-Verbose "REMOVED: key '$keyPathChild2'."
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT delete key '$keyPathChild2'."
        }
    } else {
        if (Test-Path -Path $keyPathChild2 -ea 0) {
            Write-Verbose "NOT FOUND: key '$keyPathChild2'."
        }
        if (Get-ItemProperty -Path $keyPathChild2 -Name $valueName -ea 0) {
            Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPathChild2'."
        }
    }

    $keyPathParent = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.$ext"
    $keyPathChild1 = $keyPathChild1.Substring("REGISTRY::".Length) ## remove prefix
    $keyPathChild2 = $keyPathChild2.Substring("REGISTRY::".Length) ## remove prefix
    if (Test-Path -Path $keyPathParent -ea 0) {
        $subKeyNames = (Get-ChildItem -Path $keyPathParent).Name
        if (-Not ($keyPathChild1 -in ($subKeyNames)) -And -Not ($keyPathChild2 -in $subKeyNames)) {
            Write-Verbose "There does NOT seem to be any other program on the ""Open with"" context menu for $extUC files."
            # Remove the key
            Remove-Item -Path $keyPathParent -Recurse -Force
            Write-Verbose "REMOVED: parent key '$keyPathParent' recursively."
            $extraItems++
        } else {
            Write-Verbose "There DOES seem to be other program(s) on the ""Open with"" context menu for $extUC files. Will NOT delete key '$keyPathParent'."
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPathChild1'."
    }

    Pause

}

function Clear-RemainingKeys() {
    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose "`n"
    Write-Verbose 'Attempting to remove flips.exe from the "Open with" menu...'
    Write-Verbose "`n"
    Write-Verbose "Searching HKCR..."
    $itemsDeleted = 0
    $itemsSufficient = 1
    $extraItems = 0
    $extraItemsMax = 0
    $keyPath = "REGISTRY::HKEY_CLASSES_ROOT\Applications\flips.exe"
    if (Test-Path -Path $keyPath -ea 0) {
        Remove-Item -Path $keyPath -Recurse -Force
        Write-Verbose "REMOVED: key '$keyPath'."
        $itemsDeleted++
    }
    else {
        Write-Verbose "NOT FOUND: key '$keyPath'."
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
    $valueData = "flips.exe"
    if (Test-Path -Path $keyPath -ea 0) {
        Remove-RegistryKeyPropertiesByvalueData $keyPath $valueData
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'."
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

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\ips_auto_file\shell\open\command"
    $valueData = '"C:\ProgramData\chocolatey\lib\flips\tools\builds\windows-x64-gui.zip\flips.exe" "%1"'
    $keyPath2 = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\ips_auto_file"
    
    if (Test-Path -Path $keyPath -ea 0) {
        $key = Get-Item -Path $keyPath
        $keyValues = $key.Property # easier to understand (for me at least)
        $found = $false
        foreach ($value in $keyValues) {
            # Get the data of the value
            $data = Get-ItemPropertyValue -Path $keyPath -Name $value

            # Check if the data matches $valueData
            if ($data -eq $valueData) {
                
                # Remove its parent keys
                Write-Verbose "Found data '$valueData' in key '$keyPath'."
                Remove-Item -Path $keyPath2 -Recurse -Force
                Write-Verbose "REMOVED: parent key '$keyPath' recursively."
                $found = $true
                $itemsDeleted++
                
            }
        }
        if ($found -eq $false) {
            Write-Verbose "NOT FOUND: value with data '$valueData' in key '$keyPath'."
        }
    } else {
        Write-Verbose "NOT FOUND: key '$keyPath'."
    }

    $keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts"
    $valueName = "ips_auto_file_.ips"
    if (Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) {
        Remove-ItemProperty -Path $keyPath -Name $valueName
        Write-Verbose "REMOVED: value '$valueName' in key '$keyPath'."
        $itemsDeleted++
    } else {
        Write-Verbose "NOT FOUND: value with name '$valueName' in key '$keyPath'."
    }

    Write-Report $itemsDeleted $itemsSufficient $extraItems $extraItemsMax

    Pause

}


Clear-FileAssocPatchFile "bps"
Clear-FileAssocPatchFile "ips"
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
