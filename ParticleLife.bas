'---------------------------------------------------------------------------------------------------------
' Particle Life for QB64-PE
' Copyright (c) 2022 Samuel Gomes
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' HEADER FILES
'---------------------------------------------------------------------------------------------------------
'$Include:'include/IMGUI64.bi'
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' CONSTANTS
'---------------------------------------------------------------------------------------------------------
Const ATOMS_DEFAULT = 300 ' this is the default numbers of atoms we start in each group
Const GROUPS_MAX = 7 ' maximum number of groups in the universe

Const UI_WIDGET_HEIGHT = 24 ' defaut widget height
Const UI_WIDGET_SPACE = 4 ' space between widgets
Const UI_PUSH_BUTTON_WIDTH_LARGE = 160
Const UI_PUSH_BUTTON_WIDTH_SMALL = 24
Const UI_TEXT_BOX_WIDTH = UI_PUSH_BUTTON_WIDTH_LARGE - (UI_PUSH_BUTTON_WIDTH_SMALL * 2) - (UI_WIDGET_SPACE * 2)
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' USER DEFINED TYPES
'---------------------------------------------------------------------------------------------------------
' A typical 2D floating point vector
Type Vector2DFType
    x As Single
    y As Single
End Type

' This defines the universe
Type UniverseType
    size As Vector2DType ' this MUST be set by the user - typically window width & height
    groups As Unsigned Long ' managed by AddGroup() & RemoveGroup()
    atoms As Unsigned Long ' this MUST be set by the user - typically from the UI
End Type

' This defines the name and colors for all groups
Type GroupNameType
    caption As String ' managed by InitializeGroupTable()
    clr As Unsigned Long ' managed by InitializeGroupTable()
End Type

' This defines the group
Type GroupType
    clr As Unsigned Long ' managed by AddGroup()
    gravity As Single ' this MUST be set by the user - typically from the UI
    radius As Single ' this MUST be set by the user - typically from the UI
    atomSize As Unsigned Long ' this may be set by the user - typically from the UI
End Type

' This defines the atom
Type AtomType
    position As Vector2DFType ' managed by InitializeGroup() & RunUniverse()
    velocity As Vector2DFType ' managed by RunUniverse()
End Type

Type UIType ' bunch of UI widgets to change stuff
    start As Vector2DType
    cmdShow As Long ' hide / show UI
    cmdExit As Long ' exit button
    cmdShowFPS As Long ' hide / show FPS
    cmdReset As Long ' reset to defaults
    cmdRandom As Long ' random madness
    cmdColorsDec As Long
    txtColors As Long
    cmdColorsInc As Long
    cmdAtomsDec As Long
    txtAtoms As Long
    cmdAtomsInc As Long
    cmdAtomSizeDec As Long
    txtAtomSize As Long
    cmdAtomSizeInc As Long
End Type
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' GLOBAL VARIABLES
'---------------------------------------------------------------------------------------------------------
Dim Shared UI As UIType ' user interface controls
Dim Shared Universe As UniverseType ' Universe
Dim Shared GroupTable(1 To GROUPS_MAX) As GroupNameType ' Group table
ReDim Shared Group(1 To 1) As GroupType ' Group
ReDim Shared Atom(1 To 1, 1 To 1) As AtomType ' Atom
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' PROGRAM ENTRY POINT
'---------------------------------------------------------------------------------------------------------
Screen _NewImage(DesktopWidth, DesktopHeight, 32)
FullScreen SquarePixels , Smooth
PrintMode KeepBackground
Randomize Timer

' Setup universe
Universe.size.x = Width
Universe.size.y = Height
Universe.atoms = ATOMS_DEFAULT

InitializeUI ' initialize the UI
InitializeGroupTable ' setup the group table

' Add some groups
AddGroup
AddGroup
AddGroup
'AddGroup

' Main loop
Do
    RunUniverse ' make the universe go

    Color White, Black ' This is required since the UI code can change the colors
    Cls ' clear the framebuffer

    DrawUniverse ' draw the universe
    If PushButtonDepressed(UI.cmdShowFPS) Then PrintString (0, 0), Str$(CalculateFPS) + " FPS @" + Str$(Universe.size.x) + " x" + Str$(Universe.size.y)
    WidgetUpdate

    Display ' flip the framebuffer

    Limit 120 ' let's not get out of control
Loop Until InputManager.keyCode = KEY_ESCAPE Or WidgetClicked(UI.cmdExit)

WidgetFreeAll

System
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' FUNCTIONS AND SUBROUTINES
'---------------------------------------------------------------------------------------------------------
' This initializes all the static UI that will always be there
' Also call the dynamic UI function
Sub InitializeUI
    ' Calculate UI start left
    UI.start.x = Universe.size.x - UI_PUSH_BUTTON_WIDTH_LARGE - 1 - UI_WIDGET_SPACE
    UI.start.y = UI_WIDGET_SPACE
    UI.cmdShow = PushButtonNew("Show Controls", UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, TRUE)
    PushButtonDepressed UI.cmdShow, TRUE
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdExit = PushButtonNew("Exit", UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, FALSE)
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdShowFPS = PushButtonNew("Show FPS", UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, TRUE)
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdReset = PushButtonNew("Reset", UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, FALSE)
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRandom = PushButtonNew("Random", UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, FALSE)
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdColorsDec = PushButtonNew(Chr$(17), UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtColors = TextBoxNew(Str$(Universe.groups), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, UI.start.y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdColorsInc = PushButtonNew(Chr$(16), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdAtomsDec = PushButtonNew(Chr$(17), UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtAtoms = TextBoxNew(Str$(Universe.groups), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, UI.start.y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdAtomsInc = PushButtonNew(Chr$(16), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdAtomSizeDec = PushButtonNew(Chr$(17), UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtAtomSize = TextBoxNew(Str$(Universe.groups), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, UI.start.y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdAtomSizeInc = PushButtonNew(Chr$(16), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
End Sub

' This makes all available UI visible
Sub ShowUI
End Sub

' This makes all available UI invisivble (except the main button)
Sub HideUI
End Sub

' Add UI for new groups
Sub AddGroupUI
End Sub

' Remove UI for deleted groups
Sub RemoveGroupUI
End Sub

' Validate UI values
Sub ValidateUI
End Sub

' Initializes the group name table along with the colors
Sub InitializeGroupTable
    GroupTable(1).caption = "Green"
    GroupTable(1).clr = NP_Green

    GroupTable(2).caption = "Red"
    GroupTable(2).clr = NP_Red

    GroupTable(3).caption = "Orange"
    GroupTable(3).clr = Orange

    GroupTable(4).caption = "Cyan"
    GroupTable(4).clr = Cyan

    GroupTable(5).caption = "Magenta"
    GroupTable(5).clr = Magenta

    GroupTable(6).caption = "White"
    GroupTable(6).clr = White

    GroupTable(7).caption = "Yellow"
    GroupTable(7).clr = Yellow
End Sub


' This return an index from the table for the color
' It will return 0 if color is not found
' The index can then be used to access groups in the universe
Function GetGroupTableIndex (clr As Unsigned Long)
    Dim i As Unsigned Long

    For i = 1 To GROUPS_MAX
        If clr = GroupTable(i).clr Then
            GetGroupTableIndex = i

            Exit Function
        End If
    Next
End Function


' Adds a group to the universe
Sub AddGroup
    Universe.groups = Universe.groups + 1
    ReDim Preserve Group(1 To Universe.groups) As GroupType
    Group(Universe.groups).clr = GroupTable(Universe.groups).clr

    ' Set some random values
    Group(Universe.groups).gravity = RandomBetween(-40, 40)
    Group(Universe.groups).radius = RandomBetween(20, 80)
    Group(Universe.groups).atomSize = RandomBetween(0, 2)

    ' Initialize the added group
    InitializeGroup
End Sub


' Removes a group from the universe
Sub RemoveGroup
    Universe.groups = Universe.groups - 1
    ReDim Preserve Group(1 To Universe.groups) As GroupType
End Sub


' Initializes the last group created
Sub InitializeGroup
    ReDim Preserve Atom(1 To Universe.groups, 1 To Universe.atoms) As AtomType

    Dim i As Unsigned Long
    For i = 1 To Universe.atoms
        Atom(Universe.groups, i).position.x = RandomBetween(50, Universe.size.x - 51)
        Atom(Universe.groups, i).position.y = RandomBetween(50, Universe.size.y - 51)
    Next
End Sub


' This will make everything go
Sub RunUniverse
    Dim As Single g, dx, dy, r, fx, fy, f
    Dim As Unsigned Long a1, a2, g1, g2

    For g2 = 1 To Universe.groups
        For g1 = 1 To Universe.groups
            g = Group(g1).gravity / -100

            For a1 = 1 To Universe.atoms
                fx = 0
                fy = 0
                For a2 = 1 To Universe.atoms
                    ' Calculate the distance between points using Pythagorean theorem
                    dx = Atom(g1, a1).position.x - Atom(g2, a2).position.x
                    dy = Atom(g1, a1).position.y - Atom(g2, a2).position.y
                    r = Sqr(dx * dx + dy * dy)

                    ' Calculate the force in given bounds
                    If r > 0 And r < Group(g1).radius Then
                        f = g / r
                        fx = fx + dx * f
                        fy = fy + dy * f
                    End If
                Next

                ' Calculate new velocity
                Atom(g1, a1).velocity.x = (Atom(g1, a1).velocity.x + fx) * 0.5
                Atom(g1, a1).velocity.y = (Atom(g1, a1).velocity.y + fy) * 0.5

                ' Update position based on velocity
                Atom(g1, a1).position.x = Atom(g1, a1).position.x + Atom(g1, a1).velocity.x
                Atom(g1, a1).position.y = Atom(g1, a1).position.y + Atom(g1, a1).velocity.y

                ' Checking for screen bounds
                If Atom(g1, a1).position.x < 0 Or Atom(g1, a1).position.x >= Universe.size.x Then Atom(g1, a1).velocity.x = Atom(g1, a1).velocity.x * -1
                If Atom(g1, a1).position.y < 0 Or Atom(g1, a1).position.y >= Universe.size.y Then Atom(g1, a1).velocity.y = Atom(g1, a1).velocity.y * -1
            Next
        Next
    Next
End Sub


' Draws all atoms in the universe
Sub DrawUniverse
    Dim As Unsigned Long g, a
    For g = 1 To Universe.groups
        Color Group(g).clr
        For a = 1 To Universe.atoms
            CircleFill Atom(g, a).position.x, Atom(g, a).position.y, Group(g).atomSize
        Next
    Next
End Sub


' Draws a filled circle
' CX = center x coordinate
' CY = center y coordinate
'  R = radius
Sub CircleFill (cx As Long, cy As Long, r As Long)
    Dim As Long Radius, RadiusError, X, Y

    Radius = Abs(r)
    RadiusError = -Radius
    X = Radius
    Y = 0

    If Radius = 0 Then
        PSet (cx, cy)
        Exit Sub
    End If

    Line (cx - X, cy)-(cx + X, cy), , BF

    While X > Y
        RadiusError = RadiusError + Y * 2 + 1

        If RadiusError >= 0 Then
            If X <> Y + 1 Then
                Line (cx - Y, cy - X)-(cx + Y, cy - X), , BF
                Line (cx - Y, cy + X)-(cx + Y, cy + X), , BF
            End If
            X = X - 1
            RadiusError = RadiusError - X * 2
        End If

        Y = Y + 1

        Line (cx - X, cy - Y)-(cx + X, cy - Y), , BF
        Line (cx - X, cy + Y)-(cx + X, cy + Y), , BF
    Wend
End Sub


' Generates a random number between lo & hi
Function RandomBetween& (lo As Long, hi As Long)
    RandomBetween = lo + Rnd * (hi - lo)
End Function


' Calculates and returns the FPS when repeatedly called inside a loop
Function CalculateFPS~&
    Static As Unsigned Long counter, finalFPS
    Static lastTime As Integer64
    Dim currentTime As Integer64

    counter = counter + 1

    currentTime = GetTicks
    If currentTime > lastTime + 1000 Then
        lastTime = currentTime
        finalFPS = counter
        counter = 0
    End If

    CalculateFPS = finalFPS
End Function
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' MODULE FILES
'---------------------------------------------------------------------------------------------------------
'$Include:'include/IMGUI64.bas'
'---------------------------------------------------------------------------------------------------------

