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

; Automator Vars
; -------------------------------
IsAutomating := false
IsRecording := false
IsPlaying := false
MacroData := []
RecordStartTime := 0
MacroIndex := 0
; -------------------------------

; List of Shortcuts
; -------------------------------
AllShortcuts := Map()

AllShortcuts["Main List"] := [
    ["Main List", "``"],
    ["Windows", "1"],
    ["Discord", "2"],
    ["Timers", "3"],
    ["AutoClicker", "4"],
    ["File Explorer", "5"],
    ["Media Control" "6"],
]

AllShortcuts["Windows"] := [
    ["Show/Hide Desktop", "Win + D"],
    ["Always On Top", "Win + Backtick"],
    ["Close Program", "Win + W"],
    ["Open Action Center", "Win + A"],
    ["Interact With Taskbar", "Win + Num"],
    ["Move Between Tabs", "Ctrl + Num"],
    ["New Tab", "Ctrl + T/N"],
    ["Close Tab", "Ctrl + W"],
    ["Open Calculator", "Ctrl + CapsLock"],
    ["Open Everything Search", "CapsLock + S"]
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

AllShortcuts["AutoClicker"] := [
    ["Toggle Visibility", "CapsLock + F2"],
    ["Start AutoClicker", "CapsLock + z"],
    ["Stop AutoClicker & Record", "CapsLock + x"],
    ["Start Recording", "CapsLock + c"],
    ["Play Recording", "CapsLock + v"],
]

AllShortcuts["File Explorer"] := [
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

AllShortcuts["Media Control"] := [
    ["Jump +5s/-5s", "CapsLock + Q/E"],
    ["Start/Pause", "CapsLock + W"],
    ["Prev/Next", "CapsLock + A/D"],
    ["Jump To Start", "CapsLock + T"],
    ["Jump To End", "CapsLock + R"],
]
; ===============================


; Shortcuts GUI
; ===============================
MyGui := Gui(, "Shortcut Cheat Sheet")
MyGui.BackColor := "0B090A"
MyGui.SetFont("s10", "Arial")

; -- Header --
MyGui.SetFont("s18 Bold cF5F3F4", "Arial")
MyGui.Add("Text", "x10 w430 +Center cF5F3F4 vHeaderText")

; -- List View --
MyGui.SetFont("s14 norm cF5F3F4", "Arial")
LV := MyGui.Add("ListView", "x10 y+10 w430 r13 -E0x200 -Multi Background0B090A cF5F3F4", ["Action", "Shortcut"])
LV.ModifyCol(1, 270)
LV.ModifyCol(2, "AutoHdr")

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

; Load default list
SwitchList("Main List")
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


; Automator GUI
; ===============================
AutomatorGui := Gui(, "AHK Automator")
AutomatorGui.BackColor := "0B090A"

; Auto Clicker GUI
; -------------------------------
AutomatorGui.SetFont("s18 Bold cF5F3F4", "Segoe UI")
AutomatorGui.Add("Text", "x0 y15 Center w420", "AUTO CLICKER")
AutomatorGui.Add("Text", "x0 h0 w422 0x10") 

; -- Key Selection --
AutomatorGui.SetFont("s12 Bold cWhite")
AutomatorGui.Add("Text", "x20 y+25 section", "Key/Mouse:")
EditAutoKey := AutomatorGui.Add("Edit", "x+10 w50 h26 cBlack", "m1")

; -- Interval (ms) --
AutomatorGui.Add("Text", "x+55 yp", "Interval (ms):") 
EditInterval := AutomatorGui.Add("Edit", "x+10 yp w60 h26 cBlack", "100")

; -- Location Selection --
RadioCur  := AutomatorGui.Add("Radio", "xs y+15 Checked", "Current location")
RadioPick := AutomatorGui.Add("Radio", "x+55 w20 h20", "") 
AutomatorGui.SetFont("s11 Bold cWhite")
BtnPick   := AutomatorGui.Add("Button", "x+2 yp-4 h28 w110 Background0B090A cBlack", "Pick location")
BtnPick.OnEvent("Click", GetLocation)

; -- Mode Selection (Tap/Hold) --
AutomatorGui.SetFont("s12 Bold cWhite")
RadioTap  := AutomatorGui.Add("Radio", "x20 Checked", "Tap")
RadioHold := AutomatorGui.Add("Radio", "x+10", "Hold")

; -- X & Y Coordinations --
AutomatorGui.Add("Text", "x+80 yp+4", "X:")
EditX     := AutomatorGui.Add("Edit", "x+5 yp-4 w40 h26 cBlack", "0")
AutomatorGui.Add("Text", "x+10 yp+4", "Y:")
EditY     := AutomatorGui.Add("Edit", "x+5 yp-4 w40 h26 cBlack", "0")
AutomatorGui.Add("Text", "x0 y+25 h0 w422 0x10") 

; Macro Recorder GUI
; -------------------------------
AutomatorGui.SetFont("s18 Bold")
AutomatorGui.Add("Text", "x0 y+15 Center w420 cWhite", "MACRO RECORDER")
AutomatorGui.Add("Text", "x0 h0 w422 0x10") 

; -- Repeat Logic --
AutomatorGui.SetFont("s12 Bold cWhite")
CheckRepeat := AutomatorGui.Add("Checkbox", "x20 yp+20", "Repeat")
AutomatorGui.Add("Text", "x+170", "Interval:")
EditMacroInterval := AutomatorGui.Add("Edit", "x+5 yp-3 w60 h26 cBlack", "1000")

; -- Reocrd Buttons --
AutomatorGui.SetFont("s10 cBlack")
BtnRecord  := AutomatorGui.Add("Button", "x20 w120 h30", "Record")
BtnStopRec := AutomatorGui.Add("Button", "x+10 w120 h30", "Stop")
BtnPlay    := AutomatorGui.Add("Button", "x+10 w120 h30", "Play")

; -- Record List -- 
AutomatorGui.SetFont("s12 Bold cWhite")
AutomatorGui.Add("Text", "x20 y+15", "Live Sequence:")
AutomatorGui.SetFont("s10 Bold cWhite")
MacroList  := AutomatorGui.Add("ListView", "x20 y+5 r8 w380 cBlack", ["Key", "Delay (ms)"])
MacroList.ModifyCol(1, 100)
MacroList.ModifyCol(2, 259)

; -- Export/Import --
BtnExport  := AutomatorGui.Add("Button", "x20 y+10 w185 h35 cBlack", "Export (CSV)")
BtnImport  := AutomatorGui.Add("Button", "x+10 w185 h35 cBlack", "Import (CSV)")

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
; -- Show/Hide Shortcuts --
#CapsLock::
{
    static visible := false
    visible ? MyGui.Hide() : MyGui.Show("w450 Center")
    visible := !visible
}

; -- Switch List --
#HotIf WinActive("ahk_id " MyGui.Hwnd)
`:: SwitchList("Main List")
1:: SwitchList("Windows")
2:: SwitchList("Discord")
3:: SwitchList("Timers")
4:: SwitchList("AutoClicker")
5:: SwitchList("File Explorer")
6:: SwitchList("Media Control")
Escape:: MyGui.Hide()
#HotIf

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

; -- Everything Search --
CapsLock & s::
{
    if WinExist("ahk_exe Everything.exe")
        WinActivate
    else
        Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Everything.lnk"
    return
}
; -------------------------------

; Media
; -------------------------------
; -- Start/Pause --
CapsLock & w::
{
    Send "{Media_Play_Pause}"
}

; -- Next --
CapsLock & d::
{
    Send "{Media_Next}"
}

; -- Previous --
CapsLock & a::
{
    Send "{Media_Prev}"
}

; -- Jump Backward 5s --
CapsLock & q:: {
    try {
        session := Media.GetCurrentSession()
        session.ChangePlaybackPosition(Max(0, session.Position - 5))
    } 
    catch {
        ; Do nothing
    }
}

; -- Jump Forward 5s --
CapsLock & e:: {
    try {
        session := Media.GetCurrentSession()
        session.ChangePlaybackPosition(Min(session.EndTime, session.Position + 5))
    } 
    catch {
        ; Do nothing
    }
}

; -- Jump To Start --
CapsLock & t:: {
    try {
        session := Media.GetCurrentSession()
        session.ChangePlaybackPosition(session.StartTime)
    } 
    catch {
        ; Do nothing
    }
}

; -- Jump To End --
CapsLock & r:: {
    try {
        session := Media.GetCurrentSession()
        session.ChangePlaybackPosition(session.EndTime)
    } 
    catch {
        ; Do nothing
    }
}
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

; Automator Shortcuts
; -------------------------------
; -- Toggle Visibility --
CapsLock & F2::
{
    static visible := false
    visible ? AutomatorGui.Hide() : AutomatorGui.Show("w420")
    visible := !visible
}

CapsLock & z:: RunAutoClicker()
CapsLock & x:: StopActions()
CapsLock & c:: StartRecording()
CapsLock & v:: PlayMacro()
; -------------------------------
; ===============================


; Includes/Runs
; ===============================
#Include Discord.ahk
#Include Timer.ahk
#Include FileExplorer.ahk
#Include Automator.ahk
; -------- Libraries ------------
; Source: https://github.com/Descolada/AHK-v2-libraries
; Copyright (c) 2023 Descolada
; Licensed under MIT License
#Include lib/MediaControl.ahk
; ===============================