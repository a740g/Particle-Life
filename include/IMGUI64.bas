'---------------------------------------------------------------------------------------------------------
' QB64-PE Immediate mode GUI Library
'
' This is very loosely based on Terry Ritchie's work: GLINPUT, RQBL
' Note that this library has an input manager and a focus on immediate mode UI
' Which means all UI rendering is destructive and the framebuffer needs to be redrawn every frame
' As such lot of things have changed and this will not work as a drop-in replacement for Terry's libraries
' This was born because I needed a small, fast and intuitive GUI libary for games and graphic applications
' This is a work in progress
'
' Copyright (c) 2022 Samuel Gomes
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' HEADER FILES
'---------------------------------------------------------------------------------------------------------
'$Include:'./IMGUI64.bi'
'---------------------------------------------------------------------------------------------------------

' TODO:
'   Handle visible flag correctly for all routines
'   Handle disabled flag correctly for all routines


'Dim mybutton%
'Dim x%, y%
'Dim helloworldinp%
'Dim helloworld$

'Screen _NewImage(800, 600, 32)
'_ScreenMove _Middle

'mybutton% = ButtonNew(Chr$(17), 24, 24)
'x% = (800 - ButtonWidth(mybutton%)) \ 2
'y% = (600 - ButtonHeight(mybutton%)) \ 2
'ButtonPut x%, y%, mybutton%
'ButtonShow mybutton%

'helloworldinp% = GLIInput(100, 100, 128, TEXT_BOX_ALPHA, "test me now")

'Do
'    Cls , NP_Blue

'    WidgetUpdate

'    GLIUpdate

'    Locate 10, 1: Print "Real time: "; GLIOutput$(helloworldinp%); " ";

'    ButtonUpdate
'    Select Case ButtonEvent(mybutton%)
'        Case 0
'            Locate 11, 1
'            Print "NO INTERACTION";
'            ButtonOff mybutton%
'        Case 1
'            Locate 11, 1
'            Print " LEFT BUTTON  ";
'            ButtonOn mybutton%
'        Case 2
'            Locate 11, 1
'            Print " RIGHT BUTTON ";
'            ButtonOn mybutton%

'        Case 3
'            Locate 11, 1
'            Print "   HOVERING   ";
'            ButtonOff mybutton%
'    End Select

'    _Display

'    _Limit 60
'Loop Until InputManagerGetKey& = 27 Or GLIEntered(helloworldinp%)

'helloworld$ = GLIOutput$(helloworldinp%)

'GLIClose helloworldinp%
'ButtonFree mybutton%

'_AutoDisplay

'Locate 7, 1: Print "Final    : "; helloworld$

'End


$If IMGUI64_BAS = UNDEFINED Then
    $Let IMGUI64_BAS = TRUE

    '-----------------------------------------------------------------------------------------------------
    ' FUNCTIONS & SUBROUTINES
    '-----------------------------------------------------------------------------------------------------

    ' Calculates the bounding rectangle for a object given its position & size
    Sub MakeRectangle (p As Vector2DType, s As Vector2DType, r As RectangleType)
        r.a.x = p.x
        r.a.y = p.y
        r.b.x = p.x + s.x - 1
        r.b.y = p.y + s.y - 1
    End Sub


    ' Does big contain small?
    Function RectangleContainsRectangle%% (big As RectangleType, small As RectangleType)
        RectangleContainsRectangle = PointCollidesWithRectangle(small.a, big) And PointCollidesWithRectangle(small.b, big)
    End Function


    ' Point & box collision test
    Function PointCollidesWithRectangle%% (p As Vector2DType, r As RectangleType)
        PointCollidesWithRectangle = Not (p.x < r.a.x Or p.x > r.b.x Or p.y < r.a.y Or p.y > r.b.y)
    End Function


    ' Draws a basic 3D box
    ' This can be improved ... a lot XD
    ' Also all colors are hardcoded
    Sub WidgetDrawBox3D (x1 As Long, y1 As Long, x2 As Long, y2 As Long, isRaised As Byte)
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


    ' This routine ties the whole update system and makes everything go
    Sub WidgetUpdate
        Shared Widget() As WidgetType
        Shared WidgetManager As WidgetManagerType
        Shared InputManager As InputManagerType
        Dim h As Long, r As RectangleType

        InputManagerUpdate

        If UBound(Widget) = 0 Then Exit Sub ' Exit if there is nothing to do

        ' Manage widget focus stuff
        If WidgetManager.current = 0 Then WidgetManager.current = 1 ' if this is first time set current widget to 1

        ' Shift focus if it was requested
        If WidgetManager.forced <> 0 Then ' being forced to a widget
            If WidgetManager.forced = -1 Then ' yes, to the next one?
                h = WidgetManager.current ' set scanner to current widget
                Do ' start scanning
                    h = h + 1 ' move scanner to next handle number
                    If h > UBound(Widget) Then h = 1 ' return to start of widget array if limit reached
                    If Widget(h).inUse And Widget(h).visible And Not Widget(h).disabled Then WidgetManager.current = h ' set current widget if in use
                Loop Until WidgetManager.current = h ' leave scanner when a widget in use is found
                WidgetManager.forced = 0 ' reset force indicator
            Else ' yes, to a specific input field
                If Widget(WidgetManager.forced).inUse And Widget(WidgetManager.forced).visible And Not Widget(WidgetManager.forced).disabled Then
                    WidgetManager.current = WidgetManager.forced ' set the current widget
                End If
                WidgetManager.forced = 0 ' reset force indicator
            End If
        End If

        ' Check for user input requesting focus change
        If InputManager.keyCode = KEY_TAB Then
            WidgetManager.forced = -1 ' Move to the next widget
            InputManager.keyCode = NULL ' consume the key
        End If

        ' Check if the user to trying to click on something to change focus
        For h = 1 To UBound(Widget)
            If Widget(h).inUse And Widget(h).visible And Not Widget(h).disabled And h <> WidgetManager.current Then

                ' Find the bounding box
                MakeRectangle Widget(WidgetManager.current).position, Widget(WidgetManager.current).size, r

                If InputManager.mouseLeftClicked Then
                    If RectangleContainsRectangle(r, InputManager.mouseLeftButtonClickedRectangle) Then
                        WidgetManager.forced = h ' Move to the specific widget
                        InputManager.mouseLeftClicked = FALSE ' consume mouse click
                    End If
                End If

                If InputManager.mouseRightClicked Then
                    If RectangleContainsRectangle(r, InputManager.mouseRightButtonClickedRectangle) Then
                        WidgetManager.forced = h ' Move to the specific widget
                        InputManager.mouseRightClicked = FALSE ' consume mouse click
                    End If
                End If
            End If
        Next

        ' Update individual widgets
        PushButtonUpdate
        TextBoxUpdate

        ' Draw the widget
        For h = 1 To UBound(Widget)
            If Widget(h).inUse And Widget(h).visible And Not Widget(h).disabled Then
                ' Draw
            End If
        Next
    End Sub


    Sub InputManagerUpdate
        Shared InputManager As InputManagerType
        Static As Byte mouseLeftButtonDown, mouseRightButtonDown ' keeps track if the mouse buttons were held down

        ' Collect mouse input
        Do While MouseInput
            InputManager.mousePosition.x = MouseX
            InputManager.mousePosition.y = MouseY

            InputManager.mouseLeftButton = MouseButton(1)
            InputManager.mouseRightButton = MouseButton(2)

            ' Check if the left button were previously held down and update the up position if released
            If Not InputManager.mouseLeftButton And mouseLeftButtonDown Then
                mouseLeftButtonDown = FALSE
                InputManager.mouseLeftButtonClickedRectangle.b = InputManager.mousePosition
                InputManager.mouseLeftClicked = TRUE
            End If

            ' Check if the button were previously held down and update the up position if released
            If Not InputManager.mouseRightButton And mouseRightButtonDown Then
                mouseRightButtonDown = FALSE
                InputManager.mouseRightButtonClickedRectangle.b = InputManager.mousePosition
                InputManager.mouseRightClicked = TRUE
            End If

            ' Check if the mouse button was pressed and update the down position
            If InputManager.mouseLeftButton And Not mouseLeftButtonDown Then
                mouseLeftButtonDown = TRUE
                InputManager.mouseLeftButtonClickedRectangle.a = InputManager.mousePosition
                InputManager.mouseLeftClicked = FALSE
            End If

            ' Check if the mouse button was pressed and update the down position
            If InputManager.mouseRightButton And Not mouseRightButtonDown Then
                mouseRightButtonDown = TRUE
                InputManager.mouseRightButtonClickedRectangle.a = InputManager.mousePosition
                InputManager.mouseRightClicked = FALSE
            End If
        Loop

        ' Get keyboard input from the keyboard buffer
        InputManager.keyCode = KeyHit
    End Sub


    ' This gets the current keyboard input
    Function InputManagerKey&
        Shared InputManager As InputManagerType

        InputManagerKey = InputManager.keyCode
    End Function


    ' Get the mouse X position
    Function InputManagerMouseX&
        Shared InputManager As InputManagerType

        InputManagerMouseX = InputManager.mousePosition.x
    End Function


    ' Get the mouse Y position
    Function InputManagerMouseY&
        Shared InputManager As InputManagerType

        InputManagerMouseY = InputManager.mousePosition.y
    End Function


    ' Is the left mouse button down?
    Function InputManagerMouseLeftButton%%
        Shared InputManager As InputManagerType

        InputManagerMouseLeftButton = InputManager.mouseLeftButton
    End Function


    ' Is the right mouse button down?
    Function InputManagerMouseRightButton%%
        Shared InputManager As InputManagerType

        InputManagerMouseRightButton = InputManager.mouseRightButton
    End Function


    ' Returns the handle number of the widget that has focus
    ' The function will return 0 if there are no active widgets
    Function CurrentWidget&
        Shared Widget() As WidgetType
        Shared WidgetManager As WidgetManagerType

        If UBound(Widget) = 0 Then Exit Function

        CurrentWidget = WidgetManager.current
    End Function


    ' This set the focus on the widget handle that is passed
    ' The focus changes on the next update
    ' -1 = move to next widget
    ' >0 = move to a specific widget
    Sub CurrentWidget (handle As Long)
        Shared Widget() As WidgetType
        Shared WidgetManager As WidgetManagerType

        If UBound(Widget) = 0 Then Exit Sub ' Leave if nothing is active

        If handle < -1 Or handle = 0 Or handle > UBound(Widget) Then ' is handle valid?
            Error ERROR_INVALID_HANDLE
        End If

        WidgetManager.forced = handle ' inform WidgetUpdate to change the focus
    End Sub


    ' Closes a specific widget
    Sub FreeWidget (handle As Long)
        Shared Widget() As WidgetType
        Shared WidgetManager As WidgetManagerType

        If UBound(Widget) = 0 Then Exit Sub ' leave if nothing is active

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then ' is handle valid?
            Error ERROR_INVALID_HANDLE
        End If

        ' We will not bother resizing the widget array so that subsequent allocations will be faster
        ' So just set the 'inUse' member to false
        Widget(handle).inUse = FALSE
        ' Set focus on the next widget
        CurrentWidget -1
    End Sub


    ' Closes all widgets
    Sub FreeAllWidgets
        Shared Widget() As WidgetType
        Shared WidgetManager As WidgetManagerType

        If UBound(Widget) = 0 Then Exit Sub ' leave if nothing is active

        ReDim Widget(0 To 0) As WidgetType ' reset the widget array
        WidgetManager.current = 0
        WidgetManager.forced = 0
    End Sub


    ' Retrieves the text from a specific widget
    Function WidgetText$ (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        WidgetText = Widget(handle).text
    End Function


    ' Sets the text of a specific widget
    Sub WidgetText (handle As Long, text As String)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Sub

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        Widget(handle).text = text
    End Sub


    ' Reports back if the ENTER key has been pressed on one or all input fileds
    ' handle values available to programmer:
    '  0 = get the ENTER key status of all input fields in use (TRUE/FALSE)      *
    ' >0 = get the ENTER key status on a certain input field (TRUE/FALSE)        *
    Function TextBoxEntered%% (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function ' leave if nothing is active

        If handle < 1 Or handle > UBound(Widget) Or Widget(handle).class <> WIDGET_TEXT_BOX Then ' is handle valid?
            Error ERROR_INVALID_HANDLE
        End If

        If handle > 0 Then
            TextBoxEntered = Widget(handle).txt.entered
        Else
            Dim h As Long

            TextBoxEntered = TRUE '  assume all have had ENTER key pressed (TRUE)

            For h = 1 To UBound(Widget)
                If Widget(h).inUse And Not Widget(h).txt.entered Then
                    TextBoxEntered = FALSE

                    Exit Function
                End If
            Next
        End If
    End Function


    ' Sets up a widget and returns a handle value that points to that widget
    Function NewWidget& (class As Long)
        Shared Widget() As WidgetType
        Shared WidgetManager As WidgetManagerType

        If class < 0 Or class >= WIDGET_CLASS_COUNT Then
            Error ERROR_FEATURE_UNAVAILABLE
        End If

        Dim h As Long ' the new handle number

        Do ' find available handle
            h = h + 1
        Loop Until Not Widget(h).inUse Or h = UBound(Widget)

        If Widget(h).inUse Then ' last one in use?
            h = h + 1 ' use next handle
            ReDim Preserve Widget(1 To h) As WidgetType ' increase array size
        End If

        If WidgetManager.current = 0 Then WidgetManager.current = 1 ' first time called set to 1

        Dim temp As WidgetType
        Widget(h) = temp ' ensure everything is wiped

        Widget(h).inUse = TRUE
        Widget(h).class = class ' set the class

        NewWidget = h ' return the handle
    End Function


    ' Duplicates a widget from a designated handle
    ' Returns handle value greater than 0 indicating the new widgets handle
    Function CopyWidget& (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        Dim nh As Long
        nh = NewWidget(0) ' creat a new widget of class 0. Whatever that is, is not important
        Widget(nh) = Widget(handle) ' copy all properties

        CopyWidget = nh ' return new handle
    End Function


    ' Creates a new button
    Function NewPushButton& (text As String, x As Long, y As Long, w As Unsigned Long, h As Unsigned Long)
        Shared Widget() As WidgetType
        Dim b As Long

        b = NewWidget(WIDGET_PUSH_BUTTON)

        Widget(b).text = text
        Widget(b).position.x = x
        Widget(b).position.y = y
        Widget(b).size.x = w
        Widget(b).size.y = h
        Widget(b).visible = TRUE

        ' Class specific stuff are all 0 thanks to NewWidget()
        ' So, we will not bother changing anything

        NewPushButton = b
    End Function


    ' Create a new input box
    Function NewInputBox& (text As String, x As Long, y As Long, w As Unsigned Long, h As Unsigned Long, flags As Unsigned Long)
        Shared Widget() As WidgetType

        Dim t As Long ' the new handle number

        t = NewWidget(WIDGET_TEXT_BOX)

        Widget(t).text = text
        Widget(t).position.x = x
        Widget(t).position.y = y
        Widget(t).size.x = w
        Widget(t).size.y = h
        Widget(t).visible = TRUE

        ' Set class specific stuff
        Widget(t).txt.flags = flags ' store the flags
        Widget(t).txt.textPosition = 1 ' set the cursor at the beginning of the input line
        Widget(t).txt.boxPosition = 1
        Widget(t).txt.boxTextLength = (w - PrintWidth("W") * 2) \ PrintWidth("W") ' calculate the number of character we can show at a time
        Widget(t).txt.boxStartCharacter = 1
        Widget(t).txt.insertMode = TRUE ' initial insert mode to insert

        NewInputBox = t
    End Function


    ' Hides / shows a widget on screen
    Sub WidgetVisible (handle As Long, visible As Byte)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Sub

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        Widget(handle).visible = visible
    End Sub


    ' Returns if a widget is hidden or shown
    Function WidgetVisible%% (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        WidgetVisible = Widget(handle).visible
    End Function


    ' Hides / shows a widget on screen
    Sub WidgetDisabled (handle As Long, disabled As Byte)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Sub

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        Widget(handle).disabled = disabled
    End Sub


    ' Returns if a widget is hidden or shown
    Function WidgetDisabled%% (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        WidgetDisabled = Widget(handle).disabled
    End Function


    Sub WidgetPositionX (handle As Long, x As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Sub

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        Widget(handle).position.x = x
    End Sub


    Function WidgetPositionX& (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        WidgetPositionX = Widget(handle).position.x
    End Function


    Sub WidgetPositionY (handle As Long, y As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Sub

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        Widget(handle).position.y = y
    End Sub


    Function WidgetPositionY& (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        WidgetPositionY = Widget(handle).position.y
    End Function


    Sub WidgetSizeX (handle As Long, x As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Sub

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        Widget(handle).size.x = x
    End Sub


    Function WidgetSizeX& (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        WidgetSizeX = Widget(handle).size.x
    End Function


    Sub WidgetSizeY (handle As Long, y As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Sub

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        Widget(handle).size.y = y
    End Sub


    Function WidgetSizeY& (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        WidgetSizeY = Widget(handle).size.y
    End Function


    Function WidgetClicked%% (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Then
            Error ERROR_INVALID_HANDLE
        End If

        WidgetClicked = Widget(handle).clicked
    End Function


    Sub PushButtonState (handle As Long, state As Byte)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Sub

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Or Widget(handle).class <> WIDGET_PUSH_BUTTON Then
            Error ERROR_INVALID_HANDLE
        End If

        Widget(handle).cmd.state = state
    End Sub


    Function PushButtonState%% (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Function

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Or Widget(handle).class <> WIDGET_PUSH_BUTTON Then
            Error ERROR_INVALID_HANDLE
        End If

        PushButtonState = Widget(handle).cmd.state
    End Function


    ' Toggles the button specified between pressed/depressed
    Sub PushButtonToggleState (handle As Long)
        Shared Widget() As WidgetType

        If UBound(Widget) = 0 Then Exit Sub

        If handle < 1 Or handle > UBound(Widget) Or Not Widget(handle).inUse Or Widget(handle).class <> WIDGET_PUSH_BUTTON Then
            Error ERROR_INVALID_HANDLE
        End If

        Widget(handle).cmd.state = Not Widget(handle).cmd.state
    End Sub


    ' This will update the status of a button (state & clicked etc.) based on user input
    ' This always works on the button that has focus
    Sub PushButtonUpdate
        Shared Widget() As WidgetType
        Shared WidgetManager As WidgetManagerType
        Shared InputManager As InputManagerType
        Dim r As RectangleType, clicked As Byte

        If UBound(Widget) = 0 Then Exit Sub ' leave if nothing is active

        If Widget(WidgetManager.current).class <> WIDGET_PUSH_BUTTON Then Exit Sub ' leave if the currently focused widget is not a button

        ' Find the bounding box
        MakeRectangle Widget(WidgetManager.current).position, Widget(WidgetManager.current).size, r

        If InputManager.mouseLeftClicked Then
            If RectangleContainsRectangle(r, InputManager.mouseLeftButtonClickedRectangle) Then
                clicked = TRUE
                InputManager.mouseLeftClicked = FALSE ' consume mouse click
            End If
        End If

        If InputManager.mouseRightClicked Then
            If RectangleContainsRectangle(r, InputManager.mouseRightButtonClickedRectangle) Then
                clicked = TRUE
                InputManager.mouseRightClicked = FALSE ' consume mouse click
            End If
        End If

        If InputManager.keyCode = KEY_ENTER Or InputManager.keyCode = KEY_SPACE_BAR Then
            clicked = TRUE
            InputManager.keyCode = NULL ' consume keystroke
        End If

        If clicked Then
            Widget(WidgetManager.current).clicked = TRUE

            ' Toggle if this is a toggle button
            If Widget(WidgetManager.current).cmd.toggle Then
                Widget(WidgetManager.current).cmd.state = Not Widget(WidgetManager.current).cmd.state
            End If
        End If
    End Sub


    ' This will update the state of text box based on user input
    ' This always works on the text box that has focus
    Sub TextBoxUpdate
        Shared Widget() As WidgetType
        Shared WidgetManager As WidgetManagerType
        Shared InputManager As InputManagerType

        If UBound(Widget) = 0 Then Exit Sub ' leave if nothing is active

        If Widget(WidgetManager.current).class <> WIDGET_TEXT_BOX Then Exit Sub ' leave if the currently focused widget is not a text box


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
end sub

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
            Error ERROR_INVALID_HANDLE
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

'-----------------------------------------------------------------------------------------------------
$End If
'---------------------------------------------------------------------------------------------------------
