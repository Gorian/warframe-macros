#NoEnv ; For performance and compatibility with future AutoHotkey releases
#SingleInstance, Force
#MaxThreadsPerHotkey 2
#ErrorStdOut
SendMode Input ; For speed and reliability
SetBatchLines -1 ; No script sleep, for more consistent timing behavior. Default behavior is 10ms execution then 10ms sleep
ListLines Off ; Increase performance by a few percent by not logging the lines of code that are executed
SetScrollLockState, AlwaysOff



global MELEE_LIGHT := "XButton1"
global MELEE_HEAVY := "f"
global GUI_TITLE := "Warframe Macro Manager"

; Define Config File
SplitPath, A_ScriptName,,,,selfName
global CONFIG_FILE := selfName . .ini

; MsgBox, x*(%A_ScreenDPI%/96)
; ExitApp

; Read Config
IniRead, WindowPosX, %CONFIG_FILE%, Window, PosX 
IniRead, WindowPosY, %CONFIG_FILE%, Window, PosY
IniRead, WindowSizeW, %CONFIG_FILE%, Window, SizeWidth, 600
IniRead, WindowSizeH, %CONFIG_FILE%, Window, SizeHeight, 600

; Define main GUI
    Gui, Main:New,, %GUI_TITLE%
    Gui, Main:Add, Text,,Available Macros:
    Gui, Main:Add, Text,, Light Melee - Scrolllock + L
    ;Gui, Main:Add, text, w%WindowSizeW% 0x10  ;Horizontal Line > Etched Gray
    Gui, Main:Add, Text,, Macro Status
    Gui, Main:Add, Text,, Melee
    Gui, Main:Add, Text, vMeleeLightStatus, Light off
    ; show the GUI in the center of the screen if 
    if (WindowPosX = "") or (WindowPosY = "") {
        Gui, Main:Show, w%WindowSizeW% h%WindowSizeH%
    } else {
        Gui, Main:Show, w%WindowSizeW% h%WindowSizeH% x%WindowPosX% y%WindowPosY%
    }
Return

; ---- System Functions
GetClientSize(hwnd, ByRef w, ByRef h)
{
    VarSetCapacity(rc, 16)
    DllCall("GetClientRect", "uint", hwnd, "uint", &rc)
    w := NumGet(rc, 8, "int")
    h := NumGet(rc, 12, "int")
}

SaveWindow(){
    ; Get the window position on close
    WinGetPos,posx,posy,,,%GUI_TITLE%
    ; WinGetPos gets the size of the whole Window
    ; We want the client size
    Gui Main: +hwndMainGuiHwnd
    GetClientSize(MainGuiHwnd, cWidth, cHeight)
    ; We need to account for DPI scaling
    sizew := Round(cWidth / (A_ScreenDPI/96))
    sizeh := Round(cHeight / (A_ScreenDPI/96))
    ; Write the last window position to INI file
    IniWrite, %posx%, %CONFIG_FILE%, Window, PosX
    IniWrite, %posy%, %CONFIG_FILE%, Window, PosY
    IniWrite, %sizew%, %CONFIG_FILE%, Window, SizeWidth
    IniWrite, %sizeh%, %CONFIG_FILE%, Window, SizeHeight
}

CloseApp(){
    SaveWindow()
    ExitApp
}

failPause(string){
    MsgBox, Invalid argument "%string%", pausing execution
    Pause, On
}

; ---- Hotkey Functions
MeleeAttack(type){
    if (type == "light") {
        Send, {%MELEE_LIGHT%}
        ; Send, {XButton1}
    } else if (type == "heavy") {
        Send, {%MELEE_HEAVY%}
    } else {
        failPause(type)
    }
}

ScrollLock & o::
    MsgBox, Test
Return

ScrollLock & l::
    Toggle := !Toggle
    ;GuiControl,, MeleeLightStatus, "Light on"
    Loop,
    {
        If not Toggle
            ;GuiControl,, MeleeLightStatus, "Light off"
            break
        MeleeAttack("light")
        Sleep, 40
    }
; Return



XButton2::
    Pause,Toggle
Return

ScrollLock & r::
    SaveWindow()
    Reload
Return

ScrollLock & Escape::
    CloseApp()
Return

MainGuiClose:
    CloseApp()
Return
