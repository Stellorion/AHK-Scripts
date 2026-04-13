#Requires AutoHotkey v2.0

; --- Event Attachments ---
BtnExport.OnEvent("Click", ExportMacro)
BtnImport.OnEvent("Click", ImportMacro)
BtnRecord.OnEvent("Click", (*) => StartRecording())
BtnStopRec.OnEvent("Click", (*) => StopActions()) 
BtnPlay.OnEvent("Click", (*) => PlayMacro())

; --- Logic Functions ---
GetLocation(*) {
    CoordMode "Mouse", "Screen"
    RadioPick.Value := 1 
    ToolTip("LEFT CLICK anywhere to pick coordinates...")
    KeyWait "LButton"
    KeyWait "LButton", "D"
    MouseGetPos(&x, &y)
    EditX.Value := x
    EditY.Value := y
    ToolTip()
}

ProcessMacro() {
    global IsPlaying, MacroIndex, MacroData
    
    ; If we were told to stop, turn off the timer and exit
    if (!IsPlaying) {
        SetTimer(ProcessMacro, 0)
        return
    }

    ; Get the current step
    item := MacroData[MacroIndex]

    ; Perform the action
    if (item.key ~= "i)\{(LButton|RButton|MButton)\}")
        Click(SubStr(item.key, 2, 1))
    else
        Send(item.key)

    ; Move to the next item
    MacroIndex++

    ; Check if we finished the list
    if (MacroIndex > MacroData.Length) {
        if (CheckRepeat.Value) {
            MacroIndex := 1 ; Reset to start
            SetTimer(ProcessMacro, Max(1, EditMacroInterval.Value))
        } else {
            IsPlaying := false
            SetTimer(ProcessMacro, 0)
        }
        return
    }

    ; Schedule the next key based on the recorded delay
    SetTimer(ProcessMacro, Max(1, MacroData[MacroIndex].delay))
}

StartRecording() {
    global IsRecording := true, IsPlaying := false, MacroData := [], RecordStartTime := A_TickCount
    MacroList.Delete()
    ToolTip("Recording Keys & Mouse...")
}

StopActions(*) {
    global IsRecording := false, IsPlaying := false, IsAutomating := false
    SetTimer(ProcessMacro, 0)
    ToolTip()
    SoundBeep 500, 100 
}

PlayMacro() {
    global IsPlaying, IsRecording, MacroIndex
    if (MacroData.Length = 0 || IsPlaying || IsRecording)
        return
    
    IsPlaying := true
    MacroIndex := 1 ; Start at the first item
    
    ; Start the timer immediately with a 10ms delay
    SetTimer(ProcessMacro, 10)
}

RecordKey(name) {
    if !IsRecording
        return
    global RecordStartTime
    delay := A_TickCount - RecordStartTime
    RecordStartTime := A_TickCount
    MacroData.Push({key: "{" name "}", delay: delay})
    MacroList.Add(, name, delay)
}

; -- Recording Hooks --
#HotIf IsRecording
~*LButton::RecordKey("LButton")
~*RButton::RecordKey("RButton")
~*MButton::RecordKey("MButton")
~*Space::RecordKey("Space")
~*Enter::RecordKey("Enter")
#HotIf

; Build the alphanumeric hooks
Loop 26
    Hotkey("~*" Chr(A_Index + 96), (hk) => RecordKey(SubStr(hk, 3)))
Loop 10
    Hotkey("~*" (A_Index - 1), (hk) => RecordKey(SubStr(hk, 3)))

; -- File Handling --
ExportMacro(*) {
    if !(Path := FileSelect("S16", "macro.csv"))
        return
    FileObj := FileOpen(Path, "w")
    for item in MacroData
        FileObj.WriteLine(item.key "," item.delay)
    FileObj.Close()
}

ImportMacro(*) {
    if !(Path := FileSelect(3))
        return
    global MacroData := []
    MacroList.Delete()
    Loop Read, Path {
        D := StrSplit(A_LoopReadLine, ",")
        if D.Length = 2 {
            MacroData.Push({key: D[1], delay: D[2]})
            MacroList.Add(, StrReplace(StrReplace(D[1], "{", ""), "}", ""), D[2])
        }
    }
}