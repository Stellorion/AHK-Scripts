#Requires AutoHotkey v2.0

; List of Shortcuts
; ===============================
AllShortcuts := Map()

AllShortcuts["Windows"] := [
    ["Open Task Manager", "Ctrl + Shift + Esc"],
    ["Show/Hide Desktop", "Win + D"],
    ["Lock PC", "Win + L"],
    ["File Explorer", "Win + E"],
    ["Open Settings", "Win + I"],
    ["Open Action Center", "Win + A"],
    ["Interact With Taskbar", "Win + Num"],
    ["Move Between Tabs", "Ctrl + Num"],
    ["New Tab", "Ctrl + T/N"],
    ["Close Tab", "Ctrl + W"],
    ["Open Calculator", "Ctrl + CapsLock"],
    ["Alt+Tab Left/Right", "CapsLock + Q/E"]
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
    ["Exit Call", "Ctrl + D"]
]

AllShortcuts["Game A"] := [
    ["Cast Ability 1", "Q"],
    ["Cast Ability 2", "W"],
    ["Ultimate", "R"],
    ["Item Slot 1", "1"],
    ["Scoreboard", "Tab"],
    ["Chat", "Enter"]
]

AllShortcuts["Game B"] := [
    ["Crouch", "C"],
    ["Prone", "Z"],
    ["Reload", "R"],
    ["Grenade", "G"],
    ["Map", "M"],
    ["Inventory", "I"]
]
; ===============================


; GUI
; ===============================
MyGui := Gui(, "Shortcut Cheat Sheet")
MyGui.BackColor := "0B090A"
MyGui.SetFont("s10", "Arial")

; -- Header --
MyGui.SetFont("s18 Bold cF5F3F4", "Arial")
MyGui.Add("Text", "Center w430 cF5F3F4 vHeaderText", "Windows Shortcuts")

; -- Nav Buttons --
MyGui.SetFont("s12 bold")
Btn1 := MyGui.Add("Button", "x10 w100 -E0x200", "Windows")
Btn2 := MyGui.Add("Button", "x+10 w100", "Discord")
Btn3 := MyGui.Add("Button", "x+10 w100 -E0x200", "Game A")
Btn4 := MyGui.Add("Button", "x+10 w100", "Game B")

Btn1.OnEvent("Click", (*) => SwitchList("Windows"))
Btn2.OnEvent("Click", (*) => SwitchList("Discord"))
Btn3.OnEvent("Click", (*) => SwitchList("Game A"))
Btn4.OnEvent("Click", (*) => SwitchList("Game B"))

; -- List View --
MyGui.SetFont("s14 norm cF5F3F4", "Arial")
LV := MyGui.Add("ListView", "x10 y+10 w430 r12 -E0x200 -Multi Background0B090A cF5F3F4", ["Action", "Shortcut"])
LV.ModifyCol(1, 270)
LV.ModifyCol(2, "AutoHdr")

; Load default list
SwitchList("Windows")
; ===============================


; Functions
; ===============================
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
; ===============================


; Shortcuts
; ===============================
; -- Show Window --
#CapsLock:: 
{
    MyGui.Show("w450 Center")
}

; -- Close Window --
#W:: 
{
    MyGui.Hide() 
}

; -- Open Calculator --
^CapsLock::
{
    Run "calc.exe"
}

; Just in case (Might Delete it later)
SetCapsLockState "AlwaysOff"

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


; -- Switch List --
#HotIf WinActive("ahk_id " MyGui.Hwnd)
    1::SwitchList("Windows")
    2::SwitchList("Discord")
    3::SwitchList("Game A")
    4::SwitchList("Game B")
    Escape::MyGui.Hide()
#HotIf
; ===============================


; Link External AHK Files
; ===============================
#Include schedule1.ahk
#Include Discord.ahk
; ===============================