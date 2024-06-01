; Script Name: Fishing Script
; Description: This script automates fishing activities in games or simulations, ensuring efficient and optimized fishing based on predefined settings.
; Creator: MrJambix
; GitHub Repository: https://github.com/MrJambix/EthyrialTools

#RequireAdmin  ; Ensures the script runs with administrator privileges

#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <File.au3>
#include <ColorConstants.au3>
#include <Timers.au3>
#include <Process.au3>

Global $configFile = @ScriptDir & "\config.ini"
Global $selectedProcess = ""
Global $statusLabel, $successLabel, $mainGui, $settingsButton, $themeButton
Global $successfulCatch = 0, $paused = False, $exitRequested = False, $running = False

; Load or create settings
CheckConfig()

; Select the target process
$selectedProcess = SelectProcess("Ethyrial.exe")
If $selectedProcess = "" Then
    MsgBox($MB_ICONERROR, "No Process Selected", "You must select a process to continue.")
    Exit
EndIf

Func SelectProcess($processName)
    Local $processList = ProcessList($processName)
    If $processList[0][0] = 0 Then
        MsgBox($MB_ICONERROR, "Error", "The process " & $processName & " is not running.")
        Return ""
    EndIf

    Local $pid = $processList[1][1]
    Local $windowTitle = GetWindowTitleByPID($pid)
    If $windowTitle <> "" Then
        Return $windowTitle
    Else
        MsgBox($MB_ICONERROR, "Error", "Could not find a window for the process " & $processName & ".")
        Return ""
    EndIf
EndFunc

Func GetWindowTitleByPID($pid)
    Local $winList = WinList()
    For $i = 1 To $winList[0][0]
        If WinGetProcess($winList[$i][1]) = $pid Then
            Return $winList[$i][0]
        EndIf
    Next
    Return ""
EndFunc

Func CheckConfig()
    If Not FileExists($configFile) Then
        IniWrite($configFile, "Hotkeys", "Start", "{F2}")
        IniWrite($configFile, "Hotkeys", "Pause", "{F3}")
        IniWrite($configFile, "Hotkeys", "Exit", "{F4}")
    EndIf
EndFunc

Func CreateGUI()
    $mainGui = GUICreate("Fishing Script", 300, 300)
    $titleLabel = GUICtrlCreateLabel("Fishing Script", 70, 20, 160, 30)
    GUICtrlSetFont($titleLabel, 12, 800, 0, "Arial")  ; Set font size to 12, bold weight (800)

    $statusLabel = GUICtrlCreateLabel("", 50, 80, 200, 20, $SS_CENTER)
    GUICtrlSetBkColor($statusLabel, 0x000000)  ; Set background color to black
    GUICtrlSetColor($statusLabel, 0xFFFFFF)  ; Set text color to white

    $successLabel = GUICtrlCreateLabel("Successful Catch: 0", 50, 110, 200, 20)

    $settingsButton = GUICtrlCreateButton("Settings", 10, 260, 80, 30)
    $themeButton = GUICtrlCreateButton("Change Theme", 210, 260, 80, 30)

    GUISetState(@SW_SHOW)

    HotKeySet(IniRead($configFile, "Hotkeys", "Start", "{F2}"), "StartFishingScript")
    HotKeySet(IniRead($configFile, "Hotkeys", "Pause", "{F3}"), "TogglePause")
    HotKeySet(IniRead($configFile, "Hotkeys", "Exit", "{F4}"), "ExitScript")

    While 1
        If WinExists($selectedProcess) And WinActive($selectedProcess) Then
            ; Main operation functions here, executed only when the window is active
        Else
            PauseScript()
        EndIf
        Sleep(100)  ; Reduce CPU usage
    WEnd
EndFunc

Func ShowSettings()
    Local $settingsGUI = GUICreate("Settings", 200, 240)  ; Adjusted for additional instructions
    Local $infoLabel = GUICtrlCreateLabel("Insert Keybind inside {}", 10, 10, 180, 20)
    GUICtrlCreateLabel("Start Key (e.g., {F2}):", 10, 40, 180, 20)
    Local $startKeyInput = GUICtrlCreateInput(IniRead($configFile, "Hotkeys", "Start", "{F2}"), 10, 60, 180, 20)
    GUICtrlCreateLabel("Pause/Resume Key (e.g., {F3}):", 10, 90, 180, 20)
    Local $pauseKeyInput = GUICtrlCreateInput(IniRead($configFile, "Hotkeys", "Pause", "{F3}"), 10, 110, 180, 20)
    GUICtrlCreateLabel("Exit Key (e.g., {F4}):", 10, 140, 180, 20)
    Local $exitKeyInput = GUICtrlCreateInput(IniRead($configFile, "Hotkeys", "Exit", "{F4}"), 10, 160, 180, 20)
    Local $saveButton = GUICtrlCreateButton("Save", 60, 190, 80, 30)
    GUISetState(@SW_SHOW, $settingsGUI)

    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                GUIDelete($settingsGUI)
                Return
            Case $saveButton
                SaveHotkeys(GUICtrlRead($startKeyInput), GUICtrlRead($pauseKeyInput), GUICtrlRead($exitKeyInput))
                GUIDelete($settingsGUI)
                Return
        EndSwitch
    WEnd
EndFunc

Func ChangeTheme()
    Local $bgColor = Random(0x000000, 0xFFFFFF, 1)
    Local $textColor = Random(0x000000, 0xFFFFFF, 1)

    ; Apply the random colors to the GUI elements
    GUICtrlSetBkColor($statusLabel, $bgColor)
    GUICtrlSetColor($statusLabel, $textColor)
    GUICtrlSetBkColor($successLabel, $bgColor)
    GUICtrlSetColor($successLabel, $textColor)
    GUICtrlSetBkColor($settingsButton, $bgColor)
    GUICtrlSetColor($settingsButton, $textColor)
    GUICtrlSetBkColor($themeButton, $bgColor)
    GUICtrlSetColor($themeButton, $textColor)
EndFunc

Func SaveHotkeys($start, $pause, $exit)
    IniWrite($configFile, "Hotkeys", "Start", $start)
    IniWrite($configFile, "Hotkeys", "Pause", $pause)
    IniWrite($configFile, "Hotkeys", "Exit", $exit)
    HotKeySet($start, "StartFishingScript")
    HotKeySet($pause, "TogglePause")
    HotKeySet($exit, "ExitScript")
EndFunc

Func PauseScript()
    While Not WinActive($selectedProcess)
        Sleep(500)  ; Check every half second to see if the window has become active
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
    GUICtrlSetData($statusLabel, $paused ? "Paused" : "Resuming...")
    If Not $paused Then MainMacroFunction()
EndFunc

Func ExitScript()
    $exitRequested = True
    GUIDelete()
    Exit
EndFunc

CreateGUI()
