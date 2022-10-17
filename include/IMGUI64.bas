'---------------------------------------------------------------------------------------------------------
' QB64-PE Immediate mode GUI Library
'
' Based on Terry Ritchie's work: GLINPUT, RQBL
' Note this a unification of the above libraries with an input manager and a focus on immediate mode UI
' Which means all UI rendering is destructive and the framebuffer needs to be redrawn every frame
' As such lot of things have changed and this will not work as a drop-in replacement for Terry's libraries
' This was born becuase I needed a small, fast and intuitive GUI libary for games and graphic applications
' This is a work in progress
'
' Copyright (c) 2022 Samuel Gomes
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' HEADER FILES
'---------------------------------------------------------------------------------------------------------
'$Include:'./IMGUI64.bi'
'---------------------------------------------------------------------------------------------------------


Dim mybutton%
Dim x%, y%
Dim helloworldinp%
Dim helloworld$

Screen _NewImage(800, 600, 32)
_ScreenMove _Middle

mybutton% = ButtonNew(Chr$(17), 24, 24)
x% = (800 - ButtonWidth(mybutton%)) \ 2
y% = (600 - ButtonHeight(mybutton%)) \ 2
ButtonPut x%, y%, mybutton%
ButtonShow mybutton%

helloworldinp% = GLIInput(100, 100, 128, TEXT_BOX_ALPHA, "test me now")

Do
    Cls , NP_Blue

    IMGUI64Update

    GLIUpdate ' must be the second to last command in any loop

    Locate 10, 1: Print "Real time: "; GLIOutput$(helloworldinp%); " ";

    ButtonUpdate
    Select Case ButtonEvent(mybutton%)
        Case 0
            Locate 11, 1
            Print "NO INTERACTION";
            ButtonOff mybutton%
        Case 1
            Locate 11, 1
            Print " LEFT BUTTON  ";
            ButtonOn mybutton%
        Case 2
            Locate 11, 1
            Print " RIGHT BUTTON ";
            ButtonOn mybutton%

        Case 3
            Locate 11, 1
            Print "   HOVERING   ";
            ButtonOff mybutton%
    End Select

    _Display

    _Limit 60
Loop Until IMGUI64GetKey = 27 Or GLIEntered(helloworldinp%)

helloworld$ = GLIOutput$(helloworldinp%)

GLIClose helloworldinp%
ButtonFree mybutton%

_AutoDisplay

Locate 7, 1: Print "Final    : "; helloworld$

End


' Draws a filled circle
Sub CircleFill (cx As Long, cy As Long, r As Long, c As Unsigned Long)
    Dim As Long Radius, RadiusError, X, Y

    Radius = Abs(r)
    RadiusError = -Radius
    X = Radius
    Y = 0

    If Radius = 0 Then
        PSet (cx, cy), c
        Exit Sub
    End If

    Line (cx - X, cy)-(cx + X, cy), c, BF

    While X > Y
        RadiusError = RadiusError + Y * 2 + 1

        If RadiusError >= 0 Then
            If X <> Y + 1 Then
                Line (cx - Y, cy - X)-(cx + Y, cy - X), c, BF
                Line (cx - Y, cy + X)-(cx + Y, cy + X), c, BF
            End If
            X = X - 1
            RadiusError = RadiusError - X * 2
        End If

        Y = Y + 1

        Line (cx - X, cy - Y)-(cx + X, cy - Y), c, BF
        Line (cx - X, cy + Y)-(cx + X, cy + Y), c, BF
    Wend
End Sub



$If IMGUI64_BAS = UNDEFINED Then
    $Let IMGUI64_BAS = TRUE

    '-----------------------------------------------------------------------------------------------------
    ' FUNCTIONS & SUBROUTINES
    '-----------------------------------------------------------------------------------------------------

    ' This routine ties the whole update system and makes everything go
    Sub IMGUI64Update
        IMGUI64UpdateInputSystem
    End Sub


    Sub IMGUI64UpdateInputSystem
        Shared InputManager As InputManagerType

        ' Collect mouse input
        Do While MouseInput
            InputManager.mouseX = MouseX
            InputManager.mouseY = MouseY

            InputManager.leftMouseButton = MouseButton(1)
            InputManager.rightMouseButton = MouseButton(2)

            ' Exit the loop if either buttons were pressed
            ' This will allow the library to process the click and ensure no clicks are missed
            If InputManager.leftMouseButton Or InputManager.rightMouseButton Then Exit Do
        Loop

        ' Check if the lasd keyboard input was consumed and if so get the next one
        InputManager.keyCode = _KeyHit
    End Sub


    ' This gets the current keyboard input
    Function IMGUI64GetKey&
        Shared InputManager As InputManagerType

        IMGUI64GetKey = InputManager.keyCode
    End Function


    ' Get the mouse X position
    Function IMGUI64GetMouseX&
        Shared InputManager As InputManagerType

        IMGUI64GetMouseX = InputManager.mouseX
    End Function


    ' Get the mouse Y position
    Function IMGUI64GetMouseY&
        Shared InputManager As InputManagerType

        IMGUI64GetMouseY = InputManager.mouseY
    End Function


    ' Is the left mouse button down?
    Function IMGUI64IsLeftMouseDown&
        Shared InputManager As InputManagerType

        IMGUI64IsLeftMouseDown = InputManager.leftMouseButton
    End Function


    ' Is the right mouse button down?
    Function IMGUI64IsRightMouseDown&
        Shared InputManager As InputManagerType

        IMGUI64IsRightMouseDown = InputManager.rightMouseButton
    End Function


    Sub DrawBox3D (x1 As Long, y1 As Long, x2 As Long, y2 As Long, isRaised As Byte)
        If isRaised Then
            Line (x1, y1)-(x2 - 1, y1), LightGray
            Line (x1, y1)-(x1, y2 - 1), LightGray
            Line (x1, y2)-(x2, y2), DimGray
            Line (x2, y1)-(x2, y2 - 1), DimGray
        Else
            Line (x1, y1)-(x2 - 1, y1), DimGray
            Line (x1, y1)-(x1, y2 - 1), DimGray
            Line (x1, y2)-(x2, y2), LightGray
            Line (x2, y1)-(x2, y2 - 1), LightGray
        End If

        Line (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), Gray, BF
    End Sub

    '******************************************************************************
    '*                                                                            *
    '* Returns the handle number of the current active input field. The function  *
    '* will return 0 if there are no active input fields.                         *
    '*                                                                            *
    '******************************************************************************
    Function GLICurrent&
        Shared TextBox() As TextBoxType
        Shared TextBoxSettings As TextBoxSettingsType

        GLICurrent = 0 '                                                               assume no active input fields
        If UBound(TextBox) = 0 Then Exit Function '                                        leave if no active input fields
        GLICurrent = TextBoxSettings.current '                                                         return handle of current active input field
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Forces cursor to move to a specific input field, the next input field or   *
    '* forces the input array to reset.                                           *
    '*                                                                            *
    '* handle% values available to programmer:                                    *
    '*                                                                            *
    '* -1 = force to next input field                                             *
    '* >0 = force to a specific input field                                       *
    '*                                                                            *
    '******************************************************************************
    Sub GLIForce (handle As Long)
        Shared TextBox() As TextBoxType
        Shared TextBoxSettings As TextBoxSettingsType

        If UBound(TextBox) = 0 Then Exit Sub '                                             leave if nothing is active
        If (handle < -1) Or (handle = 0) Or (handle > UBound(TextBox)) Then '           is handle% valid?
            Error 258
        End If
        TextBoxSettings.forced = handle '                                                         inform GLIUPDATE of force behavior
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Closes all or a specific input field.                                      *
    '*                                                                            *
    '* handle% values available to programmer:                                    *
    '*                                                                            *
    '*  0 = close all input fields (forces a reset of input field array)          *
    '* >0 = close a specific input field                                          *
    '*                                                                            *
    '******************************************************************************
    Sub GLIClose (handle As Long)
        Shared TextBox() As TextBoxType
        Shared TextBoxSettings As TextBoxSettingsType

        Dim Scan As Long ' used to scan through input array

        If UBound(TextBox) = 0 Then Exit Sub ' leave if nothing is active

        If handle <> 0 Then ' closing all input fields?
            If (handle < 0) Or (handle > UBound(TextBox)) Or Not TextBox(handle).inUse Then ' no, is handle% valid?
                Error 258
            End If
        End If

        If handle > 0 Then ' closing a specific input field?
            _FreeImage TextBox(handle).renderImage ' remove the text image from memory
            TextBox(handle).renderImage = 0
            TextBox(handle).inUse = FALSE ' yes, this input field no longer used (FALSE)
            For Scan = 1 To UBound(TextBox) ' cycle through the input array
                If TextBox(Scan).inUse Then ' is this input field in use?
                    GLIForce -1 ' yes, force input to next field

                    Exit Sub ' no need to scan any further
                End If
            Next
        End If

        For Scan = 1 To UBound(TextBox) ' cycle through all input fields
            If TextBox(Scan).inUse Then _FreeImage TextBox(Scan).renderImage ' remove the text image from memory
        Next

        ReDim TextBox(0 To 0) As TextBoxType ' reset the input array
        TextBoxSettings.current = 0 ' reset the current input field
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Retrieves the input text from a specific input field.                      *
    '*                                                                            *
    '* handle% values available to programmer:                                    *
    '*                                                                            *
    '* >0 = get the input text from the specific input field                      *
    '*                                                                            *
    '******************************************************************************
    Function GLIOutput$ (handle%)
        Shared TextBox() As TextBoxType

        If UBound(TextBox) = 0 Then Exit Function '                                        leave if nothing is active
        If (handle% < 1) Or (handle% > UBound(TextBox)) Or Not TextBox(handle%).inUse Then '                             is handle% valid?
            Error 258
        End If

        GLIOutput = TextBox(handle%).text
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Reports back if the ENTER key has been pressed on one or all input fileds. *
    '*                                                                            *
    '* handle% values available to programmer:                                    *
    '*                                                                            *
    '*  0 = get the ENTER key status of all input fields in use (TRUE/FALSE)      *
    '* >0 = get the ENTER key status on a certain input field (TRUE/FALSE)        *
    '*                                                                            *
    '******************************************************************************
    Function GLIEntered%% (handle%)
        Shared TextBox() As TextBoxType

        Dim Scan% '                                                                    used to scan through input array

        If UBound(TextBox) = 0 Then Exit Function '                                        leave if nothing is active
        If (handle% < 0) Or (handle% > UBound(TextBox)) Then '                             is handle% valid?
            Error 258
        End If
        If handle% > 0 Then '                                                          looking for a certain input field?
            GLIEntered = TextBox(handle%).entered '                                        yes, report back the ENTER key status
        Else '                                                                         no, looking for all input fields
            GLIEntered = TRUE '                                                          assume all have had ENTER key pressed (TRUE)
            For Scan% = 1 To UBound(TextBox) '                                             scan the entire input array
                If TextBox(Scan%).inUse And (Not TextBox(Scan%).entered) Then '                is field in use and no ENTER key pressed?
                    GLIEntered = FALSE '                                                   yes, report back not all fields been ENTERed (FALSE)
                    Exit Function '                                                    no need to check any further
                End If
            Next Scan%
        End If
    End Function


    ' Sets up a text input box. Returns a handle value that points to the input text field.
    ' x - x location of input text field
    ' y - y location of input text field
    ' w - width of the box in pixels
    ' allow - type of text allowed
    ' defaultInputText - default string in the input field
    Function GLIInput& (x As Long, y As Long, w As Unsigned Long, allow As Unsigned Integer, defaultInputText As String)
        Shared TextBox() As TextBoxType
        Shared TextBoxSettings As TextBoxSettingsType

        Dim c As Long ' the new handle number

        If TextBoxSettings.current = 0 Then TextBoxSettings.current = 1 ' first time called set to 1
        ReDim _Preserve TextBox(1 To UBound(TextBox) + 1) As TextBoxType ' create a new input array entry

        c = UBound(TextBox) ' get the new handle number

        TextBox(c).x = x ' save the x location of text
        TextBox(c).y = y ' save the y location of text
        TextBox(c).w = w - 4 ' save width - 4 pixels for the border
        TextBox(c).h = FontHeight + 4 ' save height + 4 pixels for the border
        TextBox(c).text = defaultInputText ' set default input text
        TextBox(c).allow = allow ' save the type of input allowed
        TextBox(c).cursorPosition = 1 ' set the cursor at the beginning of the input line
        TextBox(c).cursorPosBox = 1
        TextBox(c).visibleTextLen = (w - PrintWidth("W") * 2) \ PrintWidth("W")
        TextBox(c).startVisibleChar = 1
        TextBox(c).cursorWidth = PrintWidth("X")
        TextBox(c).insertMode = TRUE ' initial insert mode to insert
        TextBox(c).entered = FALSE ' ENTER has not been pressed yet (FALSE)
        TextBox(c).renderImage = NewImage(w, FontHeight, 32) ' Create a bitmap to just hold the text image
        TextBox(c).visible = TRUE ' initially visible on screen (TRUE)
        TextBox(c).inUse = TRUE ' this input field is now in use (TRUE)

        GLIInput = c ' return with the new handle number
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Updates the inputs on screen                                               *
    '*                                                                            *
    '******************************************************************************
    Sub GLIUpdate
        Shared TextBox() As TextBoxType
        Shared TextBoxSettings As TextBoxSettingsType
        Shared InputManager As InputManagerType

        Dim Scan As Long ' used to scan input array

        If UBound(TextBox) = 0 Then Exit Sub ' leave if nothing is active

        If TextBoxSettings.current = 0 Then TextBoxSettings.current = 1 ' if this is first time set current input to 1

        If TextBoxSettings.forced <> 0 Then ' being forced to an input field?
            If TextBoxSettings.forced = -1 Then ' yes, to the next one?
                Scan = TextBoxSettings.current ' set scanner to current input field
                Do ' start scanning
                    Scan = Scan + 1 ' move scanner to next handle number
                    If Scan > UBound(TextBox) Then Scan = 1 ' return to start of input array if limit reached
                    If TextBox(Scan).inUse Then TextBoxSettings.current = Scan ' set current input field if in use
                Loop Until TextBoxSettings.current = Scan ' leave scanner when an input field in use is found
                TextBoxSettings.forced = 0 ' reset force indicator
            Else ' yes, to a specific input field
                TextBoxSettings.current = TextBoxSettings.forced ' set the current input field
                TextBoxSettings.forced = 0 ' reset force indicator
            End If
        End If

        ' First process any pressed keys
        Select Case InputManager.keyCode ' which key was hit?
            Case 20992 ' INSERT key was pressed
                TextBox(TextBoxSettings.current).insertMode = Not TextBox(TextBoxSettings.current).insertMode

            Case 19712 ' RIGHT ARROW key was pressed
                TextBox(TextBoxSettings.current).cursorPosition = TextBox(TextBoxSettings.current).cursorPosition + 1 ' increment the cursor position
                If TextBox(TextBoxSettings.current).cursorPosition > Len(TextBox(TextBoxSettings.current).text) + 1 Then ' will this take the cursor too far?
                    TextBox(TextBoxSettings.current).cursorPosition = Len(TextBox(TextBoxSettings.current).text) + 1 ' yes, keep the cursor at the end of the line
                End If

                ' Box cursor movement
                TextBox(TextBoxSettings.current).cursorPosBox = TextBox(TextBoxSettings.current).cursorPosBox + 1
                If TextBox(TextBoxSettings.current).cursorPosBox > TextBox(TextBoxSettings.current).visibleTextLen + 1 Then
                    TextBox(TextBoxSettings.current).cursorPosBox = TextBox(TextBoxSettings.current).visibleTextLen + 1
                    TextBox(TextBoxSettings.current).startVisibleChar = 1 + Len(TextBox(TextBoxSettings.current).text) - TextBox(TextBoxSettings.current).visibleTextLen
                End If

            Case 19200 ' LEFT ARROW key was pressed
                TextBox(TextBoxSettings.current).cursorPosition = TextBox(TextBoxSettings.current).cursorPosition - 1 ' decrement the cursor position
                If TextBox(TextBoxSettings.current).cursorPosition < 1 Then ' did cursor go beyone beginning of line?
                    TextBox(TextBoxSettings.current).cursorPosition = 1 ' yes, keep the cursor at the beginning of the line
                End If

                ' Box cursor movement
                TextBox(TextBoxSettings.current).cursorPosBox = TextBox(TextBoxSettings.current).cursorPosBox - 1
                If TextBox(TextBoxSettings.current).cursorPosBox < 1 Then
                    TextBox(TextBoxSettings.current).cursorPosBox = 1
                    If TextBox(TextBoxSettings.current).startVisibleChar > 1 Then
                        TextBox(TextBoxSettings.current).startVisibleChar = TextBox(TextBoxSettings.current).startVisibleChar - 1
                    End If
                End If


            Case 8 ' BACKSPACE key pressed
                If TextBox(TextBoxSettings.current).cursorPosition > 1 Then ' is the cursor at the beginning of the line?
                    TextBox(TextBoxSettings.current).text = Left$(TextBox(TextBoxSettings.current).text, TextBox(TextBoxSettings.current).cursorPosition - 2) + Right$(TextBox(TextBoxSettings.current).text, Len(TextBox(TextBoxSettings.current).text) - TextBox(TextBoxSettings.current).cursorPosition + 1) ' no, delete character
                    TextBox(TextBoxSettings.current).cursorPosition = TextBox(TextBoxSettings.current).cursorPosition - 1 ' decrement the cursor position
                End If

                ' Box cursor movement
                TextBox(TextBoxSettings.current).cursorPosBox = TextBox(TextBoxSettings.current).cursorPosBox - 1
                If TextBox(TextBoxSettings.current).cursorPosBox < 1 Then
                    TextBox(TextBoxSettings.current).cursorPosBox = 1

                    If TextBox(TextBoxSettings.current).startVisibleChar > 1 Then
                        TextBox(TextBoxSettings.current).startVisibleChar = TextBox(TextBoxSettings.current).startVisibleChar - 1
                    End If
                End If

            Case 18176 ' HOME key was pressed
                TextBox(TextBoxSettings.current).cursorPosition = 1 ' move the cursor to the beginning of the line
                TextBox(TextBoxSettings.current).cursorPosBox = 1
                TextBox(TextBoxSettings.current).startVisibleChar = 1

            Case 20224 ' END key was pressed
                TextBox(TextBoxSettings.current).cursorPosition = Len(TextBox(TextBoxSettings.current).text) + 1 ' move the cursor to the end of the line
                TextBox(TextBoxSettings.current).cursorPosBox = TextBox(TextBoxSettings.current).visibleTextLen + 1
                TextBox(TextBoxSettings.current).startVisibleChar = 1 + Len(TextBox(TextBoxSettings.current).text) - TextBox(TextBoxSettings.current).visibleTextLen

            Case 21248 ' DELETE key was pressed
                If TextBox(TextBoxSettings.current).cursorPosition < Len(TextBox(TextBoxSettings.current).text) + 1 Then ' is the cursor at the end of the line?
                    TextBox(TextBoxSettings.current).text = Left$(TextBox(TextBoxSettings.current).text, TextBox(TextBoxSettings.current).cursorPosition - 1) + Right$(TextBox(TextBoxSettings.current).text, Len(TextBox(TextBoxSettings.current).text) - TextBox(TextBoxSettings.current).cursorPosition) ' no, delete character
                End If

            Case 9, 13, 20480 ' TAB, ENTER or DOWN ARROW key pressed
                If InputManager.keyCode = 13 Then TextBox(TextBoxSettings.current).entered = TRUE ' if enter key was pressed remember it (TRUE)
                Scan = TextBoxSettings.current ' set initital point of input array scan
                Do ' begin scanning input array
                    Scan = Scan + 1 ' increment the scanner
                    If Scan > UBound(TextBox) Then Scan = 1 ' go to beginning of array if the end was reached
                    If TextBox(Scan).inUse Then TextBoxSettings.current = Scan ' if this field is in use then set it as the current input field
                Loop Until TextBoxSettings.current = Scan ' keep scanning until a valid field is found

            Case 18432 ' UP ARROW key was pressed
                Scan = TextBoxSettings.current ' set initial point of input array scan
                Do ' begin scanning input array
                    Scan = Scan - 1 ' decrement the scanner
                    If Scan = 0 Then Scan = UBound(TextBox) ' go the end of the array if the beginning was reached
                    If TextBox(Scan).inUse Then TextBoxSettings.current = Scan ' if this field is in use then set it as the current input field
                Loop Until TextBoxSettings.current = Scan ' keep scanning until a valid field is found

            Case Else ' a character key was pressed
                If InputManager.keyCode > 31 And InputManager.keyCode < 256 Then ' is it a valid ASCII displayable character?
                    Dim K As String ' yes, initialize key holder variable
                    Select Case InputManager.keyCode ' which alphanumeric key was pressed?
                        Case 32 ' SPACE key was pressed
                            K = Chr$(InputManager.keyCode) ' save the keystroke

                        Case 40 To 41 ' PARENTHESIS key was pressed
                            If (TextBox(TextBoxSettings.current).allow And TEXT_BOX_SYMBOLS) Or (TextBox(TextBoxSettings.current).allow And TEXT_BOX_PAREN) Then
                                K = Chr$(InputManager.keyCode) ' if it's allowed then save the keystroke
                            End If

                        Case 45 ' DASH (minus -) key was pressed
                            If TextBox(TextBoxSettings.current).allow And TEXT_BOX_DASH Then ' are dashes allowed?
                                K = Chr$(InputManager.keyCode) ' yes, save the keystroke
                            End If

                        Case 48 To 57 ' NUMBER key was pressed
                            If TextBox(TextBoxSettings.current).allow And TEXT_BOX_NUMERIC Then ' are numbers allowed?
                                K = Chr$(InputManager.keyCode) ' yes, save the keystroke
                            End If

                        Case 33 To 47, 58 To 64, 91 To 96, 123 To 255 ' SYMBOL key was pressed
                            If TextBox(TextBoxSettings.current).allow And TEXT_BOX_SYMBOLS Then ' are symbols allowed?
                                K = Chr$(InputManager.keyCode) ' yes, save the keystroke
                            End If

                        Case 65 To 90, 97 To 122 ' ALPHABETIC key was pressed
                            If TextBox(TextBoxSettings.current).allow And TEXT_BOX_ALPHA Then ' are alpha keys allowed?
                                K = Chr$(InputManager.keyCode) ' yes, save the keystroke
                            End If
                    End Select

                    If K <> NULLSTRING Then ' was an allowed keystroke saved?
                        If TextBox(TextBoxSettings.current).allow And TEXT_BOX_LOWER Then ' should it be forced to lower case?
                            K = LCase$(K) ' yes, force the keystroke to lower case
                        End If

                        If TextBox(TextBoxSettings.current).allow And TEXT_BOX_UPPER Then ' should it be forced to upper case?
                            K = UCase$(K) ' yes, force the keystroke to upper case
                        End If

                        If TextBox(TextBoxSettings.current).cursorPosition = Len(TextBox(TextBoxSettings.current).text) + 1 Then ' is the cursor at the end of the line?
                            TextBox(TextBoxSettings.current).text = TextBox(TextBoxSettings.current).text + K ' yes, simply add the keystroke to input text
                            TextBox(TextBoxSettings.current).cursorPosition = TextBox(TextBoxSettings.current).cursorPosition + 1 ' increment the cursor position
                        ElseIf TextBox(TextBoxSettings.current).insertMode Then ' no, are we in INSERT mode?
                            TextBox(TextBoxSettings.current).text = Left$(TextBox(TextBoxSettings.current).text, TextBox(TextBoxSettings.current).cursorPosition - 1) + K + Right$(TextBox(TextBoxSettings.current).text, Len(TextBox(TextBoxSettings.current).text) - TextBox(TextBoxSettings.current).cursorPosition + 1) ' yes, insert the character
                            TextBox(TextBoxSettings.current).cursorPosition = TextBox(TextBoxSettings.current).cursorPosition + 1 ' increment the cursor position
                        Else ' no, we are in OVERWRITE mode
                            TextBox(TextBoxSettings.current).text = Left$(TextBox(TextBoxSettings.current).text, TextBox(TextBoxSettings.current).cursorPosition - 1) + K + Right$(TextBox(TextBoxSettings.current).text, Len(TextBox(TextBoxSettings.current).text) - TextBox(TextBoxSettings.current).cursorPosition) ' overwrite with new character
                            TextBox(TextBoxSettings.current).cursorPosition = TextBox(TextBoxSettings.current).cursorPosition + 1 ' increment the cursor position
                        End If

                        ' Box cursor movement
                        TextBox(TextBoxSettings.current).cursorPosBox = TextBox(TextBoxSettings.current).cursorPosBox + 1
                        If TextBox(TextBoxSettings.current).cursorPosBox > TextBox(TextBoxSettings.current).visibleTextLen + 1 Then
                            TextBox(TextBoxSettings.current).cursorPosBox = TextBox(TextBoxSettings.current).visibleTextLen + 1
                            TextBox(TextBoxSettings.current).startVisibleChar = 1 + Len(TextBox(TextBoxSettings.current).text) - TextBox(TextBoxSettings.current).visibleTextLen
                        End If
                    End If
                End If
        End Select

        Dim visibleText As String, currentTick As Integer64, charHeight As Long, curPosX As Long
        Static cursorBlink As Byte, blinkTick As Integer64

        charHeight = FontHeight

        currentTick = GetTicks
        If currentTick > blinkTick + 500 Then
            blinkTick = currentTick
            cursorBlink = Not cursorBlink
        End If

        ' Now start the render loop
        For Scan = 1 To UBound(TextBox)
            ' Only render if the text box is active and visible
            If TextBox(Scan).inUse And TextBox(Scan).visible Then
                ' Draw the box first
                DrawBox3D TextBox(Scan).x, TextBox(Scan).y, TextBox(Scan).x + TextBox(Scan).w - 1, TextBox(Scan).y + TextBox(Scan).h - 1, FALSE

                ' Next figure out what part of the text we need to draw
                visibleText = Mid$(TextBox(Scan).text, TextBox(Scan).startVisibleChar, TextBox(Scan).visibleTextLen)

                ' Draw the text over the box
                Color Black, Gray
                If TextBox(TextBoxSettings.current).allow And TEXT_BOX_PASSWORD Then
                    PrintString (2 + TextBox(Scan).x, 2 + TextBox(Scan).y), String$(TextBox(Scan).visibleTextLen, "*")
                Else
                    PrintString (2 + TextBox(Scan).x, 2 + TextBox(Scan).y), visibleText
                End If

                ' Draw the cursor
                If cursorBlink Then
                    curPosX = 2 + TextBox(Scan).x + (TextBox(Scan).cursorWidth * (TextBox(Scan).cursorPosBox - 1))
                    If TextBox(Scan).insertMode Then
                        Line (curPosX, 2 + TextBox(Scan).y + charHeight - 4)-(curPosX + TextBox(Scan).cursorWidth - 1, 2 + TextBox(Scan).y + charHeight - 1), Black, BF
                    Else
                        Line (curPosX, 2 + TextBox(Scan).y)-(curPosX + TextBox(Scan).cursorWidth - 1, 2 + TextBox(Scan).y + charHeight - 1), Black, BF
                    End If
                End If
            End If
        Next
    End Sub


    '******************************************************************************
    '* Shows a button on screen that is currently hidden.                         *
    '*                                                                            *
    '* bh% - Handle number of button to show.                                     *
    '******************************************************************************
    Sub ButtonShow (bh As Long) '                                           Error Checking
        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        CommandButton(bh).visible = TRUE
    End Sub


    '******************************************************************************
    '* Hides a button currently shown on screen.                                  *
    '*                                                                            *
    '* bh% - Handle number of button to hide.                                     *
    '******************************************************************************
    Sub ButtonHide (bh As Long) '                                           Error Checking
        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        CommandButton(bh).visible = FALSE
    End Sub


    '******************************************************************************
    '* Toggles the button to a depressed state.                                   *
    '*                                                                            *
    '* bh% - Handle number of button to press.                                    *
    '******************************************************************************
    Sub ButtonOff (bh As Long) '                                            Error Checking
        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        CommandButton(bh).state = 0 '                                       depress button
        ButtonPut CommandButton(bh).x, CommandButton(bh).y, bh '                     update button image
    End Sub


    '******************************************************************************
    '* Toggles the button to a pressed state.                                     *
    '*                                                                            *
    '* bh% - Handle number of button to press.                                    *
    '******************************************************************************
    Sub ButtonOn (bh As Long) '                                             Error Checking
        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        CommandButton(bh).state = -1 '                                      press button
        ButtonPut CommandButton(bh).x, CommandButton(bh).y, bh '                     update button image
    End Sub


    '******************************************************************************
    '* Toggles the button specified between pressed/depressed.                    *
    '*                                                                            *
    '* bh% - Handle number of button to toggle.                                   *
    '******************************************************************************
    Sub ButtonToggle (bh As Long) '                                         Error Checking
        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        CommandButton(bh).state = Not CommandButton(bh).state '                       toggle button's state
        ButtonPut CommandButton(bh).x, CommandButton(bh).y, bh '                     update button image
    End Sub


    '******************************************************************************
    '* Returns the status of a button's mouse/button interaction.                 *
    '*                                                                            *
    '* bh% = The button handle number to retrieve the status from.                *
    '******************************************************************************
    Function ButtonEvent (bh As Long) '                                     Error Checking
        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        ButtonEvent = CommandButton(bh).mouse '                             return mouse status
    End Function


    '******************************************************************************
    '* Checks the status of the buttons in relation to the mouse pointer.         *
    '*                                                                            *
    '* Sets each buttons .mouse element to the following conditions:              *
    '*   0 - no mouse event.                                                      *
    '*   1 - left mouse button clicked on button.                                 *
    '*   2 - right mouse button clicked on button.                                *
    '*   3 - mouse hovering over button.                                          *
    '*                                                                            *
    '* Note: This subroutine is called automatically if button checking is turned *
    '*       on. If button checking is turned off the user can still call this    *
    '*       subroutine manually to get updates on mouse/button interaction.      *
    '******************************************************************************
    Sub ButtonUpdate
        Shared CommandButton() As CommandButtonType '                                       button defining array
        Shared InputManager As InputManagerType

        Dim bh% '                                                 button handle counter
        Dim ev% '                                                 current mouse event

        ev% = 3 '                                                 assume hovering
        If InputManager.leftMouseButton Then ev% = 1 '                         left button clicked
        If InputManager.rightMouseButton Then ev% = 2 '                         right button cicked
        For bh% = 1 To UBound(CommandButton) '                               test pointer boundary
            If CommandButton(bh%).inUse And CommandButton(bh%).visible Then '              used and on screen?
                If (InputManager.mouseX >= CommandButton(bh%).x) And (InputManager.mouseX <= CommandButton(bh%).x + CommandButton(bh%).w - 1) And (InputManager.mouseY >= CommandButton(bh%).y) And (InputManager.mouseY <= CommandButton(bh%).y + CommandButton(bh%).h - 1) Then
                    CommandButton(bh%).mouse = ev% '                         is in boundary, set
                Else '                                            not button boundary
                    CommandButton(bh%).mouse = 0 '                           no event to set
                End If
            End If
        Next bh%
    End Sub


    '******************************************************************************
    '* Returns the height of a button handle.                                     *
    '*                                                                            *
    '* bh% - Handle number of button to get height from.                          *
    '*                                                                            *
    '* returns: Integer value indicating the height of the button.                *
    '******************************************************************************
    Function ButtonHeight (bh As Long) '                                    Error Checking
        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        ButtonHeight = CommandButton(bh).h '                               return button height
    End Function


    '******************************************************************************
    '* Returns the width of a button handle.                                      *
    '*                                                                            *
    '* bh% - Handle number of button to get width from.                           *
    '*                                                                            *
    '* returns: Integer value indicating the width of the button.                 *
    '******************************************************************************
    Function ButtonWidth (bh As Long) '                                     Error Checking
        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        ButtonWidth = CommandButton(bh).w '                                return button width
    End Function


    '******************************************************************************
    '* Duplicates a button handle from a designated handle.                       *
    '*                                                                            *
    '* bh% - Handle number of button to duplicate.                                *
    '*                                                                            *
    '* returns: Integer value greater than 0 indicating the new button's handle.  *
    '******************************************************************************
    Function ButtonCopy (bh As Long) '                                      Error Checking
        Dim nh As Long '                                                 new button handle num

        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        nh = ButtonNew(NULLSTRING, 0, 0) ' get new handle number
        CommandButton(nh) = CommandButton(bh) ' new button properties
        CommandButton(bh).visible = FALSE ' not showing on screen

        ButtonCopy = nh ' return hew handle num
    End Function


    '******************************************************************************
    '* Removes a button from the screen, restores the background image and frees  *
    '* any resources the button was using.                                        *
    '*                                                                            *
    '* bh% - Handle number of button to free.                                     *
    '******************************************************************************
    Sub ButtonFree (bh As Long) '                                           Error Checking
        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        If bh = UBound(CommandButton) And bh <> 1 Then '                   button last element?
            ReDim _Preserve CommandButton(1 To bh - 1) As CommandButtonType '                   decrease array size
        Else '                                                    not last element
            CommandButton(bh).inUse = 0 '                                   not in use any more
            CommandButton(bh).visible = FALSE '                                    not showing on screen
            CommandButton(bh).state = 0 '                                   reset button state
            CommandButton(bh).text = NULLSTRING ' remove any text
        End If
    End Sub


    '******************************************************************************
    '* Places, moves or refreshes a button on the screen.                         *
    '*                                                                            *
    '* x%  - x location of button.                                                *
    '* y%  - y location of button.                                                *
    '* bh% - Handle number of button to place.                                    *
    '*                                                                            *
    '* Note: The first time a handle is called the button will be placed on the   *
    '*       screen. Subsequent calls to the same handle will move the button to  *
    '*       a new location, restoring the background at the old position. If a   *
    '*       handle is called at the same coordinates as a previous call, the     *
    '*       button is simply refreshed on the screen.                            *
    '******************************************************************************
    Sub ButtonPut (x%, y%, bh As Long) '                                    Error Checking
        Shared CommandButton() As CommandButtonType '                                       button defining array

        If bh > UBound(CommandButton) Or bh < 1 Or Not CommandButton(bh).inUse Then
            Error 258
        End If

        If Not ((CommandButton(bh).x = x%) And (CommandButton(bh).y = y%)) Then '     button x,y change?
            CommandButton(bh).x = x% '                                      save new x location
            CommandButton(bh).y = y% '                                      save new y location
        End If
        If CommandButton(bh).visible Then '                                    is button on screen?
            If CommandButton(bh).state Then '                               is button pressed?
                DrawBox3D x%, y%, x% + CommandButton(bh).w - 1, y% + CommandButton(bh).h - 1, FALSE ' draw button pressed
                Color Black, Gray
                PrintString (1 + x% + CommandButton(bh).w \ 2 - PrintWidth(CommandButton(bh).text) \ 2, 1 + y% + CommandButton(bh).h \ 2 - FontHeight \ 2), CommandButton(bh).text

            Else '                                                button is not pressed
                DrawBox3D x%, y%, x% + CommandButton(bh).w - 1, y% + CommandButton(bh).h - 1, TRUE ' draw button depressed
                Color Black, Gray
                PrintString (x% + CommandButton(bh).w \ 2 - PrintWidth(CommandButton(bh).text) \ 2, y% + CommandButton(bh).h \ 2 - FontHeight \ 2), CommandButton(bh).text
            End If
        End If
    End Sub


    '******************************************************************************
    '* Creates a new button either internally or from a file set                  *
    '*                                                                            *
    '* xs%     - The width of the button. This value is ignored if a valid        *
    '*           filename is provided through bname$.                             *
    '* ys%     - The height of the button. This value is ignored if a valid       *
    '*           filename is provided through bname$.                             *
    '*                                                                            *
    '* returns:  Integer value greater than 0 indicating the button's handle.     *
    '*                                                                            *
    '* Note:     If the button specified in bname$ does not exist then a generic  *
    '*           button will be created from xsize%, ysize% and bcolor& to take   *
    '*           the place of the missing button file. This can either be viewed  *
    '*           as a failsafe feature or allow the coder to concentrate on the   *
    '*           code and the button graphics later.                              *
    '*                                                                            *
    '* NEED TO FIX: Custom button creation routine is half baked. The buttons     *
    '*              look "ok", but the routine could really use the touch of a    *
    '*              good graphics programmer.                                     *
    '******************************************************************************
    Function ButtonNew& (text As String, xs%, ys%)
        Dim bh As Long '                             handle number of button to be passed back

        Shared CommandButton() As CommandButtonType '                                       button defining array

        Do '                                                      find available handle
            bh = bh + 1 '                                       inc handle number
        Loop Until (Not CommandButton(bh).inUse) Or bh = UBound(CommandButton) '      test handle value
        If CommandButton(bh).inUse Then '                                   last one in use?
            bh = bh + 1 '                                       use next handle
            ReDim _Preserve CommandButton(1 To bh) As CommandButtonType '                       increase array size
        End If
        CommandButton(bh).inUse = TRUE '                                      mark as in use
        CommandButton(bh).text = text
        CommandButton(bh).state = 0 '                                       mark as out
        CommandButton(bh).x = -32767 '                                      set low for first use
        CommandButton(bh).y = -32767 '                                      set low for first use
        CommandButton(bh).w = xs% '                                width of button
        CommandButton(bh).h = ys% '                                height of button

        ButtonNew = bh '                                         return handle number
    End Function
    '-----------------------------------------------------------------------------------------------------
$End If
'---------------------------------------------------------------------------------------------------------
