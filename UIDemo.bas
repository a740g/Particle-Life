'$Include:'include/IMGUI64.bi'

Dim mybutton%
Dim x%, y%
Dim Menu%

Screen _NewImage(800, 600, 32)
_ScreenMove _Middle
Cls , SkyBlue


mybutton% = ButtonNew(225, 225, Gray)
x% = (800 - ButtonWidth(mybutton%)) \ 2
y% = (600 - ButtonHeight(mybutton%)) \ 2
ButtonPut x%, y%, mybutton%

Restore menudata
MakeMenu
ShowMenu

Do
    IMGUI64Update
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
Loop Until IMGUI64GetKey = 27 Or Menu% = 103

HideMenu

ButtonFree mybutton%

_AutoDisplay

System

menudata:
Data "&File","&Open...#CTRL+O","&Save#CTRL+S","-E&xit#CTRL+Q","*"
Data "&Help","&About...","*"
Data "!"

'$Include:'include/IMGUI64.bas'

