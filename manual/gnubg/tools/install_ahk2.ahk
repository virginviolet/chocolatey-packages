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
#Requires AutoHotkey >=2.0-
; Check the version of AutoHotkey
#Warn All
; #NoTrayIcon
SetWorkingDir A_ScriptDir ; Ensure a consistent starting directory
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

; Wait up to 12 minutes for the program to start
NewPID := ProcessWait("gnubg-cli.exe", 720)
; If not started
if not NewPID
    {
        ; [ ] Test
        Throw "The 'gnubg-cli' process did not appear within 12 minutes."
    }
; Otherwise
; [ ] Test
; Hide the window
WinHide "ahk_exe gnubg-cli.exe"
ExitApp  ; Exit the script
;}
