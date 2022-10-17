'$Include:'include/IMGUI64.bi'

Dim mybutton%
Dim x%, y%
Dim Menu%
Dim helloworldinp%
Dim helloworld$
Dim wallpaper As Long

' Create a texture
wallpaper& = _NewImage(800, 648, 32) ' create image to use as background
_Dest wallpaper&
Line (0, 0)-(Width(wallpaper) - 1, Height(wallpaper) - 1), _RGB32(0, 0, 127), BF
For y% = 0 To 14
    For x% = 0 To 17
        CircleFill x% * 48 + 16, y% * 48 + 16, 24, _RGB32(0, 0, 96)
    Next
Next


Screen _NewImage(800, 600, 32)
_ScreenMove _Middle
_PutImage (0, 0), wallpaper& '         show background image


mybutton% = ButtonNew(64, 32, Gray)
x% = (800 - ButtonWidth(mybutton%)) \ 2
y% = (600 - ButtonHeight(mybutton%)) \ 2
ButtonPut x%, y%, mybutton%

Restore menudata
MakeMenu
ShowMenu

helloworldinp% = GLIInput(100, 100, 64, IMGUI64_INPUT_ALPHA, "test me")

y% = 0
Do
    IMGUI64Update

    y% = y% - 1
    If y% = -48 Then y% = 0
    _PutImage (0, y%), wallpaper&
    Locate 6, 1: Print "Real time: "; GLIOutput$(helloworldinp%); " ";

    GLIUpdate ' must be the second to last command in any loop

    ButtonUpdate
    Select Case ButtonEvent(mybutton%)
        Case 0
            Locate 5, 14
            Print "NO INTERACTION";
            ButtonOff mybutton%
        Case 1
            Locate 5, 14
            Print " LEFT BUTTON  ";
            ButtonOn mybutton%
        Case 2
            Locate 5, 14
            Print " RIGHT BUTTON ";
            ButtonOn mybutton%

        Case 3
            Locate 5, 14
            Print "   HOVERING   ";
            ButtonOff mybutton%
    End Select

    Menu% = CheckMenu%(TRUE)

    _Display

    _Limit 60
Loop Until IMGUI64GetKey = 27 Or Menu% = 103 Or GLIEntered(helloworldinp%)

helloworld$ = GLIOutput$(helloworldinp%)

GLIClose helloworldinp%
HideMenu
ButtonFree mybutton%

FreeImage wallpaper

_AutoDisplay

Locate 7, 1: Print "Final    : "; helloworld$

End

menudata:
Data "&File","&Open...#CTRL+O","&Save#CTRL+S","-E&xit#CTRL+Q","*"
Data "&Help","&About...","*"
Data "!"


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

'$Include:'include/IMGUI64.bas'

