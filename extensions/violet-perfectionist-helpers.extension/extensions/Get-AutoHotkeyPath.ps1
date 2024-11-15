function Get-AutoHotkeyPath {
    <#
        .SYNOPSIS
        Retrieves the path to an AutoHotkey executable.

        .DESCRIPTION
        This function retrieves the path to an AutoHotkey executable.  
        autohotkey.portable is prioritized over other AutoHotkey installations.

        .EXAMPLE
        $autoHotkeyPath = Get-AutoHotkeyPath
        Retrieves the AutoHotkey executable path.
    #>
    
    function Get-AutoHotkeyExePath {
        <#
            .SYNOPSIS
            Retrieves the path to the AutoHotkey executable.

            .DESCRIPTION
            Searches for the AutoHotkey executable in the specified installation directory.
            It checks for various common AutoHotkey executable names and returns the path
            to the first executable it finds.
        #>
        param (
            # Directory to search in
            [Alias("Path")]
            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory = $true)]
            [string]
            $InstallDirPath
        )
        $executables = @(
            'AutoHotkey.exe'
            'AutoHotkeyU64.exe'
            'AutoHotkeyA64.exe'
            'AutoHotkeyU32.exe'
            'AutoHotkeyA32.exe'
        )
        foreach ($executable in $executables) {
            Write-Debug "Looking for '$executable' in '$InstallDirPath'..."
            $autoHotKeyExePath = Join-Path -Path $InstallDirPath -ChildPath $executable
            if (Test-Path -Path $autoHotKeyExePath -PathType Leaf) {
                # Write-Debug "AutoHotkey EXE found at '$autoHotKeyExePath'."
                # Write-Debug "'$autoHotKeyExePath' found."
                return $autoHotKeyExePath
            }
        }
        Write-Debug "AutoHotkey executable not found in '$InstallDirPath'."
    }

    # IMPROVE Make it possible to prioritize v1 or v2
    Write-Debug "Running Get-AutoHotkeyPath..."
    Write-Debug "Getting AutoHotkey path..."
    # Look for autohotkey.portable
    $autoHotKeyPortableInstalled = "$(Choco List -LimitOutput -Exact -By-Id-Only autohotkey.portable)"
    if ($autoHotKeyPortableInstalled) {
        Write-Debug "autohotkey.portable found."
        try {
            $chocolateyDirPath = $Env:ChocolateyInstall
            $libPath = Join-Path -Path $chocolateyDirPath -ChildPath 'lib'

            $autoHotKeyPath = Convert-Path -Path "$LibPath\autohotkey.portable\tools\AutoHotkey.exe"
            Write-Debug "AutoHotkey found at '$autoHotKeyPath'."
            Write-Debug "Get-AutoHotkeyPath has finished."
            return $autoHotKeyPath
        } catch [System.Management.Automation.CommandNotFoundException] {
            Write-Warning "AutoHotkey not found. Please reinstall autohotkey.portable.`n$_"
            $autoHotKeyPortableFailed = $true
        } catch {
            Write-Warning "Could not get AutoHotkey path`n$_"
            $autoHotKeyPortableFailed = $true
        }
    }
    if (-not $autoHotKeyPortableInstalled -or ($autoHotKeyPortableFailed)) {
        # Look for autohotkey.install
        $autoHotKeyInstallInstalled = "$(Choco List -LimitOutput -Exact -By-Id-Only autohotkey.install)"
        if ($autoHotKeyInstallInstalled) {
            Write-Debug "autohotkey.install found."
        } else {
            Write-Error "AutoHotkey not found."
        }
    }
    try {
        # Find the installation path
        # Look in the registry
        $regKeyPath = "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\AutoHotkey"
        $regKeyValueName = "InstallDir"
        Write-Debug "Looking for AutoHotkey path in registry key '$regKeyPath'...".Replace("REGISTRY::", "")
        $installDir = Get-ItemPropertyValue -Path $regKeyPath -Name $regKeyValueName
        $installDirExists = Test-Path -Path $installDir -PathType Container
        if ($installDirExists) {
            Write-Debug "AutoHotkey installation directory path '$installDir' found in the registry."
            $autoHotKeyPath = Get-AutoHotkeyExePath -InstallDirPath $installDir
            if ($autoHotKeyPath) {
                Write-Debug "AutoHotkey found at '$autoHotKeyPath'."
                Write-Debug "Get-AutoHotkeyPath has finished."
                return $autoHotKeyPath
            }
        }
    } catch [System.Management.Automation.ItemNotFoundException] {
        $message = "Could not get registry key.`n" + `
            "The key '$regKeyPath' does not exist.`n$_"
        Write-Warning $message
    } catch [System.Management.Automation.PSArgumentException] {
        $message = "Could not get registry key.`n" + 
        "The key '$Path' does not have the value '$regKeyValueName'.`n$_"
        Write-Warning $message
    } catch {
        Write-Warning $_
    }
    Write-Warning "AutoHotkey not found in the registry."
    # Search using Get-AppInstallLocation
    $installDir = Get-AppInstallLocation 'AutoHotkey*'
    if ($installDir) {
        $installDirExists = Test-Path ($installDir) -PathType Container
        if ($installDirExists) {
            $autoHotKeyPath = Get-AutoHotkeyExePath -InstallDirPath $installDir
            if ($autoHotKeyPath) {
                Write-Debug "AutoHotkey found at '$autoHotKeyPath'."
                Write-Debug "Get-AutoHotkeyPath has finished."
                return $autoHotKeyPath
            }
        }
    }
    Write-Debug "Get-AutoHotkeyPath has finished."
    Write-Error "AutoHotkey not found."
    throw
}
