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
; Avoid checking empty variables to see if they are environment variables 
#NoEnv
; Enable warnings to assist with detecting common errors
#Warn
; Disable tray icon
#NoTrayIcon
; Remove artificial delays between the execution of lines
SetBatchLines, -1
; Match window titles from the beginning
SetTitleMatchMode, 1
;}

;; WAIT AND HIDE
;{-----------------------------------------------
;
; Wait up to 12 minutes for the window to appear
WinWait, ahk_exe gnubg-cli.exe, , 720
if ErrorLevel
    {
    ; Throw error if the window did not appear within the time limit
    Throw "The 'gnubg-cli' process did not appear within 12 minutes."
}
else {
    ; Hide the window found by WinWait
    WinHide
    ; Exit the script
    ExitApp
}
;}
