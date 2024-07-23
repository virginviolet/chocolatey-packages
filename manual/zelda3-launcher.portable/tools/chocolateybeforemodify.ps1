# Unable to get this to work.

# get zelda3 process
try {
    $zelda3 = Get-Process "zelda3"
    if ($zelda3) {
        # try gracefully first
        $zelda3.CloseMainThread()
        # kill after five seconds
        Sleep 5
        if (!$zelda3.started) {
            $zelda3 | Stop-Process -Force
        }
    }
} catch {}

# get launcher process
try {
    $zelda3launcher = Get-Process "Zelda 3 Launcher"
        if ($zelda3launcher) {
        # try to close gracefully first
        $zelda3launcher.CloseMainThread()
        # kill after five seconds
        Sleep 5
        if (!$zelda3launcher.started) {
            $zelda3launcher | Stop-Process -Force
        }
    }
} catch {}