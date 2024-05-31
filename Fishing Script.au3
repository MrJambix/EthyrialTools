#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>

Global $statusLabel
Global $pauseButton
Global $exitButton
Global $startButton
Global $successLabel
Global $successfulCatch = 0
Global $paused = False
Global $exitRequested = False
Global $running = False

; Function to create the GUI
Func CreateGUI()
    ; Create the main GUI window
    GUICreate("Fishing Script", 300, 300)

    ; Add a label for the title
    GUICtrlCreateLabel("Fishing Script", 110, 20, 100, 20)

    ; Add a Start button
    $startButton = GUICtrlCreateButton("Start", 100, 60, 100, 30)

    ; Add a Pause button
    $pauseButton = GUICtrlCreateButton("Pause", 50, 110, 75, 30)

    ; Add an Exit button
    $exitButton = GUICtrlCreateButton("Exit", 175, 110, 75, 30)

    ; Add a status label with black background and yellow text
    $statusLabel = GUICtrlCreateLabel("", 50, 160, 200, 20, $SS_CENTER)
    GUICtrlSetBkColor($statusLabel, 0x000000) ; Set background color to black
    GUICtrlSetColor($statusLabel, 0xFFFF00) ; Set text color to yellow

    ; Add a Successful Catch counter label
    $successLabel = GUICtrlCreateLabel("Successful Catch: 0", 100, 190, 200, 20)

    ; Add labels for key bindings
    GUICtrlCreateLabel("KeyBind - F2: Start", 10, 230, 120, 20)
    GUICtrlCreateLabel("KeyBind - F3: Pause", 10, 250, 120, 20)
    GUICtrlCreateLabel("KeyBind - F4: Exit", 10, 270, 120, 20)

    ; Show the GUI
    GUISetState(@SW_SHOW)

    ; Set HotKeys
    HotKeySet("{F2}", "StartFishingScript")
    HotKeySet("{F3}", "TogglePause")
    HotKeySet("{F4}", "ExitScript")

    ; Start the Adlib function to check for the main function execution
    AdlibRegister("MainLoop", 100)

    ; Event loop to handle GUI events
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
                $exitRequested = True
                ExitScript()
        EndSelect
    WEnd
EndFunc

; Main event loop function
Func MainLoop()
    If $exitRequested Then ExitScript()
    If Not $running Or $paused Then Return

    MainMacroFunction()
EndFunc

; Function to start the fishing script
Func StartFishingScript()
    ; Check if already running
    If $running Then Return
    $running = True
    $paused = False

    ; Show instructions to the user
    MsgBox($MB_OK, "Instructions", "Place Fishing Rod on skill Slot 1. Ensure you set the mouse on top of the water location and leave it there.")
    ; Display a countdown before starting the main macro function
    For $i = 5 To 1 Step -1
        GUICtrlSetData($statusLabel, "Starting in " & $i & " seconds...")
        Sleep(1000)
    Next
    GUICtrlSetData($statusLabel, "Beginning Script")
    ; Click the current mouse position
    MouseClick("left")
    ; Wait for 2 seconds
    Sleep(2000)
EndFunc

; Main macro function
Func MainMacroFunction()
    ; Update status: Selecting Fishing Rod
    GUICtrlSetData($statusLabel, "Selecting Fishing Rod")
    ; Press 1 to select fishing rod
    Send("1")
    Sleep(1000) ; wait 1 second for visual confirmation

    ; Update status: Casting
    GUICtrlSetData($statusLabel, "Casting")
    ; Perform a left mouse click to cast
    MouseClick("left")
    Sleep(1000) ; wait 1 second for visual confirmation

    ; Increment and update Successful Catch counter
    $successfulCatch += 1
    GUICtrlSetData($successLabel, "Successful Catch: " & $successfulCatch)
EndFunc

; Function to toggle the pause state
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

; Function to exit the script immediately
Func ExitScript()
    $exitRequested = True
    GUIDelete()
    Exit
EndFunc

; Call the function to create the GUI
CreateGUI()
