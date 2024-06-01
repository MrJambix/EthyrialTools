#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>

Global $statusLabel, $pauseButton, $exitButton, $startButton, $successLabel
Global $successfulCatch = 0, $paused = False, $exitRequested = False, $running = False

Func CreateGUI()
    GUICreate("Fishing Script", 300, 300)
    GUICtrlCreateLabel("Fishing Script", 110, 20, 100, 20)
    $startButton = GUICtrlCreateButton("Start", 100, 60, 100, 30)
    $pauseButton = GUICtrlCreateButton("Pause", 50, 110, 75, 30)
    $exitButton = GUICtrlCreateButton("Exit", 175, 110, 75, 30)
    $statusLabel = GUICtrlCreateLabel("", 50, 160, 200, 20, $SS_CENTER)
    GUICtrlSetBkColor($statusLabel, 0x000000)
    GUICtrlSetColor($statusLabel, 0xFFFF00)
    $successLabel = GUICtrlCreateLabel("Successful Catch: 0", 100, 190, 200, 20)
    GUICtrlCreateLabel("KeyBind - F2: Start", 10, 230, 120, 20)
    GUICtrlCreateLabel("KeyBind - F3: Pause", 10, 250, 120, 20)
    GUICtrlCreateLabel("KeyBind - F4: Exit", 10, 270, 120, 20)
    GUISetState(@SW_SHOW)
    
    HotKeySet("{F2}", "StartFishingScript")
    HotKeySet("{F3}", "TogglePause")
    HotKeySet("{F4}", "ExitScript")
    AdlibRegister("MainLoop", 100)

    While 1
        $msg = GUIGetMsg()
        Select
            Case $msg = $GUI_EVENT_CLOSE
                ExitScript()
            Case $msg = $startButton
                StartFishingScript()
            Case $msg = $pauseButton
                TogglePause()
            Case $msg = $exitButton
                ExitScript()
        EndSelect
    WEnd
EndFunc

Func MainLoop()
    If $exitRequested Then ExitScript()
    If Not $running Or $paused Then Return
    MainMacroFunction()
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
    MouseClick("left")
    Sleep(2000)
EndFunc

Func MainMacroFunction()
    GUICtrlSetData($statusLabel, "Selecting Fishing Rod")
    Send("1")
    Sleep(1000)
    GUICtrlSetData($statusLabel, "Casting")
    MouseClick("left")
    Sleep(1000)
    $successfulCatch += 1
    GUICtrlSetData($successLabel, "Successful Catch: " & $successfulCatch)
EndFunc

Func TogglePause()
    If Not $running Then Return
    $paused = Not $paused
    If $paused Then
        GUICtrlSetData($pauseButton, "Resume")
        GUICtrlSetData($statusLabel, "Paused")
    Else
        GUICtrlSetData($pauseButton, "Pause")
        GUICtrlSetData($statusLabel, "Resuming...")
    EndIf
EndFunc

Func ExitScript()
    $exitRequested = True
    GUIDelete()
    Exit
EndFunc

CreateGUI()
