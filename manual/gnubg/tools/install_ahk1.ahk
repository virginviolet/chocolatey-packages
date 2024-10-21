; install
; virginviolet
;
; <Scipt Short Description>
;

;; INITIALIZATION - ENVIROMENT
;{-----------------------------------------------
;
#ErrorStdOut utf-8 ; Send errors to the Error stream rather than displaying as a dialog ; Send errors to the Error stream rather than displaying as a dialogue
#SingleInstance force
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases
#Warn ; Enable warnings to assist with detecting common errors
#NoTrayIcon ; Disables tray icon
SetBatchLines, -1 ; Removing artificial delays between the execution of lines
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory
SetTitleMatchMode, 1 ; Match window titles from the beginning
;}

;; DEFAULT SETTING - VARIABLES
;{-----------------------------------------------
;

;}

;; INITIALIZATION - VARIABLES
;{-----------------------------------------------
;

;}

;; AUTO-EXECUTE
;{-----------------------------------------------
;

;}

;; CLASSES & FUNCTIONS
;{-----------------------------------------------
;

;}

;; LIBRARIES
;{-----------------------------------------------
;

;}

;; INSTALL
;{-----------------------------------------------
;

; Wait up to 12 minutes for the window to appear
; MsgBox, Looking
WinWait, ahk_exe gnubg-cli.exe, , 720
if ErrorLevel
    {
    ; [x] Test
    ; MsgBox, "Not found"
    Throw "The 'gnubg-cli' process did not appear within 12 minutes."
}
else {
    ; [x] Test
    ; MsgBox, "Found!"
    WinHide ; Use the window found by WinWait.
    ; MsgBox, "Hidden."
    ExitApp  ; Exit the script
}

;}
