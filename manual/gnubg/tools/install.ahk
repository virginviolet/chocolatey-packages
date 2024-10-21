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

; Check the version of AutoHotkey
if A_AhkVersion >= "2.0"
{
    #Warn All
    ; #NoTrayIcon
    SetWorkingDir A_ScriptDir ; Ensure a consistent starting directory
}
else
{
    #NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases
    #Warn ; Enable warnings to assist with detecting common errors
    #NoTrayIcon ; Disables tray icon
    SetBatchLines, -1 ; Removing artificial delays between the execution of lines
    SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory
    SetTitleMatchMode, 1 ; Match window titles from the beginning
}
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

; Check AutoHotkey version
if (A_AhkVersion >= "2.0")
    {
        ; Wait up to 12 minutes for the program to start
        NewPID := Process.Wait("notepad.exe", 720)
        if not NewPID
            {
                Throw "The 'gnubg-cli' process did not appear within 12 minutes."
            }
        ; Otherwise
        ; Retrieve the window ID of Notepad
        winID := WinExist("ahk_exe gnubg-cli.exe")
        if (winID)
        {
        ; Hide the Notepad window
        WinHide "ahk_id winID"
        }
    }
    else
    {
        ; Wait up to 12 minutes for the program starts
        ; Process, Wait, gnubg-cli.exe, 720
        Process, Wait, gnubg-cli.exe, 720
        NewPID := ErrorLevel  ; Save the value immediately since ErrorLevel is often changed.
        if not NewPID  ; If Notepad has started
            {
                ; [ ] Test
                Throw "The 'gnubg-cli' process did not appear within 12 minutes."
            }
        ; Otherwise
        ; [ ] Test
        ; Retrieve the window ID of the program
        WinGet, winID, ID, ahk_exe gnubg-cli.exe
        if (winID)
        {
            ; [ ] Test
            ; Hide the Notepad window
            WinHide, ahk_id %winID%
        }
    }
    
    ExitApp  ; Exit the script



;}
