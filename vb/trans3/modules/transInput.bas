Attribute VB_Name = "transInput"
'=========================================================================
'All contents copyright 2003, 2004, Christopher Matthews or Contributors
'All rights reserved.  YOU MAY NOT REMOVE THIS NOTICE.
'Read LICENSE.txt for licensing info
'=========================================================================

'=========================================================================
' Handles keyboard and mouse input
'=========================================================================

Option Explicit

'=========================================================================
' Check status of a key
'=========================================================================
Private Declare Function GetAsyncKeyState Lib "user32" (ByVal vKey As Long) As Integer

'=========================================================================
' Virtual key codes
'=========================================================================
Private Const VK_ADD = &H6B
Private Const VK_ATTN = &HF6
Private Const VK_BACK = &H8
Private Const VK_CANCEL = &H3
Private Const VK_CAPITAL = &H14
Private Const VK_CLEAR = &HC
Private Const VK_CONTROL = &H11
Private Const VK_CRSEL = &HF7
Private Const VK_DECIMAL = &H6E
Private Const VK_DELETE = &H2E
Private Const VK_DIVIDE = &H6F
Private Const VK_DOWN = &H28
Private Const VK_END = &H23
Private Const VK_EREOF = &HF9
Private Const VK_ESCAPE = &H1B
Private Const VK_EXECUTE = &H2B
Private Const VK_EXSEL = &HF8
Private Const VK_F1 = &H70
Private Const VK_F10 = &H79
Private Const VK_F11 = &H7A
Private Const VK_F12 = &H7B
Private Const VK_F13 = &H7C
Private Const VK_F14 = &H7D
Private Const VK_F15 = &H7E
Private Const VK_F16 = &H7F
Private Const VK_F17 = &H80
Private Const VK_F18 = &H81
Private Const VK_F19 = &H82
Private Const VK_F2 = &H71
Private Const VK_F20 = &H83
Private Const VK_F21 = &H84
Private Const VK_F22 = &H85
Private Const VK_F23 = &H86
Private Const VK_F24 = &H87
Private Const VK_F3 = &H72
Private Const VK_F4 = &H73
Private Const VK_F5 = &H74
Private Const VK_F6 = &H75
Private Const VK_F7 = &H76
Private Const VK_F8 = &H77
Private Const VK_F9 = &H78
Private Const VK_HELP = &H2F
Private Const VK_HOME = &H24
Private Const VK_INSERT = &H2D
Private Const VK_LBUTTON = &H1
Private Const VK_LCONTROL = &HA2
Private Const VK_LEFT = &H25
Private Const VK_LMENU = &HA4
Private Const VK_LSHIFT = &HA0
Private Const VK_MBUTTON = &H4
Private Const VK_MENU = &H12
Private Const VK_MULTIPLY = &H6A
Private Const VK_NEXT = &H22
Private Const VK_NONAME = &HFC
Private Const VK_NUMLOCK = &H90
Private Const VK_NUMPAD0 = &H60
Private Const VK_NUMPAD1 = &H61
Private Const VK_NUMPAD2 = &H62
Private Const VK_NUMPAD3 = &H63
Private Const VK_NUMPAD4 = &H64
Private Const VK_NUMPAD5 = &H65
Private Const VK_NUMPAD6 = &H66
Private Const VK_NUMPAD7 = &H67
Private Const VK_NUMPAD8 = &H68
Private Const VK_NUMPAD9 = &H69
Private Const VK_OEM_CLEAR = &HFE
Private Const VK_PA1 = &HFD
Private Const VK_PAUSE = &H13
Private Const VK_PLAY = &HFA
Private Const VK_PRINT = &H2A
Private Const VK_PRIOR = &H21
Private Const VK_PROCESSKEY = &HE5
Private Const VK_RBUTTON = &H2
Private Const VK_RCONTROL = &HA3
Private Const VK_RETURN = &HD
Private Const VK_RIGHT = &H27
Private Const VK_RMENU = &HA5
Private Const VK_RSHIFT = &HA1
Private Const VK_SCROLL = &H91
Private Const VK_SELECT = &H29
Private Const VK_SEPARATOR = &H6C
Private Const VK_SHIFT = &H10
Private Const VK_SNAPSHOT = &H2C
Private Const VK_SPACE = &H20
Private Const VK_SUBTRACT = &H6D
Private Const VK_TAB = &H9
Private Const VK_UP = &H26
Private Const VK_ZOOM = &HFB

'=========================================================================
' Member variables
'=========================================================================
Private mouseX As Integer            'x pos of mouse
Private mouseY As Integer            'y pos of mouse
Private mouseMoveX As Integer        'x pos of mouse (dynamic)
Private mouseMoveY As Integer        'y pos of mouse (dynamic)
Private bWaitingForInput As Boolean  'waiting for input?
Private keyWaitState As Long         'Key pressed on last event.
Private keyShiftState As Long        'Key pressed shift value on last event.
Private keyAsciiState As Long        'Key pressed on last event (ascii).
Private ignoreKeyDown As Boolean     'Ignore key down events?

'=========================================================================
' Public variables
'=========================================================================
Public useArrowKeys As Boolean       'Use arrow keys?
Public useNumberPad As Boolean       'Use number pad?
Public useJoystick As Boolean        'Use joystick?

'=========================================================================
' Get mouse x coord
'=========================================================================
Public Property Get getMouseX() As Long
    getMouseX = mouseMoveX
End Property

'=========================================================================
' Get mouse y coord
'=========================================================================
Public Property Get getMouseY() As Long
    getMouseY = mouseMoveY
End Property

'=========================================================================
' Get the last key pressed
'=========================================================================
Public Property Get lastKeyPressed() As String
    lastKeyPressed = keyWaitState
End Property

'=========================================================================
' Makes us stop waiting for input
'=========================================================================
Public Sub stopWaitingForInput()
    bWaitingForInput = False
End Sub

'=========================================================================
' Read-only pointer to bWaitingForInput
'=========================================================================
Public Property Get waitingForInput() As Boolean
    waitingForInput = bWaitingForInput
End Property

'=========================================================================
' Update ASCII value of last key pressed
'=========================================================================
Public Sub setAsciiKeyState(ByVal state As Long)
    On Error Resume Next
    keyAsciiState = state
End Sub

'=========================================================================
' Wait until no key is being pressed
'=========================================================================
Public Sub FlushKB()
    On Error Resume Next
    Do Until (LenB(getKey()) = 0)
        Call processEvent
    Loop
End Sub

'=========================================================================
' "Delay" for the number of milliseconds passed in
'=========================================================================
Public Sub DoEventsFor(ByVal milliSeconds As Long)

    Dim startTime As Double

    startTime = Timer()
    Do Until (Timer() - startTime >= milliSeconds / 1000)
        ' Don't lock up
        Call processEvent
    Loop

End Sub

'=========================================================================
' Check if a key is being pressed
'=========================================================================
Public Function getKey(Optional ByVal milliSeconds As Long = 15) As String

    On Error Resume Next

    'Clear the last pressed key.
    keyWaitState = -1

    If (milliSeconds = 0) Then milliSeconds = 15

    'call processevent so we can get a key...
    Call DoEventsFor(milliSeconds)

    'Check the joystick.
    Dim jButton(4) As Boolean
    Dim theDir As Long
    
    'Get a movement direction and see any buttons that were pressed.
    theDir = joyDirection(jButton)
    
    If jButton(0) Then
        'If the primary button was pressed.
        
        getKey = "BUTTON"
        jButton(0) = False
        Exit Function
        
    End If
    
    If keyWaitState = -1 Then
        'If a button has still not been pressed, return nothing.
        getKey = vbNullString
        Exit Function
    End If
    
    Dim returnVal As String
    'Get a string of the key number.
    returnVal$ = Chr$(keyWaitState)
    
    'Check the key for common keys.
    If keyWaitState = 13 Then returnVal$ = "ENTER"
    If keyWaitState = 38 Then returnVal$ = "UP"
    If keyWaitState = 40 Then returnVal$ = "DOWN"
    If keyWaitState = 37 Then returnVal$ = "RIGHT"
    If keyWaitState = 39 Then returnVal$ = "LEFT"
    
    If keyShiftState = 1 Then returnVal$ = UCase$(returnVal$) 'If shift was pressed, return an upper-case letter.
    'Might want to add numberpad here too.
    
    getKey = returnVal

End Function

'=========================================================================
' Wait for a key to be pressed and return its ASCII value
'=========================================================================
Public Function getAsciiKey() As String
    
    On Error Resume Next
    
    'Clear the last pressed key (ascii)
    keyAsciiState = -1
    
    Dim repeat As Integer
    
    'Call call processevent 10 times(!). Give enough time for an input.
    For repeat = 0 To 10
        Call processEvent
    Next repeat
    
    If keyAsciiState = -1 Then
        'If a button has still not been pressed, return nothing.
        getAsciiKey = vbNullString
        Exit Function
    End If
    
    Dim returnVal As String
    'Get a string of the key number.
    returnVal = Chr$(keyAsciiState)
    
    getAsciiKey = returnVal

End Function

'=========================================================================
' Causes the key down event to be ignored
'=========================================================================
Public Sub haltKeyDownScanning()
    ignoreKeyDown = True
End Sub

'=========================================================================
' Causes the key down event to be processed
'=========================================================================
Public Sub startKeyDownScanning()
    ignoreKeyDown = False
End Sub

'=========================================================================
' Wait for a key to be pressed
'=========================================================================
Public Function WaitForKey() As String

    On Error Resume Next

    'Clear the last pressed key.
    keyWaitState = 0
    bWaitingForInput = True

    'Check the joystick.
    Dim jButton(4) As Boolean
    Dim theDir As Long

    Do While (keyWaitState = 0) And (Not jButton(0))
        Call processEvent
        'Get a movement direction and see any buttons that were pressed.
        theDir = joyDirection(jButton)
    Loop

    bWaitingForInput = False
    
    If jButton(0) Then
        'If the primary button was pressed.

        keyWaitState = 0
        WaitForKey = "BUTTON"
        jButton(0) = False
        Exit Function
        
    End If
    
    Dim jButtonNum As Integer
    For jButtonNum = 1 To UBound(jButton)
        'Check the other buttons
        If jButton(jButtonNum) Then
            WaitForKey = "BUTTON" & CStr(jButtonNum + 1)
        End If
    Next jButtonNum

    If (keyWaitState = 88) And (keyShiftState = 4) Then
        'User pressed ALT-X: Force exit.
        gGameState = GS_QUIT
    End If
    
    Dim returnVal As String
    'Get a string of the key number.
    returnVal = Chr$(keyWaitState)
    
    'Check the key for common keys.
    If keyWaitState = 13 Then returnVal$ = "ENTER"
    If keyWaitState = 38 Then returnVal$ = "UP"
    If keyWaitState = 40 Then returnVal$ = "DOWN"
    If keyWaitState = 37 Then returnVal$ = "LEFT"
    If keyWaitState = 39 Then returnVal$ = "RIGHT"
    If keyShiftState = 1 Then returnVal$ = UCase$(returnVal)
    'Might want to add numberpad here too.
    
    WaitForKey = returnVal
    
End Function

'=========================================================================
' Wait for the mouse to be moved
'=========================================================================
Public Sub getMouseMove(ByRef x As Long, ByRef y As Long)
    
    On Error Resume Next
    
    mouseMoveX = -1
    bWaitingForInput = True
    
    Do While (mouseMoveX = -1)
        Call processEvent
    Loop
    
    bWaitingForInput = False
    x = Int(mouseMoveX)
    y = Int(mouseMoveY)

End Sub

'=========================================================================
' Wait for the mouse to be clicked
'=========================================================================
Public Sub getMouse(ByRef x As Long, ByRef y As Long)

    On Error Resume Next

    mouseX = -1
    bWaitingForInput = True

    Do While (mouseX = -1)
        Call processEvent
    Loop

    bWaitingForInput = False

    x = Int(mouseX)
    y = Int(mouseY)

End Sub

'=========================================================================
' Check if the mouse was moved
'=========================================================================
Public Sub getMouseNoWait(ByRef x As Long, ByRef y As Long)

    On Error Resume Next
    
    bWaitingForInput = True
    Call DoEventsFor(15)
    bWaitingForInput = False

    x = Round(mouseX)
    y = Round(mouseY)

End Sub

'=========================================================================
' Check if a key is pressed
'=========================================================================
Public Function isPressed(ByVal theKey As String) As Boolean

    On Error Resume Next

    If (gGameState = GS_PAUSE) Then
        'Trans doesn't have focus!
        Exit Function
    End If

    'First check the joystick...
    Dim but(4) As Boolean
    Dim theDir As Long
    If mainMem.useJoystick = 1 Then
        theDir = joyDirection(but)
    End If
    
    Select Case UCase$(theKey)
    
        Case "LEFT":
            If GetAsyncKeyState(VK_LEFT) < 0 Then isPressed = True
            'If the left arrow key was pressed.
            Exit Function
            
        Case "RIGHT":
            If GetAsyncKeyState(VK_RIGHT) < 0 Then isPressed = True
            Exit Function
            
        Case "UP":
            If GetAsyncKeyState(VK_UP) < 0 Then isPressed = True
            Exit Function
            
        Case "DOWN":
            If GetAsyncKeyState(VK_DOWN) < 0 Then isPressed = True
            Exit Function
            
        Case "SPACE":
            If GetAsyncKeyState(VK_SPACE) < 0 Then isPressed = True
            Exit Function
        
        Case "ESC", "ESCAPE":
            If GetAsyncKeyState(VK_ESCAPE) < 0 Then isPressed = True
            Exit Function
        
        Case "ENTER":
            If GetAsyncKeyState(VK_RETURN) < 0 Then isPressed = True
            Exit Function
            
        'Added cases for the numberpad keys. Keeping them separate from directions for the moment.
        Case "NUMPAD0":
            If GetAsyncKeyState(VK_NUMPAD0) < 0 Then isPressed = True
            Exit Function
        
        Case "NUMPAD1":
            If GetAsyncKeyState(VK_NUMPAD1) < 0 Then isPressed = True
            Exit Function
            
        Case "NUMPAD2":
            If GetAsyncKeyState(VK_NUMPAD2) < 0 Then isPressed = True
            Exit Function
        
        Case "NUMPAD3":
            If GetAsyncKeyState(VK_NUMPAD3) < 0 Then isPressed = True
            Exit Function
        
        Case "NUMPAD4":
            If GetAsyncKeyState(VK_NUMPAD4) < 0 Then isPressed = True
            Exit Function
        
        Case "NUMPAD5":
            If GetAsyncKeyState(VK_NUMPAD5) < 0 Then isPressed = True
            Exit Function
                
        Case "NUMPAD6":
            If GetAsyncKeyState(VK_NUMPAD6) < 0 Then isPressed = True
            Exit Function
            
        Case "NUMPAD7":
            If GetAsyncKeyState(VK_NUMPAD7) < 0 Then isPressed = True
            Exit Function
            
        Case "NUMPAD8":
            If GetAsyncKeyState(VK_NUMPAD8) < 0 Then isPressed = True
            Exit Function
        
        Case "NUMPAD9":
            If GetAsyncKeyState(VK_NUMPAD9) < 0 Then isPressed = True
            Exit Function
            
        'Joystick buttons.
        Case "JOYLEFT":
            If theDir = 5 Or theDir = 6 Or theDir = 4 Then isPressed = True
            'If the joystick was moved left.
            Exit Function
        
        Case "JOYRIGHT":
            If theDir = 1 Or theDir = 2 Or theDir = 8 Then isPressed = True
            Exit Function
            
        Case "JOYUP":
            If theDir = 3 Or theDir = 4 Or theDir = 2 Then isPressed = True
            Exit Function
            
        Case "JOYDOWN":
            If theDir = 7 Or theDir = 8 Or theDir = 6 Then isPressed = True
            Exit Function
        
        Case "BUTTON", "BUTTON1":
            isPressed = but(0)
            Exit Function
        Case "BUTTON2":
            isPressed = but(1)
            Exit Function
        Case "BUTTON3":
            isPressed = but(2)
            Exit Function
        Case "BUTTON4":
            isPressed = but(3)
            Exit Function
        
        Case Else:
            'Not a reserved key.
            
            theKey = UCase$(theKey)
            
            'Asc function returns the the ANSI code of the character.
            Dim code As Long
            code = Asc(Mid$(theKey, 1, 1))
            
            If GetAsyncKeyState(code) < 0 Then
                isPressed = True
            End If
    End Select
    
    Call processEvent
    
End Function

'=========================================================================
' Handles key down events
'=========================================================================
Public Sub keyDownEvent(ByVal keyCode As Integer, ByVal Shift As Integer)

    On Error Resume Next
    
    'Save old keycodes.
    keyWaitState = keyCode
    keyShiftState = Shift
    
    'When a dialog window is called, either ShowFileDialog or ShowPromptDialog.
    'Control is returned when the dialog is closed.
    If (ignoreKeyDown) Then Exit Sub

    'Inform plugins...
    Dim strKey As String
    Dim Index As Integer
    
    'Check some common codes.
    Select Case keyCode
        Case 13:
            strKey = "ENTER"
        Case 27:
            strKey = "ESC"
        Case 32:
            strKey = "SPACE"
        Case 37:
            strKey = "LEFT"
        Case 38:
            strKey = "UP"
        Case 39:
            strKey = "RIGHT"
        Case 40:
            strKey = "DOWN"
        Case Else:
            strKey = Chr$(keyCode)
    End Select

    'Check custom plugins to see if they request an input.
    Dim plugName As String
    For Index = 0 To UBound(mainMem.plugins)
        If (LenB(mainMem.plugins(Index)) <> 0) Then
            'If there is a plugin in this slot, get the name.
            plugName = PakLocate(projectPath & plugPath & mainMem.plugins(Index))
            
            If PLUGInputRequested(plugName, INPUT_KB) = 1 Then
                'If an input is requested, return that input to the plugin.
                Call PLUGEventInform(plugName, keyCode, -1, -1, -1, Shift, strKey, INPUT_KB)
            End If
        End If
    Next Index
    
    'Check the menu plugin.
    If (LenB(mainMem.menuPlugin) <> 0) Then
        plugName = PakLocate(projectPath & plugPath & mainMem.menuPlugin)
        
        If PLUGInputRequested(plugName, INPUT_KB) = 1 Then
            Call PLUGEventInform(plugName, keyCode, -1, -1, -1, Shift, strKey, INPUT_KB)
        End If
    End If
    
    'Check the fight plugin.
    If (LenB(mainMem.fightPlugin) <> 0) Then
        plugName = PakLocate(projectPath & plugPath & mainMem.fightPlugin)
        
        If PLUGInputRequested(plugName, INPUT_KB) = 1 Then
            Call PLUGEventInform(plugName, keyCode, -1, -1, -1, Shift, strKey, INPUT_KB)
        End If
    End If


    If (Not runningProgram) And (Not bInMenu) And (Not fightInProgress) Then
        'Scan for special keys.
        
        If keyCode = 88 And Shift = 4 Then
            'user pressed ALT-X: Force exit.
            gGameState = GS_QUIT
            Exit Sub
        End If
        
        'If keyCode = 68 And Shift = 4 Then
            'User pressed ALT-D (toggle debugging).
        '    debugging = Not (debugging)
        'End If
        
        If UCase$(CStr(mainMem.Key)) = UCase$(CStr(keyCode)) Then
            'User pressed the activation key.
            'Check to see if there is a program to be activated at this location.
            Call programTest(pPos(selectedPlayer))
        End If
        
        'Check primary runtime key: run its associated program if so.
        If UCase$(CStr(keyCode)) = UCase$(CStr(mainMem.runKey)) Then
            Call runProgram(projectPath & prgPath & mainMem.runTime$)
            Exit Sub
        End If
        
        'Check extended runtime keys...
        For Index = 0 To 50
            If UCase$(Chr$(keyCode)) = UCase$(Chr$(mainMem.runTimeKeys(Index))) Then
                If (LenB(mainMem.runTimePrg$(Index)) <> 0) Then
                
                    Call runProgram(projectPath & prgPath & mainMem.runTimePrg$(Index))
                    Exit Sub
                
                End If
            End If
        Next Index
        
        'Check the menu key.
        If UCase$(CStr(keyCode)) = UCase$(CStr(mainMem.menuKey)) Then
            Call showMenu
            Exit Sub
        End If
        
    End If 'End if not (programRunning)
    
End Sub

'=========================================================================
' Handles mouse down events
'=========================================================================
Public Sub mouseDownEvent(ByVal x As Integer, ByVal y As Integer, ByVal Shift As Integer, ByVal Button As Integer)

    On Error GoTo fin

    'Returned values from the form.
    mouseX = x
    mouseY = y

    'Inform plugins...
    Dim Index As Integer
    Dim plugName As String

    'Check custom plugins to see if they request an input.
    For Index = 0 To UBound(mainMem.plugins)
        If (LenB(mainMem.plugins(Index)) <> 0) Then
            'If there is a plugin in this slot, get the name.
            plugName = PakLocate(projectPath & plugPath & mainMem.plugins(Index))
            
            If PLUGInputRequested(plugName, INPUT_MOUSEDOWN) = 1 Then
                'If an input is requested, return that input to the plugin.
                Call PLUGEventInform(plugName, -1, x, y, Button, Shift, "", INPUT_MOUSEDOWN)
            End If
        End If
    Next Index

    'Check the menu plugin.
    If (LenB(mainMem.menuPlugin) <> 0) Then
        plugName = PakLocate(projectPath & plugPath & mainMem.menuPlugin)
        
        If PLUGInputRequested(plugName, INPUT_MOUSEDOWN) = 1 Then
            Call PLUGEventInform(plugName, -1, x, y, Button, Shift, "", INPUT_MOUSEDOWN)
        End If
    End If

    'Check the fight plugin.
    If (LenB(mainMem.fightPlugin) <> 0) Then
        plugName = PakLocate(projectPath & plugPath & mainMem.fightPlugin)
        
        If PLUGInputRequested(plugName, INPUT_MOUSEDOWN) = 1 Then
            Call PLUGEventInform(plugName, -1, x, y, Button, Shift, "", INPUT_MOUSEDOWN)
        End If
    End If

fin:
End Sub

'=========================================================================
' Handles mouse move events
'=========================================================================
Public Sub mouseMoveEvent(ByVal x As Integer, ByVal y As Integer)
    On Error Resume Next
    mouseMoveX = x
    mouseMoveY = y
    If (Not runningProgram) Then
        Call DXRefresh
    Else
        Call renderRPGCodeScreen
    End If
End Sub

'=========================================================================
' Scan for important keys (like arrows)
'=========================================================================
Public Sub scanKeys()

    On Error Resume Next
    
    Dim queue As String
    queue = vbNullString
    'Temporarily defining these true always. Defined at top of this module.
    useArrowKeys = True
    useNumberPad = True
    
    If (isPressed("RIGHT") And isPressed("UP") And useArrowKeys) Or (isPressed("NUMPAD9") And useNumberPad) Then
        'Move NorthEast
        
        'If [UP and RIGHT are pressed and using arrow keys is enabled] or
        '   [NUMPAD9 is pressed and the numberpad is enabled]
        
        'Update the origin location to the current location (however this is already done
        'by the isometric "jump" correction in the mainLoop).
        pendingPlayerMovement(selectedPlayer).direction = MV_NE
        queue = "5"
   
    ElseIf (isPressed("LEFT") And isPressed("UP") And useArrowKeys) Or (isPressed("NUMPAD7") And useNumberPad) Then
        'Move NorthWest
        pendingPlayerMovement(selectedPlayer).direction = MV_NW
        queue = "6"

    ElseIf (isPressed("RIGHT") And isPressed("DOWN") And useArrowKeys) Or (isPressed("NUMPAD3") And useNumberPad) Then
        'Move SouthEast
        pendingPlayerMovement(selectedPlayer).direction = MV_SE
        queue = "7"
    
    ElseIf (isPressed("LEFT") And isPressed("DOWN") And useArrowKeys) Or (isPressed("NUMPAD1") And useNumberPad) Then
        'Move SouthWest
        pendingPlayerMovement(selectedPlayer).direction = MV_SW
        queue = "8"
    
    ElseIf (isPressed("UP") And useArrowKeys) Or _
        (isPressed("NUMPAD8") And useNumberPad) Or (isPressed("JOYUP") And useJoystick) Then
        'Move North
        pendingPlayerMovement(selectedPlayer).direction = MV_NORTH
        queue = "1"

    ElseIf (isPressed("DOWN") And useArrowKeys) Or _
        (isPressed("NUMPAD2") And useNumberPad) Or (isPressed("JOYDOWN") And useJoystick) Then
        'Move South
        pendingPlayerMovement(selectedPlayer).direction = MV_SOUTH
        queue = "2"

    ElseIf (isPressed("RIGHT") And useArrowKeys) Or _
        (isPressed("NUMPAD6") And useNumberPad) Or (isPressed("JOYRIGHT") And useJoystick) Then
        'Move East
        pendingPlayerMovement(selectedPlayer).direction = MV_EAST
        queue = "3"

    ElseIf (isPressed("LEFT") And useArrowKeys) Or _
        (isPressed("NUMPAD4") And useNumberPad) Or (isPressed("JOYLEFT") And useJoystick) Then
        'Move West
        pendingPlayerMovement(selectedPlayer).direction = MV_WEST
        queue = "4"

    ElseIf isPressed("BUTTON1") Then
        'Let joystick button 1 act as the activation key.
        keyWaitState = mainMem.Key
        Call programTest(pPos(selectedPlayer))
        Exit Sub

    ElseIf isPressed("BUTTON2") Then
        'Bring up the menu when the user presses joystick button 2.
        Call showMenu
        Exit Sub

    End If
    
    'Queue up the new movement.
    If LenB(queue) <> 0 Then
        'Overwrite any queued movements.
        pendingPlayerMovement(selectedPlayer).queue = queue
        gGameState = GS_MOVEMENT
    End If
    
    Exit Sub
    
    'Old:
    
    'Insert the target co-ordinates based on the movement direction.
    pendingPlayerMovement(selectedPlayer).xOrig = pPos(selectedPlayer).x
    pendingPlayerMovement(selectedPlayer).yOrig = pPos(selectedPlayer).y
    pendingPlayerMovement(selectedPlayer).lOrig = pPos(selectedPlayer).l
    Call insertTarget(pendingPlayerMovement(selectedPlayer))
    
    'Set the frame count for the move to zero (i.e. next frame will be the first).
    'movementCounter = 0
    
    'Set the mainLoop state to movement. The mainLoop will repeat until the required number of
    'frames are drawn.
    gGameState = GS_MOVEMENT
   

End Sub
