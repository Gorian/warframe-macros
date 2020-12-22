#NoEnv ; For performance and compatibility with future AutoHotkey releases
#Warn
#SingleInstance, Force
#MaxThreadsPerHotkey 2
#ErrorStdOut
#IfWinActive, Warframe ; only use hotkeys in Warframe
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

; Read Config
IniRead, WindowPosX, %CONFIG_FILE%, Window, PosX 
IniRead, WindowPosY, %CONFIG_FILE%, Window, PosY
IniRead, WindowSizeW, %CONFIG_FILE%, Window, SizeWidth, 600
IniRead, WindowSizeH, %CONFIG_FILE%, Window, SizeHeight, 600
IniRead, MeleeLightAttackState, %CONFIG_FILE%, Options, MeleeLightAttackEnabled, 1
IniRead, MeleeLightAttackHK, %CONFIG_FILE%, Options, MeleeLightAttackHotKey, E
IniRead, MeleeHeavyAttackState, %CONFIG_FILE%, Options, MeleeHeavyAttackEnabled, 1
IniRead, MeleeHeavyAttackHK, %CONFIG_FILE%, Options, MeleeHeavyAttackHotKey, 1

; Define main GUI
    Gui, Main:New,, %GUI_TITLE%
    Gui, Main:Add, Text, x12 y9 w100 h20 , Warframe Macros
    Gui, Main:Add, Text, x12 y39 w100 h20 , --Melee--
    Gui, Main:Add, CheckBox, x12 y59 w100 h20 +Right vMeleeLightToggle gMeleeLightChanged Checked%MeleeLightAttackState%, Light Attack
    Gui, Main:Add, Text, x42 y79 w50 h20 , HotKey:
    Gui, Main:Add, Hotkey, x92 y79 w60 h20 , %MeleeLightAttackHK%
    Gui, Main:Add, CheckBox, x12 y99 w100 h20 +Right vMeleeHeavyToggle gMeleeHeavyChanged Checked%MeleeHeavyAttackState%,, Heavy Attack
    Gui, Main:Add, Text, x42 y119 w50 h20 , HotKey:
    Gui, Main:Add, Hotkey, x92 y119 w60 h20 ,  %MeleeHeavyAttackHK%
    
    
    if (WindowPosX = "") or (WindowPosY = "") {
        Gui, Main:Show, w%WindowSizeW% h%WindowSizeH%
    } else {
        Gui, Main:Show, w%WindowSizeW% h%WindowSizeH% x%WindowPosX% y%WindowPosY%
    }
    
    ; Define HotKeys
    Hotkey, $%MELEE_LIGHT%, LightMeleeAttackKey
    Hotkey, $%MELEE_HEAVY%, HeavyMeleeAttackKey
Return

; ---- System Functions
MeleeLightChanged:
    Gui, Submit, NoHide
    ; MsgBox, Value is %MeleeLightToggle%
    IniWrite, %MeleeLightToggle%, %CONFIG_FILE%, GUIState, MeleeLightAttackOpt
Return

MeleeHeavyChanged:
    Gui, Submit, NoHide
    IniWrite, %MeleeHeavyToggle%, %CONFIG_FILE%, GUIState, MeleeHeavyAttackOpt
Return

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

#if MeleeLightToggle
LightMeleeAttackKey:
    Send, {Blind}{%MELEE_LIGHT%}
    KeyWait %MELEE_LIGHT%, T0.5
    If ErrorLevel
        While GetKeyState(MELEE_LIGHT,"p") {
            Send, {Blind}{%MELEE_LIGHT%}
            Sleep 50
        }
Return

#if MeleeHeavyToggle
HeavyMeleeAttackKey:
    Send, {Blind}{%MELEE_Heavy%}
    KeyWait %MELEE_Heavy%, T0.5
    If ErrorLevel
        While GetKeyState(MELEE_Heavy,"p"){
            Send, {Blind}{%MELEE_Heavy%}
            Sleep 50
        }
Return

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
