'---------------------------------------------------------------------------------------------------------
' Particle Life for QB64-PE
' Copyright (c) 2024 Samuel Gomes
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' HEADER FILES
'---------------------------------------------------------------------------------------------------------
'$INCLUDE:'include/Math/Math.bi'
'$INCLUDE:'include/ImGUI.bi'
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' METACOMMANDS
'---------------------------------------------------------------------------------------------------------
$RESIZE:SMOOTH
$EXEICON:'./ParticleLife.ico'
$VERSIONINFO:ProductName='Particle Life'
$VERSIONINFO:CompanyName='Samuel Gomes'
$VERSIONINFO:LegalCopyright='Copyright (c) 2024 Samuel Gomes'
$VERSIONINFO:LegalTrademarks='All trademarks are property of their respective owners'
$VERSIONINFO:Web='https://github.com/a740g'
$VERSIONINFO:Comments='https://github.com/a740g'
$VERSIONINFO:InternalName='ParticleLife'
$VERSIONINFO:OriginalFilename='ParticleLife.exe'
$VERSIONINFO:FileDescription='Particle Life executable'
$VERSIONINFO:FILEVERSION#=1,0,4,0
$VERSIONINFO:PRODUCTVERSION#=1,0,4,0
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

'            //printf("Group(GROUP_%s).rule%i.attract = Math_ClampLong(Val(WidgetText(UI.txt%c%c_A)), ATTRACT_MIN, ATTRACT_MAX)\n", grp[i].name, grp[j].id, grp[i].in, grp[j].in);
'            //printf("WidgetText UI.txt%c%c_A, Str$(Group(GROUP_%s).rule%i.attract)\n", grp[i].in, grp[j].in, grp[i].name, grp[j].id);
'            //printf("Group(GROUP_%s).rule%i.radius = Math_ClampLong(Val(WidgetText(UI.txt%c%c_R)), RADIUS_MIN, RADIUS_MAX)\n", grp[i].name, grp[j].id, grp[i].in, grp[j].in);
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
CONST APP_NAME = "QB64-PE Particle Life"

CONST GROUPS_MAX = 3 ' maximum number of groups in the universe
CONST PARTICLES_PER_GROUP_DEFAULT = 200 ' this is the default numbers of particles we start in each group
CONST PARTICLES_PER_GROUP_MAX = 999 ' maximum number of particles in a group
CONST PARTICLE_SIZE_DEFAULT = 1 ' default radius of each particle
CONST PARTICLE_SIZE_MAX = 8 ' maximum size of each particle
' Group IDs
CONST GROUP_RED = 1
CONST GROUP_GREEN = 2
CONST GROUP_BLUE = 3
' Group properties limits
CONST ATTRACT_MIN = -100
CONST ATTRACT_MAX = 100
CONST RADIUS_MIN = 0
CONST RADIUS_MAX = 200
' Max frame rate that we can go to
CONST FRAME_RATE_MAX = 120
' UI constants
CONST UI_WIDGET_HEIGHT = 24 ' defaut widget height
CONST UI_WIDGET_SPACE = 2 ' space between widgets
CONST UI_PUSH_BUTTON_WIDTH_LARGE = 120
CONST UI_PUSH_BUTTON_WIDTH_SMALL = 24
CONST UI_TEXT_BOX_WIDTH = UI_PUSH_BUTTON_WIDTH_LARGE - (UI_PUSH_BUTTON_WIDTH_SMALL * 2) - (UI_WIDGET_SPACE * 2)
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' USER DEFINED TYPES
'---------------------------------------------------------------------------------------------------------
' This defines the universe
TYPE UniverseType
    size AS Vector2FType ' this MUST be set by the user - typically window width & height
    particlesPerGroup AS _UNSIGNED LONG ' this MUST be set by the user - typically from the UI
    particleSize AS _UNSIGNED LONG ' this may be set by the user - typically from the UI
END TYPE

' This defines the rule type
TYPE RuleType
    attract AS LONG
    radius AS LONG
END TYPE

' This defines the group
TYPE GroupType
    clr AS _UNSIGNED LONG ' managed by InitializeGroupTable()
    rule1 AS RuleType ' self
    rule2 AS RuleType ' other
    rule3 AS RuleType ' other
END TYPE

' This defines the particle
TYPE ParticleType
    position AS Vector2FType ' managed by InitializeGroup() & RunUniverse()
    velocity AS Vector2FType ' managed by RunUniverse()
END TYPE

TYPE UIType ' bunch of UI widgets to change stuff
    hideLabels AS _BYTE ' should lables be hidden?
    changed AS _BYTE ' did anything significant in the UI change
    cmdShow AS LONG ' hide / show UI
    cmdExit AS LONG ' exit button
    cmdShowFPS AS LONG ' hide / show FPS
    cmdAbout AS LONG ' shows an about dialog
    cmdReset AS LONG ' reset particles without changing properties
    cmdRandom AS LONG ' random madness
    ' Controls the number of particles
    cmdParticlesDec AS LONG
    txtParticles AS LONG
    cmdParticlesInc AS LONG
    ' Cotnrols the particle size
    cmdParticleSizeDec AS LONG
    txtParticleSize AS LONG
    cmdParticleSizeInc AS LONG
    ' Various attraction & radius controls (auto-generated)
    cmdRR_ADec AS LONG
    txtRR_A AS LONG
    cmdRR_AInc AS LONG
    cmdRR_RDec AS LONG
    txtRR_R AS LONG
    cmdRR_RInc AS LONG
    cmdRG_ADec AS LONG
    txtRG_A AS LONG
    cmdRG_AInc AS LONG
    cmdRG_RDec AS LONG
    txtRG_R AS LONG
    cmdRG_RInc AS LONG
    cmdRB_ADec AS LONG
    txtRB_A AS LONG
    cmdRB_AInc AS LONG
    cmdRB_RDec AS LONG
    txtRB_R AS LONG
    cmdRB_RInc AS LONG
    cmdGR_ADec AS LONG
    txtGR_A AS LONG
    cmdGR_AInc AS LONG
    cmdGR_RDec AS LONG
    txtGR_R AS LONG
    cmdGR_RInc AS LONG
    cmdGG_ADec AS LONG
    txtGG_A AS LONG
    cmdGG_AInc AS LONG
    cmdGG_RDec AS LONG
    txtGG_R AS LONG
    cmdGG_RInc AS LONG
    cmdGB_ADec AS LONG
    txtGB_A AS LONG
    cmdGB_AInc AS LONG
    cmdGB_RDec AS LONG
    txtGB_R AS LONG
    cmdGB_RInc AS LONG
    cmdBR_ADec AS LONG
    txtBR_A AS LONG
    cmdBR_AInc AS LONG
    cmdBR_RDec AS LONG
    txtBR_R AS LONG
    cmdBR_RInc AS LONG
    cmdBG_ADec AS LONG
    txtBG_A AS LONG
    cmdBG_AInc AS LONG
    cmdBG_RDec AS LONG
    txtBG_R AS LONG
    cmdBG_RInc AS LONG
    cmdBB_ADec AS LONG
    txtBB_A AS LONG
    cmdBB_AInc AS LONG
    cmdBB_RDec AS LONG
    txtBB_R AS LONG
    cmdBB_RInc AS LONG
END TYPE
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' GLOBAL VARIABLES
'---------------------------------------------------------------------------------------------------------
DIM SHARED UI AS UIType ' user interface controls
DIM SHARED Universe AS UniverseType ' Universe
DIM SHARED Group(1 TO GROUPS_MAX) AS GroupType ' Group
REDIM SHARED GroupRed(1 TO 1) AS ParticleType ' Red particles
REDIM SHARED GroupGreen(1 TO 1) AS ParticleType ' Green particles
REDIM SHARED GroupBlue(1 TO 1) AS ParticleType ' Blue particles
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' PROGRAM ENTRY POINT
'---------------------------------------------------------------------------------------------------------
DIM r AS _UNSIGNED LONG: r = Math_ClampLong(VAL(COMMAND$), 1, 8) ' Check the user wants to use a lower resolution
SCREEN _NEWIMAGE(_DESKTOPWIDTH \ r, _DESKTOPHEIGHT \ r, 32)
_FULLSCREEN _SQUAREPIXELS , _SMOOTH
_PRINTMODE _KEEPBACKGROUND
Math_SetRandomSeed TIMER

' Setup universe
Universe.size.x = _WIDTH
Universe.size.y = _HEIGHT
Universe.particlesPerGroup = PARTICLES_PER_GROUP_DEFAULT
Universe.particleSize = PARTICLE_SIZE_DEFAULT

InitializeGroups ' setup the groups
InitializeParticles ' setup particles
InitializeUI ' initialize the UI

' Main loop
DO
    RunUniverse ' make the universe go

    COLOR BGRA_WHITE, BGRA_BLACK ' this is required since the UI code can change the colors
    CLS ' clear the framebuffer

    ' From here on everything is drawn in z order
    DrawUniverse ' draw the universe
    DrawFPS ' draw the FPS
    WidgetUpdate ' update the widget system
    DrawLabels ' draw the static text labels
    UpdateUI ' update and validate UI user values

    _DISPLAY ' flip the framebuffer

    _LIMIT FRAME_RATE_MAX ' let's not get out of control
LOOP UNTIL InputManager.keyCode = KEY_ESCAPE OR WidgetClicked(UI.cmdExit)

WidgetFreeAll

SYSTEM
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' FUNCTIONS AND SUBROUTINES
'---------------------------------------------------------------------------------------------------------
' This initializes all the static UI that will always be there
' Also call the dynamic UI function
SUB InitializeUI
    UI.changed = TRUE

    DIM AS LONG x, y

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
    UI.cmdParticlesDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtParticles = TextBoxNew(STR$(Universe.particlesPerGroup), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdParticlesInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdParticleSizeDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtParticleSize = TextBoxNew(STR$(Universe.particleSize), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdParticleSizeInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    ' Auto-generated stuff
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRR_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRR_A = TextBoxNew(STR$(Group(GROUP_RED).rule1.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRR_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRR_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRR_R = TextBoxNew(STR$(Group(GROUP_RED).rule1.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRR_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRG_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRG_A = TextBoxNew(STR$(Group(GROUP_RED).rule2.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRG_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRG_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRG_R = TextBoxNew(STR$(Group(GROUP_RED).rule2.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRG_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRB_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRB_A = TextBoxNew(STR$(Group(GROUP_RED).rule3.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRB_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRB_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtRB_R = TextBoxNew(STR$(Group(GROUP_RED).rule3.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRB_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGR_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGR_A = TextBoxNew(STR$(Group(GROUP_GREEN).rule1.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGR_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGR_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGR_R = TextBoxNew(STR$(Group(GROUP_GREEN).rule1.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGR_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGG_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGG_A = TextBoxNew(STR$(Group(GROUP_GREEN).rule2.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGG_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGG_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGG_R = TextBoxNew(STR$(Group(GROUP_GREEN).rule2.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGG_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGB_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGB_A = TextBoxNew(STR$(Group(GROUP_GREEN).rule3.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGB_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGB_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtGB_R = TextBoxNew(STR$(Group(GROUP_GREEN).rule3.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGB_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBR_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBR_A = TextBoxNew(STR$(Group(GROUP_BLUE).rule1.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdBR_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBR_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBR_R = TextBoxNew(STR$(Group(GROUP_BLUE).rule1.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdBR_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBG_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBG_A = TextBoxNew(STR$(Group(GROUP_BLUE).rule2.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdBG_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBG_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBG_R = TextBoxNew(STR$(Group(GROUP_BLUE).rule2.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdBG_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBB_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBB_A = TextBoxNew(STR$(Group(GROUP_BLUE).rule3.attract), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdBB_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdBB_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
    UI.txtBB_R = TextBoxNew(STR$(Group(GROUP_BLUE).rule3.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdBB_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, FALSE)
END SUB


' Updates and validate UI values whenever something changes
SUB UpdateUI
    ' Check if user wants to change the size
    IF WidgetClicked(UI.cmdParticleSizeDec) THEN Universe.particleSize = Universe.particleSize - 1: UI.changed = TRUE
    IF WidgetClicked(UI.cmdParticleSizeInc) THEN Universe.particleSize = Universe.particleSize + 1: UI.changed = TRUE
    IF TextBoxEntered(UI.txtParticleSize) THEN Universe.particleSize = VAL(WidgetText(UI.txtParticleSize)): UI.changed = TRUE

    ' Check if user wants to change the number of particles
    IF WidgetClicked(UI.cmdParticlesDec) THEN WidgetText UI.txtParticles, STR$(VAL(WidgetText$(UI.txtParticles)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdParticlesInc) THEN WidgetText UI.txtParticles, STR$(VAL(WidgetText$(UI.txtParticles)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtParticles) THEN UI.changed = TRUE

    ' Check if user clicked the reset button
    IF WidgetClicked(UI.cmdReset) THEN
        ' Then just reset the particles using the same parameters
        InitializeParticles
    END IF

    ' Check if user clicked the random button
    IF WidgetClicked(UI.cmdRandom) THEN
        InitializeGroups
        InitializeParticles

        ' Auto-generated
        WidgetText UI.txtRR_A, STR$(Group(GROUP_RED).rule1.attract)
        WidgetText UI.txtRR_R, STR$(Group(GROUP_RED).rule1.radius)
        WidgetText UI.txtRG_A, STR$(Group(GROUP_RED).rule2.attract)
        WidgetText UI.txtRG_R, STR$(Group(GROUP_RED).rule2.radius)
        WidgetText UI.txtRB_A, STR$(Group(GROUP_RED).rule3.attract)
        WidgetText UI.txtRB_R, STR$(Group(GROUP_RED).rule3.radius)
        WidgetText UI.txtGR_A, STR$(Group(GROUP_GREEN).rule1.attract)
        WidgetText UI.txtGR_R, STR$(Group(GROUP_GREEN).rule1.radius)
        WidgetText UI.txtGG_A, STR$(Group(GROUP_GREEN).rule2.attract)
        WidgetText UI.txtGG_R, STR$(Group(GROUP_GREEN).rule2.radius)
        WidgetText UI.txtGB_A, STR$(Group(GROUP_GREEN).rule3.attract)
        WidgetText UI.txtGB_R, STR$(Group(GROUP_GREEN).rule3.radius)
        WidgetText UI.txtBR_A, STR$(Group(GROUP_BLUE).rule1.attract)
        WidgetText UI.txtBR_R, STR$(Group(GROUP_BLUE).rule1.radius)
        WidgetText UI.txtBG_A, STR$(Group(GROUP_BLUE).rule2.attract)
        WidgetText UI.txtBG_R, STR$(Group(GROUP_BLUE).rule2.radius)
        WidgetText UI.txtBB_A, STR$(Group(GROUP_BLUE).rule3.attract)
        WidgetText UI.txtBB_R, STR$(Group(GROUP_BLUE).rule3.radius)
    END IF

    ' Check if the about button was clicked
    IF WidgetClicked(UI.cmdAbout) THEN
        _MESSAGEBOX "About", APP_NAME + STRING$(2, KEY_ENTER) + "Copyright (c) 2024 Samuel Gomes" + STRING$(2, KEY_ENTER) + "This was written in QB64-PE and the source code is avilable at https://github.com/a740g/Particle-Life"
    END IF

    ' Check if the show button was pressed
    IF WidgetClicked(UI.cmdShow) THEN
        ' If so, then change the UI visibility based on the show button's state
        WidgetVisibleAll PushButtonDepressed(UI.cmdShow)
        UI.hideLabels = NOT PushButtonDepressed(UI.cmdShow)
        ' However, leave the show button to be always visible
        WidgetVisible UI.cmdShow, TRUE
    END IF

    ' Check if any rule values have changed (auto-generated)
    IF WidgetClicked(UI.cmdRR_ADec) THEN WidgetText UI.txtRR_A, STR$(VAL(WidgetText$(UI.txtRR_A)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdRR_AInc) THEN WidgetText UI.txtRR_A, STR$(VAL(WidgetText$(UI.txtRR_A)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtRR_A) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdRR_RDec) THEN WidgetText UI.txtRR_R, STR$(VAL(WidgetText$(UI.txtRR_R)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdRR_RInc) THEN WidgetText UI.txtRR_R, STR$(VAL(WidgetText$(UI.txtRR_R)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtRR_R) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdRG_ADec) THEN WidgetText UI.txtRG_A, STR$(VAL(WidgetText$(UI.txtRG_A)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdRG_AInc) THEN WidgetText UI.txtRG_A, STR$(VAL(WidgetText$(UI.txtRG_A)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtRG_A) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdRG_RDec) THEN WidgetText UI.txtRG_R, STR$(VAL(WidgetText$(UI.txtRG_R)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdRG_RInc) THEN WidgetText UI.txtRG_R, STR$(VAL(WidgetText$(UI.txtRG_R)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtRG_R) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdRB_ADec) THEN WidgetText UI.txtRB_A, STR$(VAL(WidgetText$(UI.txtRB_A)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdRB_AInc) THEN WidgetText UI.txtRB_A, STR$(VAL(WidgetText$(UI.txtRB_A)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtRB_A) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdRB_RDec) THEN WidgetText UI.txtRB_R, STR$(VAL(WidgetText$(UI.txtRB_R)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdRB_RInc) THEN WidgetText UI.txtRB_R, STR$(VAL(WidgetText$(UI.txtRB_R)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtRB_R) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdGR_ADec) THEN WidgetText UI.txtGR_A, STR$(VAL(WidgetText$(UI.txtGR_A)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdGR_AInc) THEN WidgetText UI.txtGR_A, STR$(VAL(WidgetText$(UI.txtGR_A)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtGR_A) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdGR_RDec) THEN WidgetText UI.txtGR_R, STR$(VAL(WidgetText$(UI.txtGR_R)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdGR_RInc) THEN WidgetText UI.txtGR_R, STR$(VAL(WidgetText$(UI.txtGR_R)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtGR_R) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdGG_ADec) THEN WidgetText UI.txtGG_A, STR$(VAL(WidgetText$(UI.txtGG_A)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdGG_AInc) THEN WidgetText UI.txtGG_A, STR$(VAL(WidgetText$(UI.txtGG_A)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtGG_A) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdGG_RDec) THEN WidgetText UI.txtGG_R, STR$(VAL(WidgetText$(UI.txtGG_R)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdGG_RInc) THEN WidgetText UI.txtGG_R, STR$(VAL(WidgetText$(UI.txtGG_R)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtGG_R) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdGB_ADec) THEN WidgetText UI.txtGB_A, STR$(VAL(WidgetText$(UI.txtGB_A)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdGB_AInc) THEN WidgetText UI.txtGB_A, STR$(VAL(WidgetText$(UI.txtGB_A)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtGB_A) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdGB_RDec) THEN WidgetText UI.txtGB_R, STR$(VAL(WidgetText$(UI.txtGB_R)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdGB_RInc) THEN WidgetText UI.txtGB_R, STR$(VAL(WidgetText$(UI.txtGB_R)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtGB_R) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdBR_ADec) THEN WidgetText UI.txtBR_A, STR$(VAL(WidgetText$(UI.txtBR_A)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdBR_AInc) THEN WidgetText UI.txtBR_A, STR$(VAL(WidgetText$(UI.txtBR_A)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtBR_A) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdBR_RDec) THEN WidgetText UI.txtBR_R, STR$(VAL(WidgetText$(UI.txtBR_R)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdBR_RInc) THEN WidgetText UI.txtBR_R, STR$(VAL(WidgetText$(UI.txtBR_R)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtBR_R) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdBG_ADec) THEN WidgetText UI.txtBG_A, STR$(VAL(WidgetText$(UI.txtBG_A)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdBG_AInc) THEN WidgetText UI.txtBG_A, STR$(VAL(WidgetText$(UI.txtBG_A)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtBG_A) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdBG_RDec) THEN WidgetText UI.txtBG_R, STR$(VAL(WidgetText$(UI.txtBG_R)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdBG_RInc) THEN WidgetText UI.txtBG_R, STR$(VAL(WidgetText$(UI.txtBG_R)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtBG_R) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdBB_ADec) THEN WidgetText UI.txtBB_A, STR$(VAL(WidgetText$(UI.txtBB_A)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdBB_AInc) THEN WidgetText UI.txtBB_A, STR$(VAL(WidgetText$(UI.txtBB_A)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtBB_A) THEN UI.changed = TRUE
    IF WidgetClicked(UI.cmdBB_RDec) THEN WidgetText UI.txtBB_R, STR$(VAL(WidgetText$(UI.txtBB_R)) - 1): UI.changed = TRUE
    IF WidgetClicked(UI.cmdBB_RInc) THEN WidgetText UI.txtBB_R, STR$(VAL(WidgetText$(UI.txtBB_R)) + 1): UI.changed = TRUE
    IF TextBoxEntered(UI.txtBB_R) THEN UI.changed = TRUE

    IF UI.changed THEN
        Universe.particleSize = Math_ClampLong(Universe.particleSize, 0, PARTICLE_SIZE_MAX)
        WidgetText UI.txtParticleSize, STR$(Universe.particleSize)

        IF Universe.particlesPerGroup <> VAL(WidgetText$(UI.txtParticles)) THEN
            Universe.particlesPerGroup = Math_ClampLong(VAL(WidgetText$(UI.txtParticles)), 1, PARTICLES_PER_GROUP_MAX)
            WidgetText UI.txtParticles, STR$(Universe.particlesPerGroup)
            InitializeParticles
        END IF

        ' Update rule values (auto-generated)
        Group(GROUP_RED).rule1.attract = Math_ClampLong(VAL(WidgetText(UI.txtRR_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtRR_A, STR$(Group(GROUP_RED).rule1.attract)
        Group(GROUP_RED).rule1.radius = Math_ClampLong(VAL(WidgetText(UI.txtRR_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtRR_R, STR$(Group(GROUP_RED).rule1.radius)
        Group(GROUP_RED).rule2.attract = Math_ClampLong(VAL(WidgetText(UI.txtRG_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtRG_A, STR$(Group(GROUP_RED).rule2.attract)
        Group(GROUP_RED).rule2.radius = Math_ClampLong(VAL(WidgetText(UI.txtRG_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtRG_R, STR$(Group(GROUP_RED).rule2.radius)
        Group(GROUP_RED).rule3.attract = Math_ClampLong(VAL(WidgetText(UI.txtRB_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtRB_A, STR$(Group(GROUP_RED).rule3.attract)
        Group(GROUP_RED).rule3.radius = Math_ClampLong(VAL(WidgetText(UI.txtRB_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtRB_R, STR$(Group(GROUP_RED).rule3.radius)
        Group(GROUP_GREEN).rule1.attract = Math_ClampLong(VAL(WidgetText(UI.txtGR_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtGR_A, STR$(Group(GROUP_GREEN).rule1.attract)
        Group(GROUP_GREEN).rule1.radius = Math_ClampLong(VAL(WidgetText(UI.txtGR_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtGR_R, STR$(Group(GROUP_GREEN).rule1.radius)
        Group(GROUP_GREEN).rule2.attract = Math_ClampLong(VAL(WidgetText(UI.txtGG_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtGG_A, STR$(Group(GROUP_GREEN).rule2.attract)
        Group(GROUP_GREEN).rule2.radius = Math_ClampLong(VAL(WidgetText(UI.txtGG_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtGG_R, STR$(Group(GROUP_GREEN).rule2.radius)
        Group(GROUP_GREEN).rule3.attract = Math_ClampLong(VAL(WidgetText(UI.txtGB_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtGB_A, STR$(Group(GROUP_GREEN).rule3.attract)
        Group(GROUP_GREEN).rule3.radius = Math_ClampLong(VAL(WidgetText(UI.txtGB_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtGB_R, STR$(Group(GROUP_GREEN).rule3.radius)
        Group(GROUP_BLUE).rule1.attract = Math_ClampLong(VAL(WidgetText(UI.txtBR_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtBR_A, STR$(Group(GROUP_BLUE).rule1.attract)
        Group(GROUP_BLUE).rule1.radius = Math_ClampLong(VAL(WidgetText(UI.txtBR_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtBR_R, STR$(Group(GROUP_BLUE).rule1.radius)
        Group(GROUP_BLUE).rule2.attract = Math_ClampLong(VAL(WidgetText(UI.txtBG_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtBG_A, STR$(Group(GROUP_BLUE).rule2.attract)
        Group(GROUP_BLUE).rule2.radius = Math_ClampLong(VAL(WidgetText(UI.txtBG_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtBG_R, STR$(Group(GROUP_BLUE).rule2.radius)
        Group(GROUP_BLUE).rule3.attract = Math_ClampLong(VAL(WidgetText(UI.txtBB_A)), ATTRACT_MIN, ATTRACT_MAX)
        WidgetText UI.txtBB_A, STR$(Group(GROUP_BLUE).rule3.attract)
        Group(GROUP_BLUE).rule3.radius = Math_ClampLong(VAL(WidgetText(UI.txtBB_R)), RADIUS_MIN, RADIUS_MAX)
        WidgetText UI.txtBB_R, STR$(Group(GROUP_BLUE).rule3.radius)

        UI.changed = FALSE
    END IF
END SUB


SUB DrawStringRightAligned (text AS STRING, x AS LONG, y AS LONG)
    _PRINTSTRING (x - LEN(text) * _FONTWIDTH, y), text
END SUB


' This draws the static texts next to the UI buttons to show what they do
SUB DrawLabels
    IF NOT UI.hideLabels THEN
        COLOR BGRA_GRAY

        DIM AS LONG x, y

        x = Universe.size.x - UI_PUSH_BUTTON_WIDTH_LARGE - 1 - UI_WIDGET_SPACE - _FONTWIDTH
        y = (UI_WIDGET_HEIGHT + UI_WIDGET_SPACE) * 6 + (UI_WIDGET_HEIGHT + UI_WIDGET_SPACE) \ 2 - _FONTHEIGHT \ 2
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
    END IF
END SUB


' Draws the FPS on the top left corner of the screen if selected
SUB DrawFPS
    IF PushButtonDepressed(UI.cmdShowFPS) THEN
        COLOR BGRA_YELLOW
        _PRINTSTRING (0, 0), STR$(Time_GetHertz) + " FPS @" + STR$(Universe.size.x) + " x" + STR$(Universe.size.y)
    END IF
END SUB


' Initializes all groups
SUB InitializeGroups
    Group(GROUP_RED).clr = BGRA_RED
    Group(GROUP_RED).rule1.attract = Math_GetRandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_RED).rule1.radius = Math_GetRandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_RED).rule2.attract = Math_GetRandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_RED).rule2.radius = Math_GetRandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_RED).rule3.attract = Math_GetRandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_RED).rule3.radius = Math_GetRandomBetween(RADIUS_MIN, RADIUS_MAX)

    Group(GROUP_GREEN).clr = BGRA_GREEN
    Group(GROUP_GREEN).rule1.attract = Math_GetRandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_GREEN).rule1.radius = Math_GetRandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_GREEN).rule2.attract = Math_GetRandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_GREEN).rule2.radius = Math_GetRandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_GREEN).rule3.attract = Math_GetRandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_GREEN).rule3.radius = Math_GetRandomBetween(RADIUS_MIN, RADIUS_MAX)

    Group(GROUP_BLUE).clr = BGRA_BLUE
    Group(GROUP_BLUE).rule1.attract = Math_GetRandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_BLUE).rule1.radius = Math_GetRandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_BLUE).rule2.attract = Math_GetRandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_BLUE).rule2.radius = Math_GetRandomBetween(RADIUS_MIN, RADIUS_MAX)
    Group(GROUP_BLUE).rule3.attract = Math_GetRandomBetween(ATTRACT_MIN, ATTRACT_MAX)
    Group(GROUP_BLUE).rule3.radius = Math_GetRandomBetween(RADIUS_MIN, RADIUS_MAX)
END SUB


' Initializes all particles in the universe
SUB InitializeParticles
    DIM AS _UNSIGNED LONG i

    REDIM GroupRed(1 TO Universe.particlesPerGroup) AS ParticleType
    REDIM GroupGreen(1 TO Universe.particlesPerGroup) AS ParticleType
    REDIM GroupBlue(1 TO Universe.particlesPerGroup) AS ParticleType

    FOR i = 1 TO Universe.particlesPerGroup
        GroupRed(i).position.x = Math_GetRandomBetween(50, Universe.size.x - 51)
        GroupRed(i).position.y = Math_GetRandomBetween(50, Universe.size.y - 51)
    NEXT

    FOR i = 1 TO Universe.particlesPerGroup
        GroupGreen(i).position.x = Math_GetRandomBetween(50, Universe.size.x - 51)
        GroupGreen(i).position.y = Math_GetRandomBetween(50, Universe.size.y - 51)
    NEXT

    FOR i = 1 TO Universe.particlesPerGroup
        GroupBlue(i).position.x = Math_GetRandomBetween(50, Universe.size.x - 51)
        GroupBlue(i).position.y = Math_GetRandomBetween(50, Universe.size.y - 51)
    NEXT
END SUB


' Interaction between 2 particle groups
' Grp1 is the group that will be modified by the interaction
' Grp2 is the interacting group (its value won't be modified)
SUB ApplyRule (grp1() AS ParticleType, grp2() AS ParticleType, rule AS RuleType)
    DIM AS SINGLE g, dx, dy, r, fx, fy, f
    DIM AS _UNSIGNED LONG i, j

    g = rule.attract / ATTRACT_MIN

    FOR i = 1 TO Universe.particlesPerGroup
        fx = 0
        fy = 0
        FOR j = 1 TO Universe.particlesPerGroup
            ' Calculate the distance between points using Pythagorean theorem
            dx = grp1(i).position.x - grp2(j).position.x
            dy = grp1(i).position.y - grp2(j).position.y
            r = SQR(dx * dx + dy * dy)

            ' Calculate the force in given bounds
            IF r > 0 AND r < rule.radius THEN
                f = g / r
                fx = fx + dx * f
                fy = fy + dy * f
            END IF
        NEXT

        ' Calculate new velocity
        grp1(i).velocity.x = (grp1(i).velocity.x + fx) * 0.5
        grp1(i).velocity.y = (grp1(i).velocity.y + fy) * 0.5

        ' Update position based on velocity
        grp1(i).position.x = grp1(i).position.x + grp1(i).velocity.x
        grp1(i).position.y = grp1(i).position.y + grp1(i).velocity.y

        ' Check for screen bounds
        IF grp1(i).position.x < 0 OR grp1(i).position.x >= Universe.size.x THEN grp1(i).velocity.x = grp1(i).velocity.x * -1
        IF grp1(i).position.y < 0 OR grp1(i).position.y >= Universe.size.y THEN grp1(i).velocity.y = grp1(i).velocity.y * -1

        'IF grp1(i).position.x < 0 THEN
        '    grp1(i).position.x = 0
        '    grp1(i).velocity.x = grp1(i).velocity.x * -1
        'ELSEIF grp1(i).position.x >= Universe.size.x THEN
        '    grp1(i).position.x = Universe.size.x - 1
        '    grp1(i).velocity.x = grp1(i).velocity.x * -1
        'END IF

        'IF grp1(i).position.y < 0 THEN
        '    grp1(i).position.y = 0
        '    grp1(i).velocity.x = grp1(i).velocity.x * -1
        'ELSEIF grp1(i).position.y >= Universe.size.y THEN
        '    grp1(i).position.y = Universe.size.y - 1
        '    grp1(i).velocity.y = grp1(i).velocity.y * -1
        'END IF
    NEXT
END SUB


' This will make everything go
SUB RunUniverse
    ApplyRule GroupRed(), GroupRed(), Group(GROUP_RED).rule1
    ApplyRule GroupRed(), GroupGreen(), Group(GROUP_RED).rule2
    ApplyRule GroupRed(), GroupBlue(), Group(GROUP_RED).rule3

    ApplyRule GroupGreen(), GroupRed(), Group(GROUP_GREEN).rule1
    ApplyRule GroupGreen(), GroupGreen(), Group(GROUP_GREEN).rule2
    ApplyRule GroupGreen(), GroupBlue(), Group(GROUP_GREEN).rule3

    ApplyRule GroupBlue(), GroupRed(), Group(GROUP_BLUE).rule1
    ApplyRule GroupBlue(), GroupGreen(), Group(GROUP_BLUE).rule2
    ApplyRule GroupBlue(), GroupBlue(), Group(GROUP_BLUE).rule3
END SUB


' Draws all particles in a group
SUB DrawGroup (grp() AS ParticleType, gId AS _UNSIGNED LONG)
    DIM AS _UNSIGNED LONG i

    FOR i = 1 TO Universe.particlesPerGroup
        Graphics_DrawFilledCircle grp(i).position.x, grp(i).position.y, Universe.particleSize, Group(gId).clr
    NEXT
END SUB


' Draws all particles in the universe
SUB DrawUniverse
    ' We give every group a fair chance to be on top XD
    SELECT CASE Math_GetRandomBetween(1, 6)
        CASE 6
            DrawGroup GroupBlue(), GROUP_BLUE
            DrawGroup GroupGreen(), GROUP_GREEN
            DrawGroup GroupRed(), GROUP_RED
        CASE 5
            DrawGroup GroupBlue(), GROUP_BLUE
            DrawGroup GroupRed(), GROUP_RED
            DrawGroup GroupGreen(), GROUP_GREEN
        CASE 4
            DrawGroup GroupGreen(), GROUP_GREEN
            DrawGroup GroupBlue(), GROUP_BLUE
            DrawGroup GroupRed(), GROUP_RED
        CASE 3
            DrawGroup GroupGreen(), GROUP_GREEN
            DrawGroup GroupRed(), GROUP_RED
            DrawGroup GroupBlue(), GROUP_BLUE
        CASE 2
            DrawGroup GroupRed(), GROUP_RED
            DrawGroup GroupBlue(), GROUP_BLUE
            DrawGroup GroupGreen(), GROUP_GREEN
        CASE ELSE
            DrawGroup GroupRed(), GROUP_RED
            DrawGroup GroupGreen(), GROUP_GREEN
            DrawGroup GroupBlue(), GROUP_BLUE
    END SELECT
END SUB
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' MODULE FILES
'---------------------------------------------------------------------------------------------------------
'$INCLUDE:'include/ImGUI.bas'
'$INCLUDE:'include/GraphicOps.bas'
'---------------------------------------------------------------------------------------------------------
