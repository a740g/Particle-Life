$Debug
'---------------------------------------------------------------------------------------------------------
' QB64-PE Immediate mode GUI Library
'
' Based on Terry Ritchie's work: GLINPUT, RQBL, RQML
' Note this a combintion of the above libraries with a unified input manager
' As such some things have chaged and will not work as a drop in replacement for Terry's libraries
' This was born becuase I needed a small, fast and intuitive GUI libary for games and graphic applications
'
' Copyright (c) 2022 Samuel Gomes
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' HEADER FILES
'---------------------------------------------------------------------------------------------------------
'$Include:'./IMGUI64.bi'
'---------------------------------------------------------------------------------------------------------


Dim Menu%

Screen _NewImage(800, 600, 32)
_ScreenMove _Middle
Cls , SkyBlue


Restore menudata
MakeMenu
ShowMenu

Do
    IMGUI64Update
    ButtonUpdate
    Menu% = CheckMenu%(TRUE)

Loop Until IMGUI64GetKey = 27 Or Menu% = 103

HideMenu

System

menudata:
Data "&File","&Open...#CTRL+O","&Save#CTRL+S","-E&xit#CTRL+Q","*"
Data "&Help","&About...","*"
Data "!"


$If IMGUI64_BAS = UNDEFINED Then
    $Let IMGUI64_BAS = TRUE

    '-----------------------------------------------------------------------------------------------------
    ' FUNCTIONS & SUBROUTINES
    '-----------------------------------------------------------------------------------------------------

    ' This routine ties the whole update system and makes everything go
    Sub IMGUI64Update
        Shared __IMGUI64_InputSystem As __IMGUI64_InputSystemType

        ' Collect mouse input
        Do While MouseInput
            __IMGUI64_InputSystem.mouseX = MouseX
            __IMGUI64_InputSystem.mouseY = MouseY

            __IMGUI64_InputSystem.leftMouseButton = MouseButton(1)
            __IMGUI64_InputSystem.rightMouseButton = MouseButton(2)

            ' Exit the loop if either buttons were pressed
            ' This will allow the library to process the click and ensure no clicks are missed
            If __IMGUI64_InputSystem.leftMouseButton Or __IMGUI64_InputSystem.rightMouseButton Then Exit Do
        Loop

        ' Check if the lasd keyboard input was consumed and if so get the next one
        __IMGUI64_InputSystem.keyCode = _KeyHit
    End Sub


    ' This gets the current keyboard input
    Function IMGUI64GetKey&
        Shared __IMGUI64_InputSystem As __IMGUI64_InputSystemType

        IMGUI64GetKey = __IMGUI64_InputSystem.keyCode
    End Function


    ' Get the mouse X position
    Function IMGUI64GetMouseX&
        Shared __IMGUI64_InputSystem As __IMGUI64_InputSystemType

        IMGUI64GetMouseX = __IMGUI64_InputSystem.mouseX
    End Function


    ' Get the mouse Y position
    Function IMGUI64GetMouseY&
        Shared __IMGUI64_InputSystem As __IMGUI64_InputSystemType

        IMGUI64GetMouseY = __IMGUI64_InputSystem.mouseY
    End Function


    ' Is the left mouse button down?
    Function IMGUI64IsLeftMouseDown&
        Shared __IMGUI64_InputSystem As __IMGUI64_InputSystemType

        IMGUI64IsLeftMouseDown = __IMGUI64_InputSystem.leftMouseButton
    End Function


    ' Is the right mouse button down?
    Function IMGUI64IsRightMouseDown&
        Shared __IMGUI64_InputSystem As __IMGUI64_InputSystemType

        IMGUI64IsRightMouseDown = __IMGUI64_InputSystem.rightMouseButton
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Returns the handle number of the current active input field. The function  *
    '* will return 0 if there are no active input fields.                         *
    '*                                                                            *
    '******************************************************************************
    Function GLICurrent&
        Shared __IMGUI64_InputInfo() As __IMGUI64_InputInfoType
        Shared __IMGUI64_InputCurrent As Long

        GLICurrent = 0 '                                                               assume no active input fields
        If UBound(__IMGUI64_InputInfo) = 0 Then Exit Function '                                        leave if no active input fields
        GLICurrent = __IMGUI64_InputCurrent '                                                         return handle of current active input field
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Restores all input background images                                       *
    '*                                                                            *
    '******************************************************************************
    Sub GLIClear
        Shared __IMGUI64_InputInfo() As __IMGUI64_InputInfoType

        Dim Scan% '                                                                    used to scan through input array

        If UBound(__IMGUI64_InputInfo) = 0 Then Exit Sub '                                             leave if nothing is active
        For Scan% = 1 To UBound(__IMGUI64_InputInfo) '                                                 cycle through input array
            _PutImage (__IMGUI64_InputInfo(Scan%).x, __IMGUI64_InputInfo(Scan%).y), __IMGUI64_InputInfo(Scan%).Background '            restore the destination (screen) background
        Next Scan%
    End Sub


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
        Shared __IMGUI64_InputInfo() As __IMGUI64_InputInfoType
        Shared __IMGUI64_InputForced As Long

        If UBound(__IMGUI64_InputInfo) = 0 Then Exit Sub '                                             leave if nothing is active
        If (handle < -1) Or (handle = 0) Or (handle > UBound(__IMGUI64_InputInfo)) Then '           is handle% valid?
            Error 258
        End If
        __IMGUI64_InputForced = handle '                                                         inform GLIUPDATE of force behavior
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
    Sub GLIClose (handle As Long, behavior%)
        Shared __IMGUI64_InputInfo() As __IMGUI64_InputInfoType
        Shared __IMGUI64_InputCurrent As Long

        Dim Scan% '                                                                    used to scan through input array

        If UBound(__IMGUI64_InputInfo) = 0 Then Exit Sub '                                             leave if nothing is active
        If handle <> 0 Then '                                                         closing all input fields?
            If (handle < 0) Or (handle > UBound(__IMGUI64_InputInfo)) Or Not __IMGUI64_InputInfo(handle).InUse Then ' no, is handle% valid?
                Error 258
            End If
        End If
        If handle > 0 Then '                                                          closing a specific input field?
            __IMGUI64_InputInfo(handle).InUse = 0 '                                                   yes, this input field no longer used (FALSE)
            If behavior% Then '                                                        should text be hidden?
                _PutImage (__IMGUI64_InputInfo(handle).x, __IMGUI64_InputInfo(handle).y), __IMGUI64_InputInfo(handle).Background '  yes, restore original background image
                __IMGUI64_InputInfo(handle).Visible = 0 '                                             set this input field to invisible (FALSE)
            End If
            For Scan% = 1 To UBound(__IMGUI64_InputInfo) '                                             cycle through the input array
                If __IMGUI64_InputInfo(Scan%).InUse Then '                                             is this input field in use?
                    GLIForce -1 '                                                      yes, force input to next field
                    Exit Sub '                                                         no need to scan any further
                End If
            Next Scan%
        End If
        For Scan% = 1 To UBound(__IMGUI64_InputInfo) '                                                 cycle through all input fields
            If behavior% And __IMGUI64_InputInfo(Scan%).Visible Then '                                 make a visible input invisible?
                _PutImage (__IMGUI64_InputInfo(Scan%).x, __IMGUI64_InputInfo(Scan%).y), __IMGUI64_InputInfo(Scan%).Background '        yes, restore original background
            End If
            _FreeImage __IMGUI64_InputInfo(Scan%).TextImage '                                          remove the text image from memory
            _FreeImage __IMGUI64_InputInfo(Scan%).Background '                                         remove the background image from memory
        Next Scan%
        ReDim __IMGUI64_InputInfo(0) As __IMGUI64_InputInfoType '                                                      reset the input array
        __IMGUI64_InputCurrent = 0 '                                                                  reset the current input field
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
        Shared __IMGUI64_InputInfo() As __IMGUI64_InputInfoType

        Dim InputText$ '                                                               holds cleaned input text from array

        If UBound(__IMGUI64_InputInfo) = 0 Then Exit Function '                                        leave if nothing is active
        If (handle% < 1) Or (handle% > UBound(__IMGUI64_InputInfo)) Or Not __IMGUI64_InputInfo(handle%).InUse Then '                             is handle% valid?
            Error 258
        End If
        InputText$ = RTrim$(__IMGUI64_InputInfo(handle%).InputText) '                                  trim excess spaces from end of text input
        GLIOutput$ = Left$(InputText$, Len(InputText$) - 1) '                          remove chr(0) place holder and return value
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
        Shared __IMGUI64_InputInfo() As __IMGUI64_InputInfoType

        Dim Scan% '                                                                    used to scan through input array

        If UBound(__IMGUI64_InputInfo) = 0 Then Exit Function '                                        leave if nothing is active
        If (handle% < 0) Or (handle% > UBound(__IMGUI64_InputInfo)) Then '                             is handle% valid?
            Error 258
        End If
        If handle% > 0 Then '                                                          looking for a certain input field?
            GLIEntered = __IMGUI64_InputInfo(handle%).Entered '                                        yes, report back the ENTER key status
        Else '                                                                         no, looking for all input fields
            GLIEntered = TRUE '                                                          assume all have had ENTER key pressed (TRUE)
            For Scan% = 1 To UBound(__IMGUI64_InputInfo) '                                             scan the entire input array
                If __IMGUI64_InputInfo(Scan%).InUse And (Not __IMGUI64_InputInfo(Scan%).Entered) Then '                is field in use and no ENTER key pressed?
                    GLIEntered = FALSE '                                                   yes, report back not all fields been ENTERed (FALSE)
                    Exit Function '                                                    no need to check any further
                End If
            Next Scan%
        End If
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Sets up a text input at the coordinates given, allowed input text and      *
    '* display text. Returns a handle value that points to the input text field.  *
    '*                                                                            *
    '* x%     - x location of input text field                                    *
    '* y%     - y location of input text field                                    *
    '* allow% - type of text allowed                                              *
    '* text$  - string of text to display in front of input field                 *
    '* Save%  - TRUE to save background image, FALSE to overwrite background      *
    '*                                                                            *
    '******************************************************************************
    Function GLIInput& (x%, y%, allow%, text$, Save%) Static
        Shared __IMGUI64_InputInfo() As __IMGUI64_InputInfoType
        Shared __IMGUI64_InputCurrent As Long

        Dim c% '                                                                       the new handle number

        If __IMGUI64_InputCurrent = 0 Then __IMGUI64_InputCurrent = 1 '                                              first time called set to 1
        ReDim _Preserve __IMGUI64_InputInfo(UBound(__IMGUI64_InputInfo) + 1) As __IMGUI64_InputInfoType '                              create a new input array entry
        c% = UBound(__IMGUI64_InputInfo) '                                                             get the new handle number
        __IMGUI64_InputInfo(c%).x = x% '                                                               save the x location of text
        __IMGUI64_InputInfo(c%).y = y% '                                                               save the y location of text
        __IMGUI64_InputInfo(c%).Allow = allow% '                                                       save the type of input allowed
        __IMGUI64_InputInfo(c%).Text = text$ + Chr$(0) '                                               pad the text with a chr(0)
        __IMGUI64_InputInfo(c%).InUse = -1 '                                                           this input field is now in use (TRUE)
        __IMGUI64_InputInfo(c%).CurrentFont = _Font(_Dest) '                                           get the font currently in use
        __IMGUI64_InputInfo(c%).FontHeight = _FontHeight(_Font(_Dest)) '                               get the height of the current font
        __IMGUI64_InputInfo(c%).FontWidth = _FontWidth(_Font(_Dest)) '                                 get the width of the current font
        If __IMGUI64_InputInfo(c%).FontWidth > 0 Then __IMGUI64_InputInfo(c%).MonoSpace = -1 '                         identify monospace fonts (TRUE)
        __IMGUI64_InputInfo(c%).BackgroundColor = _BackgroundColor '                                   get the current background color
        __IMGUI64_InputInfo(c%).DefaultColor = _DefaultColor '                                         get the current foreground color
        __IMGUI64_InputInfo(c%).TextWidth = _PrintWidth(text$) '                                       get the width of the text
        __IMGUI64_InputInfo(c%).CursorPosition = 1 '                                                   set the cursor at the beginning of the input line
        __IMGUI64_InputInfo(c%).InputTextX = _PrintWidth(text$) '                                      get the x location of the input text line
        __IMGUI64_InputInfo(c%).InputText = Chr$(0) '                                                  set input text as empty
        __IMGUI64_InputInfo(c%).ICursorHeight = Int(_FontHeight(_Font(_Dest)) / 12) - 1 '              compute the insert cursor height
        If __IMGUI64_InputInfo(c%).ICursorHeight < 0 Then __IMGUI64_InputInfo(c%).ICursorHeight = 0 '                  correct cursor height for very small fonts
        __IMGUI64_InputInfo(c%).OCursorHeight = _FontHeight(_Font(_Dest)) - 1 '                        compute the overwrite cursor height
        __IMGUI64_InputInfo(c%).CursorX = _PrintWidth(text$) '                                         compute the x location of cursor
        __IMGUI64_InputInfo(c%).ICursorY = _FontHeight(_Font(_Dest)) - __IMGUI64_InputInfo(c%).ICursorHeight - 1 '     compute the y location of insert cursor
        __IMGUI64_InputInfo(c%).OCursorY = 0 '                                                         save the y location of the overwrite cursor
        __IMGUI64_InputInfo(c%).BlinkTimer = Timer '                                                   save the cursor blink timer
        __IMGUI64_InputInfo(c%).CursorWidth = _PrintWidth("1") - 1 '                                   save the initial width of the cursor
        __IMGUI64_InputInfo(c%).InsertMode = 0 '                                                       initial insert mode to insert
        __IMGUI64_InputInfo(c%).Entered = 0 '                                                          ENTER has not been pressed yet (FALSE)
        __IMGUI64_InputInfo(c%).Save = Save% '                                                         get the background saving behavior
        __IMGUI64_InputInfo(c%).Visible = -1 '                                                         initially visible on screen (TRUE)
        __IMGUI64_InputInfo(c%).TextImage = _NewImage(1, 1, 32) '                                      create initial text image holder
        __IMGUI64_InputInfo(c%).Background = _NewImage(1, 1, 32) '                                     create initial background image holder
        GLIInput = c% '                                                                return with the new handle number
    End Function



    '******************************************************************************
    '*                                                                            *
    '* Updates the inputs on screen                                               *
    '*                                                                            *
    '******************************************************************************
    Sub GLIUpdate
        Shared __IMGUI64_InputInfo() As __IMGUI64_InputInfoType
        Shared __IMGUI64_InputForced As Long
        Shared __IMGUI64_InputCurrent As Long

        Dim Scan% '                                                                    used to scan input array
        Dim CursorWidth% '                                                             holds width of cursor at current text position
        Dim Text$ '                                                                    holds clean text from text within array
        Dim InputText$ '                                                               holds clean input text from input text within array
        Dim OriginalFont& '                                                            the font before this subroutine called
        Dim Spc$ '                                                                     space padding needed at end of line
        Dim OriginalDest& '                                                            the image destination before subroutine called
        Dim c%, cy%, ch%
        Dim k&, k$

        If UBound(__IMGUI64_InputInfo) = 0 Then Exit Sub '                                             leave if nothing is active
        If __IMGUI64_InputCurrent = 0 Then __IMGUI64_InputCurrent = 1 '                                              if this is first time set current input to 1
        OriginalDest& = _Dest '                                                        save current desitnation image
        OriginalFont& = _Font(_Dest) '                                                 save current font
        For Scan% = 1 To UBound(__IMGUI64_InputInfo) '                                                 cycle through all inputs
            If __IMGUI64_InputInfo(Scan%).Visible Then '                                               is this input visible?
                _FreeImage __IMGUI64_InputInfo(Scan%).TextImage '                                      yes, free input's text image from memory
                _FreeImage __IMGUI64_InputInfo(Scan%).Background '                                     free input's background image from memory
                InputText$ = RTrim$(__IMGUI64_InputInfo(Scan%).InputText) '                            get clean input text from array
                InputText$ = Left$(InputText$, Len(InputText$) - 1) '                  remove the chr(0) placeholder
                Text$ = RTrim$(__IMGUI64_InputInfo(Scan%).Text) '                                      get clean text from array
                Text$ = Left$(Text$, Len(Text$) - 1) '                                 remove the chr(0) placeholder
                _Font __IMGUI64_InputInfo(Scan%).CurrentFont '                                         set font for this input field
                If __IMGUI64_InputInfo(Scan%).MonoSpace Then Spc$ = "  " Else Spc$ = Space$(10) '      set up input trailing spaces
        __imgui64_inputinfo(Scan%).TextImage = _NEWIMAGE(_PRINTWIDTH(Text$ + InputText$ +_
            "W"), __imgui64_inputinfo(Scan%).FontHeight, 32) '                                 create new text image
                _Dest __IMGUI64_InputInfo(Scan%).TextImage '                                           set the text image as the destination
                _Font __IMGUI64_InputInfo(Scan%).CurrentFont, __IMGUI64_InputInfo(Scan%).TextImage '                   apply font to the new text image
        _PUTIMAGE (0, 0), OriginalDest&, __imgui64_inputinfo(Scan%).TextImage, (__imgui64_inputinfo(Scan%).x,_
            __imgui64_inputinfo(Scan%).y)-(__imgui64_inputinfo(Scan%).x + _PRINTWIDTH(Text$ + InputText$ +_
            "W") - 1, __imgui64_inputinfo(Scan%).y + __imgui64_inputinfo(Scan%).FontHeight - 1) '              get the background image
                __IMGUI64_InputInfo(Scan%).Background = _CopyImage(__IMGUI64_InputInfo(Scan%).TextImage) '             copy a clean background image
                If __IMGUI64_InputInfo(Scan%).Save Then '                                              should input save the background?
                    _PrintMode _KeepBackground , __IMGUI64_InputInfo(Scan%).TextImage '                set font to save the background
                Else '                                                                 no, background is to be ignored
            LINE (0, 0)-(_WIDTH(_DEST), _HEIGHT(_DEST)),_
                __imgui64_inputinfo(c%).BackgroundColor, BF '                                  set text background color
                End If
                Color __IMGUI64_InputInfo(Scan%).DefaultColor, __IMGUI64_InputInfo(Scan%).BackgroundColor '            set the foreground and background colors
                _PrintString (0, 0), Text$, __IMGUI64_InputInfo(Scan%).TextImage '                     display the leading text (if any)
                If __IMGUI64_InputInfo(Scan%).Allow And 128 Then '                                     is this a password field?
            _PRINTSTRING (__imgui64_inputinfo(Scan%).InputTextX, 0), STRING$(LEN(InputText$),_
                "*") + Spc$, __imgui64_inputinfo(Scan%).TextImage '                            yes, display asterisks only
                    CursorWidth% = _PrintWidth("*") - 1 '                              cursor always width of an asterisk
            __imgui64_inputinfo(Scan%).CursorX = __imgui64_inputinfo(Scan%).InputTextX +_
                _PRINTWIDTH(LEFT$(STRING$(LEN(InputText$), "*"),_
                __imgui64_inputinfo(Scan%).CursorPosition - 1)) '                              compute cursor x location
                Else '                                                                 no, this is not a password field
            _PRINTSTRING (__imgui64_inputinfo(Scan%).InputTextX, 0), InputText$ +_
                Spc$, __imgui64_inputinfo(Scan%).TextImage '                                   display actual input text
            CursorWidth% = _PRINTWIDTH(MID$(InputText$,_
                __imgui64_inputinfo(Scan%).CursorPosition, 1)) - 1 '                           cursor width based on size of current position
                    If CursorWidth% <= 0 Then CursorWidth% = _PrintWidth("1") - 1 '    at end of line? if so set cursor width to default size
            __imgui64_inputinfo(Scan%).CursorX = __imgui64_inputinfo(Scan%).InputTextX +_
                _PRINTWIDTH(LEFT$(InputText$, __imgui64_inputinfo(Scan%).CursorPosition - 1)) 'compute cursor x location
                End If
        _PUTIMAGE (__imgui64_inputinfo(Scan%).x, __imgui64_inputinfo(Scan%).y),_
            __imgui64_inputinfo(Scan%).TextImage, OriginalDest& '                              place the text image on the destination image (screen)
            End If
        Next Scan%
        InputText$ = RTrim$(__IMGUI64_InputInfo(__IMGUI64_InputCurrent).InputText) '                                  get clean input text from array
        InputText$ = Left$(InputText$, Len(InputText$) - 1) '                          remove the chr(0) placeholder
        _Font __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CurrentFont '                                               set current input field font
        If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).Allow And 128 Then '                                           is this a password field?
            CursorWidth% = _PrintWidth("*") - 1 '                                      yes, cursor always width of an asterisk
        Else '                                                                         no, this is not a password field
    CursorWidth% = _PRINTWIDTH(MID$(InputText$,_
       __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition, 1)) - 1 '                                  cursor width based on size of current position
            If CursorWidth% <= 0 Then CursorWidth% = _PrintWidth("1") - 1 '            at end of line? if so set cursor width to default size
        End If
        _Dest __IMGUI64_InputInfo(__IMGUI64_InputCurrent).TextImage '                                                 set the text image as new destination
        If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).InsertMode = 0 Then '                                          in INSERT mode?
            cy% = __IMGUI64_InputInfo(__IMGUI64_InputCurrent).ICursorY '                                              yes, use insert mode cursor y position
            ch% = __IMGUI64_InputInfo(__IMGUI64_InputCurrent).ICursorHeight '                                         use insert mode cursor height
        Else '                                                                         no, in OVERWRITE mode
            cy% = __IMGUI64_InputInfo(__IMGUI64_InputCurrent).OCursorY '                                              use overwrite mode cursor y position
            ch% = __IMGUI64_InputInfo(__IMGUI64_InputCurrent).OCursorHeight '                                         use overwrite mode cursor height
        End If
        Select Case Timer '                                                            look at the value in timer
            Case Is < __IMGUI64_InputInfo(__IMGUI64_InputCurrent).BlinkTimer + .15 '                                  has 0 to .15 second elapsed?
                If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition > Len(InputText$) Then '                yes, is the cursor at the end of line?
            LINE (__imgui64_inputinfo(__IMGUI64_InputCurrent).CursorX, cy%)-(__imgui64_inputinfo(__IMGUI64_InputCurrent).CursorX +_
                CursorWidth%, cy% + ch%),_
                __imgui64_inputinfo(__IMGUI64_InputCurrent).BackgroundColor, BF '                             yes, erase the cursor
                End If
            Case Is < __IMGUI64_InputInfo(__IMGUI64_InputCurrent).BlinkTimer + .3 '                                   has .16 to .3 second elapsed?
        LINE (__imgui64_inputinfo(__IMGUI64_InputCurrent).CursorX, cy%)-(__imgui64_inputinfo(__IMGUI64_InputCurrent).CursorX +_
            CursorWidth%, cy% + ch%), __imgui64_inputinfo(__IMGUI64_InputCurrent).DefaultColor, BF '          yes, draw the cursor
            Case Else '                                                                greater than .3 second has elapsed
                __IMGUI64_InputInfo(__IMGUI64_InputCurrent).BlinkTimer = Timer '                                      reset the array blink timer
        End Select
        _Dest OriginalDest& '                                                          restore original destination
        _Font OriginalFont& '                                                          restore calling procedure font
        _PutImage (__IMGUI64_InputInfo(__IMGUI64_InputCurrent).x, __IMGUI64_InputInfo(__IMGUI64_InputCurrent).y), __IMGUI64_InputInfo(__IMGUI64_InputCurrent).TextImage '           place the text image on the destination image (screen)
        If __IMGUI64_InputForced <> 0 Then '                                                      being forced to an input field?
            If __IMGUI64_InputForced = -1 Then '                                                  yes, to the next one?
                Scan% = __IMGUI64_InputCurrent '                                                      set scanner to current input field
                Do '                                                                   start scanning
                    Scan% = Scan% + 1 '                                                move scanner to next handle number
                    If Scan% > UBound(__IMGUI64_InputInfo) Then Scan% = 1 '                            return to start of input array if limit reached
                    If __IMGUI64_InputInfo(Scan%).InUse Then __IMGUI64_InputCurrent = Scan% '                         set current input field if in use
                Loop Until __IMGUI64_InputCurrent = Scan% '                                           leave scanner when an input field in use is found
                __IMGUI64_InputForced = 0 '                                                       reset force indicator
            Else '                                                                     yes, to a specific input field
                __IMGUI64_InputCurrent = __IMGUI64_InputForced '                                                 set the current input field
                __IMGUI64_InputForced = 0 '                                                       reset force indicator
            End If
        End If
        k& = _KeyHit '                                                            check for a key having been pressed
        If k& > 0 Then '                                                          was a key pressed?
            __IMGUI64_InputInfo(__IMGUI64_InputCurrent).InsertMode = _KeyDown(200012) '                               yes, get the insert mode
            Select Case k& '                                                      which key was hit?
                Case 20992 '                                                           INSERT key was pressed
                    Exit Sub '                                                         user changed insert mode, leave subroutine
                Case 19712 '                                                           RIGHT ARROW key was pressed
                    __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition = __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition + 1 '    increment the cursor position
                    If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition% > Len(InputText$) + 1 Then '       will this take the cursor too far?
                        __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition = Len(InputText$) + 1 '            yes, keep the cursor at the end of the line
                    End If
                Case 19200 '                                                           LEFT ARROW key was pressed
                    __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition = __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition - 1 '    decrement the cursor position
                    If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition = 0 Then '                          did cursor go beyone beginning of line?
                        __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition = 1 '                              yes, keep the cursor at the beginning of the line
                    End If
                Case 8 '                                                               BACKSPACE key pressed
                    If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition > 1 Then '                          is the cursor at the beginning of the line?
                InputText$ = LEFT$(InputText$,_
                    __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition - 2) +_
                    RIGHT$(InputText$, LEN(InputText$) -_
                    __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition% + 1) '                        no, delete character
                        __IMGUI64_InputInfo(__IMGUI64_InputCurrent).InputText = InputText$ + Chr$(0) '                save new input text into input array
                        __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition = __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition - 1 'decrement the cursor position
                    End If
                Case 18176 '                                                           HOME key was pressed
                    __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition = 1 '                                  move the cursor to the beginning of the line
                Case 20224 '                                                           END key was pressed
                    __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition = Len(InputText$) + 1 '                move the cursor to the end of the line
                Case 21248 '                                                           DELETE key was pressed
                    If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition < Len(InputText$) + 1 Then '        is the cursor at the end of the line?
                InputText$ = LEFT$(InputText$,_
                __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition - 1) +_
                RIGHT$(InputText$, LEN(InputText$) -_
                __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition) '                                 no, delete character
                        __IMGUI64_InputInfo(__IMGUI64_InputCurrent).InputText = InputText$ + Chr$(0) '                save new input text into input array
                    End If
                Case 9, 13, 20480 '                                                    TAB, ENTER or DOWN ARROW key pressed
                    If k& = 13 Then __IMGUI64_InputInfo(__IMGUI64_InputCurrent).Entered = -1 '                   if enter key was pressed remember it (TRUE)
                    Scan% = __IMGUI64_InputCurrent '                                                  set initital point of input array scan
                    Do '                                                               begin scanning input array
                        Scan% = Scan% + 1 '                                            increment the scanner
                        If Scan% > UBound(__IMGUI64_InputInfo) Then Scan% = 1 '                        go to beginning of array if the end was reached
                        If __IMGUI64_InputInfo(Scan%).InUse Then __IMGUI64_InputCurrent = Scan% '                     if this field is in use then set it as the current input field
                    Loop Until __IMGUI64_InputCurrent = Scan% '                                       keep scanning until a valid field is found
                    __IMGUI64_InputInfo(__IMGUI64_InputCurrent).InsertMode = _KeyDown(200012) '                       save the current insert mode to use in this field
                Case 18432 '                                                           UP ARROW key was pressed
                    Scan% = __IMGUI64_InputCurrent '                                                  set initial point of input array scan
                    Do '                                                               begin scanning input array
                        Scan% = Scan% - 1 '                                            decrement the scanner
                        If Scan% = 0 Then Scan% = UBound(__IMGUI64_InputInfo) '                        go the end of the array if the beginning was reached
                        If __IMGUI64_InputInfo(Scan%).InUse Then __IMGUI64_InputCurrent = Scan% '                     if this field is in use then set it as the current input field
                    Loop Until __IMGUI64_InputCurrent = Scan% '                                       keep scanning until a valid field is found
                    __IMGUI64_InputInfo(__IMGUI64_InputCurrent).InsertMode = _KeyDown(200012) '                       save the current insert mode to use in this field
                Case Else '                                                            a character key was pressed
                    If k& > 31 And k& < 256 Then '                           is it a valid ASCII displayable character?
                        k$ = "" '                                                 yes, initialize key holder variable
                        Select Case k& '                                          which alphanumeric key was pressed?
                            Case 32 '                                                  SPACE key was pressed
                                k$ = Chr$(k&) '                              save the keystroke
                            Case 40 To 41 '                                            PARENTHESIS key was pressed
                        IF (__imgui64_inputinfo(__IMGUI64_InputCurrent).Allow AND 4) OR_
                            (__imgui64_inputinfo(__IMGUI64_InputCurrent).Allow AND 16) THEN_
                            K$ = CHR$(K&) '                          if it's allowed then save the keystroke
                            Case 45 '                                                  DASH (minus -) key was pressed
                                If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).Allow And 8 Then '                     are dashes allowed?
                                    k$ = Chr$(k&) '                          yes, save the keystroke
                                End If
                            Case 48 To 57 '                                            NUMBER key was pressed
                                If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).Allow And 2 Then '                     are numbers allowed?
                                    k$ = Chr$(k&) '                          yes, save the keystroke
                                End If
                            Case 33 To 47, 58 To 64, 91 To 96, 123 To 255 '            SYMBOL key was pressed
                                If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).Allow And 4 Then '                     are symbols allowed?
                                    k$ = Chr$(k&) '                          yes, save the keystroke
                                End If
                            Case 65 To 90, 97 To 122 '                                 ALPHABETIC key was pressed
                                If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).Allow And 1 Then '                     are alpha keys allowed?
                                    k$ = Chr$(k&) '                          yes, save the keystroke
                                End If
                        End Select
                        If k$ <> "" Then '                                        was an allowed keystroke saved?
                            If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).Allow And 32 Then '                        should it be forced to lower case?
                                k$ = LCase$(k$) '                            yes, force the keystroke to lower case
                            End If
                            If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).Allow And 64 Then '                        should it be forced to upper case?
                                k$ = UCase$(k$) '                            yes, force the keystroke to upper case
                            End If
                            If __IMGUI64_InputInfo(__IMGUI64_InputCurrent).CursorPosition = Len(InputText$) + 1 Then 'is the cursor at the end of the line?
                                InputText$ = InputText$ + k$ '                    yes, simply add the keystroke to input text
                                __IMGUI64_InputInfo(__IMGUI64_InputCurrent).InputText = InputText$ + Chr$(0) '        pad input text with chr(0) and save new input text in array
                        __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition = _
                            __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition + 1 '                  increment the cursor position
                            ElseIf __IMGUI64_InputInfo(__IMGUI64_InputCurrent).InsertMode = 0 Then '                  no, are we in INSERT mode?
                        InputText$ = LEFT$(InputText$,_
                            __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition - 1) + K$ +_
                            RIGHT$(InputText$, LEN(InputText$) -_
                            __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition + 1) '                 yes, insert the character
                                __IMGUI64_InputInfo(__IMGUI64_InputCurrent).InputText = InputText$ + Chr$(0) '        pad input text with chr(0) and save new input text in array
                        __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition =_
                            __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition + 1 '                  increment the cursor position
                            Else '                                                     no, we are in OVERWRITE mode
                        InputText$ = LEFT$(InputText$,_
                            __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition - 1) + K$ +_
                            RIGHT$(InputText$, LEN(InputText$) -_
                            __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition) '                     overwrite with new character
                                __IMGUI64_InputInfo(__IMGUI64_InputCurrent).InputText = InputText$ + Chr$(0) '        pad input text with chr(0) and save new input text in array
                        __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition =_
                            __imgui64_inputinfo(__IMGUI64_InputCurrent).CursorPosition + 1 '                  increment the cursor position
                            End If
                        End If
                    End If
            End Select
        End If
    End Sub


    '******************************************************************************
    '* Shows a button on screen that is currently hidden.                         *
    '*                                                                            *
    '* bh% - Handle number of button to show.                                     *
    '******************************************************************************
    Sub ButtonShow (bh As Long) '                                           Error Checking
        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        If Not __IMGUI64_ButtonInfo(bh).show Then '                                not currently shown?
            __IMGUI64_ButtonInfo(bh).show = 1 '                                    now showing on screen
            ButtonPut __IMGUI64_ButtonInfo(bh).x, __IMGUI64_ButtonInfo(bh).y, bh '                 show button on screen
        End If
    End Sub


    '******************************************************************************
    '* Hides a button currently shown on screen.                                  *
    '*                                                                            *
    '* bh% - Handle number of button to hide.                                     *
    '******************************************************************************
    Sub ButtonHide (bh As Long) '                                           Error Checking
        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        __IMGUI64_ButtonInfo(bh).show = FALSE '                                    not showing on screen
    End Sub


    '******************************************************************************
    '* Toggles the button to a depressed state.                                   *
    '*                                                                            *
    '* bh% - Handle number of button to press.                                    *
    '******************************************************************************
    Sub ButtonOff (bh As Long) '                                            Error Checking
        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        __IMGUI64_ButtonInfo(bh).state = 0 '                                       depress button
        ButtonPut __IMGUI64_ButtonInfo(bh).x, __IMGUI64_ButtonInfo(bh).y, bh '                     update button image
    End Sub


    '******************************************************************************
    '* Toggles the button to a pressed state.                                     *
    '*                                                                            *
    '* bh% - Handle number of button to press.                                    *
    '******************************************************************************
    Sub ButtonOn (bh As Long) '                                             Error Checking
        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        __IMGUI64_ButtonInfo(bh).state = -1 '                                      press button
        ButtonPut __IMGUI64_ButtonInfo(bh).x, __IMGUI64_ButtonInfo(bh).y, bh '                     update button image
    End Sub


    '******************************************************************************
    '* Toggles the button specified between pressed/depressed.                    *
    '*                                                                            *
    '* bh% - Handle number of button to toggle.                                   *
    '******************************************************************************
    Sub ButtonToggle (bh As Long) '                                         Error Checking
        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        __IMGUI64_ButtonInfo(bh).state = Not __IMGUI64_ButtonInfo(bh).state '                       toggle button's state
        ButtonPut __IMGUI64_ButtonInfo(bh).x, __IMGUI64_ButtonInfo(bh).y, bh '                     update button image
    End Sub


    '******************************************************************************
    '* Returns the status of a button's mouse/button interaction.                 *
    '*                                                                            *
    '* bh% = The button handle number to retrieve the status from.                *
    '******************************************************************************
    Function ButtonEvent (bh As Long) '                                     Error Checking
        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        ButtonEvent = __IMGUI64_ButtonInfo(bh).mouse '                             return mouse status
    End Function


    '******************************************************************************
    '* Turns automatic button checking on or off. (local variables static)        *
    '*                                                                            *
    '* bc% - true (-1) = turn checking on.                                        *
    '*       false (0) = turn checking off.                                       *
    '*                                                                            *
    '* Note: The first time this routine is called with true (-1) an event timer  *
    '*       is created and turned on. Subsequent calls with true (-1) will       *
    '*       simply turn the event timer on if it is currently off.               *
    '******************************************************************************
    Sub ButtonChecking (bc%) Static '
        Dim created% '                                            first time creation
        Dim ct% '                                                 event checking timer

        Shared __IMGUI64_ButtonChecking As Byte '                                       button check status

        If bc% Then '                                             true? checking on
            If Not created% Then '                                is timer created?
                ct% = _FreeTimer '                                no, get timer handle
                On Timer(ct%, .05) ButtonUpdate '                 set timer event
                created% = -1 '                                   timer now created
            End If
            If Not __IMGUI64_ButtonChecking Then Timer(ct%) On '                timer on already?
            __IMGUI64_ButtonChecking = TRUE '                                     other routines know
        Else
            If created% And __IMGUI64_ButtonChecking Then '                     timer made and on?
                Timer(ct%) Off '                                  yes, timer event off
                __IMGUI64_ButtonChecking = FALSE '                                  other routines know
            End If
        End If
    End Sub


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
        Dim bh% '                                                 button handle counter
        Dim ev% '                                                 current mouse event

        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        Do: Loop While _MouseInput '                              get last mouse event
        ev% = 3 '                                                 assume hovering
        If _MouseButton(1) Then ev% = 1 '                         left button clicked
        If _MouseButton(2) Then ev% = 2 '                         right button cicked
        For bh% = 1 To UBound(__IMGUI64_ButtonInfo) '                               test pointer boundary
            If __IMGUI64_ButtonInfo(bh%).inuse And __IMGUI64_ButtonInfo(bh%).show Then '              used and on screen?
                If (_MouseX >= __IMGUI64_ButtonInfo(bh%).x) And (_MouseX <= __IMGUI64_ButtonInfo(bh%).x + __IMGUI64_ButtonInfo(bh%).xs - 1) And (_MouseY >= __IMGUI64_ButtonInfo(bh%).y) And (_MouseY <= __IMGUI64_ButtonInfo(bh%).y + __IMGUI64_ButtonInfo(bh%).ys - 1) Then
                    __IMGUI64_ButtonInfo(bh%).mouse = ev% '                         is in boundary, set
                Else '                                            not button boundary
                    __IMGUI64_ButtonInfo(bh%).mouse = 0 '                           no event to set
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
        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        ButtonHeight = __IMGUI64_ButtonInfo(bh).ys '                               return button height
    End Function


    '******************************************************************************
    '* Returns the width of a button handle.                                      *
    '*                                                                            *
    '* bh% - Handle number of button to get width from.                           *
    '*                                                                            *
    '* returns: Integer value indicating the width of the button.                 *
    '******************************************************************************
    Function ButtonWidth (bh As Long) '                                     Error Checking
        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        ButtonWidth = __IMGUI64_ButtonInfo(bh).xs '                                return button width
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

        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        nh = ButtonNew(0, 0, 0) '                           get new handle number
        __IMGUI64_ButtonInfo(nh) = __IMGUI64_ButtonInfo(bh) '                                       new button properties  ///// this may be a problem - copying background?? not freeing properly?
        __IMGUI64_ButtonInfo(bh).shown = 0 '                                       never been on screen
        __IMGUI64_ButtonInfo(bh).show = 0 '                                        not showing on screen

        ButtonCopy = nh '                                        return hew handle num
    End Function


    '******************************************************************************
    '* Removes a button from the screen, restores the background image and frees  *
    '* any resources the button was using.                                        *
    '*                                                                            *
    '* bh% - Handle number of button to free.                                     *
    '******************************************************************************
    Sub ButtonFree (bh As Long) '                                           Error Checking
        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        If bh = UBound(__IMGUI64_ButtonInfo) And bh <> 1 Then '                   button last element?
            ReDim _Preserve __IMGUI64_ButtonInfo(bh - 1) As __IMGUI64_ButtonInfoType '                   decrease array size
        Else '                                                    not last element
            __IMGUI64_ButtonInfo(bh).inuse = 0 '                                   not in use any more
            __IMGUI64_ButtonInfo(bh).show = 0 '                                    not showing on screen
            __IMGUI64_ButtonInfo(bh).shown = 0 '                                   never been on screen
            __IMGUI64_ButtonInfo(bh).state = 0 '                                   reset button state
            __IMGUI64_ButtonInfo(bh).text = "" '                                   remove any text
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
        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        If bh > UBound(__IMGUI64_ButtonInfo) Or bh < 1 Or Not __IMGUI64_ButtonInfo(bh).inuse Then
            Error 258
        End If

        If Not ((__IMGUI64_ButtonInfo(bh).x = x%) And (__IMGUI64_ButtonInfo(bh).y = y%)) Then '     button x,y change?
            If Not __IMGUI64_ButtonInfo(bh).shown Then '                           shown for 1st time?
                __IMGUI64_ButtonInfo(bh).shown = TRUE '                              set 1st time showing
                __IMGUI64_ButtonInfo(bh).show = TRUE '                               now showing on screen
            End If
            __IMGUI64_ButtonInfo(bh).x = x% '                                      save new x location
            __IMGUI64_ButtonInfo(bh).y = y% '                                      save new y location
        End If
        If __IMGUI64_ButtonInfo(bh).show Then '                                    is button on screen?
            If __IMGUI64_ButtonInfo(bh).state Then '                               is button pressed?
                _PutImage (x%, y%), __IMGUI64_ButtonInfo(bh).in '                  draw button pressed
            Else '                                                button is not pressed
                _PutImage (x%, y%), __IMGUI64_ButtonInfo(bh).out '                 draw button depressed
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
    '* bcolor& - The color of the button. This value is ignored if a valid        *
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
    Function ButtonNew& (xs%, ys%, bcolor&)
        Dim bh As Long '                             handle number of button to be passed back
        Dim scr& '                            holds the handle of the current screen
        Dim cred&, newred& '                  red color value used in button creation
        Dim cgreen&, newgreen& '              green color value used in button creation
        Dim cblue&, newblue& '                blue color value used in button creation

        Shared __IMGUI64_ButtonInfo() As __IMGUI64_ButtonInfoType '                                       button defining array

        Do '                                                      find available handle
            bh = bh + 1 '                                       inc handle number
        Loop Until (Not __IMGUI64_ButtonInfo(bh).inuse) Or bh = UBound(__IMGUI64_ButtonInfo) '      test handle value
        If __IMGUI64_ButtonInfo(bh).inuse Then '                                   last one in use?
            bh = bh + 1 '                                       use next handle
            ReDim _Preserve __IMGUI64_ButtonInfo(bh) As __IMGUI64_ButtonInfoType '                       increase array size
        End If
        __IMGUI64_ButtonInfo(bh).inuse = -1 '                                      mark as in use
        __IMGUI64_ButtonInfo(bh).state = 0 '                                       mark as out
        __IMGUI64_ButtonInfo(bh).x = -32767 '                                      set low for first use
        __IMGUI64_ButtonInfo(bh).y = -32767 '                                      set low for first use
        __IMGUI64_ButtonInfo(bh).out = _NewImage(xs%, ys%, 32) '           generic gfx
        __IMGUI64_ButtonInfo(bh).in = _NewImage(xs%, ys%, 32) '            generic gfx
        __IMGUI64_ButtonInfo(bh).xs = xs% '                                width of button
        __IMGUI64_ButtonInfo(bh).ys = ys% '                                height of button
        scr& = _Dest '                                    current screen handle
        _Dest __IMGUI64_ButtonInfo(bh).out '                               new image destination
        '\\\
        'Generic button creation routine - needs work! \\\\\\\\\\\\\\\\\\\\\\\\
        '///
        cred& = _Red(bcolor&)
        cgreen& = _Green(bcolor&)
        cblue& = _Blue(bcolor&)
        Cls , bcolor&
        newred& = cred& + 64: If newred& > 255 Then newred& = 255
        newgreen& = cgreen& + 64: If newgreen& > 255 Then newgreen& = 255
        newblue& = cblue& + 64: If newblue& > 255 Then newblue& = 255
        Line (0, ys% - 2)-(0, 0), _RGB(newred&, newgreen&, newblue&)
        Line -(xs% - 2, 0), _RGB(newred&, newgreen&, newblue&)
        newred& = cred& + 32: If newred& > 255 Then newred& = 255
        newgreen& = cgreen& + 32: If newgreen& > 255 Then newgreen& = 255
        newblue& = cblue& + 32: If newblue& > 255 Then newblue& = 255
        Line (1, ys% - 3)-(1, 1), _RGB(newred&, newgreen&, newblue&)
        Line -(xs% - 3, 1), _RGB(newred&, newgreen&, newblue&)
        newred& = cred& - 64: If newred& < 0 Then newred& = 0
        newgreen& = cgreen& - 64: If newgreen& < 0 Then newgreen& = 0
        newblue& = cblue& - 64: If newblue& < 0 Then newblue& = 0
        Line (0, ys% - 1)-(xs% - 1, ys% - 1), _RGB(newred&, newgreen&, newblue&)
        Line -(xs% - 1, 0), _RGB(newred&, newgreen&, newblue&)
        newred& = cred& - 32: If newred& < 0 Then newred& = 0
        newgreen& = cgreen& - 32: If newgreen& < 0 Then newgreen& = 0
        newblue& = cblue& - 32: If newblue& < 0 Then newblue& = 0
        Line (1, ys% - 2)-(xs% - 2, ys% - 2), _RGB(newred&, newgreen&, newblue&)
        Line -(xs% - 2, 1), _RGB(newred&, newgreen&, newblue&)
        _Dest __IMGUI64_ButtonInfo(bh).in
        _PutImage (__IMGUI64_ButtonInfo(bh).xs - 1, __IMGUI64_ButtonInfo(bh).ys - 1)-(0, 0), __IMGUI64_ButtonInfo(bh).out
        _Dest scr&
        '\\\
        'End generic button creation routine \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
        '///

        ButtonNew = bh '                                         return handle number
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Retreives whether menu is currently active (in use) (-1) TRUE, (0) FALSE   *
    '*                                                                            *
    '******************************************************************************
    Function GetMenuActive%
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        GetMenuActive% = __IMGUI64_MenuSettings.menuactive
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Retreives whether the menu is showing or not (-1) TRUE, (0) FALSE          *
    '*                                                                            *
    '******************************************************************************
    Function GetMenuShowing%
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        GetMenuShowing% = __IMGUI64_MenuSettings.showing
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Removes the menu from the screen and restores the background image that    *
    '* was under the top bar and any submenu showing.                             *
    '*                                                                            *
    '******************************************************************************
    Sub HideMenu
        Shared __IMGUI64_MenuInfo() As __IMGUI64_MenuInfoType
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        'Mset.menuactive = -1 - Mset.menuactive '                                       toggle active state of menu
        If __IMGUI64_MenuSettings.submenuactive Then '                                                   is a submenu showing?
            _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu ' yes, remove it
        End If
        __IMGUI64_MenuSettings.submenu = 0 '                                                             reset current submenu entry value
        __IMGUI64_MenuSettings.oldsubmenu = 0 '                                                          reset previous submenu entry value
        __IMGUI64_MenuSettings.menuactive = 0 '
        __IMGUI64_MenuSettings.submenuactive = 0 '                                                       disable active state of submenu
        _PutImage (0, 0), __IMGUI64_MenuSettings.undermenu '                                             restore background under top menu bar
        __IMGUI64_MenuSettings.showing = 0 '                                                             menu is no longer showing on screen
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Places the menu bar at the top of the current screen and activates the     *
    '* menu system. The image under the menu bar will be saved and can be         *
    '* restored with HideMenu().                                                  *
    '*                                                                            *
    '******************************************************************************
    Sub ShowMenu
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        _PutImage (0, 0), _Dest, __IMGUI64_MenuSettings.undermenu, (0, 0)-(_Width(__IMGUI64_MenuSettings.menubar) - 1, _Height(__IMGUI64_MenuSettings.menubar) - 1) ' save background under top menu bar
        _PutImage (0, 0), __IMGUI64_MenuSettings.menubar '                                               put the top menu bar on screen
        __IMGUI64_MenuSettings.showing = -1 '                                                            menu is now showing on screen
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Retreives the menu bar height.                                             *
    '*                                                                            *
    '******************************************************************************
    Function GetMenuHeight%
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        GetMenuHeight% = __IMGUI64_MenuSettings.height '                                                 return the height of the top menu bar
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Retreives the menu number user is currently active on.                     *
    '*                                                                            *
    '******************************************************************************
    Function GetCurrentMenu%
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        GetCurrentMenu% = __IMGUI64_MenuSettings.mainmenu * 100 + __IMGUI64_MenuSettings.submenu '                         return the current menu user in on
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Sets the height of the submenu above the background, creating a shadow     *
    '* underneath. A height% of 0 effectively turns off shadowing.                *
    '*                                                                            *
    '******************************************************************************
    Sub SetMenuShadow (Hgt%)
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        If Hgt% < 0 Then Hgt% = 0 '                                              height must be no less than 0
        __IMGUI64_MenuSettings.shadow = Hgt% '                                                        set the submenu shadow height
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Tweaks the location of the submenu Y location by tweak% amount. Positive   *
    '* values lower the submenus, negative values raise the submenus.             *
    '*                                                                            *
    '******************************************************************************
    Sub SetSubMenuLocation (tweak%)
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        __IMGUI64_MenuSettings.subtweak = tweak% '                                                      set the Y tweak amount
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Sets the amount a space, in pixels, to the right and left of main and sub  *
    '* menu entries.                                                              *
    '*                                                                            *
    '******************************************************************************
    Sub SetMenuSpacing (spacing%)
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        If spacing% < 0 Then spacing% = 0 '                                            spacing must be no less than 0
        __IMGUI64_MenuSettings.spacing = spacing% '                                                      set the menu spacing amount
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Set the text and background colors for the sub menu.                       *
    '*                                                                            *
    '* The colors values are passed in this order:                                *
    '*                                                                            *
    '* smatext~&  = sub menu active (normal) text color                           *
    '* smhtext~&  = sub menu highlight text color                                 *
    '* smitext~&  = sub menu inactive text color                                  *
    '* smihtext~& = sub menu inactive highlight text color                        *
    '* smabg~&    = sub menu active background color                              *
    '* smhbg~&    = sub menu highlight background color                           *
    '* smibg~&    = sub menu inactive background color                            *
    '* smihbg~&   = sub menu inactive highlight background color                  *
    '*                                                                            *
    '******************************************************************************
    Sub SetSubmenuColors (smatext~&, smhtext~&, smitext~&, smihtext~&, smabg~&, smhbg~&, smibg~&, smihbg~&)
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        __IMGUI64_MenuSettings.smatext = smatext~& '                                                     set the active (normal) sub menu text color
        __IMGUI64_MenuSettings.smhtext = smhtext~& '                                                     set the highlight sub menu text color
        __IMGUI64_MenuSettings.smitext = smitext~& '                                                     set the inactive sub menu text color
        __IMGUI64_MenuSettings.smihtext = smihtext~& '                                                   set the inactive highlight sub menu text color
        __IMGUI64_MenuSettings.smabg = smabg~& '                                                         set the active (normal) sub menu background color
        __IMGUI64_MenuSettings.smhbg = smhbg~& '                                                         set the highlight sub menu background color
        __IMGUI64_MenuSettings.smibg = smibg~& '                                                         set the inactive sub menu background color
        __IMGUI64_MenuSettings.smihbg = smihbg~& '                                                       set the inactive highlight sub menu background color
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Set the text and background colors for the main menu top bar.              *
    '*                                                                            *
    '* The colors values are passed in this order:                                *
    '*                                                                            *
    '* mmatext~&  = main menu active (normal) text color                          *
    '* mmhtext~&  = main menu highlight text color                                *
    '* mmstext~&  = main menu selected text color                                 *
    '* mmabarbg~& = main menu active (normal) background color                    *
    '* mmhbarbg~& = main menu highlight background color                          *
    '* mmsbarbg~& = main menu selected background color                           *
    '*                                                                            *
    '******************************************************************************
    Sub SetMainMenuColors (mmatext~&, mmhtext~&, mmstext~&, mmabarbg~&, mmhbarbg~&, mmsbarbg~&)
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        __IMGUI64_MenuSettings.mmatext = mmatext~& '                                                     set main menu active (normal) text color
        __IMGUI64_MenuSettings.mmhtext = mmhtext~& '                                                     set main menu highlight text color
        __IMGUI64_MenuSettings.mmstext = mmstext~& '                                                     set main menu selected text color
        __IMGUI64_MenuSettings.mmabarbg = mmabarbg~& '                                                   set main menu active menu bar background color
        __IMGUI64_MenuSettings.mmhbarbg = mmhbarbg~& '                                                   set main menu highlight menu bar backgrund color
        __IMGUI64_MenuSettings.mmsbarbg = mmsbarbg~& '                                                   set main menu selected menu bar background color
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* If TRUE (-1) is passed the menu will take on a 3D effect. Passing a value  *
    '* of FALSE (0) will make the menu take on a flat look.                       *
    '*                                                                            *
    '******************************************************************************
    Sub SetMenu3D (mmbar%, smbar%, mm%, sm%)
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        __IMGUI64_MenuSettings.mmbar3D = mmbar% '                                                        main menu bar to 3D
        __IMGUI64_MenuSettings.smbar3D = smbar% '                                                        sub menu boxes to 3D
        __IMGUI64_MenuSettings.mm3D = mm% '                                                              main menu entries to 3D
        __IMGUI64_MenuSettings.sm3D = sm% '                                                              sub menu entries to 3D
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Tweaks the location of the menu and sub menu text by tweak% amount.        *
    '* Positive values lower the text, negative values raise the text.            *
    '*                                                                            *
    '******************************************************************************
    Sub SetMenuText (tweak%)
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        __IMGUI64_MenuSettings.texttweak = tweak% '                                                      set amount of Y text shifting
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Tweaks the location of the ALT key underscore by Tweak% amount. Positive   *
    '* values lower the underscore, negative values raise the underscore.         *
    '*                                                                            *
    '******************************************************************************
    Sub SetMenuUnderscore (tweak%)
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        __IMGUI64_MenuSettings.alttweak = tweak% '                                                       set amount of Y ALT underscore shifting
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Forces the indent of each meny entry to indent%                            *
    '*                                                                            *
    '******************************************************************************
    Sub SetMenuIndent (Indent%)
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        If Indent% < 0 Then Indent% = 0 '                                              must be 0 or higher
        __IMGUI64_MenuSettings.indent = Indent% '                                                        set amount of menu indention
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Forces the height of each menu entry to hgt%                            *
    '*                                                                            *
    '******************************************************************************
    Sub SetMenuHeight (Hgt%)
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        If Hgt% < 10 Then Hgt% = 10 '                                            height of menu can't be less than 10 pixels
        __IMGUI64_MenuSettings.height = Hgt% '                                                        set the menu height
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Draws the initial submenu images (internal library use only)               *
    '*                                                                            *
    '******************************************************************************
    Sub DrawSubMenu (MainEntry%)
        Dim lx% '                                                                      upper left  X corner of submenu
        Dim ly% '                                                                      upper left  Y corner of submenu
        Dim rx% '                                                                      lower right X corner of submenu
        Dim ry% '                                                                      lower right Y corner of submenu
        Dim menuRed% '                                                                     red component of submenu colors
        Dim menuGreen% '                                                                   green component of submenu colors
        Dim menuBlue% '                                                                    blue component of submenu colors
        Dim Light~& '                                                                  bright version of submenu color
        Dim Dark~& '                                                                   dark version of submenu color
        Dim Darker~& '                                                                 darker version of submenu color

        Shared __IMGUI64_MenuInfo() As __IMGUI64_MenuInfoType
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        lx% = 0 '                                                                      upper left X corner of submenu
        ly% = 0 '                                                                      upper left Y corner of submenu
        rx% = _Width(__IMGUI64_MenuInfo(MainEntry%, 0).submenu) - 1 '                                lower right X corner of submenu
        ry% = _Height(__IMGUI64_MenuInfo(MainEntry%, 0).submenu) - 1 '                               lower right Y corner of submenu
        _Dest __IMGUI64_MenuInfo(MainEntry%, 0).submenu '                                            set destination graphic as submenu mage
        Cls , __IMGUI64_MenuSettings.smabg '                                                             set submenu background color
        menuRed% = _Red(__IMGUI64_MenuSettings.smabg) '                                                      get red component of normal background color
        menuGreen% = _Green(__IMGUI64_MenuSettings.smabg) '                                                  get green component of normal background color
        menuBlue% = _Blue(__IMGUI64_MenuSettings.smabg) '                                                    get blue component of normal background color
        Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2) '                             calculate a dark version of the normal background color
        Darker~& = _RGB32(menuRed% \ 4, menuGreen% \ 4, menuBlue% \ 4) '                           calculate a darker version of the normal background color
        Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2) '                            calculate a lighter version of the normal background color
        If __IMGUI64_MenuSettings.smbar3D Then '                                                         should submenu be in 3D?
            Line (lx% + 1, ry% - 2)-(lx% + 1, ly% + 1), Light~& '                      yes, draw a raised box look around submenu
            Line -(rx% - 2, ly% + 1), Light~&
            Line (lx%, ry%)-(rx%, ry%), Darker~&
            Line -(rx%, ly%), Darker~&
            Line (lx% + 1, ry% - 1)-(rx% - 1, ry% - 1), Dark~&
            Line -(rx% - 1, ly% + 1), Dark~&
        Else
            Line (lx%, ly%)-(rx%, ry%), Dark~&, B '                                    no, draw a dark box around submenu
            Line (lx% + 1, ly% + 1)-(rx% - 1, ry% - 1), Dark~&, B
        End If
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Draws the three menu bars Mset.menubar, Mset.menubarhighlight and          *
    '* Mset.menubarselected (internal library use only)                           *
    '*                                                                            *
    '******************************************************************************
    Sub DrawMenuBars
        Dim lx% '                                                                      upper left  X corner of menu bars
        Dim ly% '                                                                      upper left  Y corner of menu bars
        Dim rx% '                                                                      lower right X corner of menu bars
        Dim ry% '                                                                      lower right Y corner of menu bars
        Dim menuRed% '                                                                     red component of menu bar colors
        Dim menuGreen% '                                                                   green component of menu bar colors
        Dim menuBlue% '                                                                    blue component of menu bar colors
        Dim Dark~& '                                                                   dark version of menu bar colors
        Dim Light~& '                                                                  bright version of of menu bar colors

        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        lx% = 0 '                                                                      upper left X corner of menu bar
        ly% = 0 '                                                                      upper left Y corner of menu bar
        rx% = _Width(__IMGUI64_MenuSettings.menubar) - 1 '                                               lower right X corner of menu bar
        ry% = _Height(__IMGUI64_MenuSettings.menubar) - 1 '                                              lower right Y corner of menu bar
        _Dest __IMGUI64_MenuSettings.menubar '                                                           set normal menu bar as destination graphic
        Cls , __IMGUI64_MenuSettings.mmabarbg '                                                          set normal menu bar background color
        If __IMGUI64_MenuSettings.mmbar3D Then '                                                         should menu bar be in 3D?
            menuRed% = _Red(__IMGUI64_MenuSettings.mmabarbg) '                                               yes, get the red component of normal menu bar background
            menuGreen% = _Green(__IMGUI64_MenuSettings.mmabarbg) '                                           get the green component of normal menu bar background
            menuBlue% = _Blue(__IMGUI64_MenuSettings.mmabarbg) '                                             get the blue component of normal menu bar background
            Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2) '                         calculate a dark version of normal menu bar background
            Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2) '                        calculate a bright verion of normal menu bar background
            Line (lx%, ry% - 1)-(lx%, ly%), Light~& '                                  draw a raised box look around normal menu bar
            Line -(rx% - 1, ly%), Light~&
            Line (lx%, ry%)-(rx%, ry%), Dark~&
            Line -(rx%, ly% + 1), Dark~&
        End If
        _Dest __IMGUI64_MenuSettings.menubarhighlight '                                                  set highlighted menu bar as destination graphic
        Cls , __IMGUI64_MenuSettings.mmabarbg
        Line (lx%, ly% + 2)-(rx%, ry% - 2), __IMGUI64_MenuSettings.mmhbarbg, BF
        If __IMGUI64_MenuSettings.mmbar3D Then
            menuRed% = _Red(__IMGUI64_MenuSettings.mmhbarbg)
            menuGreen% = _Green(__IMGUI64_MenuSettings.mmhbarbg)
            menuBlue% = _Blue(__IMGUI64_MenuSettings.mmhbarbg)
            Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2)
            Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2)
            Line (lx%, ry% - 1)-(lx%, ly%), Light~&
            Line -(rx% - 1, ly%), Light~&
            Line (lx%, ry%)-(rx%, ry%), Dark~&
            Line -(rx%, ly% + 1), Dark~&
        End If
        _Dest __IMGUI64_MenuSettings.menubarselected '                                                   set selected menu bar as destination graphic
        Cls , __IMGUI64_MenuSettings.mmabarbg
        Line (lx%, ly% + 2)-(rx%, ry% - 2), __IMGUI64_MenuSettings.mmsbarbg, BF
        If __IMGUI64_MenuSettings.mmbar3D Then
            menuRed% = _Red(__IMGUI64_MenuSettings.mmsbarbg)
            menuGreen% = _Green(__IMGUI64_MenuSettings.mmsbarbg)
            menuBlue% = _Blue(__IMGUI64_MenuSettings.mmsbarbg)
            Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2)
            Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2)
            Line (lx%, ry% - 1)-(lx%, ly%), Light~&
            Line -(rx% - 1, ly%), Light~&
            Line (lx%, ry%)-(rx%, ry%), Dark~&
            Line -(rx%, ly% + 1), Dark~&
        End If
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Draw the sub menu entries (internal library use only)                      *
    '*                                                                            *
    '******************************************************************************
    Sub DrawSubEntry (MainEntry%, SubEntry%)
        Dim lx% '                                                                      upper left X corner of submenu entry
        Dim ly% '                                                                      upper left Y corner of submenu entry
        Dim rx% '                                                                      lower right X corner of submenu entry
        Dim ry% '                                                                      lower right Y corner of submenu entry
        Dim menuRed% '                                                                     red component of submenu entry
        Dim menuGreen% '                                                                   green component of submenu entry
        Dim menuBlue% '                                                                    blue component of submenu entry
        Dim Light~& '                                                                  bright version of submenu color
        Dim Dark~& '                                                                   dark version of submenu color
        Dim sm3d%
        Dim smbar3d%

        Shared __IMGUI64_MenuInfo() As __IMGUI64_MenuInfoType
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        lx% = 0 '                                                                      upper left X location of submenu entry
        ly% = 0 '                                                                      upper left Y location of submenu entry
        rx% = _Width(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).active) - 1 '                         lower right X location of submenu entry
        ry% = _Height(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).active) - 1 '                        lower right Y location of submenu entry
        sm3d% = Abs(__IMGUI64_MenuSettings.sm3D)
        smbar3d% = Abs(__IMGUI64_MenuSettings.smbar3D)
        _Dest __IMGUI64_MenuInfo(MainEntry%, SubEntry%).active '                                     set the normal submenu entry as the destination
        Cls , __IMGUI64_MenuSettings.smabg '                                                             set the normal submenu entry background color
        Color __IMGUI64_MenuSettings.smatext '                                                           set the normal submenu entry text color
        _PrintString (lx% + __IMGUI64_MenuSettings.spacing, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak), RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).ljustify) ' print text to normal submenu entry
        If __IMGUI64_MenuInfo(MainEntry%, SubEntry%).hotkey Then '                                   print right justified hotkey combo if hotkey present
            _PrintString (rx% - _PrintWidth(RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).rjustify)) - __IMGUI64_MenuSettings.spacing, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak), RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).rjustify)
        End If
        If __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkey Then '                                   draw ALT key underscore if ALT key present
            Line (lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeyx, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak)-(lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeyx + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeywidth, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak), __IMGUI64_MenuSettings.smatext
        End If
        menuRed% = _Red(__IMGUI64_MenuSettings.smabg) '                                                      get red component of normal submenu entry background color
        menuGreen% = _Green(__IMGUI64_MenuSettings.smabg) '                                                  get green component of normal submenu entry background color
        menuBlue% = _Blue(__IMGUI64_MenuSettings.smabg) '                                                    get blue component of normal submenu entry background color
        Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2) '                             calculate dark version of normal background color
        Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2) '                            calculate bright version of normal background color
        If __IMGUI64_MenuSettings.sm3D Then '                                                            should submenu entry be in 3D?
            Line (lx%, ry% - 1)-(lx%, ly%), Light~& '                                  yes, draw raised box look around submenu entry
            Line -(rx% - 1, ly%), Light~&
            Line (lx%, ry%)-(rx%, ry%), Dark~&
            Line -(rx%, ly%), Dark~&
        ElseIf __IMGUI64_MenuInfo(MainEntry%, SubEntry%).drawline Then '                             no, should a line be drawn above this submenu entry?
            If __IMGUI64_MenuSettings.smbar3D Then '                                                     yes, is the submenu box in 3D?
                Line (lx% + 1, ly%)-(rx% - 1, ly%), Light~& '                          yes, draw line at the top of this entry
            Else
                Line (lx% + 1, ly%)-(rx% - 1, ly%), Dark~& '                           no, draw line at the top of this entry
            End If
            _Dest __IMGUI64_MenuInfo(MainEntry%, SubEntry% - 1).active '                             make the submenu entry above this one the destination
            Line (lx% + 1, ry%)-(rx% - 1, ry%), Dark~& '                               draw a line at the bottom of this entry
            '**************************************************************************
            '* Redraw the entry above since a line was drawn on it                    *
            '**************************************************************************
            _PutImage (__IMGUI64_MenuInfo(MainEntry%, SubEntry% - 1).x, __IMGUI64_MenuInfo(MainEntry%, SubEntry% - 1).y), __IMGUI64_MenuInfo(MainEntry%, SubEntry% - 1).active, __IMGUI64_MenuInfo(MainEntry%, 0).submenu
        End If
        '******************************************************************************
        '* draw the entry onto the normal submenu image                               *
        '******************************************************************************
        _PutImage (__IMGUI64_MenuInfo(MainEntry%, SubEntry%).x, __IMGUI64_MenuInfo(MainEntry%, SubEntry%).y), __IMGUI64_MenuInfo(MainEntry%, SubEntry%).active, __IMGUI64_MenuInfo(MainEntry%, 0).submenu
        '******************************************************************************
        '* the remainder of the code in this subroutine follows the same order as     *
        '* above except that the highlight, inactive and inactive highlight menu      *
        '* entries are not drawn onto the normal submenu image                        *
        '******************************************************************************
        _Dest __IMGUI64_MenuInfo(MainEntry%, SubEntry%).highlight
        Cls , __IMGUI64_MenuSettings.smabg
        Line (lx% + 1, ly% + 1)-(rx% - 1, ry% - 1), __IMGUI64_MenuSettings.smhbg, BF
        Color __IMGUI64_MenuSettings.smhtext
        _PrintString (lx% + __IMGUI64_MenuSettings.spacing + sm3d%, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak + sm3d%), RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).ljustify)
        If __IMGUI64_MenuInfo(MainEntry%, SubEntry%).hotkey Then
            _PrintString (rx% - _PrintWidth(RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).rjustify)) - __IMGUI64_MenuSettings.spacing + sm3d%, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak + sm3d%), RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).rjustify)
        End If
        If __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkey Then
            Line (lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeyx + sm3d%, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak + sm3d%)-(lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeyx + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeywidth + sm3d%, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak + sm3d%), __IMGUI64_MenuSettings.smhtext
        End If
        If __IMGUI64_MenuSettings.sm3D Then
            menuRed% = _Red(__IMGUI64_MenuSettings.smhbg)
            menuGreen% = _Green(__IMGUI64_MenuSettings.smhbg)
            menuBlue% = _Blue(__IMGUI64_MenuSettings.smhbg)
            Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2)
            Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2)
            Line (lx%, ry% - 1)-(lx%, ly%), Dark~&
            Line -(rx% - 1, ly%), Dark~&
            Line (lx%, ry%)-(rx%, ry%), Light~&
            Line -(rx%, ly%), Light~&
        ElseIf __IMGUI64_MenuInfo(MainEntry%, SubEntry%).drawline Then
            menuRed% = _Red(__IMGUI64_MenuSettings.smabg)
            menuGreen% = _Green(__IMGUI64_MenuSettings.smabg)
            menuBlue% = _Blue(__IMGUI64_MenuSettings.smabg)
            Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2)
            Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2)
            If __IMGUI64_MenuSettings.smbar3D Then
                Line (lx% + 1, ly%)-(rx% - 1, ly%), Light~&
            Else
                Line (lx% + 1, ly%)-(rx% - 1, ly%), Dark~&
            End If
            _Dest __IMGUI64_MenuInfo(MainEntry%, SubEntry% - 1).highlight
            Line (lx% + 1, ry%)-(rx% - 1, ry%), Dark~&
        End If
        _Dest __IMGUI64_MenuInfo(MainEntry%, SubEntry%).inactive
        Cls , __IMGUI64_MenuSettings.smabg
        Line (lx% + 1, ly% + 1)-(rx% - 1, ry% - 1), __IMGUI64_MenuSettings.smibg, BF
        menuRed% = _Red(__IMGUI64_MenuSettings.smibg)
        menuGreen% = _Green(__IMGUI64_MenuSettings.smibg)
        menuBlue% = _Blue(__IMGUI64_MenuSettings.smibg)
        Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2)
        Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2)
        If __IMGUI64_MenuSettings.smbar3D Then
            Color Light~&
            _PrintString (lx% + __IMGUI64_MenuSettings.spacing + 2, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak + 2), RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).ljustify)
        End If
        Color __IMGUI64_MenuSettings.smitext
        _PrintString (lx% + __IMGUI64_MenuSettings.spacing + smbar3d%, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak + smbar3d%), RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).ljustify)
        If __IMGUI64_MenuInfo(MainEntry%, SubEntry%).hotkey Then
            If __IMGUI64_MenuSettings.smbar3D Then
                Color Light~&
                _PrintString (rx% - _PrintWidth(RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).rjustify)) - __IMGUI64_MenuSettings.spacing + 2, __IMGUI64_MenuSettings.centered + 2 + __IMGUI64_MenuSettings.texttweak), RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).rjustify)
            End If
            Color __IMGUI64_MenuSettings.smitext
            _PrintString (rx% - _PrintWidth(RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).rjustify)) - __IMGUI64_MenuSettings.spacing + smbar3d%, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak + smbar3d%), RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).rjustify)
        End If
        If __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkey Then
            If __IMGUI64_MenuSettings.smbar3D Then Line (lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeyx + 2, __IMGUI64_MenuSettings.centered + _FontHeight + 2 + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak)-(lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeyx + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeywidth + 2, __IMGUI64_MenuSettings.centered + _FontHeight + 2 + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak), Light~&
            Line (lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeyx + smbar3d%, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak + smbar3d%)-(lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeyx + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeywidth + smbar3d%, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak + smbar3d%), __IMGUI64_MenuSettings.smitext
        End If
        If __IMGUI64_MenuSettings.sm3D Then
            Line (lx%, ry% - 1)-(lx%, ly%), Dark~&
            Line -(rx% - 1, ly%), Dark~&
            Line (lx%, ry%)-(rx%, ry%), Light~&
            Line -(rx%, ly%), Light~&
        ElseIf __IMGUI64_MenuInfo(MainEntry%, SubEntry%).drawline Then
            menuRed% = _Red(__IMGUI64_MenuSettings.smabg)
            menuGreen% = _Green(__IMGUI64_MenuSettings.smabg)
            menuBlue% = _Blue(__IMGUI64_MenuSettings.smabg)
            Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2)
            Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2)
            If __IMGUI64_MenuSettings.smbar3D Then
                Line (lx% + 1, ly%)-(rx% - 1, ly%), Light~&
            Else
                Line (lx% + 1, ly%)-(rx% - 1, ly%), Dark~&
            End If
            _Dest __IMGUI64_MenuInfo(MainEntry%, SubEntry% - 1).inactive
            Line (lx% + 1, ry%)-(rx% - 1, ry%), Dark~&
        End If
        _Dest __IMGUI64_MenuInfo(MainEntry%, SubEntry%).ihighlight
        Cls , __IMGUI64_MenuSettings.smabg
        Line (lx% + 1, ly% + 1)-(rx% - 1, ry% - 1), __IMGUI64_MenuSettings.smihbg, BF
        Color __IMGUI64_MenuSettings.smihtext
        _PrintString (lx% + __IMGUI64_MenuSettings.spacing + smbar3d%, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak + smbar3d%), RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).ljustify)
        If __IMGUI64_MenuInfo(MainEntry%, SubEntry%).hotkey Then
            _PrintString (rx% - _PrintWidth(RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).rjustify)) - __IMGUI64_MenuSettings.spacing + smbar3d%, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak + smbar3d%), RTrim$(__IMGUI64_MenuInfo(MainEntry%, SubEntry%).rjustify)
        End If
        If __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkey Then
            Line (lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeyx + smbar3d%, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak + smbar3d%)-(lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeyx + __IMGUI64_MenuInfo(MainEntry%, SubEntry%).altkeywidth + smbar3d%, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak + smbar3d%), __IMGUI64_MenuSettings.smihtext
        End If
        If __IMGUI64_MenuSettings.sm3D Then
            menuRed% = _Red(__IMGUI64_MenuSettings.smihbg)
            menuGreen% = _Green(__IMGUI64_MenuSettings.smihbg)
            menuBlue% = _Blue(__IMGUI64_MenuSettings.smihbg)
            Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2)
            Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2)
            Line (lx%, ry% - 1)-(lx%, ly%), Dark~&
            Line -(rx% - 1, ly%), Dark~&
            Line (lx%, ry%)-(rx%, ry%), Light~&
            Line -(rx%, ly%), Light~&
        ElseIf __IMGUI64_MenuInfo(MainEntry%, SubEntry%).drawline Then
            menuRed% = _Red(__IMGUI64_MenuSettings.smabg)
            menuGreen% = _Green(__IMGUI64_MenuSettings.smabg)
            menuBlue% = _Blue(__IMGUI64_MenuSettings.smabg)
            Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2)
            Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2)
            If __IMGUI64_MenuSettings.smbar3D Then
                Line (lx% + 1, ly%)-(rx% - 1, ly%), Light~&
            Else
                Line (lx% + 1, ly%)-(rx% - 1, ly%), Dark~&
            End If
            _Dest __IMGUI64_MenuInfo(MainEntry%, SubEntry% - 1).ihighlight
            Line (lx% + 1, ry%)-(rx% - 1, ry%), Dark~&
        End If
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Draw the main menu entries (internal library use only)                     *
    '*                                                                            *
    '******************************************************************************
    Sub DrawMainEntry (MainEntry%)
        Dim lx% '                                                                      upper left X corner of main menu entry
        Dim ly% '                                                                      upper left Y corner of main menu entry
        Dim rx% '                                                                      lower right X corner of main menu entry
        Dim ry% '                                                                      lower right Y corner of main menu entry
        Dim menuRed% '
        Dim menuGreen%
        Dim menuBlue%
        Dim Light~&
        Dim Dark~&
        Dim mm3d%

        Shared __IMGUI64_MenuInfo() As __IMGUI64_MenuInfoType
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        lx% = __IMGUI64_MenuInfo(MainEntry%, 0).x
        ly% = 0
        rx% = __IMGUI64_MenuInfo(MainEntry%, 0).x + __IMGUI64_MenuInfo(MainEntry%, 0).width - 1
        ry% = __IMGUI64_MenuSettings.height - 1
        mm3d% = Abs(__IMGUI64_MenuSettings.mm3D)
        _Dest __IMGUI64_MenuSettings.menubar
        Color __IMGUI64_MenuSettings.mmatext
        _PrintString (__IMGUI64_MenuInfo(MainEntry%, 0).x + __IMGUI64_MenuSettings.spacing, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak), RTrim$(__IMGUI64_MenuInfo(MainEntry%, 0).text)
        If __IMGUI64_MenuInfo(MainEntry%, 0).altkey Then
            Line (lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, 0).altkeyx, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak)-(lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, 0).altkeyx + __IMGUI64_MenuInfo(MainEntry%, 0).altkeywidth, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak), __IMGUI64_MenuSettings.mmatext
        End If
        _PutImage (0, 0), __IMGUI64_MenuSettings.menubar, __IMGUI64_MenuInfo(MainEntry%, 0).active, (lx%, ly%)-(rx%, ry%)
        _Dest __IMGUI64_MenuSettings.menubarhighlight
        Color __IMGUI64_MenuSettings.mmhtext
        _PrintString (__IMGUI64_MenuInfo(MainEntry%, 0).x + __IMGUI64_MenuSettings.spacing, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak), RTrim$(__IMGUI64_MenuInfo(MainEntry%, 0).text)
        If __IMGUI64_MenuInfo(MainEntry%, 0).altkey Then
            Line (lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, 0).altkeyx, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak)-(lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, 0).altkeyx + __IMGUI64_MenuInfo(MainEntry%, 0).altkeywidth, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak), __IMGUI64_MenuSettings.mmhtext
        End If
        If __IMGUI64_MenuSettings.mm3D Then
            menuRed% = _Red(__IMGUI64_MenuSettings.mmhbarbg)
            menuGreen% = _Green(__IMGUI64_MenuSettings.mmhbarbg)
            menuBlue% = _Blue(__IMGUI64_MenuSettings.mmhbarbg)
            Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2)
            Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2)
            Line (lx%, ry% - 2)-(lx%, ly% + 1), Light~&
            Line -(rx% - 1, ly% + 1), Light~&
            Line (lx%, ry% - 1)-(rx%, ry% - 1), Dark~&
            Line -(rx%, ly% + 1), Dark~&
        End If
        _PutImage (0, 0), __IMGUI64_MenuSettings.menubarhighlight, __IMGUI64_MenuInfo(MainEntry%, 0).highlight, (lx%, ly%)-(rx%, ry%)
        _Dest __IMGUI64_MenuSettings.menubarselected
        Color __IMGUI64_MenuSettings.mmstext
        _PrintString (__IMGUI64_MenuInfo(MainEntry%, 0).x + __IMGUI64_MenuSettings.spacing + mm3d%, __IMGUI64_MenuSettings.centered + __IMGUI64_MenuSettings.texttweak + mm3d%), RTrim$(__IMGUI64_MenuInfo(MainEntry%, 0).text)
        If __IMGUI64_MenuInfo(MainEntry%, 0).altkey Then
            Line (lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, 0).altkeyx + mm3d%, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak + mm3d%)-(lx% + __IMGUI64_MenuSettings.spacing + __IMGUI64_MenuInfo(MainEntry%, 0).altkeyx + __IMGUI64_MenuInfo(MainEntry%, 0).altkeywidth + mm3d%, __IMGUI64_MenuSettings.centered + _FontHeight + __IMGUI64_MenuSettings.alttweak + __IMGUI64_MenuSettings.texttweak + mm3d%), __IMGUI64_MenuSettings.mmstext
        End If
        If __IMGUI64_MenuSettings.mm3D Then
            menuRed% = _Red(__IMGUI64_MenuSettings.mmsbarbg)
            menuGreen% = _Green(__IMGUI64_MenuSettings.mmsbarbg)
            menuBlue% = _Blue(__IMGUI64_MenuSettings.mmsbarbg)
            Dark~& = _RGB32(menuRed% \ 2, menuGreen% \ 2, menuBlue% \ 2)
            Light~& = _RGB32(menuRed% * 2, menuGreen% * 2, menuBlue% * 2)
            Line (lx%, ry% - 2)-(lx%, ly% + 1), Dark~&
            Line -(rx% - 1, ly% + 1), Dark~&
            Line (lx%, ry% - 1)-(rx%, ry% - 1), Light~&
            Line -(rx%, ly% + 1), Light~&
        End If
        _PutImage (0, 0), __IMGUI64_MenuSettings.menubarselected, __IMGUI64_MenuInfo(MainEntry%, 0).selected, (lx%, ly%)-(rx%, ry%)
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Enables or disables a sub menu entry                                       *
    '*                                                                            *
    '* idnum%    - sub menu entry to enable or disable                            *
    '*                                                                            *
    '* behavior% -  0 (FALSE) disable the sub menu entry                          *
    '*             -1 (TRUE)  enable the sub menu entry                           *
    '*                                                                            *
    '* Example:    SETMENUSTATE 201, 0                                            *
    '*                                                                            *
    '******************************************************************************
    Sub SetMenuState (idnum%, behavior%)
        Shared __IMGUI64_MenuInfo() As __IMGUI64_MenuInfoType

        __IMGUI64_MenuInfo(idnum% \ 100, idnum% - ((idnum% \ 100) * 100)).live = behavior% '         set submenu entry to enabled/disabled
    End Sub


    '******************************************************************************
    '*                                                                            *
    '* Checks the menu for user mouse or keyboard interaction                     *
    '*                                                                            *
    '* Once the _KEYDOWN bug is corrected this function can be made so that       *
    '* the keyboard routines are only entered once an ALT key has been detected.  *
    '* Right now, the keyboard routine must be entered every time unless the      *
    '* programmer overrides it with KBDCheck%.                                    *
    '*                                                                            *
    '* Usage: EntrySelected% = CHECKMENU%(KeyboardCheck%)                         *
    '*                                                                            *
    '* KeyboardCheck% - used to enable or disable keyboard menu checking          *
    '*                  -1 (TRUE)  will check for keyboard/menu interaction       *
    '*                   0 (FALSE) will disable keyboard menu checking            *
    '*                                                                            *
    '* EntrySelected% - the menu entry selected in the form of mmss               *
    '*                  mm - (100 - 9900) the main menu entry is under            *
    '*                  ss - (1 - 99) the submenu entry selected                  *
    '*                                                                            *
    '* For example, if Exit is the 5th entry under the File menu, and the File    *
    '* menu is the first main menu entry, selecting Exit would return the value   *
    '* 105 (100 = first main menu entry, 05 = 5th submenu entry)                  *
    '*                                                                            *
    '******************************************************************************
    Function CheckMenu% (KBDCheck%) Static
        Dim menuMouseX '                                                                  current  mouse X position
        Dim menuMouseY '                                                                  current  mouse Y position
        Dim OldMousex% '                                                               previous mouse X position
        Dim OldMousey% '                                                               previous mouse Y position
        Dim Mbutton% '                                                                 status of left mouse button

        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        If __IMGUI64_MenuSettings.showing Then
            While _MouseInput: Wend '                                                  update mouse data
            menuMouseX = _MouseX '                                                        get current mouse X position
            menuMouseY = _MouseY '                                                        get current mouse Y position
            Mbutton% = _MouseButton(1) '                                               get status of left mouse button
            If (menuMouseX <> OldMousex%) Or (menuMouseY <> OldMousey%) Or Mbutton% Then '   has mouse moved or left button clicked?
                CheckMenu% = MenuMouseCheck%(menuMouseX, menuMouseY, Mbutton%) '             yes, report back what user did in menu
                OldMousex% = menuMouseX '                                                 save as previous mouse X position
                OldMousey% = menuMouseY '                                                 save as precious mouse Y position
                If Mbutton% Then '                                                     was left mouse button pressed?
                    Do: While _MouseInput: Wend: Loop Until _MouseButton(1) = 0 '      yes, wait until it's released
                End If
            Else '                                                                     there was no mouse activity
                If KBDCheck% Then '                                                    should keyboard activity be checked?
                    CheckMenu% = MenuKeyboardCheck% '                                  yes, return any keyboard activity
                End If
            End If
        End If
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Interprets keystrokes related to menu interaction (internal library use)   *
    '*                                                                            *
    '* Returns the sub menu ID number of an entry that had ENTER pressed on it or *
    '* if its hot-key combination was pressed. Returns 0 if no sub menu entry     *
    '* selected.                                                                  *
    '*                                                                            *
    '******************************************************************************
    Function MenuKeyboardCheck% Static
        Dim KeyPress& '              current key being pressed
        Dim OldKeyPress& '           previous key that was pressed (STATIC)
        Dim AltKeyDown% '            TRUE if ALT key in down position (STATIC)
        Dim OldAltKeyDown% '         TRUE if ALT key was previously in down position (STATIC)
        Dim KeysProcessed% '         TRUE is keys followed the ALT key (STATIC)
        Dim MenuScan% '              counter used to scan through menu entries
        Dim SubmenuScan% '           counter used to scan through sub menu entries
        Dim HotkeyCombo& '           keeps track of hot-key combos pressed (STATIC)
        Dim SubMenuSkip% '           used to skip submenus that have had all entries disabled

        Shared __IMGUI64_MenuInfo() As __IMGUI64_MenuInfoType
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        MenuKeyboardCheck% = 0
        KeyPress& = _KeyHit
        Do While KeyPress& <> 0
            Select Case KeyPress&
                Case 100307, 100308, -100307, -100308 '                                ** Right ALT key, Left ALT key, -Right ALT key, -Left ALT key
                    '***********************************
                    '* ALT key was pressed or released *
                    '***********************************
                    AltKeyDown% = -1 - AltKeyDown%
                    If (AltKeyDown% = 0) And (OldAltKeyDown% = -1) And (KeysProcessed% = 0) Then
                        '*************************************
                        '* ALT key was pressed then released *
                        '*************************************
                        __IMGUI64_MenuSettings.menuactive = -1 - __IMGUI64_MenuSettings.menuactive
                        If __IMGUI64_MenuSettings.menuactive Then
                            __IMGUI64_MenuSettings.mainmenu = 1
                            __IMGUI64_MenuSettings.oldmainmenu = 1
                            _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).highlight
                        Else
                            If __IMGUI64_MenuSettings.submenuactive Then _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu
                            If __IMGUI64_MenuSettings.mainmenu Then _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).active
                            __IMGUI64_MenuSettings.submenu = 0
                            __IMGUI64_MenuSettings.oldsubmenu = 0
                            __IMGUI64_MenuSettings.submenuactive = 0
                        End If
                    End If
                    OldAltKeyDown% = AltKeyDown%
                    KeysProcessed% = 0
                Case 19712, 19200 '                                                    ** Right Arrow Key, Left Arrow Key
                    '*********************************************
                    '* RIGHT ARROW or LEFT ARROW key was pressed *
                    '*********************************************
                    If __IMGUI64_MenuSettings.menuactive Then
                        If KeyPress& = 19712 Then '                                    ** Right Arrow Key
                            __IMGUI64_MenuSettings.mainmenu = __IMGUI64_MenuSettings.mainmenu + 1
                            If __IMGUI64_MenuSettings.mainmenu > UBound(__IMGUI64_MenuInfo) Then __IMGUI64_MenuSettings.mainmenu = 1
                        Else
                            __IMGUI64_MenuSettings.mainmenu = __IMGUI64_MenuSettings.mainmenu - 1
                            If __IMGUI64_MenuSettings.mainmenu < 1 Then __IMGUI64_MenuSettings.mainmenu = UBound(__IMGUI64_MenuInfo)
                        End If
                        If __IMGUI64_MenuSettings.submenuactive = 0 Then
                            '*****************************************************
                            '* no submenu - just move highlight on main menu bar *
                            '*****************************************************
                            If __IMGUI64_MenuSettings.oldmainmenu Then _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).active
                            If __IMGUI64_MenuSettings.mainmenu Then _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).highlight
                        Else
                            '************************************************************
                            '* submenu showing - move selected bar and show new submenu *
                            '************************************************************
                            If __IMGUI64_MenuSettings.oldmainmenu Then
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).undersubmenu
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).active
                            End If
                            If __IMGUI64_MenuSettings.mainmenu Then
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).selected
                                _PutImage (0, 0), _Dest, __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu, (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak)-(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1)
                                If __IMGUI64_MenuSettings.shadow Then Line (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuSettings.shadow, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuSettings.shadow)-(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1), _RGBA32(0, 0, 0, 63), BF
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).submenu
                                For SubmenuScan% = 1 To __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum - ((__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100)
                                    If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubmenuScan%).live = 0 Then
                                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubmenuScan%).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubmenuScan%).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubmenuScan%).inactive
                                    End If
                                Next SubmenuScan%
                            End If
                            __IMGUI64_MenuSettings.submenu = 0
                            __IMGUI64_MenuSettings.oldsubmenu = 0
                        End If
                        __IMGUI64_MenuSettings.oldmainmenu = __IMGUI64_MenuSettings.mainmenu
                        KeysProcessed% = -1
                    End If
                Case 20480, 18432, 13, 27 '                                            ** Down Arrow Key, Up Arrow Key, ENTER Key, ESCape Key
                    '******************************************************
                    '* DOWN ARROW, UP ARROW, ENTER or ESC key was pressed *
                    '******************************************************
                    If __IMGUI64_MenuSettings.menuactive Then
                        If (__IMGUI64_MenuSettings.submenuactive = 0) And (KeyPress& <> 27) Then '           ** ESCape Key
                            '*************************************
                            '* no submenu showing - show submenu *
                            '*************************************
                            If __IMGUI64_MenuSettings.mainmenu Then
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).selected
                                _PutImage (0, 0), _Dest, __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu, (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak)-(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1)
                                If __IMGUI64_MenuSettings.shadow Then Line (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuSettings.shadow, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuSettings.shadow)-(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1), _RGBA32(0, 0, 0, 63), BF
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).submenu
                                For SubmenuScan% = 1 To __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum - ((__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100)
                                    If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubmenuScan%).live = 0 Then
                                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubmenuScan%).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubmenuScan%).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubmenuScan%).inactive
                                    End If
                                Next SubmenuScan%
                            End If
                            __IMGUI64_MenuSettings.submenu = 0
                            __IMGUI64_MenuSettings.oldsubmenu = 0
                            __IMGUI64_MenuSettings.submenuactive = -1
                        Else
                            '*******************
                            '* submenu showing *
                            '*******************
                            If KeyPress& = 20480 Or KeyPress& = 18432 Then '           ** Down Arrow Key, Up Arrow Key
                                '*****************************************************
                                '* DOWN ARROW key pressed, move down submenu entries *
                                '*****************************************************
                                If KeyPress& = 20480 Then '                            ** Down Arrow Key
                                    SubMenuSkip% = __IMGUI64_MenuSettings.submenu
                                    Do
                                        __IMGUI64_MenuSettings.submenu = __IMGUI64_MenuSettings.submenu + 1
                                        If __IMGUI64_MenuSettings.submenu > __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum - ((__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100) Then __IMGUI64_MenuSettings.submenu = 1
                                    Loop Until (__IMGUI64_MenuSettings.submenu = SubMenuSkip%) Or __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).live
                                Else
                                    SubMenuSkip% = __IMGUI64_MenuSettings.submenu
                                    Do
                                        __IMGUI64_MenuSettings.submenu = __IMGUI64_MenuSettings.submenu - 1
                                        If __IMGUI64_MenuSettings.submenu < 1 Then __IMGUI64_MenuSettings.submenu = __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum - ((__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100)
                                    Loop Until (__IMGUI64_MenuSettings.submenu = SubMenuSkip%) Or __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).live
                                End If
                                If __IMGUI64_MenuSettings.oldsubmenu Then
                                    If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).live Then
                                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).active
                                    Else
                                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).inactive
                                    End If
                                End If
                                If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).live Then
                                    _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).highlight
                                Else
                                    _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).inactive
                                End If
                                __IMGUI64_MenuSettings.oldsubmenu = __IMGUI64_MenuSettings.submenu
                            Else
                                '**********************************************************************
                                '* ENTER or ESC key pressed - return ID number of submenu or 0 if ESC *
                                '**********************************************************************
                                If __IMGUI64_MenuSettings.submenu > 0 Then
                                    If KeyPress& = 13 Then '                           ** ENTER Key
                                        MenuKeyboardCheck% = (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100 + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).idnum
                                    Else
                                        MenuKeyboardCheck% = 0
                                    End If
                                End If
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).active
                                __IMGUI64_MenuSettings.submenu = 0
                                __IMGUI64_MenuSettings.oldsubmenu = 0
                                __IMGUI64_MenuSettings.mainmenu = 0
                                __IMGUI64_MenuSettings.oldmainmenu = 0
                                __IMGUI64_MenuSettings.submenuactive = 0
                                __IMGUI64_MenuSettings.menuactive = 0
                                Exit Function
                            End If
                        End If
                        KeysProcessed% = -1
                    End If
                Case Else
                    '**********************************
                    '* find out which key was pressed *
                    '**********************************
                    If Abs(KeyPress&) >= 97 And Abs(KeyPress&) <= 122 Then KeyPress& = KeyPress& - Sgn(KeyPress&) * 32 ' uppercase all alpha keys
                    If AltKeyDown% And (__IMGUI64_MenuSettings.submenuactive = 0) Then
                        '******************************************************
                        '* scan through list of altkeycharacters in main menu *
                        '******************************************************
                        For MenuScan% = 1 To UBound(__IMGUI64_MenuInfo)
                            If KeyPress& = __IMGUI64_MenuInfo(MenuScan%, 0).altkeycharacter Then
                                __IMGUI64_MenuSettings.mainmenu = MenuScan%
                                __IMGUI64_MenuSettings.menuactive = -1
                                '****************************************
                                '* show submenu that has been activated *
                                '****************************************
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).selected
                                _PutImage (0, 0), _Dest, __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu, (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak)-(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1)
                                If __IMGUI64_MenuSettings.shadow Then Line (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuSettings.shadow, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuSettings.shadow)-(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1), _RGBA32(0, 0, 0, 63), BF
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).submenu
                                __IMGUI64_MenuSettings.oldmainmenu = __IMGUI64_MenuSettings.mainmenu
                                __IMGUI64_MenuSettings.submenu = 0
                                __IMGUI64_MenuSettings.oldsubmenu = 0
                                __IMGUI64_MenuSettings.submenuactive = -1
                                Exit For
                            End If
                        Next MenuScan%
                    ElseIf __IMGUI64_MenuSettings.submenuactive Then
                        '*******************************************************
                        '* scan through list of alt key characters in sub menu *
                        '*******************************************************
                        For MenuScan% = 1 To __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum - ((__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100)
                            If KeyPress& = __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, MenuScan%).altkeycharacter Then
                                MenuKeyboardCheck% = (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100 + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, MenuScan%).idnum
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).active
                                __IMGUI64_MenuSettings.submenu = 0
                                __IMGUI64_MenuSettings.oldsubmenu = 0
                                __IMGUI64_MenuSettings.mainmenu = 0
                                __IMGUI64_MenuSettings.oldmainmenu = 0
                                __IMGUI64_MenuSettings.submenuactive = 0
                                __IMGUI64_MenuSettings.menuactive = 0
                                Exit Function
                            End If
                        Next MenuScan%
                    Else
                        '******************************************************
                        '* make both CTRL and SHIFT keys equal the same value *
                        '******************************************************
                        If KeyPress& <> OldKeyPress& Then
                            If (Abs(KeyPress&) = 100306) Or (Abs(KeyPress&) = 100304) Then KeyPress& = KeyPress& - Sgn(KeyPress&) ' ** Left CTRL Key, Left SHIFT Key
                            HotkeyCombo& = HotkeyCombo& + KeyPress&
                        End If
                        OldKeyPress& = KeyPress&
                        If HotkeyCombo& < 0 Then HotkeyCombo& = 0 ' discard released key values
                        '*********************************************
                        '* scan list of hotkeys through all submenus *
                        '*********************************************
                        If HotkeyCombo& > 0 Then
                            For MenuScan% = 1 To UBound(__IMGUI64_MenuInfo)
                                For SubmenuScan% = 1 To __IMGUI64_MenuInfo(MenuScan%, 0).idnum - ((__IMGUI64_MenuInfo(MenuScan%, 0).idnum \ 100) * 100)
                                    If HotkeyCombo& = __IMGUI64_MenuInfo(MenuScan%, SubmenuScan%).hotkey Then
                                        MenuKeyboardCheck% = (__IMGUI64_MenuInfo(MenuScan%, 0).idnum \ 100) * 100 + __IMGUI64_MenuInfo(MenuScan%, SubmenuScan%).idnum
                                        Exit Function
                                    End If
                                Next SubmenuScan%
                            Next MenuScan%
                        End If
                    End If
                    KeysProcessed% = -1
            End Select
            KeyPress& = _KeyHit
        Loop
    End Function


    '******************************************************************************
    '*                                                                            *
    '* Interprets mouse actions related to menu interaction (internal library use)*
    '*                                                                            *
    '* Returns the sub menu ID number of an entry that had the left mouse button  *
    '* clicked on it or if its hot-key combination was pressed. Returns 0 if no   *
    '* sub menu entry was selected.                                               *
    '*                                                                            *
    '******************************************************************************
    Function MenuMouseCheck% (Mx%, My%, Mb%)
        Dim MainMenuScan% '        counter used to scan main menu entries
        Dim SubMenuScan% '         counter used to scan submenu entries

        Shared __IMGUI64_MenuInfo() As __IMGUI64_MenuInfoType
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        MenuMouseCheck% = 0
        If (Mx% > __IMGUI64_MenuSettings.indent) And (Mx% < __IMGUI64_MenuSettings.width + __IMGUI64_MenuSettings.indent) And (My% > 2) And (My% < __IMGUI64_MenuSettings.height - 2) Then
            __IMGUI64_MenuSettings.menuactive = -1
            __IMGUI64_MenuSettings.mainmenu = 0
            For MainMenuScan% = 1 To UBound(__IMGUI64_MenuInfo)
                If (Mx% >= __IMGUI64_MenuInfo(MainMenuScan%, 0).x) And (Mx% <= __IMGUI64_MenuInfo(MainMenuScan%, 0).x + __IMGUI64_MenuInfo(MainMenuScan%, 0).width - 1) Then __IMGUI64_MenuSettings.mainmenu = MainMenuScan%
            Next MainMenuScan%
            If __IMGUI64_MenuSettings.mainmenu <> __IMGUI64_MenuSettings.oldmainmenu Then '                                         ** mouse has changed menu position
                If __IMGUI64_MenuSettings.submenuactive Then '                                                ** submenu is showing
                    '*********************************************
                    '* turn off old submenu and show new submenu *
                    '*********************************************
                    If __IMGUI64_MenuSettings.oldmainmenu Then
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).undersubmenu
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).active
                    End If
                    If __IMGUI64_MenuSettings.mainmenu Then
                        _PutImage (0, 0), _Dest, __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu, (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak)-(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1)
                        If __IMGUI64_MenuSettings.shadow Then Line (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuSettings.shadow, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuSettings.shadow)-(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1), _RGBA32(0, 0, 0, 63), BF
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).selected
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).submenu
                        For SubMenuScan% = 1 To __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum - ((__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100)
                            If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubMenuScan%).live = 0 Then
                                _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubMenuScan%).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubMenuScan%).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubMenuScan%).inactive
                            End If
                        Next SubMenuScan%
                    End If
                    __IMGUI64_MenuSettings.submenu = 0
                    __IMGUI64_MenuSettings.oldsubmenu = 0
                Else '                                                                 ** submenu is not showing
                    '*************************************
                    '* switch to new main menu highlight *
                    '*************************************
                    If __IMGUI64_MenuSettings.oldmainmenu Then _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).active
                    If __IMGUI64_MenuSettings.mainmenu Then _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).highlight
                End If
                __IMGUI64_MenuSettings.oldmainmenu = __IMGUI64_MenuSettings.mainmenu
            ElseIf Mb% Then
                '**************************************************
                '* clicked on main menu entry to bring up submenu *
                '**************************************************
                __IMGUI64_MenuSettings.submenuactive = -1 - __IMGUI64_MenuSettings.submenuactive
                If __IMGUI64_MenuSettings.submenuactive Then
                    _PutImage (0, 0), _Dest, __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu, (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak)-(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1)
                    If __IMGUI64_MenuSettings.shadow Then Line (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuSettings.shadow, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuSettings.shadow)-(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).undersubmenu) - 1), _RGBA32(0, 0, 0, 63), BF
                    _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).selected
                    _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).submenu
                    For SubMenuScan% = 1 To __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum - ((__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100)
                        If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubMenuScan%).live = 0 Then
                            _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubMenuScan%).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubMenuScan%).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubMenuScan%).inactive
                        End If
                    Next SubMenuScan%
                Else
                    _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).undersubmenu
                    _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).highlight
                End If
            ElseIf __IMGUI64_MenuSettings.submenuactive Then
                '**************************************
                '* turn off highlighted submenu entry *
                '**************************************
                If __IMGUI64_MenuSettings.oldsubmenu Then
                    If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).live Then
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).active
                    Else
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).inactive
                    End If
                End If
                __IMGUI64_MenuSettings.submenu = 0
                __IMGUI64_MenuSettings.oldsubmenu = 0
            End If
        ElseIf __IMGUI64_MenuSettings.submenuactive And (Mx% >= __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x) And (Mx% <= __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).submenu) - 1) And (My% >= __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak) And (My% <= __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + _Height(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).submenu) - 1) Then
            '**********************************************************
            '* there is a dropdown submenu showing and mouse is on it *
            '**********************************************************
            For SubMenuScan% = 1 To __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum - ((__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100)
                If (Mx% >= __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x) And (Mx% <= __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + _Width(__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).submenu) - 1) And (My% >= __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubMenuScan%).y) And (My% <= __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, SubMenuScan%).y + __IMGUI64_MenuSettings.height - 1) Then
                    __IMGUI64_MenuSettings.submenu = SubMenuScan%
                    Exit For
                End If
            Next SubMenuScan%
            If __IMGUI64_MenuSettings.submenu <> __IMGUI64_MenuSettings.oldsubmenu Then
                '*******************************************************
                '* mouse has changed from one submenu entry to another *
                '*******************************************************
                If __IMGUI64_MenuSettings.oldsubmenu Then
                    If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).live Then
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).active
                    Else
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.oldsubmenu).inactive
                    End If
                End If
                If __IMGUI64_MenuSettings.submenu Then
                    If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).live Then
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).highlight
                    Else
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).ihighlight
                    End If
                End If
                __IMGUI64_MenuSettings.oldsubmenu = __IMGUI64_MenuSettings.submenu
            ElseIf Mb% Then
                '**************************************************
                '* mouse has been clicked - return menu ID number *
                '**************************************************
                If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.submenu).live Then
                    _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).undersubmenu
                    _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).active
                    MenuMouseCheck% = (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, 0).idnum \ 100) * 100 + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.mainmenu, __IMGUI64_MenuSettings.submenu).idnum
                    __IMGUI64_MenuSettings.mainmenu = 0
                    __IMGUI64_MenuSettings.oldmainmenu = 0
                    __IMGUI64_MenuSettings.submenu = 0
                    __IMGUI64_MenuSettings.oldsubmenu = 0
                    __IMGUI64_MenuSettings.menuactive = 0
                    __IMGUI64_MenuSettings.submenuactive = 0
                    Exit Function
                End If
            End If
        Else '                                                                         ** mouse not on submenu
            '**************************************
            '* turn off highlighted submenu entry *
            '**************************************
            If __IMGUI64_MenuSettings.submenuactive Then
                If __IMGUI64_MenuSettings.oldsubmenu Then
                    If __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).live Then
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).active
                    Else
                        _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak + __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).y), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, __IMGUI64_MenuSettings.oldsubmenu).inactive
                    End If
                End If
                __IMGUI64_MenuSettings.submenu = 0
                __IMGUI64_MenuSettings.oldsubmenu = 0
            Else
                If __IMGUI64_MenuSettings.oldmainmenu Then
                    _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).active
                    __IMGUI64_MenuSettings.mainmenu = 0
                    __IMGUI64_MenuSettings.oldmainmenu = 0
                    __IMGUI64_MenuSettings.menuactive = 0
                End If
            End If
            '*****************************************
            '* button clicked off entire menu system *
            '*****************************************
            If Mb% Then
                If __IMGUI64_MenuSettings.submenuactive Then _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, __IMGUI64_MenuSettings.height + __IMGUI64_MenuSettings.subtweak), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).undersubmenu
                If __IMGUI64_MenuSettings.oldmainmenu Then _PutImage (__IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).x, 0), __IMGUI64_MenuInfo(__IMGUI64_MenuSettings.oldmainmenu, 0).active
                __IMGUI64_MenuSettings.mainmenu = 0
                __IMGUI64_MenuSettings.oldmainmenu = 0
                __IMGUI64_MenuSettings.submenu = 0
                __IMGUI64_MenuSettings.oldsubmenu = 0
                __IMGUI64_MenuSettings.menuactive = 0
                __IMGUI64_MenuSettings.submenuactive = 0
            End If
        End If
    End Function


    '******************************************************************************
    '* Creates the menu graphics for the menu system.
    '*
    '* Structure of menu entries:
    '*
    '* Menu entries must be put into DATA statements. For example:
    '*
    '* DATA "&File","&New#Ctrl+N","&Open#Ctrl+O","-&Save#Ctrl+S"
    '* DATA "Save &as...#Ctrl+Shift+S","-E&xit#Ctrl+Q","*","!"
    '*
    '* Would create a new main menu entry called "File" and a submenu containing
    '* "New", "Open", Save", "Save as..." and "Exit" appearing like so:
    '*
    '* +----+
    '* |File|                        ID = 105 (1xx = first menu entry  )
    '* |~   |                                 (x05 = 5 sub menu entries)
    '* +----+--------------------+
    '* | New              Ctrl+N |   ID = 1 (returned as 101)
    '* | ~                       |
    '* | Open             Ctrl+O |   ID = 2 (returned as 102)
    '* | ~                       |                .
    '* | ------------------------|                .
    '* | Save             Ctrl+S |   ID = 3       .
    '* | ~                       |                .
    '* | Save as... Ctrl+Shift+S |   ID = 4       .
    '* |      ~                  |                .
    '* | ------------------------|                .
    '* | Exit             Ctrl+Q |   ID = 5 (returned as 105)
    '* |  ~                      |
    '* +-------------------------+
    '*
    '* Symbols used:
    '*
    '* "-" - placing a dash at beginning places a line above this entry
    '* "#" - text will be right justified
    '* "&" - the following letter is the ALT key combination (underline)
    '* "*" - denotes end of submenu entries   (must be alone)
    '* "!" - denotes end of main menu entries (must be alone)
    '*
    '* Hotkey combinations following the "#" symbol will automatically be
    '* deciphered, but the only key seperators allowed are the "+" plus symbol
    '* and " " space. The following are valid:
    '*
    '* #Ctrl+X   #CTRLX   #Ctrl X   #ctrlx   #ctrl+x   #CTRL+ X   etc..
    '*
    '* The following names (upper, lower or any combination of case) can be used
    '* for special keys:
    '*
    '* F1, F2 ... F12, CTRL, SHIFT, DEL, DELETE, INS, INSERT, HOME, END
    '* PGUP, PAGEUP, PAGE UP, PGDN, PAGEDOWN, PAGE DOWN, UP, UPARROW, UP ARROW
    '* DOWN, DOWNARROW, DOWN ARROW, RIGHT, RIGHTARROW, RIGHT ARROW, LEFT
    '* LEFTARROW, LEFT ARROW, SCROLL, SLOCK, SCROLLLOCK, SCROLL LOCK, CAPS
    '* CLOCK, CAPSLOCK, CAPS LOCK, NLOCK, NUMLOCK, NUM LOCK
    '*
    '******************************************************************************
    Sub MakeMenu
        Dim x%
        Dim MainMenu%
        Dim SubMenu%
        Dim MaxSubMenu%
        Dim Length1%
        Dim Length2%
        Dim MaxLength1%
        Dim MaxLength2%
        Dim ReadData$
        Dim Plus%
        Dim Space%
        Dim AltKey%
        Dim RightAltKey
        Dim Rjustify$
        Dim ScreenWidth%
        Dim FontHold&
        Dim DestHold&

        ReDim MaxLength%(0)
        ReDim TotalSubmenu%(0)
        Shared __IMGUI64_MenuInfo() As __IMGUI64_MenuInfoType
        Shared __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType

        '******************************************************************************
        '* Set default values if not set by programmer. These defaults will set up a  *
        '* generic menu with the standard Windows look and feel to it.                *
        '******************************************************************************

        SetMainMenuColors _RGB32(0, 0, 0), _RGB32(0, 0, 0), _RGB32(0, 0, 0), _RGB32(212, 208, 200), _RGB32(212, 208, 200), _RGB32(212, 208, 200)

        If __IMGUI64_MenuSettings.sm3D Then
            SetSubmenuColors _RGB32(0, 0, 0), _RGB32(0, 0, 0), _RGB32(128, 128, 128), _RGB32(128, 128, 128), _RGB32(212, 208, 200), _RGB32(212, 208, 200), _RGB32(212, 208, 200), _RGB32(212, 208, 200)
        Else
            SetSubmenuColors _RGB32(0, 0, 0), _RGB32(255, 255, 255), _RGB32(128, 128, 128), _RGB32(128, 128, 128), _RGB32(212, 208, 200), _RGB32(10, 36, 106), _RGB32(212, 208, 200), _RGB32(10, 36, 106)
        End If

        SetMenu3D 0, -1, -1, 0
        SetMenuHeight _FontHeight + 8
        SetMenuSpacing 10
        SetMenuIndent 0
        SetMenuText 1
        SetMenuUnderscore -1
        SetSubMenuLocation 0
        SetMenuShadow 5

        ScreenWidth% = _Width(_Dest) '                                                 get the width of the current screen
        DestHold& = _Dest '                                                            remember the calling destination
        FontHold& = _Font(_Dest) '                                                     remember the font used when entering this routine

        '******************************************************************************
        '* Scan the menu DATA to get menu and submenu sizing to create menu array     *
        '******************************************************************************
        MainMenu% = 0 '                                                                reset main menu entry counter
        MaxSubMenu% = 0 '                                                              reset maximum submenus seen
        Read ReadData$ '                                                               first entry must be main menu entry
        Do While ReadData$ <> "!" '                                                    stop looping when encountered
            MainMenu% = MainMenu% + 1 '                                                increment main menu entry counter
            Read ReadData$ '                                                           second entry must be sub menu entry
            SubMenu% = 0 '                                                             reset sub menu entry counter
            MaxLength1% = 0 '                                                          reset max length of left text seen
            MaxLength2% = 0 '                                                          reset max length right justified text seen
            Do While ReadData$ <> "*" '                                                stop looping when encountered
                SubMenu% = SubMenu% + 1 '                                              increment sub menu entry counter
                Length1% = 0 '                                                         reset length of left text seen
                Length2% = 0 '                                                         reset length of right justified text seen
                '**********************************************************************
                '* strip away all special formatting characters to reveal text only   *
                '**********************************************************************
                If InStr(ReadData$, "-") Then ReadData$ = Right$(ReadData$, Len(ReadData$) - 1)
                If InStr(ReadData$, "&") Then ReadData$ = Left$(ReadData$, InStr(ReadData$, "&") - 1) + Right$(ReadData$, Len(ReadData$) - InStr(ReadData$, "&"))
                If InStr(ReadData$, "#") Then
                    '******************************************************************
                    '* get the length of left and right justified text and spacing    *
                    '******************************************************************
                    Length1% = _PrintWidth(Left$(ReadData$, InStr(ReadData$, "#") - 1)) + __IMGUI64_MenuSettings.spacing * 2
                    Length2% = _PrintWidth(Right$(ReadData$, Len(ReadData$) - InStr(ReadData$, "#"))) + __IMGUI64_MenuSettings.spacing
                Else
                    Length1% = _PrintWidth(ReadData$) + __IMGUI64_MenuSettings.spacing * 2
                End If
                If Length1% > MaxLength1% Then MaxLength1% = Length1% '                remember the maximum left text seen
                If Length2% > MaxLength2% Then MaxLength2% = Length2% '                remember the maximum right justified text seen
                Read ReadData$ '                                                       read next sub menu entry
            Loop
            If SubMenu% > MaxSubMenu% Then MaxSubMenu% = SubMenu% '                    save the largest number of sub menu entries seen
            ReDim _Preserve MaxLength%(MainMenu%) '                                    increase submenu max length array
            MaxLength%(MainMenu%) = MaxLength1% + MaxLength2% '                        save maximum submenu entry length for this submenu
            ReDim _Preserve TotalSubmenu%(MainMenu%) '                                 increase submenu entry counter
            TotalSubmenu%(MainMenu%) = SubMenu% '                                      save nnumber of submenu entries seen for this submenu
            Read ReadData$ '                                                           read next main menu entry
        Loop
        ReDim __IMGUI64_MenuInfo(MainMenu%, MaxSubMenu%) As __IMGUI64_MenuInfoType '                                   resize the menu entry array accordingly
        Restore '                                                                      restore the DATA to be read in again
        x% = __IMGUI64_MenuSettings.indent
        MainMenu% = 0 '                                                                reset main menu entry counter
        SubMenu% = 0 '                                                                 reset submenu entry counter
        __IMGUI64_MenuSettings.centered = (__IMGUI64_MenuSettings.height - _FontHeight) \ 2 - 1 '               centered location of text on main/submenu entries
        Read ReadData$ '                                                               first entry must be main menu entry
        Do While ReadData$ <> "!" '                                                    stop looping when encountered
            MainMenu% = MainMenu% + 1 '                                                increment main menu entry counter
            AltKey% = InStr(ReadData$, "&")
            If AltKey% Then
                __IMGUI64_MenuInfo(MainMenu%, 0).altkey = RightAltKey + Asc(UCase$(ReadData$), AltKey% + 1)
                __IMGUI64_MenuInfo(MainMenu%, 0).altkeycharacter = Asc(UCase$(ReadData$), AltKey% + 1)
                ReadData$ = Left$(ReadData$, AltKey% - 1) + Right$(ReadData$, Len(ReadData$) - AltKey%)
                __IMGUI64_MenuInfo(MainMenu%, 0).altkeyx = _PrintWidth(Left$(ReadData$, AltKey% - 1))
                __IMGUI64_MenuInfo(MainMenu%, 0).altkeywidth = _PrintWidth(Mid$(ReadData$, AltKey%, 1)) - 2
            End If
            __IMGUI64_MenuInfo(MainMenu%, 0).text = ReadData$ '                                      yes, save the main menu entry
            __IMGUI64_MenuInfo(MainMenu%, 0).idnum = MainMenu% * 100 '                               save the main menu entry id number (hundreds place)
            __IMGUI64_MenuInfo(MainMenu%, 0).width = _PrintWidth(ReadData$) + __IMGUI64_MenuSettings.spacing * 2 '                             width of main menu entry
            __IMGUI64_MenuSettings.width = __IMGUI64_MenuSettings.width + __IMGUI64_MenuInfo(MainMenu%, 0).width '                                           main menu total width
            __IMGUI64_MenuInfo(MainMenu%, 0).x = x% '                                                                    left location of main entry box
            __IMGUI64_MenuInfo(MainMenu%, 0).active = _NewImage(__IMGUI64_MenuInfo(MainMenu%, 0).width, __IMGUI64_MenuSettings.height, 32) '             active main menu entry image (normal)
            _Dest __IMGUI64_MenuInfo(MainMenu%, 0).active

            _PrintMode _KeepBackground
            __IMGUI64_MenuInfo(MainMenu%, 0).highlight = _NewImage(__IMGUI64_MenuInfo(MainMenu%, 0).width, __IMGUI64_MenuSettings.height, 32) '          highlighted main menu entry image (mouse over)
            _Dest __IMGUI64_MenuInfo(MainMenu%, 0).highlight

            _PrintMode _KeepBackground
            __IMGUI64_MenuInfo(MainMenu%, 0).selected = _NewImage(__IMGUI64_MenuInfo(MainMenu%, 0).width, __IMGUI64_MenuSettings.height, 32) '           selected main menu entry image (left clicked)
            _Dest __IMGUI64_MenuInfo(MainMenu%, 0).selected

            _PrintMode _KeepBackground
            __IMGUI64_MenuInfo(MainMenu%, 0).submenu = _NewImage(MaxLength%(MainMenu%) + 4, (TotalSubmenu%(MainMenu%)) * __IMGUI64_MenuSettings.height + 4, 32)
            _Dest __IMGUI64_MenuInfo(MainMenu%, 0).submenu

            _PrintMode _KeepBackground
            __IMGUI64_MenuInfo(MainMenu%, 0).undersubmenu = _NewImage(MaxLength%(MainMenu%) + 4 + __IMGUI64_MenuSettings.shadow, (TotalSubmenu%(MainMenu%)) * __IMGUI64_MenuSettings.height + 4 + __IMGUI64_MenuSettings.shadow, 32)
            _Dest __IMGUI64_MenuInfo(MainMenu%, 0).undersubmenu

            _PrintMode _KeepBackground
            SubMenu% = 0 '                                                                                 reset sub menu entry counter
            Read ReadData$ '                                                                               second entry must be sub menu entry
            Do While ReadData$ <> "*" '                                                                    stop looping when encountered
                SubMenu% = SubMenu% + 1 '                                                                  increment sub menu entry counter
                __IMGUI64_MenuInfo(MainMenu%, SubMenu%).text = ReadData$ '                                               yes, save the sub menu entry
                __IMGUI64_MenuInfo(MainMenu%, SubMenu%).idnum = SubMenu% '                                               save the sub menu entry id number (1-99)
                __IMGUI64_MenuInfo(MainMenu%, SubMenu%).width = MaxLength%(MainMenu%) '                                  width of submenu entry
                __IMGUI64_MenuInfo(MainMenu%, SubMenu%).x = 2 '                                                          x location of submenu entry
                __IMGUI64_MenuInfo(MainMenu%, SubMenu%).y = ((SubMenu% - 1) * __IMGUI64_MenuSettings.height) + 2 '                         y location of submenu entry
                __IMGUI64_MenuInfo(MainMenu%, SubMenu%).active = _NewImage(MaxLength%(MainMenu%), __IMGUI64_MenuSettings.height, 32) '     active (normal) submenu entry image
                _Dest __IMGUI64_MenuInfo(MainMenu%, SubMenu%).active

                _PrintMode _KeepBackground
                __IMGUI64_MenuInfo(MainMenu%, SubMenu%).highlight = _NewImage(MaxLength%(MainMenu%), __IMGUI64_MenuSettings.height, 32) '  highlighted submenu entry image
                _Dest __IMGUI64_MenuInfo(MainMenu%, SubMenu%).highlight

                _PrintMode _KeepBackground
                __IMGUI64_MenuInfo(MainMenu%, SubMenu%).inactive = _NewImage(MaxLength%(MainMenu%), __IMGUI64_MenuSettings.height, 32) '   inactive (disabled) submenu entry image
                _Dest __IMGUI64_MenuInfo(MainMenu%, SubMenu%).inactive

                _PrintMode _KeepBackground
                __IMGUI64_MenuInfo(MainMenu%, SubMenu%).ihighlight = _NewImage(MaxLength%(MainMenu%), __IMGUI64_MenuSettings.height, 32) ' inactive (disabled) highlighted submenu entry image
                _Dest __IMGUI64_MenuInfo(MainMenu%, SubMenu%).ihighlight

                _PrintMode _KeepBackground
                __IMGUI64_MenuInfo(MainMenu%, SubMenu%).live = -1 '                                                      submenu entry enabled by default
                If InStr(ReadData$, "-") Then '                                                            should this entry have a line above?
                    If SubMenu% > 1 Then __IMGUI64_MenuInfo(MainMenu%, SubMenu%).drawline = -1 '                        yes, remember this
                    ReadData$ = Right$(ReadData$, Len(ReadData$) - 1) '                                        remove the dash
                End If
                AltKey% = InStr(ReadData$, "&") '                                                             find an alt key marker
                If AltKey% Then '                                                                             found?
                    __IMGUI64_MenuInfo(MainMenu%, SubMenu%).altkey = RightAltKey + Asc(UCase$(ReadData$), AltKey% + 1) '    yes, save the alt key combo value
                    __IMGUI64_MenuInfo(MainMenu%, SubMenu%).altkeycharacter = Asc(UCase$(ReadData$), AltKey% + 1) '         save the actual alt key
                    ReadData$ = Left$(ReadData$, AltKey% - 1) + Right$(ReadData$, Len(ReadData$) - AltKey%) ' remove the alt key marker
                    __IMGUI64_MenuInfo(MainMenu%, SubMenu%).altkeyx = _PrintWidth(Left$(ReadData$, AltKey% - 1)) '          remember position of alt underline
                    __IMGUI64_MenuInfo(MainMenu%, SubMenu%).altkeywidth = _PrintWidth(Mid$(ReadData$, AltKey%, 1)) - 2 '    remember how wide the underline is
                End If
                If InStr(ReadData$, "#") Then '                                                                      is there a hot key marker?
                    __IMGUI64_MenuInfo(MainMenu%, SubMenu%).ljustify = Left$(ReadData$, InStr(ReadData$, "#") - 1) '               yes, get left submenu text
                    __IMGUI64_MenuInfo(MainMenu%, SubMenu%).rjustify = Right$(ReadData$, Len(ReadData$) - InStr(ReadData$, "#")) ' get hotkey right justified text
                    '******************************************
                    '* Attempt to discover hotkey combination *
                    '******************************************
                    Rjustify$ = UCase$(RTrim$(__IMGUI64_MenuInfo(MainMenu%, SubMenu%).rjustify))
                    While InStr(Rjustify$, "+") Or InStr(Rjustify$, " ")
                        Plus% = InStr(Rjustify$, "+")
                        If Plus% Then Rjustify$ = Left$(Rjustify$, Plus% - 1) + Right$(Rjustify$, Len(Rjustify$) - Plus%)
                        Space% = InStr(Rjustify$, " ")
                        If Space% Then Rjustify$ = Left$(Rjustify$, Space% - 1) + Right$(Rjustify$, Len(Rjustify$) - Space%)
                    Wend
                    If InStr(Rjustify$, "CTRL") Then
                        __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 100305 ' ** Right CTRL Key
                        Rjustify$ = Left$(Rjustify$, InStr(Rjustify$, "CTRL") - 1) + Right$(Rjustify$, Len(Rjustify$) - (InStr(Rjustify$, "CTRL") + 3))
                    End If
                    If InStr(Rjustify$, "SHIFT") Then
                        __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 100303 ' ** Right SHIFT key
                        Rjustify$ = Left$(Rjustify$, InStr(Rjustify$, "SHIFT") - 1) + Right$(Rjustify$, Len(Rjustify$) - (InStr(Rjustify$, "SHIFT") + 4))
                    End If
                    Select Case Rjustify$
                        Case "F1"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 15104 ' ** F1 Key
                        Case "F2"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 15360 ' ** F2 Key
                        Case "F3"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 15616 ' ** F3 Key
                        Case "F4"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 15872 ' ** F4 Key
                        Case "F5"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 16128 ' ** F5 Key
                        Case "F6"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 16384 ' ** F6 Key
                        Case "F7"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 16640 ' ** F7 Key
                        Case "F8"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 16896 ' ** F8 Key
                        Case "F9"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 17152 ' ** F9 Key
                        Case "F10"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 17408 ' ** F10 Key
                        Case "F11"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 34048 ' ** F11 Key
                        Case "F12"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 34304 ' ** F12 Key
                        Case "DEL", "DELETE"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 21248 ' ** DELETE Key
                        Case "INS", "INSERT"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 20992 ' ** INSERT Key
                        Case "HOME"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 18176 ' ** HOME Key
                        Case "END"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 20224 ' ** END Key
                        Case "PGUP", "PAGEUP"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 18688 ' ** PGUP Key
                        Case "PGDN", "PAGEDOWN"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 20736 ' ** PGDN Key
                        Case "RIGHT", "RIGHTARROW"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 19712 ' ** Right Arrow Key (use?)
                        Case "LEFT", "LEFTARROW"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 19200 ' ** Left Arrow Key  (use?)
                        Case "UP", "UPARROW"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 18432 ' ** Up Arrow Key    (use?)
                        Case "DOWN", "DOWNARROW"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 20480 ' ** Down Arrow Key  (use?)
                        Case "CLOCK", "CAPS", "CAPSLOCK"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 100301 ' ** CAPS Lock Key
                        Case "NLOCK", "NUM", "NUMLOCK"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 100300 ' ** NUM Lock Key
                        Case "SLOCK", "SCROLL", "SCROLLLOCK"
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + 100302 ' ** SCROLL Lock Key
                        Case Else
                            __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey = __IMGUI64_MenuInfo(MainMenu%, SubMenu%).hotkey + Asc(Rjustify$) ' ** any other key
                    End Select
                Else
                    __IMGUI64_MenuInfo(MainMenu%, SubMenu%).ljustify = ReadData$ '                   left text
                    __IMGUI64_MenuInfo(MainMenu%, SubMenu%).rjustify = "" '                          no hotkey
                End If
                Read ReadData$ '                                                       read next sub menu entry
            Loop
            __IMGUI64_MenuInfo(MainMenu%, 0).idnum = __IMGUI64_MenuInfo(MainMenu%, 0).idnum + SubMenu% '           attach the number of sub menu entries to main id number
            x% = x% + __IMGUI64_MenuInfo(MainMenu%, 0).width '                                       move to next main menu position
            Read ReadData$ '                                                           read next main menu entry
        Loop
        __IMGUI64_MenuSettings.menubar = _NewImage(ScreenWidth%, __IMGUI64_MenuSettings.height, 32) '                          create normal menu bar image
        _Dest __IMGUI64_MenuSettings.menubar '                                                               set it as the destination image

        _PrintMode _KeepBackground '                                                   set its font behavior
        __IMGUI64_MenuSettings.menubarhighlight = _NewImage(ScreenWidth%, __IMGUI64_MenuSettings.height, 32) '                 create higlighted menu bar image
        _Dest __IMGUI64_MenuSettings.menubarhighlight '                                                      set it as the destination image

        _PrintMode _KeepBackground '                                                   set its font behavior
        __IMGUI64_MenuSettings.menubarselected = _NewImage(ScreenWidth%, __IMGUI64_MenuSettings.height, 32) '                  create selected menu bar image
        _Dest __IMGUI64_MenuSettings.menubarselected '                                                       set it as the destination image

        _PrintMode _KeepBackground '                                                   set its font behavior
        __IMGUI64_MenuSettings.undermenu = _NewImage(ScreenWidth%, __IMGUI64_MenuSettings.height, 32)

        '******************************************************************************
        '* Draw all the menu graphics                                                 *
        '******************************************************************************
        DrawMenuBars
        For MainMenu% = 1 To UBound(__IMGUI64_MenuInfo)
            DrawMainEntry MainMenu%
            DrawSubMenu MainMenu%
            For SubMenu% = 1 To __IMGUI64_MenuInfo(MainMenu%, 0).idnum - ((__IMGUI64_MenuInfo(MainMenu%, 0).idnum \ 100) * 100)
                DrawSubEntry MainMenu%, SubMenu%
            Next SubMenu%
        Next MainMenu%
        '******************************************************************************
        '* routine cleanup                                                            *
        '******************************************************************************
        ReDim MaxLength%(0) '                                                          array no longer needed, free memory
        ReDim TotalSubmenu%(0) '                                                       array no longer needed, free memory
        _FreeImage __IMGUI64_MenuSettings.menubarhighlight '                                                 image no longer needed, free memory
        _FreeImage __IMGUI64_MenuSettings.menubarselected '                                                  image no longer needed, free memory
        _Dest DestHold& '                                                              restore original destination when routine called
        _Font FontHold& '                                                              restore original font when routine called
    End Sub
    '-----------------------------------------------------------------------------------------------------
$End If
'---------------------------------------------------------------------------------------------------------
