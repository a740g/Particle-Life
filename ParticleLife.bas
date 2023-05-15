'---------------------------------------------------------------------------------------------------------
' Particle Life for QB64-PE
' Copyright (c) 2023 Samuel Gomes
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' HEADER FILES
'---------------------------------------------------------------------------------------------------------
'$Include:'include/IMGUI.bi'
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' METACOMMANDS
'---------------------------------------------------------------------------------------------------------
$ExeIcon:'./ParticleLife.ico'
$VersionInfo:ProductName=Particle Life
$VersionInfo:CompanyName=Samuel Gomes
$VersionInfo:LegalCopyright=Copyright (c) 2023 Samuel Gomes
$VersionInfo:LegalTrademarks=All trademarks are property of their respective owners
$VersionInfo:Web=https://github.com/a740g
$VersionInfo:Comments=https://github.com/a740g
$VersionInfo:InternalName=ParticleLife
$VersionInfo:OriginalFilename=ParticleLife.exe
$VersionInfo:FileDescription=Particle Life executable
$VersionInfo:FILEVERSION#=1,0,1,0
$VersionInfo:PRODUCTVERSION#=1,0,1,0
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' UI AUTO-GENERATION CODE (https://www.onlinegdb.com/online_c++_compiler)
'---------------------------------------------------------------------------------------------------------
'#include <iostream>

'int main()
'{
'    struct group {
'        char* name;
'        char in;
'        int id;
'    } grp[3] = {{"Red", 'R', 1}, {"Green", 'G', 2}, {"Blue", 'B', 3}};

'    for (int i = 0; i < 3; i++) {
'        for (int j = 0; j < 3; j++) {
'            //printf("cmd%c%c_ADec As Long\n", grp[i].in, grp[j].in);
'            //printf("txt%c%c_A As Long\n", grp[i].in, grp[j].in);
'            //printf("cmd%c%c_AInc As Long\n", grp[i].in, grp[j].in);
'            //printf("cmd%c%c_RDec As Long\n", grp[i].in, grp[j].in);
'            //printf("txt%c%c_R As Long\n", grp[i].in, grp[j].in);
'            //printf("cmd%c%c_RInc As Long\n", grp[i].in, grp[j].in);

'            //printf("y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE\n");
'            //printf("UI.cmd%c%c_ADec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)\n", grp[i].in, grp[j].in);
'            //printf("UI.txt%c%c_A = TextBoxNew(Str$(Group(GROUP_%s).rule%i.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)\n", grp[i].in, grp[j].in, grp[i].name, grp[j].id);
'            //printf("UI.cmd%c%c_AInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)\n", grp[i].in, grp[j].in);
'            //printf("y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE\n");
'            //printf("UI.cmd%c%c_RDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)\n", grp[i].in, grp[j].in);
'            //printf("UI.txt%c%c_R = TextBoxNew(Str$(Group(GROUP_%s).rule%i.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)\n", grp[i].in, grp[j].in, grp[i].name, grp[j].id);
'            //printf("UI.cmd%c%c_RInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)\n", grp[i].in, grp[j].in);

'            //printf("If WidgetClicked(UI.cmd%c%c_ADec) Then WidgetText UI.txt%c%c_A, Str$(Val(WidgetText$(UI.txt%c%c_A)) - 1): UI.changed = TRUE\n", grp[i].in, grp[j].in, grp[i].in, grp[j].in, grp[i].in, grp[j].in);
'            //printf("If WidgetClicked(UI.cmd%c%c_AInc) Then WidgetText UI.txt%c%c_A, Str$(Val(WidgetText$(UI.txt%c%c_A)) + 1): UI.changed = TRUE\n", grp[i].in, grp[j].in, grp[i].in, grp[j].in, grp[i].in, grp[j].in);
'            //printf("If TextBoxEntered(UI.txt%c%c_A) Then UI.changed = TRUE\n", grp[i].in, grp[j].in);
'            //printf("If WidgetClicked(UI.cmd%c%c_RDec) Then WidgetText UI.txt%c%c_R, Str$(Val(WidgetText$(UI.txt%c%c_R)) - 1): UI.changed = TRUE\n", grp[i].in, grp[j].in, grp[i].in, grp[j].in, grp[i].in, grp[j].in);
'            //printf("If WidgetClicked(UI.cmd%c%c_RInc) Then WidgetText UI.txt%c%c_R, Str$(Val(WidgetText$(UI.txt%c%c_R)) + 1): UI.changed = TRUE\n", grp[i].in, grp[j].in, grp[i].in, grp[j].in, grp[i].in, grp[j].in);
'            //printf("If TextBoxEntered(UI.txt%c%c_R) Then UI.changed = TRUE\n", grp[i].in, grp[j].in);

'            //printf("Group(GROUP_%s).rule%i.attract = ClampLong(Val(WidgetText(UI.txt%c%c_A)), ATTRACT_MIN, ATTRACT_MAX)\n", grp[i].name, grp[j].id, grp[i].in, grp[j].in);
'            //printf("WidgetText UI.txt%c%c_A, Str$(Group(GROUP_%s).rule%i.attract)\n", grp[i].in, grp[j].in, grp[i].name, grp[j].id);
'            //printf("Group(GROUP_%s).rule%i.radius = ClampLong(Val(WidgetText(UI.txt%c%c_R)), RADIUS_MIN, RADIUS_MAX)\n", grp[i].name, grp[j].id, grp[i].in, grp[j].in);
'            //printf("WidgetText UI.txt%c%c_R, Str$(Group(GROUP_%s).rule%i.radius)\n", grp[i].in, grp[j].in, grp[i].name, grp[j].id);

'            //printf("y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE\n");
'            //printf("DrawStringRightAligned \"Attract %c <-> %c:\", x, y\n", grp[i].in, grp[j].in);
'            //printf("y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE\n");
'            //printf("DrawStringRightAligned \"Radius %c <-> %c:\", x, y\n", grp[i].in, grp[j].in);
'        }
'    }

'    return 0;
'}
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' CONSTANTS
'---------------------------------------------------------------------------------------------------------
Const APP_NAME = "QB64-PE Particle Life"

Const GROUPS_MAX = 3 ' maximum number of groups in the universe
Const PARTICLES_PER_GROUP_DEFAULT = 200 ' this is the default numbers of particles we start in each group
Const PARTICLES_PER_GROUP_MAX = 999 ' maximum number of particles in a group
Const PARTICLE_SIZE_DEFAULT = 1 ' default radius of each particle
Const PARTICLE_SIZE_MAX = 8 ' maximum size of each particle
' Group IDs
Const GROUP_RED = 1
Const GROUP_GREEN = 2
Const GROUP_BLUE = 3
' Group properties limits
Const ATTRACT_MIN = -100
Const ATTRACT_MAX = 100
Const RADIUS_MIN = 0
Const RADIUS_MAX = 200
' Max frame rate that we can go to
Const FRAME_RATE_MAX = 120
' UI constants
Const UI_WIDGET_HEIGHT = 24 ' defaut widget height
Const UI_WIDGET_SPACE = 2 ' space between widgets
Const UI_PUSH_BUTTON_WIDTH_LARGE = 120
Const UI_PUSH_BUTTON_WIDTH_SMALL = 24
Const UI_TEXT_BOX_WIDTH = UI_PUSH_BUTTON_WIDTH_LARGE - (UI_PUSH_BUTTON_WIDTH_SMALL * 2) - (UI_WIDGET_SPACE * 2)
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' USER DEFINED TYPES
'---------------------------------------------------------------------------------------------------------
' This defines the universe
Type UniverseType
    size As Vector2DType ' this MUST be set by the user - typically window width & height
    particlesPerGroup As Unsigned Long ' this MUST be set by the user - typically from the UI
    particleSize As Unsigned Long ' this may be set by the user - typically from the UI
End Type

' This defines the rule type
Type RuleType
    attract As Long
    radius As Long
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
    hideLabels As Byte ' should lables be hidden?
    changed As Byte ' did anything significant in the UI change
    cmdShow As Long ' hide / show UI
    cmdExit As Long ' exit button
    cmdShowFPS As Long ' hide / show FPS
    cmdAbout As Long ' shows an about dialog
    cmdReset As Long ' reset particles without changing properties
    cmdRandom As Long ' random madness
    ' Controls the number of particles
    cmdParticlesDec As Long
    txtParticles As Long
    cmdParticlesInc As Long
    ' Cotnrols the particle size
    cmdParticleSizeDec As Long
    txtParticleSize As Long
    cmdParticleSizeInc As Long
    ' Various attraction & radius controls (auto-generated)
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
Dim r As Unsigned Long: r = ClampLong(Val(Command$), 1, 8) ' Check the user wants to use a lower resolution
Screen NewImage(DesktopWidth \ r, DesktopHeight \ r, 32)
FullScreen SquarePixels , Smooth
PrintMode KeepBackground
SRand Timer

' Setup universe
Universe.size.x = Width
Universe.size.y = Height
Universe.particlesPerGroup = PARTICLES_PER_GROUP_DEFAULT
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

    Dim As Long x, y

    ' Calculate UI start left
    x = Universe.size.x - UI_PUSH_BUTTON_WIDTH_LARGE - 1 - UI_WIDGET_SPACE
    y = UI_WIDGET_SPACE
    UI.cmdShow = PushButtonNew("Show Controls", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, TRUE)
    PushButtonDepressed UI.cmdShow, TRUE
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdExit = PushButtonNew("Exit", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdAbout = PushButtonNew("About...", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdShowFPS = PushButtonNew("Show FPS", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, TRUE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdReset = PushButtonNew("Reset", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRandom = PushButtonNew("Random", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdParticlesDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtParticles = TextBoxNew(Str$(Universe.particlesPerGroup), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdParticlesInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdParticleSizeDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtParticleSize = TextBoxNew(Str$(Universe.particleSize), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdParticleSizeInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    ' Auto-generated stuff
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRR_ADec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRR_A = TextBoxNew(Str$(Group(GROUP_RED).rule1.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdRR_AInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRR_RDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRR_R = TextBoxNew(Str$(Group(GROUP_RED).rule1.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdRR_RInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRG_ADec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRG_A = TextBoxNew(Str$(Group(GROUP_RED).rule2.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdRG_AInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRG_RDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRG_R = TextBoxNew(Str$(Group(GROUP_RED).rule2.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdRG_RInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRB_ADec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRB_A = TextBoxNew(Str$(Group(GROUP_RED).rule3.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdRB_AInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRB_RDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRB_R = TextBoxNew(Str$(Group(GROUP_RED).rule3.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdRB_RInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGR_ADec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGR_A = TextBoxNew(Str$(Group(GROUP_GREEN).rule1.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdGR_AInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGR_RDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGR_R = TextBoxNew(Str$(Group(GROUP_GREEN).rule1.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdGR_RInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGG_ADec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGG_A = TextBoxNew(Str$(Group(GROUP_GREEN).rule2.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdGG_AInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGG_RDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGG_R = TextBoxNew(Str$(Group(GROUP_GREEN).rule2.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdGG_RInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGB_ADec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGB_A = TextBoxNew(Str$(Group(GROUP_GREEN).rule3.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdGB_AInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGB_RDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGB_R = TextBoxNew(Str$(Group(GROUP_GREEN).rule3.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdGB_RInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBR_ADec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBR_A = TextBoxNew(Str$(Group(GROUP_BLUE).rule1.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdBR_AInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBR_RDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBR_R = TextBoxNew(Str$(Group(GROUP_BLUE).rule1.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdBR_RInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBG_ADec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBG_A = TextBoxNew(Str$(Group(GROUP_BLUE).rule2.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdBG_AInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBG_RDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBG_R = TextBoxNew(Str$(Group(GROUP_BLUE).rule2.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdBG_RInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBB_ADec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBB_A = TextBoxNew(Str$(Group(GROUP_BLUE).rule3.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdBB_AInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBB_RDec = PushButtonNew(Chr$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBB_R = TextBoxNew(Str$(Group(GROUP_BLUE).rule3.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC Or TEXT_BOX_DASH Or TEXT_BOX_DOT)
    UI.cmdBB_RInc = PushButtonNew(Chr$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
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

    ' Check if user clicked the reset button
    If WidgetClicked(UI.cmdReset) Then
        ' Then just reset the particles using the same parameters
        InitializeParticles
    End If

    ' Check if user clicked the random button
    If WidgetClicked(UI.cmdRandom) Then
        InitializeGroups
        InitializeParticles

        ' Auto-generated
        WidgetText UI.txtRR_A, Str$(Group(GROUP_RED).rule1.attract)
        WidgetText UI.txtRR_R, Str$(Group(GROUP_RED).rule1.radius)
        WidgetText UI.txtRG_A, Str$(Group(GROUP_RED).rule2.attract)
        WidgetText UI.txtRG_R, Str$(Group(GROUP_RED).rule2.radius)
        WidgetText UI.txtRB_A, Str$(Group(GROUP_RED).rule3.attract)
        WidgetText UI.txtRB_R, Str$(Group(GROUP_RED).rule3.radius)
        WidgetText UI.txtGR_A, Str$(Group(GROUP_GREEN).rule1.attract)
        WidgetText UI.txtGR_R, Str$(Group(GROUP_GREEN).rule1.radius)
        WidgetText UI.txtGG_A, Str$(Group(GROUP_GREEN).rule2.attract)
        WidgetText UI.txtGG_R, Str$(Group(GROUP_GREEN).rule2.radius)
        WidgetText UI.txtGB_A, Str$(Group(GROUP_GREEN).rule3.attract)
        WidgetText UI.txtGB_R, Str$(Group(GROUP_GREEN).rule3.radius)
        WidgetText UI.txtBR_A, Str$(Group(GROUP_BLUE).rule1.attract)
        WidgetText UI.txtBR_R, Str$(Group(GROUP_BLUE).rule1.radius)
        WidgetText UI.txtBG_A, Str$(Group(GROUP_BLUE).rule2.attract)
        WidgetText UI.txtBG_R, Str$(Group(GROUP_BLUE).rule2.radius)
        WidgetText UI.txtBB_A, Str$(Group(GROUP_BLUE).rule3.attract)
        WidgetText UI.txtBB_R, Str$(Group(GROUP_BLUE).rule3.radius)
    End If

    ' Check if the about button was clicked
    If WidgetClicked(UI.cmdAbout) Then
        $If VERSION > 3.3 Then
            MessageBox "About", APP_NAME + String$(2, KEY_ENTER) + "Copyright (c) 2023 Samuel Gomes" + String$(2, KEY_ENTER) + "This was written in QB64-PE and the source code is avilable at https://github.com/a740g/Particle-Life"
        $End If
    End If

    ' Check if the show button was pressed
    If WidgetClicked(UI.cmdShow) Then
        ' If so, then change the UI visibility based on the show button's state
        WidgetVisibleAll PushButtonDepressed(UI.cmdShow)
        UI.hideLabels = Not PushButtonDepressed(UI.cmdShow)
        ' However, leave the show button to be always visible
        WidgetVisible UI.cmdShow, TRUE
    End If

    ' Check if any rule values have changed (auto-generated)
    If WidgetClicked(UI.cmdRR_ADec) Then WidgetText UI.txtRR_A, Str$(Val(WidgetText$(UI.txtRR_A)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdRR_AInc) Then WidgetText UI.txtRR_A, Str$(Val(WidgetText$(UI.txtRR_A)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtRR_A) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdRR_RDec) Then WidgetText UI.txtRR_R, Str$(Val(WidgetText$(UI.txtRR_R)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdRR_RInc) Then WidgetText UI.txtRR_R, Str$(Val(WidgetText$(UI.txtRR_R)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtRR_R) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdRG_ADec) Then WidgetText UI.txtRG_A, Str$(Val(WidgetText$(UI.txtRG_A)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdRG_AInc) Then WidgetText UI.txtRG_A, Str$(Val(WidgetText$(UI.txtRG_A)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtRG_A) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdRG_RDec) Then WidgetText UI.txtRG_R, Str$(Val(WidgetText$(UI.txtRG_R)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdRG_RInc) Then WidgetText UI.txtRG_R, Str$(Val(WidgetText$(UI.txtRG_R)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtRG_R) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdRB_ADec) Then WidgetText UI.txtRB_A, Str$(Val(WidgetText$(UI.txtRB_A)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdRB_AInc) Then WidgetText UI.txtRB_A, Str$(Val(WidgetText$(UI.txtRB_A)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtRB_A) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdRB_RDec) Then WidgetText UI.txtRB_R, Str$(Val(WidgetText$(UI.txtRB_R)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdRB_RInc) Then WidgetText UI.txtRB_R, Str$(Val(WidgetText$(UI.txtRB_R)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtRB_R) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdGR_ADec) Then WidgetText UI.txtGR_A, Str$(Val(WidgetText$(UI.txtGR_A)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdGR_AInc) Then WidgetText UI.txtGR_A, Str$(Val(WidgetText$(UI.txtGR_A)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtGR_A) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdGR_RDec) Then WidgetText UI.txtGR_R, Str$(Val(WidgetText$(UI.txtGR_R)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdGR_RInc) Then WidgetText UI.txtGR_R, Str$(Val(WidgetText$(UI.txtGR_R)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtGR_R) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdGG_ADec) Then WidgetText UI.txtGG_A, Str$(Val(WidgetText$(UI.txtGG_A)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdGG_AInc) Then WidgetText UI.txtGG_A, Str$(Val(WidgetText$(UI.txtGG_A)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtGG_A) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdGG_RDec) Then WidgetText UI.txtGG_R, Str$(Val(WidgetText$(UI.txtGG_R)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdGG_RInc) Then WidgetText UI.txtGG_R, Str$(Val(WidgetText$(UI.txtGG_R)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtGG_R) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdGB_ADec) Then WidgetText UI.txtGB_A, Str$(Val(WidgetText$(UI.txtGB_A)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdGB_AInc) Then WidgetText UI.txtGB_A, Str$(Val(WidgetText$(UI.txtGB_A)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtGB_A) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdGB_RDec) Then WidgetText UI.txtGB_R, Str$(Val(WidgetText$(UI.txtGB_R)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdGB_RInc) Then WidgetText UI.txtGB_R, Str$(Val(WidgetText$(UI.txtGB_R)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtGB_R) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdBR_ADec) Then WidgetText UI.txtBR_A, Str$(Val(WidgetText$(UI.txtBR_A)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdBR_AInc) Then WidgetText UI.txtBR_A, Str$(Val(WidgetText$(UI.txtBR_A)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtBR_A) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdBR_RDec) Then WidgetText UI.txtBR_R, Str$(Val(WidgetText$(UI.txtBR_R)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdBR_RInc) Then WidgetText UI.txtBR_R, Str$(Val(WidgetText$(UI.txtBR_R)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtBR_R) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdBG_ADec) Then WidgetText UI.txtBG_A, Str$(Val(WidgetText$(UI.txtBG_A)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdBG_AInc) Then WidgetText UI.txtBG_A, Str$(Val(WidgetText$(UI.txtBG_A)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtBG_A) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdBG_RDec) Then WidgetText UI.txtBG_R, Str$(Val(WidgetText$(UI.txtBG_R)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdBG_RInc) Then WidgetText UI.txtBG_R, Str$(Val(WidgetText$(UI.txtBG_R)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtBG_R) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdBB_ADec) Then WidgetText UI.txtBB_A, Str$(Val(WidgetText$(UI.txtBB_A)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdBB_AInc) Then WidgetText UI.txtBB_A, Str$(Val(WidgetText$(UI.txtBB_A)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtBB_A) Then UI.changed = TRUE
    If WidgetClicked(UI.cmdBB_RDec) Then WidgetText UI.txtBB_R, Str$(Val(WidgetText$(UI.txtBB_R)) - 1): UI.changed = TRUE
    If WidgetClicked(UI.cmdBB_RInc) Then WidgetText UI.txtBB_R, Str$(Val(WidgetText$(UI.txtBB_R)) + 1): UI.changed = TRUE
    If TextBoxEntered(UI.txtBB_R) Then UI.changed = TRUE

    If UI.changed Then
        Universe.particleSize = ClampLong(Universe.particleSize, 0, PARTICLE_SIZE_MAX)
        WidgetText UI.txtParticleSize, Str$(Universe.particleSize)

        If Universe.particlesPerGroup <> Val(WidgetText$(UI.txtParticles)) Then
            Universe.particlesPerGroup = ClampLong(Val(WidgetText$(UI.txtParticles)), 1, PARTICLES_PER_GROUP_MAX)
            WidgetText UI.txtParticles, Str$(Universe.particlesPerGroup)
            InitializeParticles
        End If

        ' Update rule values (auto-generated)
        Group(GROUP_RED).rule1.attract = ClampLong(Val(WidgetText(UI.txtRR_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtRR_A, Str$(Group(GROUP_RED).rule1.attract)
        Group(GROUP_RED).rule1.radius = ClampLong(Val(WidgetText(UI.txtRR_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtRR_R, Str$(Group(GROUP_RED).rule1.radius)
        Group(GROUP_RED).rule2.attract = ClampLong(Val(WidgetText(UI.txtRG_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtRG_A, Str$(Group(GROUP_RED).rule2.attract)
        Group(GROUP_RED).rule2.radius = ClampLong(Val(WidgetText(UI.txtRG_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtRG_R, Str$(Group(GROUP_RED).rule2.radius)
        Group(GROUP_RED).rule3.attract = ClampLong(Val(WidgetText(UI.txtRB_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtRB_A, Str$(Group(GROUP_RED).rule3.attract)
        Group(GROUP_RED).rule3.radius = ClampLong(Val(WidgetText(UI.txtRB_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtRB_R, Str$(Group(GROUP_RED).rule3.radius)
        Group(GROUP_GREEN).rule1.attract = ClampLong(Val(WidgetText(UI.txtGR_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtGR_A, Str$(Group(GROUP_GREEN).rule1.attract)
        Group(GROUP_GREEN).rule1.radius = ClampLong(Val(WidgetText(UI.txtGR_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtGR_R, Str$(Group(GROUP_GREEN).rule1.radius)
        Group(GROUP_GREEN).rule2.attract = ClampLong(Val(WidgetText(UI.txtGG_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtGG_A, Str$(Group(GROUP_GREEN).rule2.attract)
        Group(GROUP_GREEN).rule2.radius = ClampLong(Val(WidgetText(UI.txtGG_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtGG_R, Str$(Group(GROUP_GREEN).rule2.radius)
        Group(GROUP_GREEN).rule3.attract = ClampLong(Val(WidgetText(UI.txtGB_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtGB_A, Str$(Group(GROUP_GREEN).rule3.attract)
        Group(GROUP_GREEN).rule3.radius = ClampLong(Val(WidgetText(UI.txtGB_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtGB_R, Str$(Group(GROUP_GREEN).rule3.radius)
        Group(GROUP_BLUE).rule1.attract = ClampLong(Val(WidgetText(UI.txtBR_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtBR_A, Str$(Group(GROUP_BLUE).rule1.attract)
        Group(GROUP_BLUE).rule1.radius = ClampLong(Val(WidgetText(UI.txtBR_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtBR_R, Str$(Group(GROUP_BLUE).rule1.radius)
        Group(GROUP_BLUE).rule2.attract = ClampLong(Val(WidgetText(UI.txtBG_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtBG_A, Str$(Group(GROUP_BLUE).rule2.attract)
        Group(GROUP_BLUE).rule2.radius = ClampLong(Val(WidgetText(UI.txtBG_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtBG_R, Str$(Group(GROUP_BLUE).rule2.radius)
        Group(GROUP_BLUE).rule3.attract = ClampLong(Val(WidgetText(UI.txtBB_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtBB_A, Str$(Group(GROUP_BLUE).rule3.attract)
        Group(GROUP_BLUE).rule3.radius = ClampLong(Val(WidgetText(UI.txtBB_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtBB_R, Str$(Group(GROUP_BLUE).rule3.radius)

        UI.changed = FALSE
    End If
End Sub


Sub DrawStringRightAligned (text As String, x As Long, y As Long)
    PrintString (x - Len(text) * FontWidth, y), text
End Sub


' This draws the static texts next to the UI buttons to show what they do
Sub DrawLabels
    If Not UI.hideLabels Then
        Color Gray

        Dim As Long x, y

        x = Universe.size.x - UI_PUSH_BUTTON_WIDTH_LARGE - 1 - UI_WIDGET_SPACE - FontWidth
        y = (UI_WIDGET_HEIGHT + UI_WIDGET_SPACE) * 6 + (UI_WIDGET_HEIGHT + UI_WIDGET_SPACE) \ 2 - FontHeight \ 2
        DrawStringRightAligned "Particles / Group:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Particle size:", x, y

        ' Auto-generated
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Attract R <-> R:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Radius R <-> R:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Attract R <-> G:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Radius R <-> G:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Attract R <-> B:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Radius R <-> B:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Attract G <-> R:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Radius G <-> R:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Attract G <-> G:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Radius G <-> G:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Attract G <-> B:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Radius G <-> B:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Attract B <-> R:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Radius B <-> R:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Attract B <-> G:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Radius B <-> G:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Attract B <-> B:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Radius B <-> B:", x, y
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
    Group(GROUP_RED).rule1.attract = RandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_RED).rule1.radius = RandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_RED).rule2.attract = RandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_RED).rule2.radius = RandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_RED).rule3.attract = RandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_RED).rule3.radius = RandomBetween(RADIUS_MIN, RADIUS_MAX)

    Group(GROUP_GREEN).clr = NP_Green
    Group(GROUP_GREEN).rule1.attract = RandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_GREEN).rule1.radius = RandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_GREEN).rule2.attract = RandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_GREEN).rule2.radius = RandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_GREEN).rule3.attract = RandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_GREEN).rule3.radius = RandomBetween(RADIUS_MIN, RADIUS_MAX)

    Group(GROUP_BLUE).clr = NP_Blue
    Group(GROUP_BLUE).rule1.attract = RandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_BLUE).rule1.radius = RandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_BLUE).rule2.attract = RandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_BLUE).rule2.radius = RandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_BLUE).rule3.attract = RandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_BLUE).rule3.radius = RandomBetween(RADIUS_MIN, RADIUS_MAX)
End Sub


' Initializes all particles in the universe
Sub InitializeParticles
    Dim As Unsigned Long i

    ReDim GroupRed(1 To Universe.particlesPerGroup) As ParticleType
    ReDim GroupGreen(1 To Universe.particlesPerGroup) As ParticleType
    ReDim GroupBlue(1 To Universe.particlesPerGroup) As ParticleType

    For i = 1 To Universe.particlesPerGroup
        GroupRed(i).position.x = RandomBetween(50, Universe.size.x - 51)
        GroupRed(i).position.y = RandomBetween(50, Universe.size.y - 51)
    Next

    For i = 1 To Universe.particlesPerGroup
        GroupGreen(i).position.x = RandomBetween(50, Universe.size.x - 51)
        GroupGreen(i).position.y = RandomBetween(50, Universe.size.y - 51)
    Next

    For i = 1 To Universe.particlesPerGroup
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

    g = rule.attract / ATTRACT_MIN

    For i = 1 To Universe.particlesPerGroup
        fx = 0
        fy = 0
        For j = 1 To Universe.particlesPerGroup
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

    ApplyRule GroupGreen(), GroupRed(), Group(GROUP_GREEN).rule1
    ApplyRule GroupGreen(), GroupGreen(), Group(GROUP_GREEN).rule2
    ApplyRule GroupGreen(), GroupBlue(), Group(GROUP_GREEN).rule3

    ApplyRule GroupBlue(), GroupRed(), Group(GROUP_BLUE).rule1
    ApplyRule GroupBlue(), GroupGreen(), Group(GROUP_BLUE).rule2
    ApplyRule GroupBlue(), GroupBlue(), Group(GROUP_BLUE).rule3
End Sub


' Draws all particles in a group
Sub DrawGroup (grp() As ParticleType, gId As Unsigned Long)
    Dim As Unsigned Long i

    Color Group(gId).clr
    For i = 1 To Universe.particlesPerGroup
        CircleFill grp(i).position.x, grp(i).position.y, Universe.particleSize
    Next
End Sub


' Draws all particles in the universe
Sub DrawUniverse
    ' We give every group a fair chance to be on top XD
    Select Case RandomBetween(1, 6)
        Case 6
            DrawGroup GroupBlue(), GROUP_BLUE
            DrawGroup GroupGreen(), GROUP_GREEN
            DrawGroup GroupRed(), GROUP_RED
        Case 5
            DrawGroup GroupBlue(), GROUP_BLUE
            DrawGroup GroupRed(), GROUP_RED
            DrawGroup GroupGreen(), GROUP_GREEN
        Case 4
            DrawGroup GroupGreen(), GROUP_GREEN
            DrawGroup GroupBlue(), GROUP_BLUE
            DrawGroup GroupRed(), GROUP_RED
        Case 3
            DrawGroup GroupGreen(), GROUP_GREEN
            DrawGroup GroupRed(), GROUP_RED
            DrawGroup GroupBlue(), GROUP_BLUE
        Case 2
            DrawGroup GroupRed(), GROUP_RED
            DrawGroup GroupBlue(), GROUP_BLUE
            DrawGroup GroupGreen(), GROUP_GREEN
        Case Else
            DrawGroup GroupRed(), GROUP_RED
            DrawGroup GroupGreen(), GROUP_GREEN
            DrawGroup GroupBlue(), GROUP_BLUE
    End Select
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
'$Include:'include/IMGUI.bas'
'---------------------------------------------------------------------------------------------------------

