#Requires AutoHotkey v2.0

; SW Functions
; ===============================
ToggleSW(Index) {
    ; Determine which button to update
    BtnObj := (Index = 1) ? BtnSW1 : BtnSW2

    if !SW[Index].Running {
        ; START/RESUME logic
        SW[Index].Start := A_TickCount
        SW[Index].Running := true
        BtnObj.Text := "Stop"
    } else {
        ; STOP/PAUSE logic
        SW[Index].Time += A_TickCount - SW[Index].Start
        SW[Index].Running := false
        BtnObj.Text := "Start"
    }
}

ResetSW(Index) {
    SW[Index].Running := false
    SW[Index].Time := 0

    ; Reset the Button Text
    (Index = 1 ? BtnSW1 : BtnSW2).Text := "Start"

    ; Reset the Display Text
    (Index = 1 ? SW1_Display : SW2_Display).Value := "00:00.00"
    Diff_Display.Value := "Diff: 00:00.00"
}
; ===============================

; CD Functions
; ===============================
ToggleCD(Idx) {
    if CD[Idx].Running {
        CD[Idx].Running := false
        CD_Controls[Idx].Btn.Text := "Start" ; Update button text
        return
    }

    ; If Not Running: Check if we are resuming or starting fresh
    if (CD[Idx].Left <= 0) {
        ; Start fresh: Parse the input box
        InputStr := CD_Controls[Idx].Edit.Value
        CD[Idx].Total := ParseInput(InputStr)
        CD[Idx].Left := CD[Idx].Total
    }

    ; Validate and Start
    if (CD[Idx].Left > 0) {
        CD[Idx].Last := A_TickCount
        CD[Idx].Running := true
        CD_Controls[Idx].Btn.Text := "Stop" ; Update button text
    }
}

ResetCD(Idx) {
    CD[Idx].Running := false
    CD[Idx].Left := 0
    CD_Controls[Idx].Btn.Text := "Start" ; Ensure button resets to "Start"
    UpdateDisplayFromInput(Idx)
}

; Toggles the "Loop" checkbox for a specific countdown
ToggleCDLoop(Idx) {
    ; (1 = checked, 0 = unchecked)
    CD_Controls[Idx].Chk.Value := !CD_Controls[Idx].Chk.Value
}

; -- Visual Update --
UpdateDisplayFromInput(Idx) {
    if !CD[Idx].Running {
        raw := CD_Controls[Idx].Edit.Value
        if (raw == "") {
            CD_Controls[Idx].Disp.Value := "00:00"
            return
        }
        ; Formatting logic
        CD_Controls[Idx].Disp.Value := InStr(raw, ":") ? raw : "00:" . raw
    }
}
; ===============================

; Helper & Timer Functions
; ===============================

; -- Updates all GUI elements --
UpdateTimers() {
    ; 1. Update Stopwatches
    loop 2 {
        CurrentTotal := SW[A_Index].Time
        if SW[A_Index].Running
            CurrentTotal += A_TickCount - SW[A_Index].Start

        ; Update Text
        (A_Index = 1 ? SW1_Display : SW2_Display).Value := FormatMS(CurrentTotal)
    }

    ; 2. Update Difference (Diff)
    T1 := SW[1].Running ? (SW[1].Time + A_TickCount - SW[1].Start) : SW[1].Time
    T2 := SW[2].Running ? (SW[2].Time + A_TickCount - SW[2].Start) : SW[2].Time
    Diff := Abs(T1 - T2)
    Diff_Display.Value := "Diff: " . FormatMS(Diff)

    ; 3. Update Countdowns
    loop 4 {
        if CD[A_Index].Running {
            Now := A_TickCount
            Delta := Now - CD[A_Index].Last
            CD[A_Index].Left -= Delta
            CD[A_Index].Last := Now

            ; Handle Finish
            if (CD[A_Index].Left <= 0) {
                ; Check Repeat
                if CD_Controls[A_Index].Chk.Value {
                    CD[A_Index].Left := CD[A_Index].Total
                    SoundBeep 400, 100 ; Beep on loop

                    ; Check Finished
                } else {
                    CD[A_Index].Left := 0
                    CD[A_Index].Running := false
                    CD_Controls[A_Index].Btn.Text := "Start"
                    SoundBeep 750, 500 ; Long beep on finish
                }
            }
        }

        ; Render Countdown Text
        SecondsLeft := Ceil(CD[A_Index].Left / 1000)
        Min := Floor(SecondsLeft / 60)
        Sec := Mod(SecondsLeft, 60)
        CD_Controls[A_Index].Disp.Value := Format("{:02}:{:02}", Min, Sec)
    }
}

; -- Converts "mm:ss" or "ss" strings to Milliseconds --
ParseInput(Str) {
    if InStr(Str, ":") {
        parts := StrSplit(Str, ":")
        ; Handle cases where user types ":" without numbers safely
        m := IsNumber(parts[1]) ? parts[1] : 0
        s := (parts.Length > 1 && IsNumber(parts[2])) ? parts[2] : 0
        return ((m * 60) + s) * 1000
    }
    return (IsNumber(Str) ? Str : 0) * 1000
}

; -- Converts Milliseconds to "00:00.00" string --
FormatMS(ms) {
    TotalSec := Floor(ms / 1000)
    Hund := Floor(Mod(ms, 1000) / 10)
    Min := Floor(TotalSec / 60)
    Sec := Mod(TotalSec, 60)
    return Format("{:02}:{:02}.{:02}", Min, Sec, Hund)
}

; -- Fixes "too many params" error for bound events --
CallbackCreate(Func, Idx) {
    return (ctrl, info) => Func(Idx)
}
; ===============================
