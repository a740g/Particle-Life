'---------------------------------------------------------------------------------------------------------
' QB64-PE Immediate mode GUI Library
'
' This is very loosely based on Terry Ritchie's work: GLINPUT, RQBL
' Note this library has an input manager and a focus on immediate mode UI
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

    Const WIDGET_PUSH_BUTTON = 0
    Const WIDGET_TEXT_BOX = 1
    Const WIDGET_CLASS_COUNT = 2

    Const KEY_TAB = 9
    Const KEY_ENTER = 13
    Const KEY_SPACE_BAR = 32

    Const ERROR_INVALID_HANDLE = 258
    Const ERROR_FEATURE_UNAVAILABLE = 73
    '-----------------------------------------------------------------------------------------------------

    '-----------------------------------------------------------------------------------------------------
    ' USER DEFINED TYPES
    '-----------------------------------------------------------------------------------------------------
    Type Vector2DType ' simple 2D vector
        x As Long
        y As Long
    End Type

    Type RectangleType ' 2D rectangle
        a As Vector2DType
        b As Vector2DType
    End Type

    Type InputManagerType ' simple input manager
        keyCode As Long ' buffer keyboard input
        mousePosition As Vector2DType ' mouse position
        mouseLeftButton As Byte ' mouse left button down
        mouseRightButton As Byte ' mouse right button down
        mouseLeftClicked As Byte
        mouseLeftButtonClickedRectangle As RectangleType ' the rectangle where the mouse left button was clicked
        mouseRightClicked As Byte
        mouseRightButtonClickedRectangle As RectangleType ' the rectangle where the mouse left button was clicked
    End Type

    Type WidgetManagerType ' widget state information
        forced As Long ' widget that is forced to get focus
        current As Long ' current widget that has focus
    End Type

    Type TextBoxType ' text box type
        flags As Unsigned Long ' allowed characters and other flags
        textPosition As Long ' current cursor position within input field text
        boxPosition As Long ' cursor character position in the box
        boxTextLength As Long ' how much charcters will be visible in the box
        boxStartCharacter As Long ' starting visible character
        insertMode As Byte ' current cursor insert mode (-1 = INSERT, 0 = OVERWRITE)
        entered As Byte ' ENTER has been pressed on this input field (T/F)
    End Type

    Type PushButtonType ' button information
        toggle As Byte ' is this a toggle button?
        state As Byte ' state of button (down or up)
    End Type

    Type WidgetType
        inUse As Byte ' is this widget in use?
        visible As Byte ' is this widget visible on screen?
        disabled As Byte ' is the widget disabled?
        position As Vector2DType ' position of the widget on the screen
        size As Vector2DType ' size of the widget on the screen
        text As String ' text associated with the widget
        clicked As Byte ' was the widget pressed / clicked?

        class As Long ' type of widget

        ' Class specific stuff
        cmd As PushButtonType
        txt As TextBoxType
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
    Dim WidgetManager As WidgetManagerType
    ReDim Widget(0 To 0) As WidgetType
    '-----------------------------------------------------------------------------------------------------
$End If
'---------------------------------------------------------------------------------------------------------

