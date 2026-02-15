#Requires AutoHotkey v2.0

; --- Configuration Section ---
#HotIf WinActive("ahk_exe Schedule I.exe")

; --- Properties ---
^1::ExecuteTeleport("teleport motelroom")
^2::ExecuteTeleport("teleport sweatshop")
^3::ExecuteTeleport("teleport storageunit")
^4::ExecuteTeleport("teleport bungalow")
^5::ExecuteTeleport("teleport barn")
^6::ExecuteTeleport("teleport dockswarehouse")

; --- Business ---
^[::ExecuteTeleport("teleport laundromat")
^]::ExecuteTeleport("teleport postoffice")
^'::ExecuteTeleport("teleport carwash")
^\::ExecuteTeleport("teleport tacoticklers")

#HotIf

; --- Logic Function ---
ExecuteTeleport(Command) {
    Send("``")             ; 1. Open console (Backtick)
    Sleep(100)             ; 2. Wait for UI animation (100ms)
    SendText(Command)      ; 3. Write the command accurately
    Sleep(50)              ; 4. Short buffer
    Send("{Enter}")        ; 5. Execute
}