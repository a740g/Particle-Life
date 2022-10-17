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
'$Include:'./Common.bi'
'---------------------------------------------------------------------------------------------------------

$If IMGUI64_BI = UNDEFINED Then
    $Let IMGUI64_BI = TRUE

    '-----------------------------------------------------------------------------------------------------
    ' CONSTANTS
    '-----------------------------------------------------------------------------------------------------
    Const TEXT_BOX_ALPHA = 1 'alphabetic input allowed
    Const TEXT_BOX_NUMERIC = 2 'numeric input allowed
    Const TEXT_BOX_SYMBOLS = 4 'all symbols allowed
    Const TEXT_BOX_DASH = 8 'dash (-) symbol allowed
    Const TEXT_BOX_PAREN = 16 'parenthesis allowed
    Const TEXT_BOX_LOWER = 32 'lower case only
    Const TEXT_BOX_UPPER = 64 'upper case only
    Const TEXT_BOX_PASSWORD = 128 'password * only
    '-----------------------------------------------------------------------------------------------------

    '-----------------------------------------------------------------------------------------------------
    ' USER DEFINED TYPES
    '-----------------------------------------------------------------------------------------------------
    Type InputManagerType 'A simple input management system type
        keyCode As Long 'Buffered keyboard input
        mouseX As Long 'Current mouse X position
        mouseY As Long 'Current mouse Y position
        leftMouseButton As Byte 'Current left mouse button down state
        rightMouseButton As Byte 'Current right mouse button down state
    End Type

    Type TextBoxType 'graphics line input array type
        inUse As Byte 'is this field in use (T/F)
        visible As Byte 'TRUE if input field visible on screen, FALSE otherwise
        x As Long 'x location of text
        y As Long 'y location of text
        w As Unsigned Long 'width of the box
        h As Unsigned Long 'height of the box
        text As String 'text being entered into input field
        allow As Unsigned Long 'allowed characters in input field
        cursorPosition As Long 'current cursor position within input field
        cursorPosBox As Long 'cursor character position in the visible box
        visibleTextLen As Long 'how much charcters of the text will be visible
        startVisibleChar As Long 'starting visible character
        cursorWidth As Long 'width of the cursor in pixels
        insertMode As Byte 'current cursor insert mode (-1 = INSERT, 0 = OVERWRITE)
        entered As Byte 'ENTER has been pressed on this input field (T/F)
        renderImage As Long 'bitmap the text is rendered into
    End Type

    Type TextBoxSettingsType 'textbox settings and state information
        forced As Long 'used to pass GLIFORCE messages to GLIUPDATE
        current As Long 'current field user typing into
    End Type

    Type CommandButtonType 'button information
        inUse As Byte 'button is in use(set by BUTTONNEW, BUTTONFREE)
        visible As Integer 'button on screen? (set by BUTTONPUT)
        x As Long 'x location of button(set by BUTTONPUT)
        y As Long 'y location of button(set by BUTTONPUT)
        w As Unsigned Long 'width of button(set by BUTTONNEW)
        h As Unsigned Long 'height of button (set by BUTTONNEW)
        text As String 'text of button(set by ButtonText)
        state As Integer 'state of button (set by BUTTONNEW, BUTTONTOGGLE)
        mouse As Integer 'mouse status of button (1-left, 2-right, 3-hover)
    End Type
    '-----------------------------------------------------------------------------------------------------

    '-----------------------------------------------------------------------------------------------------
    ' EXTERNAL LIBRARIES
    '-----------------------------------------------------------------------------------------------------
    Declare CustomType Library
        Function GetTicks&&
    End Declare
    '-----------------------------------------------------------------------------------------------------

    '-----------------------------------------------------------------------------------------------------
    ' SHARED VARIABLES
    '-----------------------------------------------------------------------------------------------------
    Dim InputManager As InputManagerType 'input manager global variable. Use this to check for input
    ReDim TextBox(0 To 0) As TextBoxType 'text input array
    Dim TextBoxSettings As TextBoxSettingsType 'settings for textbox
    ReDim CommandButton(1 To 1) As CommandButtonType 'array defining button information
    '-----------------------------------------------------------------------------------------------------
$End If
'---------------------------------------------------------------------------------------------------------

