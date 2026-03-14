#Requires AutoHotkey v2.0
#SingleInstance Force

; Global Vars
; ===============================

; Timer Vars
; -------------------------------
; Stopwatches: [AccumulatedTime, IsRunning, StartTick]
SW := [{ Time: 0, Running: false, Start: 0 }, { Time: 0, Running: false, Start: 0 }]

; Countdowns: [TargetTime(ms), Remaining(ms), IsRunning, LastTick, IsRepeat, InputValue]
CD := []
loop 4 {
    CD.Push({ Total: 0, Left: 0, Running: false, Last: 0, Repeat: 0, ID: A_Index })
}
; -------------------------------

; List of Shortcuts
; -------------------------------
AllShortcuts := Map()

AllShortcuts["Windows"] := [
    ["Show/Hide Desktop", "Win + D"],
    ["Always On Top", "Win + Backtick"],
    ["Close Program", "Win + W"],
    ["Open Settings", "Win + I"],
    ["Open Action Center", "Win + A"],
    ["Interact With Taskbar", "Win + Num"],
    ["Move Between Tabs", "Ctrl + Num"],
    ["New Tab", "Ctrl + T/N"],
    ["Close Tab", "Ctrl + W"],
    ["Open Calculator", "Ctrl + CapsLock"],
    ["Alt+Tab Left/Right", "CapsLock + Q/E"],
    ["Start/Pause Media", "CapsLock + W"],
]

AllShortcuts["Discord"] := [
    ["Mute", "Ctrl + Shift + Z"],
    ["Deafen", "Ctrl + Shift + X"],
    ["Switch Server", "Ctrl + Alt + W/S"],
    ["Switch Channel", "Alt + W/S"],
    ["Scroll", "Ctrl W/S"],
    ["Quick Switcher", "Ctrl + Q"],
    ["Go To Active Call", "Ctrl + Alt + A"],
    ["Answer Call", "Ctrl + E"],
    ["Exit Call", "Ctrl + D"],
]

AllShortcuts["Timers"] := [
    ["Toggle Visibility", "CapsLock + F1"],
    ["Stopwatch 1-2 Start/Stop", "Alt + 1-2"],
    ["Stopwatch 1-2 Reset", "Shift + Alt + 1-2"],
    ["Countdown 1-4 Start/Stop", "Alt + 3-6"],
    ["Countdown 1-4 Reset", "Ctrl + Alt + 3-6"],
    ["Countdown 1-4 Loop Toggle", "Ctrl + 1-4"],
]

AllShortcuts["Explorer"] := [
    ["Games", "CapsLock + 1"],
    ["Software", "CapsLock + 2"],
    ["Desktop", "CapsLock + 3"],
    ["Downloads", "CapsLock + 4"],
    ["My PC", "CapsLock + 5"],
    ["Jump to Parent", "CapsLock + Tab"],
    ["Copy File Path", "Ctrl + Alt + C"],
    ["Create Shortcut", "Alt + Left Click"],
    ["Create Copy", "Ctrl + Left Click"],
]
; ===============================


; Shortcuts GUI
; ===============================
MyGui := Gui(, "Shortcut Cheat Sheet")
MyGui.BackColor := "0B090A"
MyGui.SetFont("s10", "Arial")

; -- Header --
MyGui.SetFont("s18 Bold cF5F3F4", "Arial")
MyGui.Add("Text", "Center w430 cF5F3F4 vHeaderText", "Windows Shortcuts")

; -- Nav Buttons --
MyGui.SetFont("s12 bold")
Btn1 := MyGui.Add("Button", "Background0B090A x10 w100 -E0x200", "Windows")
Btn2 := MyGui.Add("Button", "Background0B090A x+10 w100", "Discord")
Btn3 := MyGui.Add("Button", "Background0B090A x+10 w100 -E0x200", "Timers")
Btn4 := MyGui.Add("Button", "Background0B090A x+10 w100", "Explorer")

Btn1.OnEvent("Click", (*) => SwitchList("Windows"))
Btn2.OnEvent("Click", (*) => SwitchList("Discord"))
Btn3.OnEvent("Click", (*) => SwitchList("Timers"))
Btn4.OnEvent("Click", (*) => SwitchList("Explorer"))

; -- List View --
MyGui.SetFont("s14 norm cF5F3F4", "Arial")
LV := MyGui.Add("ListView", "x10 y+10 w430 r12 -E0x200 -Multi Background0B090A cF5F3F4", ["Action", "Shortcut"])
LV.ModifyCol(1, 270)
LV.ModifyCol(2, "AutoHdr")

; Load default list
SwitchList("Windows")
; ===============================


; Timer GUI
; ===============================
TimeGui := Gui(, "AHK Timer")
TimeGui.BackColor := "0B090A"
TimeGui.SetFont("s10 cWhite", "Segoe UI")

; SW GUI
; -------------------------------
TimeGui.SetFont("s18 Bold cF5F3F4", "Segoe UI")
TimeGui.Add("Text", "x10 Center w400 h35 cWhite", "STOPWATCHES")
TimeGui.Add("Text", "x0 h0 w422 0x10") ; Separator line

; -- SW 1 --
TimeGui.SetFont("s25 cWhite", "Consolas")
SW1_Display := TimeGui.Add("Text", "x10 Center w400", "00:00.00")
TimeGui.SetFont("s10")

; -- SW 1: Buttons --
BtnSW1 := TimeGui.Add("Button", "Background0B090A x125 w80", "Start")
BtnSW1.OnEvent("Click", (*) => ToggleSW(1))
TimeGui.Add("Button", "Background0B090A x+10 w80", "Reset").OnEvent("Click", (*) => ResetSW(1))

; -- SW 2 --
TimeGui.SetFont("s25 cWhite", "Consolas")
SW2_Display := TimeGui.Add("Text", "x10 y+10 Center w400", "00:00.00")
TimeGui.SetFont("s10")

; -- SW 2: Buttons --
BtnSW2 := TimeGui.Add("Button", "Background0B090A x125 w80", "Start")
BtnSW2.OnEvent("Click", (*) => ToggleSW(2))
TimeGui.Add("Button", "Background0B090A x+10 w80", "Reset").OnEvent("Click", (*) => ResetSW(2))

; -- Comparison --
TimeGui.SetFont("s12 cwhite", "Consolas")
Diff_Display := TimeGui.Add("Text", "x10 y+15 h25 Center w400", "Diff: 00:00.00")
TimeGui.Add("Text", "x0 h0 w422 0x10") ; Separator line
; -------------------------------

; CD GUI
; -------------------------------
TimeGui.SetFont("s18 Bold cWhite", "Segoe UI")
TimeGui.Add("Text", "x10 y+20 Center h35 w400", "COUNTDOWNS")
TimeGui.Add("Text", "x0 h5 w422 0x10") ; Separator line
TimeGui.SetFont("s10 cWhite", "Segoe UI")

; Generate 4 CD Rows
CD_Controls := []

loop 4 {
    Idx := A_Index
    YPos := (Idx = 1) ? "y+10" : "y+5"

    ; Time Display
    TimeGui.SetFont("s12 cWhite", "Consolas")
    Display := TimeGui.Add("Text", "x50 " YPos " w80 Right", "00:00")

    ; Input Field
    Input := TimeGui.Add("Edit", "x+10 cBlack w50 Center", "")
    Input.OnEvent("Change", (ctrl, info) => UpdateDisplayFromInput(Idx))

    ; Buttons
    TimeGui.SetFont("s9", "Segoe UI")
    BtnToggle := TimeGui.Add("Button", "x+10 w40", "Start")
    BtnReset := TimeGui.Add("Button", "x+3 w40", "Reset")

    ; Loops Checkbox
    ChkRepeat := TimeGui.Add("Checkbox", "x+10 h35 cWhite", "Loop")

    ; Bind Events
    BtnToggle.OnEvent("Click", CallbackCreate(ToggleCD, Idx))
    BtnReset.OnEvent("Click", CallbackCreate(ResetCD, Idx))

    ; Store for later uses
    CD_Controls.Push({ Disp: Display, Edit: Input, Chk: ChkRepeat, Btn: BtnToggle })
}
; -------------------------------
; ===============================


; ===============================
; Update GUI every 50ms
SetTimer UpdateTimers, 50
; Function Key
SetCapsLockState "AlwaysOff"
; ===============================


; Hotkeys
; ===============================

; WinShortcuts
; -------------------------------
SwitchList(ListName) {
    ; Update Header Text
    MyGui["HeaderText"].Value := ListName . " Shortcuts"

    ; Clear and Repopulate ListView
    LV.Delete()
    if AllShortcuts.Has(ListName) {
        for item in AllShortcuts[ListName] {
            LV.Add(, item*)
        }
    }
}

; -- Show/Hide Window --
#CapsLock::
{
    static visible := false
    visible ? MyGui.Hide() : MyGui.Show("w450 Center")
    visible := !visible
}

; -- Open Calculator --
^CapsLock::
{
    Run "calc.exe"
}

; -- Open Task Manager --
CapsLock & Esc::
{
    Send "^+{Escape}"
}

; -- Jump Backward --
CapsLock & q::
{
    Send "!{Tab}"
    Sleep 200
    Send "{Left}"
    Sleep 50
    Send "!{Tab}"
}

; -- Jump Forward --
CapsLock & e::
{
    Send "!{Tab}"
    Sleep 200
    Send "{Right}"
    Sleep 50
    Send "!{Tab}"
}

; -- Start/Pause --
CapsLock & w::
{
    Send "{Media_Play_Pause}"
}

; -- Close Active Program --
#w::
{
    Send "!{f4}"
}

; -- Always On Top --
#`::
{
    WinSetAlwaysOnTop -1, "A"
}

; -- Switch List --
#HotIf WinActive("ahk_id " MyGui.Hwnd)
1:: SwitchList("Windows")
2:: SwitchList("Discord")
3:: SwitchList("Timers")
4:: SwitchList("Explorer")
Escape:: MyGui.Hide()
#HotIf
; -------------------------------

; Timer Shortcuts
; -------------------------------
; -- Toggle Visibility --
CapsLock & F1::
{
    static visible := false
    visible ? TimeGui.Hide() : TimeGui.Show("w420")
    visible := !visible
}

#HotIf WinActive("ahk_id " TimeGui.Hwnd)

; -- Stopwatch Start/Stop --
!1:: ToggleSW(1)
!2:: ToggleSW(2)

; -- Stopwatch Reset --
+!1:: ResetSW(1)
+!2:: ResetSW(2)

; -- Countdown Start/Stop --
!3:: ToggleCD(1)
!4:: ToggleCD(2)
!5:: ToggleCD(3)
!6:: ToggleCD(4)

; -- Countdown Reset --
^!3:: ResetCD(1)
^!4:: ResetCD(2)
^!5:: ResetCD(3)
^!6:: ResetCD(4)

; -- Toggle Countdown Checkbox --
^1:: ToggleCDLoop(1)
^2:: ToggleCDLoop(2)
^3:: ToggleCDLoop(3)
^4:: ToggleCDLoop(4)

#HotIf
; -------------------------------
; ===============================


; Includes
; ===============================
#Include schedule1.ahk
#Include Discord.ahk
#Include Timer.ahk
#Include FileExplorer.ahk
; ===============================