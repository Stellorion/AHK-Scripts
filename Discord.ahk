#Requires AutoHotkey v2.0

; --- Configuration Section ---
#HotIf WinActive("ahk_exe Discord.exe")

; -- Mute --
^+z::
{
    Send "^+m"
}

; -- Deafen --
^+x::
{
    Send "^+d"
}

; -- Scroll Up --
^w::
{
    Send "{WheelUp}"
}

; -- Scroll Down --
^s::
{
    Send "{WheelDown}"
}

; -- QuickSwitcher --
^q::
{
    Send "^k"
}

; -- Answer Call --
^e::
{
    Send "^{Enter}"
}

; -- Nav to Active Call --
^+a::
{
    Send "^+!v"
}

; -- Switch Server Upward --
^!w::
{
    Send "^!{Up}"
}

; -- Switch Server Downward --
^!s::
{
    Send "^!{Down}"
}

; -- Switch Channel Upward --
!w::
{
    Send "!{Up}"
}

; -- Switch Channel Downward --
!s::
{
    Send "!{Down}"
}

; -- Exit Call --
^d::
{
    WinActivate("ahk_exe Discord.exe")
    WinWaitActive("ahk_exe Discord.exe")

    ; Get the window size to calculate the center-bottom area
    WinGetPos(&OutX, &OutY, &OutWidth, &OutHeight, "ahk_exe Discord.exe")

    TargetX := OutWidth * 0.175
    TargetY := OutHeight * 0.82

    Click TargetX, TargetY
}