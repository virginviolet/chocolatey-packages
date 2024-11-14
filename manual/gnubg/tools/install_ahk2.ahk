; Script to make installation of gnubg with Chocolatey silent
;
; Hide the command prompt window that showing compiler progress
; as soon as it appears.
;

;; INITIALIZATION
;{-----------------------------------------------
;
; Send errors to the Error stream rather than displaying as a dialog
; (this doesn't work for me, but I wish it would)
#ErrorStdOut utf-8
; Enforce single instance
#SingleInstance force
; Set AutoHotKey version requirement
; (the dash means that pre-release versions are allowed)
#Requires AutoHotkey >=2.0-
; Enable warnings to assist with detecting common errors
#Warn All
; Disable tray icon
#NoTrayIcon
;}

;; WAIT AND HIDE
;{-----------------------------------------------
;
; Wait up to 12 minutes for the window to appear
HWND := WinWait("ahk_exe gnubg-cli.exe", , 720)
; If it does not appear
if not HWND
    {
        ; Throw error if the window did not appear within the time limit
        Throw "A window from a 'gnubg-cli.exe' process did not appear within 12 minutes."
    }
; Otherwise
; Hide the window
WinHide "ahk_exe gnubg-cli.exe"
; Exit the script
ExitApp
;}
