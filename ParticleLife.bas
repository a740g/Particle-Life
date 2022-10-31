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
Const APP_NAME = "QB64-PE Particle Life"

Const PARTICLES_DEFAULT = 140 ' this is the default numbers of particles we start in each group
Const PARTICLES_MAX = 999 ' maximum number of particles in a group
Const GROUPS_MAX = 4 ' maximum number of groups in the universe
Const PARTICLE_SIZE_DEFAULT = 1 ' default radius of each particle
Const PARTICLE_SIZE_MAX = 8 ' maximum size of each particle

Const FRAME_RATE_MAX = 120

Const UI_FONT_HEIGHT = 16
Const UI_FONT_WIDTH = 8
Const UI_WIDGET_HEIGHT = 24 ' defaut widget height
Const UI_WIDGET_SPACE = 8 ' space between widgets
Const UI_PUSH_BUTTON_WIDTH_LARGE = 120
Const UI_PUSH_BUTTON_WIDTH_SMALL = 24
Const UI_TEXT_BOX_WIDTH = UI_PUSH_BUTTON_WIDTH_LARGE - (UI_PUSH_BUTTON_WIDTH_SMALL * 2) - (UI_WIDGET_SPACE * 2)
Const UI_HEIGHT_CHARS = (UI_WIDGET_HEIGHT + UI_WIDGET_SPACE) \ UI_FONT_HEIGHT
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
    particles As Unsigned Long ' this MUST be set by the user - typically from the UI
    particleSize As Unsigned Long ' this may be set by the user - typically from the UI
End Type

' This defines the group
Type GroupType
    caption As String ' managed by InitializeGroupTable()
    clr As Unsigned Long ' managed by InitializeGroupTable()
    gravity As Single ' this MUST be set by the user - typically from the UI
    radius As Single ' this MUST be set by the user - typically from the UI
End Type

' This defines the particle
Type ParticleType
    position As Vector2DFType ' managed by InitializeGroup() & RunUniverse()
    velocity As Vector2DFType ' managed by RunUniverse()
End Type

Type UIType ' bunch of UI widgets to change stuff
    start As Vector2DType
    hideLabels As Byte ' should lables be hidden?
    changed As Byte ' did anything significant in the UI change
    cmdShow As Long ' hide / show UI
    cmdExit As Long ' exit button
    cmdShowFPS As Long ' hide / show FPS
    cmdAbout As Long ' shows an about dialog
    cmdRandom As Long ' random madness
    ' Controls the number of particles
    cmdParticlesDec As Long
    txtParticles As Long
    cmdParticlesInc As Long
    ' Cotnrols the particle size
    cmdParticleSizeDec As Long
    txtParticleSize As Long
    cmdParticleSizeInc As Long
End Type
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' GLOBAL VARIABLES
'---------------------------------------------------------------------------------------------------------
Dim Shared UI As UIType ' user interface controls
Dim Shared Universe As UniverseType ' Universe
Dim Shared Group(1 To GROUPS_MAX) As GroupType ' Group
ReDim Shared Particle(1 To 1, 1 To 1) As ParticleType ' Particle(group, particles)
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' PROGRAM ENTRY POINT
'---------------------------------------------------------------------------------------------------------
Dim r As Long
r = Clamp(Val(Command$), 1, 8) ' Check the user wants to use a lower resolution
Screen NewImage(DesktopWidth \ r, DesktopHeight \ r, 32)
FullScreen SquarePixels , Smooth
PrintMode KeepBackground
Randomize Timer

' Setup universe
Universe.size.x = Width
Universe.size.y = Height
Universe.particles = PARTICLES_DEFAULT
Universe.particleSize = PARTICLE_SIZE_DEFAULT

InitializeGroups ' setup the groups
InitializeParticles ' setup particles
InitializeUI ' initialize the UI

' Main loop
Do
    RunUniverse ' make the universe go

    Color White, Black ' this is required since the UI code can change the colors
    Cls ' clear the framebuffer

    ' From here on everything is drawn in z order
    DrawUniverse ' draw the universe
    DrawFPS ' draw the FPS
    WidgetUpdate ' update the widget system
    DrawLabels ' draw the static text labels
    UpdateUI ' update and validate UI user values

    Display ' flip the framebuffer

    Limit FRAME_RATE_MAX ' let's not get out of control
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
    UI.changed = TRUE

    ' Calculate UI start left
    UI.start.x = Universe.size.x - UI_PUSH_BUTTON_WIDTH_LARGE - 1 - UI_WIDGET_SPACE
    UI.start.y = UI_WIDGET_SPACE
    UI.cmdShow = PushButtonNew("Show Controls", UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, TRUE)
    PushButtonDepressed UI.cmdShow, TRUE
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdExit = PushButtonNew("Exit", UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, FALSE)
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdAbout = PushButtonNew("About...", UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, FALSE)
UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdShowFPS = PushButtonNew("Show FPS", UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, TRUE)
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRandom = PushButtonNew("Random", UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, FALSE)
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdParticlesDec = PushButtonNew(Chr$(17), UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtParticles = TextBoxNew(Str$(Universe.particles), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, UI.start.y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdParticlesInc = PushButtonNew(Chr$(16), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdParticleSizeDec = PushButtonNew(Chr$(17), UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtParticleSize = TextBoxNew(Str$(Universe.particleSize), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, UI.start.y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdParticleSizeInc = PushButtonNew(Chr$(16), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
End Sub


' Updates and validate UI values whenever something changes
Sub UpdateUI
    ' Check if user wants to change the size
    If WidgetClicked(UI.cmdParticleSizeDec) Then Universe.particleSize = Universe.particleSize - 1: UI.changed = TRUE
    If WidgetClicked(UI.cmdParticleSizeInc) Then Universe.particleSize = Universe.particleSize + 1: UI.changed = TRUE
    If TextBoxEntered(UI.txtParticleSize) Then Universe.particleSize = Val(WidgetText(UI.txtParticleSize)): UI.changed = TRUE

    ' Check if user wants to change the number of particles
    If WidgetClicked(UI.cmdParticlesDec) Then WidgetText UI.txtParticles, Str$(Val(WidgetText$(UI.txtParticles)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdParticlesInc) Then WidgetText UI.txtParticles, Str$(Val(WidgetText$(UI.txtParticles)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtParticles) Then UI.changed = TRUE

    ' Check if user clicked the random button
    If WidgetClicked(UI.cmdRandom) Then
        InitializeGroups
        InitializeParticles
    End If

    ' Check if the about button was clicked
    If WidgetClicked(UI.cmdAbout) Then
        MessageBox "About", APP_NAME + String$(2, KEY_ENTER) + "Copyright (c) 2022 Samuel Gomes" + String$(2, KEY_ENTER) + "This was written in QB64-PE and the source code is avilable at https://github.com/a740g/Particle-Life"
    End If

    ' Check is the show button was pressed
    If WidgetClicked(UI.cmdShow) Then
        ' If so, then change the UI visibility based on the show button's state
        WidgetVisibleAll PushButtonDepressed(UI.cmdShow)
        UI.hideLabels = Not PushButtonDepressed(UI.cmdShow)
        ' However, leave the show button to be always visible
        WidgetVisible UI.cmdShow, TRUE
    End If

    If UI.changed Then
        Universe.particleSize = Clamp(Universe.particleSize, 0, PARTICLE_SIZE_MAX)
        WidgetText UI.txtParticleSize, Str$(Universe.particleSize)

        If Universe.particles <> Val(WidgetText$(UI.txtParticles)) Then
            Universe.particles = Clamp(Val(WidgetText$(UI.txtParticles)), 1, PARTICLES_MAX)
            InitializeParticles
        End If

        UI.changed = FALSE
    End If
End Sub


Sub PrintRightAligned (text As String, cx As Integer, cy As Integer)
    Locate cy, cx - Len(text)
    Print text;
End Sub


' This draws the static texts next to the UI buttons to show what they do
Sub DrawLabels
    If Not UI.hideLabels Then
        Dim cx As Integer

        cx = UI.start.x \ UI_FONT_WIDTH

        Color Gray

        PrintRightAligned "Particles:", cx, UI_HEIGHT_CHARS * 6
        PrintRightAligned "Size:", cx, UI_HEIGHT_CHARS * 7
    End If
End Sub


' Draws the FPS on the top left corner of the screen if selected
Sub DrawFPS
    If PushButtonDepressed(UI.cmdShowFPS) Then
        Color Yellow
        PrintString (0, 0), Str$(CalculateFPS) + " FPS @" + Str$(Universe.size.x) + " x" + Str$(Universe.size.y)
    End If
End Sub


' Initializes all groups
Sub InitializeGroups
    Group(1).caption = "Red"
    Group(1).clr = NP_Red
    Group(1).gravity = RandomBetween(-80, 80)
    Group(1).radius = RandomBetween(10, 80)

    Group(2).caption = "Green"
    Group(2).clr = NP_Green
    Group(2).gravity = RandomBetween(-80, 80)
    Group(2).radius = RandomBetween(10, 80)

    Group(3).caption = "Blue"
    Group(3).clr = NP_Blue
    Group(3).gravity = RandomBetween(-80, 80)
    Group(3).radius = RandomBetween(10, 80)

    Group(4).caption = "White"
    Group(4).clr = White
    Group(4).gravity = RandomBetween(-80, 80)
    Group(4).radius = RandomBetween(10, 80)
End Sub


' Initializes all particles in the universe
Sub InitializeParticles
    ReDim Particle(1 To GROUPS_MAX, 1 To Universe.particles) As ParticleType

    Dim As Unsigned Long g, a
    For g = 1 To GROUPS_MAX
        For a = 1 To Universe.particles
            Particle(g, a).position.x = RandomBetween(50, Universe.size.x - 51)
            Particle(g, a).position.y = RandomBetween(50, Universe.size.y - 51)
        Next
    Next
End Sub


' This will make everything go
Sub RunUniverse
    Dim As Single g, dx, dy, r, fx, fy, f
    Dim As Unsigned Long a1, a2, g1, g2

    For g2 = 1 To GROUPS_MAX
        For g1 = 1 To GROUPS_MAX
            g = Group(g1).gravity / -100

            For a1 = 1 To Universe.particles
                fx = 0
                fy = 0
                For a2 = 1 To Universe.particles
                    ' Calculate the distance between points using Pythagorean theorem
                    dx = Particle(g1, a1).position.x - Particle(g2, a2).position.x
                    dy = Particle(g1, a1).position.y - Particle(g2, a2).position.y
                    r = Sqr(dx * dx + dy * dy)

                    ' Calculate the force in given bounds
                    If r > 0 And r < Group(g1).radius Then
                        f = g / r
                        fx = fx + dx * f
                        fy = fy + dy * f
                    End If
                Next

                ' Calculate new velocity
                Particle(g1, a1).velocity.x = (Particle(g1, a1).velocity.x + fx) * 0.5
                Particle(g1, a1).velocity.y = (Particle(g1, a1).velocity.y + fy) * 0.5

                ' Update position based on velocity
                Particle(g1, a1).position.x = Particle(g1, a1).position.x + Particle(g1, a1).velocity.x
                Particle(g1, a1).position.y = Particle(g1, a1).position.y + Particle(g1, a1).velocity.y

                ' Checking for screen bounds
                If Particle(g1, a1).position.x < 0 Or Particle(g1, a1).position.x >= Universe.size.x Then Particle(g1, a1).velocity.x = Particle(g1, a1).velocity.x * -1
                If Particle(g1, a1).position.y < 0 Or Particle(g1, a1).position.y >= Universe.size.y Then Particle(g1, a1).velocity.y = Particle(g1, a1).velocity.y * -1
            Next
        Next
    Next
End Sub


' Draws all particles in the universe
Sub DrawUniverse
    Dim As Unsigned Long g, a
    For g = 1 To GROUPS_MAX
        Color Group(g).clr
        For a = 1 To Universe.particles
            CircleFill Particle(g, a).position.x, Particle(g, a).position.y, Universe.particleSize
        Next
    Next
End Sub


' Draws a filled circle
' CX = center x coordinate
' CY = center y coordinate
'  R = radius
Sub CircleFill (cx As Long, cy As Long, r As Long)
    Dim As Long radius, radiusError, X, Y

    radius = Abs(r)
    radiusError = -radius
    X = radius
    Y = 0

    If radius = 0 Then
        PSet (cx, cy)
        Exit Sub
    End If

    Line (cx - X, cy)-(cx + X, cy), , BF

    While X > Y
        radiusError = radiusError + Y * 2 + 1

        If radiusError >= 0 Then
            If X <> Y + 1 Then
                Line (cx - Y, cy - X)-(cx + Y, cy - X), , BF
                Line (cx - Y, cy + X)-(cx + Y, cy + X), , BF
            End If
            X = X - 1
            radiusError = radiusError - X * 2
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


' Clamps v between lo and hi
Function Clamp& (v As Long, lo As Long, hi As Long)
    If v < lo Then
        Clamp = lo
    ElseIf v > hi Then
        Clamp = hi
    Else
        Clamp = v
    End If
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

