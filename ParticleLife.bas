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

Const PARTICLES_DEFAULT = 200 ' this is the default numbers of particles we start in each group
Const PARTICLES_MAX = 999 ' maximum number of particles in a group
Const GROUPS_MAX = 3 ' maximum number of groups in the universe
Const PARTICLE_SIZE_DEFAULT = 1 ' default radius of each particle
Const PARTICLE_SIZE_MAX = 8 ' maximum size of each particle

Const GROUP_RED = 1
Const GROUP_GREEN = 2
Const GROUP_BLUE = 3

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

' This defines the rule type
Type RuleType
    attraction As Single
    radius As Single
End Type

' This defines the group
Type GroupType
    clr As Unsigned Long ' managed by InitializeGroupTable()
    rule1 As RuleType ' self
    rule2 As RuleType ' other
    rule3 As RuleType ' other
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
    ' Various attraction & radius controls
    cmdRR_ADec As Long
    txtRR_A As Long
    cmdRR_AInc As Long
    cmdRR_RDec As Long
    txtRR_R As Long
    cmdRR_RInc As Long

    cmdRG_ADec As Long
    txtRG_A As Long
    cmdRG_AInc As Long
    cmdRG_RDec As Long
    txtRG_R As Long
    cmdRG_RInc As Long

    cmdRB_ADec As Long
    txtRB_A As Long
    cmdRB_AInc As Long
    cmdRB_RDec As Long
    txtRB_R As Long
    cmdRB_RInc As Long

    cmdGR_ADec As Long
    txtGR_A As Long
    cmdGR_AInc As Long
    cmdGR_RDec As Long
    txtGR_R As Long
    cmdGR_RInc As Long

    cmdGG_ADec As Long
    txtGG_A As Long
    cmdGG_AInc As Long
    cmdGG_RDec As Long
    txtGG_R As Long
    cmdGG_RInc As Long

    cmdGB_ADec As Long
    txtGB_A As Long
    cmdGB_AInc As Long
    cmdGB_RDec As Long
    txtGB_R As Long
    cmdGB_RInc As Long

    cmdBR_ADec As Long
    txtBR_A As Long
    cmdBR_AInc As Long
    cmdBR_RDec As Long
    txtBR_R As Long
    cmdBR_RInc As Long

    cmdBG_ADec As Long
    txtBG_A As Long
    cmdBG_AInc As Long
    cmdBG_RDec As Long
    txtBG_R As Long
    cmdBG_RInc As Long

    cmdBB_ADec As Long
    txtBB_A As Long
    cmdBB_AInc As Long
    cmdBB_RDec As Long
    txtBB_R As Long
    cmdBB_RInc As Long
End Type
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' GLOBAL VARIABLES
'---------------------------------------------------------------------------------------------------------
Dim Shared UI As UIType ' user interface controls
Dim Shared Universe As UniverseType ' Universe
Dim Shared Group(1 To GROUPS_MAX) As GroupType ' Group
ReDim Shared GroupRed(1 To 1) As ParticleType ' Red particles
ReDim Shared GroupGreen(1 To 1) As ParticleType ' Green particles
ReDim Shared GroupBlue(1 To 1) As ParticleType ' Blue particles
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' PROGRAM ENTRY POINT
'---------------------------------------------------------------------------------------------------------
Dim r As Unsigned Long
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

    Color White, &HFF0F0F0F~& ' this is required since the UI code can change the colors
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

    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRR_ADec = PushButtonNew(Chr$(17), UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRR_A = TextBoxNew(Str$(Group(GROUP_RED).rule1.attraction), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, UI.start.y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdRR_AInc = PushButtonNew(Chr$(16), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)

    UI.start.y = UI.start.y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRR_RDec = PushButtonNew(Chr$(17), UI.start.x, UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRR_R = TextBoxNew(Str$(Group(GROUP_RED).rule1.radius), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, UI.start.y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdRR_RInc = PushButtonNew(Chr$(16), UI.start.x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), UI.start.y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
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


Sub PrintRightAligned (text As String, cx As Long, cy As Long)
    Locate cy, cx - Len(text)
    Print text;
End Sub


' This draws the static texts next to the UI buttons to show what they do
Sub DrawLabels
    If Not UI.hideLabels Then
        Dim cx As Long

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
    Group(GROUP_RED).clr = NP_Red
    Group(GROUP_RED).rule1.attraction = RandomBetween(-100, 100)
    Group(GROUP_RED).rule1.radius = RandomBetween(10, 200)
    Group(GROUP_RED).rule2.attraction = RandomBetween(-100, 100)
    Group(GROUP_RED).rule2.radius = RandomBetween(10, 200)
    Group(GROUP_RED).rule3.attraction = RandomBetween(-100, 100)
    Group(GROUP_RED).rule3.radius = RandomBetween(10, 200)

    Group(GROUP_GREEN).clr = NP_Green
    Group(GROUP_GREEN).rule1.attraction = RandomBetween(-100, 100)
    Group(GROUP_GREEN).rule1.radius = RandomBetween(10, 200)
    Group(GROUP_GREEN).rule2.attraction = RandomBetween(-100, 100)
    Group(GROUP_GREEN).rule2.radius = RandomBetween(10, 200)
    Group(GROUP_GREEN).rule3.attraction = RandomBetween(-100, 100)
    Group(GROUP_GREEN).rule3.radius = RandomBetween(10, 200)

    Group(GROUP_BLUE).clr = NP_Blue
    Group(GROUP_BLUE).rule1.attraction = RandomBetween(-100, 100)
    Group(GROUP_BLUE).rule1.radius = RandomBetween(10, 200)
    Group(GROUP_BLUE).rule2.attraction = RandomBetween(-100, 100)
    Group(GROUP_BLUE).rule2.radius = RandomBetween(10, 200)
    Group(GROUP_BLUE).rule3.attraction = RandomBetween(-100, 100)
    Group(GROUP_BLUE).rule3.radius = RandomBetween(10, 200)
End Sub


' Initializes all particles in the universe
Sub InitializeParticles
    Dim As Unsigned Long i

    ReDim GroupRed(1 To Universe.particles) As ParticleType
    ReDim GroupGreen(1 To Universe.particles) As ParticleType
    ReDim GroupBlue(1 To Universe.particles) As ParticleType

    For i = 1 To Universe.particles
        GroupRed(i).position.x = RandomBetween(50, Universe.size.x - 51)
        GroupRed(i).position.y = RandomBetween(50, Universe.size.y - 51)
    Next

    For i = 1 To Universe.particles
        GroupGreen(i).position.x = RandomBetween(50, Universe.size.x - 51)
        GroupGreen(i).position.y = RandomBetween(50, Universe.size.y - 51)
    Next

    For i = 1 To Universe.particles
        GroupBlue(i).position.x = RandomBetween(50, Universe.size.x - 51)
        GroupBlue(i).position.y = RandomBetween(50, Universe.size.y - 51)
    Next
End Sub


' Interaction between 2 particle groups
' Grp1 is the group that will be modified by the interaction
' Grp2 is the interacting group (its value won't be modified)
Sub ApplyRule (grp1() As ParticleType, grp2() As ParticleType, rule As RuleType)
    Dim As Single g, dx, dy, r, fx, fy, f
    Dim As Unsigned Long i, j

    g = rule.attraction / -100

    For i = 1 To Universe.particles
        fx = 0
        fy = 0
        For j = 1 To Universe.particles
            ' Calculate the distance between points using Pythagorean theorem
            dx = grp1(i).position.x - grp2(j).position.x
            dy = grp1(i).position.y - grp2(j).position.y
            r = Sqr(dx * dx + dy * dy)

            ' Calculate the force in given bounds
            If r > 0 And r < rule.radius Then
                f = g / r
                fx = fx + dx * f
                fy = fy + dy * f
            End If
        Next

        ' Calculate new velocity
        grp1(i).velocity.x = (grp1(i).velocity.x + fx) * 0.5
        grp1(i).velocity.y = (grp1(i).velocity.y + fy) * 0.5

        ' Update position based on velocity
        grp1(i).position.x = grp1(i).position.x + grp1(i).velocity.x
        grp1(i).position.y = grp1(i).position.y + grp1(i).velocity.y

        ' Check for screen bounds
        If grp1(i).position.x < 0 Or grp1(i).position.x >= Universe.size.x Then grp1(i).velocity.x = grp1(i).velocity.x * -1
        If grp1(i).position.y < 0 Or grp1(i).position.y >= Universe.size.y Then grp1(i).velocity.y = grp1(i).velocity.y * -1
    Next
End Sub


' This will make everything go
Sub RunUniverse
    ApplyRule GroupRed(), GroupRed(), Group(GROUP_RED).rule1
    ApplyRule GroupRed(), GroupGreen(), Group(GROUP_RED).rule2
    ApplyRule GroupRed(), GroupBlue(), Group(GROUP_RED).rule3

    ApplyRule GroupGreen(), GroupGreen(), Group(GROUP_GREEN).rule1
    ApplyRule GroupGreen(), GroupRed(), Group(GROUP_GREEN).rule2
    ApplyRule GroupGreen(), GroupBlue(), Group(GROUP_GREEN).rule3

    ApplyRule GroupBlue(), GroupBlue(), Group(GROUP_BLUE).rule1
    ApplyRule GroupBlue(), GroupRed(), Group(GROUP_BLUE).rule2
    ApplyRule GroupBlue(), GroupGreen(), Group(GROUP_BLUE).rule3
End Sub


' Draws all particles in a group
Sub DrawGroup (grp() As ParticleType, gId As Unsigned Long)
    Dim As Unsigned Long i

    Color Group(gId).clr
    For i = 1 To Universe.particles
        CircleFill grp(i).position.x, grp(i).position.y, Universe.particleSize
    Next
End Sub


' Draws all particles in the universe
Sub DrawUniverse
    DrawGroup GroupRed(), GROUP_RED
    DrawGroup GroupGreen(), GROUP_GREEN
    DrawGroup GroupBlue(), GROUP_BLUE
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

