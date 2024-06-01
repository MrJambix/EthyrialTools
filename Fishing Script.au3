#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>

Global $statusLabel, $successLabel
Global $successfulCatch = 0, $paused = False, $exitRequested = False, $running = False

Func CreateGUI()
    GUICreate("Fishing Script", 300, 260) ; Adjusted height to fit keybind labels
    GUICtrlCreateLabel("Fishing Script", 110, 20, 100, 20)
    $statusLabel = GUICtrlCreateLabel("", 50, 80, 200, 20, $SS_CENTER)
    GUICtrlSetBkColor($statusLabel, 0x000000) ; Black background
    GUICtrlSetColor($statusLabel, 0xFFFF00) ; Yellow text
    $successLabel = GUICtrlCreateLabel("Successful Catch: 0", 50, 110, 200, 20)
    
    ; Keybind labels added here
    GUICtrlCreateLabel("Press F2 to Start", 10, 140, 280, 20)
    GUICtrlCreateLabel("Press F3 to Pause/Resume", 10, 160, 280, 20)
    GUICtrlCreateLabel("Press F4 to Exit", 10, 180, 280, 20)

    GUISetState(@SW_SHOW)

    HotKeySet("{F2}", "StartFishingScript")
    HotKeySet("{F3}", "TogglePause")
    HotKeySet("{F4}", "ExitScript")
    AdlibRegister("MainLoop", 100)
    
    While 1
        $msg = GUIGetMsg()
        If $msg = $GUI_EVENT_CLOSE Then ExitScript()
        Sleep(10) ; Prevent high CPU usage
    WEnd
EndFunc

Func StartFishingScript()
    If $running Then Return
    $running = True
    $paused = False
    MsgBox($MB_OK, "Instructions", "Place Fishing Rod on skill Slot 1. Ensure you set the mouse on top of the water location and leave it there.")
    For $i = 5 To 1 Step -1
        GUICtrlSetData($statusLabel, "Starting in " & $i & " seconds...")
        Sleep(1000)
    Next
    GUICtrlSetData($statusLabel, "Beginning Script")
    MainMacroFunction()
EndFunc

Func MainMacroFunction()
    While $running And Not $paused
        GUICtrlSetData($statusLabel, "Selecting Fishing Rod")
        Send("1")
        Sleep(1000)
        GUICtrlSetData($statusLabel, "Casting")
        MouseClick("left")
        Sleep(1000)
        $successfulCatch += 1
        GUICtrlSetData($successLabel, "Successful Catch: " & $successfulCatch)
        Sleep(1000) ; Adjust timing as needed for the fishing cycle
    WEnd
EndFunc

Func TogglePause()
    If Not $running Then Return
    $paused = Not $paused
    If $paused Then
        GUICtrlSetData($statusLabel, "Paused")
    Else
        GUICtrlSetData($statusLabel, "Resuming...")
        MainMacroFunction()
    EndIf
EndFunc

Func ExitScript()
    $exitRequested = True
    GUIDelete()
    Exit
EndFunc

CreateGUI()
