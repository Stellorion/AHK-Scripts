#Requires AutoHotkey v2.0

; --- Quick Folder Jumps ---
#HotIf WinActive("ahk_class CabinetWClass")
; -- Games --
CapsLock & 1:: ExplorerJump(A_Desktop . "\Games")
; -- Softwares --
CapsLock & 2:: ExplorerJump(A_Desktop . "\Softwares")
; -- Desktop --
CapsLock & 3:: ExplorerJump(A_Desktop)
; -- Downloads --
CapsLock & 4:: ExplorerJump(EnvGet("USERPROFILE") . "\Downloads")
; -- MyPc --
CapsLock & 5:: ExplorerJump("shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")

; -- Jump to Parent --
CapsLock & Tab:: Send("!{Up}")

#HotIf

; The Navigation Function
ExplorerJump(Path) {
    if WinActive("ahk_class CabinetWClass") {
        for window in ComObject("Shell.Application").Windows {
            try {
                if (window.hwnd == WinActive("A")) {
                    window.Navigate(Path)
                    return
                }
            }
        }
    }
    if DirExist(Path)
        Run(Path)
    else
        MsgBox("Folder does not exist: " . Path)
}