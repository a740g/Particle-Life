'---------------------------------------------------------------------------------------------------------
' Particle Life for QB64-PE
' Copyright (c) 2025 Samuel Gomes
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' HEADER FILES
'---------------------------------------------------------------------------------------------------------
$LET TOOLBOX64_STRICT = TRUE
'$INCLUDE:'include/Math/Math.bi'
'$INCLUDE:'include/Math/Vector2f.bi'
'$INCLUDE:'include/Graphics/GUI.bi'
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' METACOMMANDS
'---------------------------------------------------------------------------------------------------------
$VERSIONINFO:ProductName='Particle Life'
$VERSIONINFO:CompanyName='Samuel Gomes'
$VERSIONINFO:LegalCopyright='Copyright (c) 2025 Samuel Gomes'
$VERSIONINFO:LegalTrademarks='All trademarks are property of their respective owners'
$VERSIONINFO:Web='https://github.com/a740g'
$VERSIONINFO:Comments='https://github.com/a740g'
$VERSIONINFO:InternalName='ParticleLife'
$VERSIONINFO:OriginalFilename='ParticleLife.exe'
$VERSIONINFO:FileDescription='Particle Life executable'
$VERSIONINFO:FILEVERSION#=1,1,1,0
$VERSIONINFO:PRODUCTVERSION#=1,1,1,0
$EXEICON:'./ParticleLife.ico'
$RESIZE:SMOOTH
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' CONSTANTS
'---------------------------------------------------------------------------------------------------------
CONST APP_NAME = "QB64-PE Particle Life"

CONST SCREEN_WIDTH = 1920
CONST SCREEN_HEIGHT = 1080

CONST GROUPS_COUNT = 4 ' maximum number of groups in the universe
CONST PARTICLES_PER_GROUP_MAX = 10000 ' maximum number of particles in a group
CONST PARTICLE_RADIUS_MAX = 16 ' maximum radius of each particle
CONST PARTICLE_RADIUS_DEFAULT = 1
CONST PARTICLES_PER_GROUP_DEFAULT = 500
' Group IDs
CONST GROUP_RED = 1
CONST GROUP_GREEN = 2
CONST GROUP_CYAN = 3
CONST GROUP_YELLOW = 4
' Group properties limits
CONST ATTRACTION_MIN = -100
CONST ATTRACTION_MAX = 100
CONST RADIUS_MIN = 0
CONST RADIUS_MAX = 200
CONST VISCOSITY_DEFAULT = 0.7!
CONST TIMESCALE_DEFAULT = 1.0!
CONST GRAVITY_DEFAULT = 0.0!
CONST WALL_REPEL_DEFAULT = 40.0!
CONST WALL_REPEL_STRENGTH_DEFAULT = 0.1!
' Max frame rate that we can go to
CONST FRAME_RATE_TARGET = 60
' UI constants
CONST UI_WIDGET_HEIGHT = 16 ' default widget height
CONST UI_WIDGET_SPACE = 2 ' space between widgets
CONST UI_PUSH_BUTTON_WIDTH_LARGE = 120
CONST UI_PUSH_BUTTON_WIDTH_SMALL = 24
CONST UI_TEXT_BOX_WIDTH = UI_PUSH_BUTTON_WIDTH_LARGE - (UI_PUSH_BUTTON_WIDTH_SMALL * 2) - (UI_WIDGET_SPACE * 2)
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' USER DEFINED TYPES
'---------------------------------------------------------------------------------------------------------
' This defines the universe
TYPE UniverseSettings
    size AS Vector2i ' this MUST be set by the user - typically window width & height
    particlesPerGroup AS _UNSIGNED LONG ' this MUST be set by the user - typically from the UI
    particleRadius AS _UNSIGNED LONG ' this may be set by the user - typically from the UI
    viscosity AS SINGLE
    timeScale AS SINGLE
    gravity AS SINGLE
    wallRepel AS SINGLE
    wallRepelStrength AS SINGLE
END TYPE

' This defines the rule type
TYPE GroupRule
    attraction AS LONG
    radius AS LONG
END TYPE

' This defines the group
TYPE ParticleGroup
    color AS _UNSIGNED LONG ' managed by InitializeGroupTable()
    rule1 AS GroupRule ' rules for interaction with each group
    rule2 AS GroupRule
    rule3 AS GroupRule
    rule4 AS GroupRule
END TYPE

' This defines the particle
TYPE SimulationParticle
    position AS Vector2f ' managed by InitializeGroup() & RunUniverseSimulation()
    velocity AS Vector2f ' managed by RunUniverseSimulation()
    groupId AS LONG ' managed by InitializeParticles()
END TYPE

TYPE SimulationUI
    hideLabels AS _BYTE ' should labels be hidden?
    isChanged AS _BYTE ' did anything significant in the UI change
    cmdShowHideControls AS LONG ' hide / show UI
    cmdExitProgram AS LONG ' exit button
    cmdShowFPS AS LONG ' hide / show FPS
    cmdShowAbout AS LONG ' shows an about dialog
    cmdResetParticles AS LONG ' reset particles without changing properties
    cmdRandomizeRules AS LONG ' random madness
    ' Controls the number of particles
    cmdParticlesDec AS LONG
    txtParticles AS LONG
    cmdParticlesInc AS LONG
    ' Controls the particle size
    cmdParticleRadiusDec AS LONG
    txtParticleRadius AS LONG
    cmdParticleRadiusInc AS LONG
    ' Global simulation controls
    cmdViscosityDec AS LONG
    txtViscosity AS LONG
    cmdViscosityInc AS LONG
    cmdTimeScaleDec AS LONG
    txtTimeScale AS LONG
    cmdTimeScaleInc AS LONG
    cmdGravityDec AS LONG
    txtGravity AS LONG
    cmdGravityInc AS LONG
    cmdWallRepelDec AS LONG
    txtWallRepel AS LONG
    cmdWallRepelInc AS LONG
    cmdWallRepelStrengthDec AS LONG
    txtWallRepelStrength AS LONG
    cmdWallRepelStrengthInc AS LONG
    ' Various attraction & radius controls
    cmdRR_ADec AS LONG: txtRR_A AS LONG: cmdRR_AInc AS LONG
    cmdRR_RDec AS LONG: txtRR_R AS LONG: cmdRR_RInc AS LONG
    cmdRG_ADec AS LONG: txtRG_A AS LONG: cmdRG_AInc AS LONG
    cmdRG_RDec AS LONG: txtRG_R AS LONG: cmdRG_RInc AS LONG
    cmdRC_ADec AS LONG: txtRC_A AS LONG: cmdRC_AInc AS LONG
    cmdRC_RDec AS LONG: txtRC_R AS LONG: cmdRC_RInc AS LONG
    cmdRY_ADec AS LONG: txtRY_A AS LONG: cmdRY_AInc AS LONG
    cmdRY_RDec AS LONG: txtRY_R AS LONG: cmdRY_RInc AS LONG
    cmdGR_ADec AS LONG: txtGR_A AS LONG: cmdGR_AInc AS LONG
    cmdGR_RDec AS LONG: txtGR_R AS LONG: cmdGR_RInc AS LONG
    cmdGG_ADec AS LONG: txtGG_A AS LONG: cmdGG_AInc AS LONG
    cmdGG_RDec AS LONG: txtGG_R AS LONG: cmdGG_RInc AS LONG
    cmdGC_ADec AS LONG: txtGC_A AS LONG: cmdGC_AInc AS LONG
    cmdGC_RDec AS LONG: txtGC_R AS LONG: cmdGC_RInc AS LONG
    cmdGY_ADec AS LONG: txtGY_A AS LONG: cmdGY_AInc AS LONG
    cmdGY_RDec AS LONG: txtGY_R AS LONG: cmdGY_RInc AS LONG
    cmdCR_ADec AS LONG: txtCR_A AS LONG: cmdCR_AInc AS LONG
    cmdCR_RDec AS LONG: txtCR_R AS LONG: cmdCR_RInc AS LONG
    cmdCG_ADec AS LONG: txtCG_A AS LONG: cmdCG_AInc AS LONG
    cmdCG_RDec AS LONG: txtCG_R AS LONG: cmdCG_RInc AS LONG
    cmdCC_ADec AS LONG: txtCC_A AS LONG: cmdCC_AInc AS LONG
    cmdCC_RDec AS LONG: txtCC_R AS LONG: cmdCC_RInc AS LONG
    cmdCY_ADec AS LONG: txtCY_A AS LONG: cmdCY_AInc AS LONG
    cmdCY_RDec AS LONG: txtCY_R AS LONG: cmdCY_RInc AS LONG
    cmdYR_ADec AS LONG: txtYR_A AS LONG: cmdYR_AInc AS LONG
    cmdYR_RDec AS LONG: txtYR_R AS LONG: cmdYR_RInc AS LONG
    cmdYG_ADec AS LONG: txtYG_A AS LONG: cmdYG_AInc AS LONG
    cmdYG_RDec AS LONG: txtYG_R AS LONG: cmdYG_RInc AS LONG
    cmdYC_ADec AS LONG: txtYC_A AS LONG: cmdYC_AInc AS LONG
    cmdYC_RDec AS LONG: txtYC_R AS LONG: cmdYC_RInc AS LONG
    cmdYY_ADec AS LONG: txtYY_A AS LONG: cmdYY_AInc AS LONG
    cmdYY_RDec AS LONG: txtYY_R AS LONG: cmdYY_RInc AS LONG
END TYPE
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' GLOBAL VARIABLES
'---------------------------------------------------------------------------------------------------------
DIM SHARED UI AS SimulationUI ' user interface controls
DIM SHARED Universe AS UniverseSettings ' Universe
DIM SHARED ParticleGroups(1 TO GROUPS_COUNT) AS ParticleGroup ' Groups
DIM SHARED AttractionRulesCache(1 TO GROUPS_COUNT, 1 TO GROUPS_COUNT) AS SINGLE ' pre-calculated attraction rules
DIM SHARED RadiusRulesCache(1 TO GROUPS_COUNT, 1 TO GROUPS_COUNT) AS SINGLE ' pre-calculated radius rules
REDIM SHARED AllParticles(0) AS SimulationParticle ' all particles in the universe
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' PROGRAM ENTRY POINT
'---------------------------------------------------------------------------------------------------------
Math_SetRandomSeed TIMER

InitializeSimulationCanvas
InitializeSimulationUniverse
InitializeSimulationGroups
InitializeSimulationParticles
InitializeSimulationUI

' Main loop
DO
    RunUniverseSimulation

    CLS , 0 ' clear the framebuffer

    ' From here on everything is drawn in z order
    DrawSimulationUniverse ' draw the universe
    DrawSimulationFPS ' draw the FPS
    WidgetUpdate ' update the widget system
    DrawSimulationUILabels ' draw the static text labels
    UpdateSimulationUI ' update and validate UI user values

    _DISPLAY ' flip the framebuffer

    _LIMIT FRAME_RATE_TARGET ' let's not get out of control
LOOP UNTIL InputManager_PeekKeyboardKey = _KEY_ESC _ORELSE InputManager_WindowShouldClose _ORELSE WidgetClicked(UI.cmdExitProgram)

WidgetFreeAll

SYSTEM
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
' FUNCTIONS AND SUBROUTINES
'---------------------------------------------------------------------------------------------------------
SUB InitializeSimulationCanvas
    SCREEN _NEWIMAGE(SCREEN_WIDTH, SCREEN_HEIGHT, 32)
    _FULLSCREEN _SQUAREPIXELS , _SMOOTH
    _PRINTMODE _KEEPBACKGROUND
    _TITLE APP_NAME
    _FONT 8
END SUB

SUB InitializeSimulationUniverse
    Universe.size.x = _WIDTH
    Universe.size.y = _HEIGHT
    Universe.particlesPerGroup = PARTICLES_PER_GROUP_DEFAULT
    Universe.particleRadius = PARTICLE_RADIUS_DEFAULT
    Universe.viscosity = VISCOSITY_DEFAULT
    Universe.timeScale = TIMESCALE_DEFAULT
    Universe.gravity = GRAVITY_DEFAULT
    Universe.wallRepel = WALL_REPEL_DEFAULT
    Universe.wallRepelStrength = WALL_REPEL_STRENGTH_DEFAULT
END SUB

SUB InitializeSimulationGroups
    ParticleGroups(GROUP_RED).color = _RGBA32(255, 31, 31, 191)
    ParticleGroups(GROUP_GREEN).color = _RGBA32(31, 255, 31, 191)
    ParticleGroups(GROUP_CYAN).color = _RGBA32(31, 255, 255, 191)
    ParticleGroups(GROUP_YELLOW).color = _RGBA32(255, 255, 31, 191)

    DIM AS LONG g1, g2
    FOR g1 = 1 TO GROUPS_COUNT
        FOR g2 = 1 TO GROUPS_COUNT
            DIM attractionValue AS LONG: attractionValue = Math_GetRandomBetween(ATTRACTION_MIN, ATTRACTION_MAX)
            DIM radiusValue AS LONG: radiusValue = Math_GetRandomBetween(RADIUS_MIN, RADIUS_MAX)
            SELECT CASE g1
                CASE GROUP_RED
                    SELECT CASE g2
                        CASE GROUP_RED
                            ParticleGroups(GROUP_RED).rule1.attraction = attractionValue
                            ParticleGroups(GROUP_RED).rule1.radius = radiusValue
                        CASE GROUP_GREEN
                            ParticleGroups(GROUP_RED).rule2.attraction = attractionValue
                            ParticleGroups(GROUP_RED).rule2.radius = radiusValue
                        CASE GROUP_CYAN
                            ParticleGroups(GROUP_RED).rule3.attraction = attractionValue
                            ParticleGroups(GROUP_RED).rule3.radius = radiusValue
                        CASE GROUP_YELLOW
                            ParticleGroups(GROUP_RED).rule4.attraction = attractionValue
                            ParticleGroups(GROUP_RED).rule4.radius = radiusValue
                    END SELECT

                CASE GROUP_GREEN
                    SELECT CASE g2
                        CASE GROUP_RED
                            ParticleGroups(GROUP_GREEN).rule1.attraction = attractionValue
                            ParticleGroups(GROUP_GREEN).rule1.radius = radiusValue
                        CASE GROUP_GREEN
                            ParticleGroups(GROUP_GREEN).rule2.attraction = attractionValue
                            ParticleGroups(GROUP_GREEN).rule2.radius = radiusValue
                        CASE GROUP_CYAN
                            ParticleGroups(GROUP_GREEN).rule3.attraction = attractionValue
                            ParticleGroups(GROUP_GREEN).rule3.radius = radiusValue
                        CASE GROUP_YELLOW
                            ParticleGroups(GROUP_GREEN).rule4.attraction = attractionValue
                            ParticleGroups(GROUP_GREEN).rule4.radius = radiusValue
                    END SELECT

                CASE GROUP_CYAN
                    SELECT CASE g2
                        CASE GROUP_RED
                            ParticleGroups(GROUP_CYAN).rule1.attraction = attractionValue
                            ParticleGroups(GROUP_CYAN).rule1.radius = radiusValue
                        CASE GROUP_GREEN
                            ParticleGroups(GROUP_CYAN).rule2.attraction = attractionValue
                            ParticleGroups(GROUP_CYAN).rule2.radius = radiusValue
                        CASE GROUP_CYAN
                            ParticleGroups(GROUP_CYAN).rule3.attraction = attractionValue
                            ParticleGroups(GROUP_CYAN).rule3.radius = radiusValue
                        CASE GROUP_YELLOW
                            ParticleGroups(GROUP_CYAN).rule4.attraction = attractionValue
                            ParticleGroups(GROUP_CYAN).rule4.radius = radiusValue
                    END SELECT

                CASE GROUP_YELLOW
                    SELECT CASE g2
                        CASE GROUP_RED
                            ParticleGroups(GROUP_YELLOW).rule1.attraction = attractionValue
                            ParticleGroups(GROUP_YELLOW).rule1.radius = radiusValue
                        CASE GROUP_GREEN
                            ParticleGroups(GROUP_YELLOW).rule2.attraction = attractionValue
                            ParticleGroups(GROUP_YELLOW).rule2.radius = radiusValue
                        CASE GROUP_CYAN
                            ParticleGroups(GROUP_YELLOW).rule3.attraction = attractionValue
                            ParticleGroups(GROUP_YELLOW).rule3.radius = radiusValue
                        CASE GROUP_YELLOW
                            ParticleGroups(GROUP_YELLOW).rule4.attraction = attractionValue
                            ParticleGroups(GROUP_YELLOW).rule4.radius = radiusValue
                    END SELECT
            END SELECT
        NEXT
    NEXT

    UpdateSimulationRulesCache
END SUB

SUB InitializeSimulationParticles
    DIM AS _UNSIGNED LONG i, totalParticles

    totalParticles = Universe.particlesPerGroup * GROUPS_COUNT
    REDIM AllParticles(1 TO totalParticles) AS SimulationParticle

    FOR i = 1 TO totalParticles
        AllParticles(i).position.x = Math_GetRandomBetween(50, Universe.size.x - 51)
        AllParticles(i).position.y = Math_GetRandomBetween(50, Universe.size.y - 51)
        AllParticles(i).velocity.x = 0!
        AllParticles(i).velocity.y = 0!
        AllParticles(i).groupId = ((i - 1) \ Universe.particlesPerGroup) + 1
    NEXT
END SUB

SUB InitializeSimulationUI
    UI.isChanged = _TRUE

    DIM AS LONG x, y

    ' Calculate UI start left
    x = Universe.size.x - UI_PUSH_BUTTON_WIDTH_LARGE - 1 - UI_WIDGET_SPACE
    y = UI_WIDGET_SPACE
    UI.cmdShowHideControls = PushButtonNew("Show Controls", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, _TRUE)
    PushButtonDepressed UI.cmdShowHideControls, _TRUE
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdExitProgram = PushButtonNew("Exit", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdShowAbout = PushButtonNew("About...", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdShowFPS = PushButtonNew("Show FPS", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, _TRUE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdResetParticles = PushButtonNew("Reset", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRandomizeRules = PushButtonNew("Random", x, y, UI_PUSH_BUTTON_WIDTH_LARGE, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdParticlesDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtParticles = TextBoxNew(_TOSTR$(Universe.particlesPerGroup), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdParticlesInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdParticleRadiusDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtParticleRadius = TextBoxNew(_TOSTR$(Universe.particleRadius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdParticleRadiusInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)

    ' Global parameters
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdViscosityDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtViscosity = TextBoxNew(_TOSTR$(Universe.viscosity), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdViscosityInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdTimeScaleDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtTimeScale = TextBoxNew(_TOSTR$(Universe.timeScale), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdTimeScaleInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGravityDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtGravity = TextBoxNew(_TOSTR$(Universe.gravity), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGravityInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdWallRepelDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtWallRepel = TextBoxNew(_TOSTR$(Universe.wallRepel), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdWallRepelInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdWallRepelStrengthDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtWallRepelStrength = TextBoxNew(_TOSTR$(Universe.wallRepelStrength), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdWallRepelStrengthInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)

    ' Rule widgets
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRR_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtRR_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_RED).rule1.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRR_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRR_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtRR_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_RED).rule1.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRR_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRG_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtRG_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_RED).rule2.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRG_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRG_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtRG_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_RED).rule2.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRG_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRC_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtRC_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_RED).rule3.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRC_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRC_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtRC_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_RED).rule3.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRC_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRY_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtRY_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_RED).rule4.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRY_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdRY_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtRY_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_RED).rule4.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdRY_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)

    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGR_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtGR_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_GREEN).rule1.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGR_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGR_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtGR_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_GREEN).rule1.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGR_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGG_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtGG_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_GREEN).rule2.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGG_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGG_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtGG_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_GREEN).rule2.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGG_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGC_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtGC_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_GREEN).rule3.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGC_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGC_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtGC_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_GREEN).rule3.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGC_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGY_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtGY_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_GREEN).rule4.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGY_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdGY_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtGY_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_GREEN).rule4.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdGY_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)

    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdCR_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtCR_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_CYAN).rule1.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdCR_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdCR_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtCR_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_CYAN).rule1.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdCR_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdCG_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtCG_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_CYAN).rule2.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdCG_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdCG_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtCG_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_CYAN).rule2.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdCG_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdCC_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtCC_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_CYAN).rule3.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdCC_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdCC_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtCC_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_CYAN).rule3.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdCC_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdCY_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtCY_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_CYAN).rule4.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdCY_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdCY_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtCY_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_CYAN).rule4.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdCY_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)

    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdYR_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtYR_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_YELLOW).rule1.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdYR_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdYR_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtYR_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_YELLOW).rule1.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdYR_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdYG_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtYG_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_YELLOW).rule2.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdYG_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdYG_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtYG_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_YELLOW).rule2.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdYG_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdYC_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtYC_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_YELLOW).rule3.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdYC_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdYC_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtYC_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_YELLOW).rule3.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdYC_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdYY_ADec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtYY_A = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_YELLOW).rule4.attraction), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdYY_AInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
    UI.cmdYY_RDec = PushButtonNew(CHR$(17), x, y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
    UI.txtYY_R = TextBoxNew(_TOSTR$(ParticleGroups(GROUP_YELLOW).rule4.radius), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_WIDGET_SPACE, y, UI_TEXT_BOX_WIDTH, UI_WIDGET_HEIGHT, TEXT_BOX_NUMERIC OR TEXT_BOX_DASH OR TEXT_BOX_DOT)
    UI.cmdYY_RInc = PushButtonNew(CHR$(16), x + UI_PUSH_BUTTON_WIDTH_SMALL + UI_TEXT_BOX_WIDTH + (UI_WIDGET_SPACE * 2), y, UI_PUSH_BUTTON_WIDTH_SMALL, UI_WIDGET_HEIGHT, _FALSE)
END SUB

SUB UpdateSimulationUI
    ' Check if user wants to change the size
    IF WidgetClicked(UI.cmdParticleRadiusDec) THEN Universe.particleRadius = Universe.particleRadius - 1: UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdParticleRadiusInc) THEN Universe.particleRadius = Universe.particleRadius + 1: UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtParticleRadius) THEN Universe.particleRadius = VAL(WidgetText(UI.txtParticleRadius)): UI.isChanged = _TRUE

    ' Check if user wants to change the number of particles
    IF WidgetClicked(UI.cmdParticlesDec) THEN WidgetText UI.txtParticles, _TOSTR$(VAL(WidgetText$(UI.txtParticles)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdParticlesInc) THEN WidgetText UI.txtParticles, _TOSTR$(VAL(WidgetText$(UI.txtParticles)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtParticles) THEN UI.isChanged = _TRUE

    ' Global simulation parameters
    IF WidgetClicked(UI.cmdViscosityDec) THEN Universe.viscosity = Universe.viscosity - 0.1!: UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdViscosityInc) THEN Universe.viscosity = Universe.viscosity + 0.1!: UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtViscosity) THEN Universe.viscosity = VAL(WidgetText(UI.txtViscosity)): UI.isChanged = _TRUE

    IF WidgetClicked(UI.cmdTimeScaleDec) THEN Universe.timeScale = Universe.timeScale - 0.1!: UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdTimeScaleInc) THEN Universe.timeScale = Universe.timeScale + 0.1!: UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtTimeScale) THEN Universe.timeScale = VAL(WidgetText(UI.txtTimeScale)): UI.isChanged = _TRUE

    IF WidgetClicked(UI.cmdGravityDec) THEN Universe.gravity = Universe.gravity - 0.05!: UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGravityInc) THEN Universe.gravity = Universe.gravity + 0.05!: UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtGravity) THEN Universe.gravity = VAL(WidgetText(UI.txtGravity)): UI.isChanged = _TRUE

    IF WidgetClicked(UI.cmdWallRepelDec) THEN Universe.wallRepel = Universe.wallRepel - 1!: UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdWallRepelInc) THEN Universe.wallRepel = Universe.wallRepel + 1!: UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtWallRepel) THEN Universe.wallRepel = VAL(WidgetText(UI.txtWallRepel)): UI.isChanged = _TRUE

    IF WidgetClicked(UI.cmdWallRepelStrengthDec) THEN Universe.wallRepelStrength = Universe.wallRepelStrength - 0.01!: UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdWallRepelStrengthInc) THEN Universe.wallRepelStrength = Universe.wallRepelStrength + 0.01!: UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtWallRepelStrength) THEN Universe.wallRepelStrength = VAL(WidgetText(UI.txtWallRepelStrength)): UI.isChanged = _TRUE

    ' Check if user clicked the reset button
    IF WidgetClicked(UI.cmdResetParticles) THEN
        InitializeSimulationParticles
    END IF

    ' Check if user clicked the random button
    IF WidgetClicked(UI.cmdRandomizeRules) THEN
        InitializeSimulationGroups
        InitializeSimulationParticles

        ' Update UI text boxes with new group rules
        WidgetText UI.txtRR_A, _TOSTR$(ParticleGroups(GROUP_RED).rule1.attraction)
        WidgetText UI.txtRR_R, _TOSTR$(ParticleGroups(GROUP_RED).rule1.radius)
        WidgetText UI.txtRG_A, _TOSTR$(ParticleGroups(GROUP_RED).rule2.attraction)
        WidgetText UI.txtRG_R, _TOSTR$(ParticleGroups(GROUP_RED).rule2.radius)
        WidgetText UI.txtRC_A, _TOSTR$(ParticleGroups(GROUP_RED).rule3.attraction)
        WidgetText UI.txtRC_R, _TOSTR$(ParticleGroups(GROUP_RED).rule3.radius)
        WidgetText UI.txtRY_A, _TOSTR$(ParticleGroups(GROUP_RED).rule4.attraction)
        WidgetText UI.txtRY_R, _TOSTR$(ParticleGroups(GROUP_RED).rule4.radius)

        WidgetText UI.txtGR_A, _TOSTR$(ParticleGroups(GROUP_GREEN).rule1.attraction)
        WidgetText UI.txtGR_R, _TOSTR$(ParticleGroups(GROUP_GREEN).rule1.radius)
        WidgetText UI.txtGG_A, _TOSTR$(ParticleGroups(GROUP_GREEN).rule2.attraction)
        WidgetText UI.txtGG_R, _TOSTR$(ParticleGroups(GROUP_GREEN).rule2.radius)
        WidgetText UI.txtGC_A, _TOSTR$(ParticleGroups(GROUP_GREEN).rule3.attraction)
        WidgetText UI.txtGC_R, _TOSTR$(ParticleGroups(GROUP_GREEN).rule3.radius)
        WidgetText UI.txtGY_A, _TOSTR$(ParticleGroups(GROUP_GREEN).rule4.attraction)
        WidgetText UI.txtGY_R, _TOSTR$(ParticleGroups(GROUP_GREEN).rule4.radius)

        WidgetText UI.txtCR_A, _TOSTR$(ParticleGroups(GROUP_CYAN).rule1.attraction)
        WidgetText UI.txtCR_R, _TOSTR$(ParticleGroups(GROUP_CYAN).rule1.radius)
        WidgetText UI.txtCG_A, _TOSTR$(ParticleGroups(GROUP_CYAN).rule2.attraction)
        WidgetText UI.txtCG_R, _TOSTR$(ParticleGroups(GROUP_CYAN).rule2.radius)
        WidgetText UI.txtCC_A, _TOSTR$(ParticleGroups(GROUP_CYAN).rule3.attraction)
        WidgetText UI.txtCC_R, _TOSTR$(ParticleGroups(GROUP_CYAN).rule3.radius)
        WidgetText UI.txtCY_A, _TOSTR$(ParticleGroups(GROUP_CYAN).rule4.attraction)
        WidgetText UI.txtCY_R, _TOSTR$(ParticleGroups(GROUP_CYAN).rule4.radius)

        WidgetText UI.txtYR_A, _TOSTR$(ParticleGroups(GROUP_YELLOW).rule1.attraction)
        WidgetText UI.txtYR_R, _TOSTR$(ParticleGroups(GROUP_YELLOW).rule1.radius)
        WidgetText UI.txtYG_A, _TOSTR$(ParticleGroups(GROUP_YELLOW).rule2.attraction)
        WidgetText UI.txtYG_R, _TOSTR$(ParticleGroups(GROUP_YELLOW).rule2.radius)
        WidgetText UI.txtYC_A, _TOSTR$(ParticleGroups(GROUP_YELLOW).rule3.attraction)
        WidgetText UI.txtYC_R, _TOSTR$(ParticleGroups(GROUP_YELLOW).rule3.radius)
        WidgetText UI.txtYY_A, _TOSTR$(ParticleGroups(GROUP_YELLOW).rule4.attraction)
        WidgetText UI.txtYY_R, _TOSTR$(ParticleGroups(GROUP_YELLOW).rule4.radius)
    END IF

    ' Check if the about button was clicked
    IF WidgetClicked(UI.cmdShowAbout) THEN
        _MESSAGEBOX "About", APP_NAME + _CHR_CR + _CHR_CR + "Copyright (c) 2024 Samuel Gomes" + _CHR_CR + _CHR_CR + "This was written in QB64-PE and the source code is avilable at https://github.com/a740g/Particle-Life"
    END IF

    ' Check if the show button was pressed
    IF WidgetClicked(UI.cmdShowHideControls) THEN
        WidgetVisibleAll PushButtonDepressed(UI.cmdShowHideControls)
        UI.hideLabels = NOT PushButtonDepressed(UI.cmdShowHideControls)
        WidgetVisible UI.cmdShowHideControls, _TRUE
    END IF

    ' Rule value changes
    IF WidgetClicked(UI.cmdRR_ADec) THEN WidgetText UI.txtRR_A, _TOSTR$(VAL(WidgetText$(UI.txtRR_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRR_AInc) THEN WidgetText UI.txtRR_A, _TOSTR$(VAL(WidgetText$(UI.txtRR_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtRR_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRR_RDec) THEN WidgetText UI.txtRR_R, _TOSTR$(VAL(WidgetText$(UI.txtRR_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRR_RInc) THEN WidgetText UI.txtRR_R, _TOSTR$(VAL(WidgetText$(UI.txtRR_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtRR_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRG_ADec) THEN WidgetText UI.txtRG_A, _TOSTR$(VAL(WidgetText$(UI.txtRG_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRG_AInc) THEN WidgetText UI.txtRG_A, _TOSTR$(VAL(WidgetText$(UI.txtRG_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtRG_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRG_RDec) THEN WidgetText UI.txtRG_R, _TOSTR$(VAL(WidgetText$(UI.txtRG_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRG_RInc) THEN WidgetText UI.txtRG_R, _TOSTR$(VAL(WidgetText$(UI.txtRG_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtRG_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRC_ADec) THEN WidgetText UI.txtRC_A, _TOSTR$(VAL(WidgetText$(UI.txtRC_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRC_AInc) THEN WidgetText UI.txtRC_A, _TOSTR$(VAL(WidgetText$(UI.txtRC_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtRC_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRC_RDec) THEN WidgetText UI.txtRC_R, _TOSTR$(VAL(WidgetText$(UI.txtRC_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRC_RInc) THEN WidgetText UI.txtRC_R, _TOSTR$(VAL(WidgetText$(UI.txtRC_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtRC_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRY_ADec) THEN WidgetText UI.txtRY_A, _TOSTR$(VAL(WidgetText$(UI.txtRY_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRY_AInc) THEN WidgetText UI.txtRY_A, _TOSTR$(VAL(WidgetText$(UI.txtRY_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtRY_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRY_RDec) THEN WidgetText UI.txtRY_R, _TOSTR$(VAL(WidgetText$(UI.txtRY_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdRY_RInc) THEN WidgetText UI.txtRY_R, _TOSTR$(VAL(WidgetText$(UI.txtRY_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtRY_R) THEN UI.isChanged = _TRUE

    IF WidgetClicked(UI.cmdGR_ADec) THEN WidgetText UI.txtGR_A, _TOSTR$(VAL(WidgetText$(UI.txtGR_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGR_AInc) THEN WidgetText UI.txtGR_A, _TOSTR$(VAL(WidgetText$(UI.txtGR_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtGR_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGR_RDec) THEN WidgetText UI.txtGR_R, _TOSTR$(VAL(WidgetText$(UI.txtGR_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGR_RInc) THEN WidgetText UI.txtGR_R, _TOSTR$(VAL(WidgetText$(UI.txtGR_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtGR_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGG_ADec) THEN WidgetText UI.txtGG_A, _TOSTR$(VAL(WidgetText$(UI.txtGG_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGG_AInc) THEN WidgetText UI.txtGG_A, _TOSTR$(VAL(WidgetText$(UI.txtGG_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtGG_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGG_RDec) THEN WidgetText UI.txtGG_R, _TOSTR$(VAL(WidgetText$(UI.txtGG_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGG_RInc) THEN WidgetText UI.txtGG_R, _TOSTR$(VAL(WidgetText$(UI.txtGG_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtGG_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGC_ADec) THEN WidgetText UI.txtGC_A, _TOSTR$(VAL(WidgetText$(UI.txtGC_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGC_AInc) THEN WidgetText UI.txtGC_A, _TOSTR$(VAL(WidgetText$(UI.txtGC_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtGC_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGC_RDec) THEN WidgetText UI.txtGC_R, _TOSTR$(VAL(WidgetText$(UI.txtGC_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGC_RInc) THEN WidgetText UI.txtGC_R, _TOSTR$(VAL(WidgetText$(UI.txtGC_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtGC_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGY_ADec) THEN WidgetText UI.txtGY_A, _TOSTR$(VAL(WidgetText$(UI.txtGY_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGY_AInc) THEN WidgetText UI.txtGY_A, _TOSTR$(VAL(WidgetText$(UI.txtGY_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtGY_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGY_RDec) THEN WidgetText UI.txtGY_R, _TOSTR$(VAL(WidgetText$(UI.txtGY_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdGY_RInc) THEN WidgetText UI.txtGY_R, _TOSTR$(VAL(WidgetText$(UI.txtGY_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtGY_R) THEN UI.isChanged = _TRUE

    IF WidgetClicked(UI.cmdCR_ADec) THEN WidgetText UI.txtCR_A, _TOSTR$(VAL(WidgetText$(UI.txtCR_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCR_AInc) THEN WidgetText UI.txtCR_A, _TOSTR$(VAL(WidgetText$(UI.txtCR_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtCR_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCR_RDec) THEN WidgetText UI.txtCR_R, _TOSTR$(VAL(WidgetText$(UI.txtCR_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCR_RInc) THEN WidgetText UI.txtCR_R, _TOSTR$(VAL(WidgetText$(UI.txtCR_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtCR_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCG_ADec) THEN WidgetText UI.txtCG_A, _TOSTR$(VAL(WidgetText$(UI.txtCG_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCG_AInc) THEN WidgetText UI.txtCG_A, _TOSTR$(VAL(WidgetText$(UI.txtCG_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtCG_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCG_RDec) THEN WidgetText UI.txtCG_R, _TOSTR$(VAL(WidgetText$(UI.txtCG_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCG_RInc) THEN WidgetText UI.txtCG_R, _TOSTR$(VAL(WidgetText$(UI.txtCG_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtCG_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCC_ADec) THEN WidgetText UI.txtCC_A, _TOSTR$(VAL(WidgetText$(UI.txtCC_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCC_AInc) THEN WidgetText UI.txtCC_A, _TOSTR$(VAL(WidgetText$(UI.txtCC_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtCC_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCC_RDec) THEN WidgetText UI.txtCC_R, _TOSTR$(VAL(WidgetText$(UI.txtCC_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCC_RInc) THEN WidgetText UI.txtCC_R, _TOSTR$(VAL(WidgetText$(UI.txtCC_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtCC_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCY_ADec) THEN WidgetText UI.txtCY_A, _TOSTR$(VAL(WidgetText$(UI.txtCY_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCY_AInc) THEN WidgetText UI.txtCY_A, _TOSTR$(VAL(WidgetText$(UI.txtCY_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtCY_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCY_RDec) THEN WidgetText UI.txtCY_R, _TOSTR$(VAL(WidgetText$(UI.txtCY_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdCY_RInc) THEN WidgetText UI.txtCY_R, _TOSTR$(VAL(WidgetText$(UI.txtCY_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtCY_R) THEN UI.isChanged = _TRUE

    IF WidgetClicked(UI.cmdYR_ADec) THEN WidgetText UI.txtYR_A, _TOSTR$(VAL(WidgetText$(UI.txtYR_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYR_AInc) THEN WidgetText UI.txtYR_A, _TOSTR$(VAL(WidgetText$(UI.txtYR_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtYR_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYR_RDec) THEN WidgetText UI.txtYR_R, _TOSTR$(VAL(WidgetText$(UI.txtYR_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYR_RInc) THEN WidgetText UI.txtYR_R, _TOSTR$(VAL(WidgetText$(UI.txtYR_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtYR_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYG_ADec) THEN WidgetText UI.txtYG_A, _TOSTR$(VAL(WidgetText$(UI.txtYG_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYG_AInc) THEN WidgetText UI.txtYG_A, _TOSTR$(VAL(WidgetText$(UI.txtYG_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtYG_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYG_RDec) THEN WidgetText UI.txtYG_R, _TOSTR$(VAL(WidgetText$(UI.txtYG_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYG_RInc) THEN WidgetText UI.txtYG_R, _TOSTR$(VAL(WidgetText$(UI.txtYG_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtYG_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYC_ADec) THEN WidgetText UI.txtYC_A, _TOSTR$(VAL(WidgetText$(UI.txtYC_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYC_AInc) THEN WidgetText UI.txtYC_A, _TOSTR$(VAL(WidgetText$(UI.txtYC_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtYC_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYC_RDec) THEN WidgetText UI.txtYC_R, _TOSTR$(VAL(WidgetText$(UI.txtYC_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYC_RInc) THEN WidgetText UI.txtYC_R, _TOSTR$(VAL(WidgetText$(UI.txtYC_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtYC_R) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYY_ADec) THEN WidgetText UI.txtYY_A, _TOSTR$(VAL(WidgetText$(UI.txtYY_A)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYY_AInc) THEN WidgetText UI.txtYY_A, _TOSTR$(VAL(WidgetText$(UI.txtYY_A)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtYY_A) THEN UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYY_RDec) THEN WidgetText UI.txtYY_R, _TOSTR$(VAL(WidgetText$(UI.txtYY_R)) - 1): UI.isChanged = _TRUE
    IF WidgetClicked(UI.cmdYY_RInc) THEN WidgetText UI.txtYY_R, _TOSTR$(VAL(WidgetText$(UI.txtYY_R)) + 1): UI.isChanged = _TRUE
    IF TextBoxEntered(UI.txtYY_R) THEN UI.isChanged = _TRUE

    IF UI.isChanged THEN
        Universe.particleRadius = Math_ClampLong(Universe.particleRadius, 0, PARTICLE_RADIUS_MAX)
        WidgetText UI.txtParticleRadius, _TOSTR$(Universe.particleRadius)

        Universe.viscosity = Math_ClampSingle(Universe.viscosity, 0.1!, 2!)
        WidgetText UI.txtViscosity, _TOSTR$(Universe.viscosity)

        Universe.timeScale = Math_ClampSingle(Universe.timeScale, 0.1!, 5!)
        WidgetText UI.txtTimeScale, _TOSTR$(Universe.timeScale)

        Universe.gravity = Math_ClampSingle(Universe.gravity, -1!, 1!)
        WidgetText UI.txtGravity, _TOSTR$(Universe.gravity)

        Universe.wallRepel = Math_ClampSingle(Universe.wallRepel, 0!, 100!)
        WidgetText UI.txtWallRepel, _TOSTR$(Universe.wallRepel)

        Universe.wallRepelStrength = Math_ClampSingle(Universe.wallRepelStrength, 0!, 1!)
        WidgetText UI.txtWallRepelStrength, _TOSTR$(Universe.wallRepelStrength)

        IF Universe.particlesPerGroup <> VAL(WidgetText$(UI.txtParticles)) THEN
            Universe.particlesPerGroup = Math_ClampLong(VAL(WidgetText$(UI.txtParticles)), 1, PARTICLES_PER_GROUP_MAX)
            WidgetText UI.txtParticles, _TOSTR$(Universe.particlesPerGroup)
            InitializeSimulationParticles
        END IF

        ' Update rule values
        DIM g1 AS LONG, g2 AS LONG
        FOR g1 = 1 TO GROUPS_COUNT
            FOR g2 = 1 TO GROUPS_COUNT
                DIM txtId AS LONG
                SELECT CASE g1
                    CASE GROUP_RED
                        SELECT CASE g2
                            CASE GROUP_RED
                                txtId = UI.txtRR_A
                            CASE GROUP_GREEN
                                txtId = UI.txtRG_A
                            CASE GROUP_CYAN
                                txtId = UI.txtRC_A
                            CASE GROUP_YELLOW
                                txtId = UI.txtRY_A
                        END SELECT

                    CASE GROUP_GREEN
                        SELECT CASE g2
                            CASE GROUP_RED
                                txtId = UI.txtGR_A
                            CASE GROUP_GREEN
                                txtId = UI.txtGG_A
                            CASE GROUP_CYAN
                                txtId = UI.txtGC_A
                            CASE GROUP_YELLOW
                                txtId = UI.txtGY_A
                        END SELECT

                    CASE GROUP_CYAN
                        SELECT CASE g2
                            CASE GROUP_RED
                                txtId = UI.txtCR_A
                            CASE GROUP_GREEN
                                txtId = UI.txtCG_A
                            CASE GROUP_CYAN
                                txtId = UI.txtCC_A
                            CASE GROUP_YELLOW
                                txtId = UI.txtCY_A
                        END SELECT

                    CASE GROUP_YELLOW
                        SELECT CASE g2
                            CASE GROUP_RED
                                txtId = UI.txtYR_A
                            CASE GROUP_GREEN
                                txtId = UI.txtYG_A
                            CASE GROUP_CYAN
                                txtId = UI.txtYC_A
                            CASE GROUP_YELLOW
                                txtId = UI.txtYY_A
                        END SELECT
                END SELECT
                DIM attractionValue AS LONG: attractionValue = Math_ClampLong(VAL(WidgetText(txtId)), ATTRACTION_MIN, ATTRACTION_MAX)
                WidgetText txtId, _TOSTR$(attractionValue)

                SELECT CASE g1
                    CASE GROUP_RED
                        SELECT CASE g2
                            CASE GROUP_RED
                                txtId = UI.txtRR_R
                            CASE GROUP_GREEN
                                txtId = UI.txtRG_R
                            CASE GROUP_CYAN
                                txtId = UI.txtRC_R
                            CASE GROUP_YELLOW
                                txtId = UI.txtRY_R
                        END SELECT

                    CASE GROUP_GREEN
                        SELECT CASE g2
                            CASE GROUP_RED
                                txtId = UI.txtGR_R
                            CASE GROUP_GREEN
                                txtId = UI.txtGG_R
                            CASE GROUP_CYAN
                                txtId = UI.txtGC_R
                            CASE GROUP_YELLOW
                                txtId = UI.txtGY_R
                        END SELECT

                    CASE GROUP_CYAN
                        SELECT CASE g2
                            CASE GROUP_RED
                                txtId = UI.txtCR_R
                            CASE GROUP_GREEN
                                txtId = UI.txtCG_R
                            CASE GROUP_CYAN
                                txtId = UI.txtCC_R
                            CASE GROUP_YELLOW
                                txtId = UI.txtCY_R
                        END SELECT

                    CASE GROUP_YELLOW
                        SELECT CASE g2
                            CASE GROUP_RED
                                txtId = UI.txtYR_R
                            CASE GROUP_GREEN
                                txtId = UI.txtYG_R
                            CASE GROUP_CYAN
                                txtId = UI.txtYC_R
                            CASE GROUP_YELLOW
                                txtId = UI.txtYY_R
                        END SELECT
                END SELECT
                DIM radiusValue AS LONG: radiusValue = Math_ClampLong(VAL(WidgetText(txtId)), RADIUS_MIN, RADIUS_MAX)
                WidgetText txtId, _TOSTR$(radiusValue)

                SELECT CASE g1
                    CASE GROUP_RED
                        SELECT CASE g2
                            CASE GROUP_RED
                                ParticleGroups(GROUP_RED).rule1.attraction = attractionValue
                                ParticleGroups(GROUP_RED).rule1.radius = radiusValue
                            CASE GROUP_GREEN
                                ParticleGroups(GROUP_RED).rule2.attraction = attractionValue
                                ParticleGroups(GROUP_RED).rule2.radius = radiusValue
                            CASE GROUP_CYAN
                                ParticleGroups(GROUP_RED).rule3.attraction = attractionValue
                                ParticleGroups(GROUP_RED).rule3.radius = radiusValue
                            CASE GROUP_YELLOW
                                ParticleGroups(GROUP_RED).rule4.attraction = attractionValue
                                ParticleGroups(GROUP_RED).rule4.radius = radiusValue
                        END SELECT

                    CASE GROUP_GREEN
                        SELECT CASE g2
                            CASE GROUP_RED
                                ParticleGroups(GROUP_GREEN).rule1.attraction = attractionValue
                                ParticleGroups(GROUP_GREEN).rule1.radius = radiusValue
                            CASE GROUP_GREEN
                                ParticleGroups(GROUP_GREEN).rule2.attraction = attractionValue
                                ParticleGroups(GROUP_GREEN).rule2.radius = radiusValue
                            CASE GROUP_CYAN
                                ParticleGroups(GROUP_GREEN).rule3.attraction = attractionValue
                                ParticleGroups(GROUP_GREEN).rule3.radius = radiusValue
                            CASE GROUP_YELLOW
                                ParticleGroups(GROUP_GREEN).rule4.attraction = attractionValue
                                ParticleGroups(GROUP_GREEN).rule4.radius = radiusValue
                        END SELECT

                    CASE GROUP_CYAN
                        SELECT CASE g2
                            CASE GROUP_RED
                                ParticleGroups(GROUP_CYAN).rule1.attraction = attractionValue
                                ParticleGroups(GROUP_CYAN).rule1.radius = radiusValue
                            CASE GROUP_GREEN
                                ParticleGroups(GROUP_CYAN).rule2.attraction = attractionValue
                                ParticleGroups(GROUP_CYAN).rule2.radius = radiusValue
                            CASE GROUP_CYAN
                                ParticleGroups(GROUP_CYAN).rule3.attraction = attractionValue
                                ParticleGroups(GROUP_CYAN).rule3.radius = radiusValue
                            CASE GROUP_YELLOW
                                ParticleGroups(GROUP_CYAN).rule4.attraction = attractionValue
                                ParticleGroups(GROUP_CYAN).rule4.radius = radiusValue
                        END SELECT

                    CASE GROUP_YELLOW
                        SELECT CASE g2
                            CASE GROUP_RED
                                ParticleGroups(GROUP_YELLOW).rule1.attraction = attractionValue
                                ParticleGroups(GROUP_YELLOW).rule1.radius = radiusValue
                            CASE GROUP_GREEN
                                ParticleGroups(GROUP_YELLOW).rule2.attraction = attractionValue
                                ParticleGroups(GROUP_YELLOW).rule2.radius = radiusValue
                            CASE GROUP_CYAN
                                ParticleGroups(GROUP_YELLOW).rule3.attraction = attractionValue
                                ParticleGroups(GROUP_YELLOW).rule3.radius = radiusValue
                            CASE GROUP_YELLOW
                                ParticleGroups(GROUP_YELLOW).rule4.attraction = attractionValue
                                ParticleGroups(GROUP_YELLOW).rule4.radius = radiusValue
                        END SELECT
                END SELECT
            NEXT
        NEXT

        UpdateSimulationRulesCache
        UI.isChanged = _FALSE
    END IF
END SUB

SUB UpdateSimulationRulesCache
    DIM AS LONG g1, g2
    FOR g1 = 1 TO GROUPS_COUNT
        FOR g2 = 1 TO GROUPS_COUNT
            DIM attractionValue AS LONG
            DIM radiusValue AS LONG

            SELECT CASE g1
                CASE GROUP_RED
                    SELECT CASE g2
                        CASE GROUP_RED
                            attractionValue = ParticleGroups(GROUP_RED).rule1.attraction
                            radiusValue = ParticleGroups(GROUP_RED).rule1.radius
                        CASE GROUP_GREEN
                            attractionValue = ParticleGroups(GROUP_RED).rule2.attraction
                            radiusValue = ParticleGroups(GROUP_RED).rule2.radius
                        CASE GROUP_CYAN
                            attractionValue = ParticleGroups(GROUP_RED).rule3.attraction
                            radiusValue = ParticleGroups(GROUP_RED).rule3.radius
                        CASE GROUP_YELLOW
                            attractionValue = ParticleGroups(GROUP_RED).rule4.attraction
                            radiusValue = ParticleGroups(GROUP_RED).rule4.radius
                    END SELECT

                CASE GROUP_GREEN
                    SELECT CASE g2
                        CASE GROUP_RED
                            attractionValue = ParticleGroups(GROUP_GREEN).rule1.attraction
                            radiusValue = ParticleGroups(GROUP_GREEN).rule1.radius
                        CASE GROUP_GREEN
                            attractionValue = ParticleGroups(GROUP_GREEN).rule2.attraction
                            radiusValue = ParticleGroups(GROUP_GREEN).rule2.radius
                        CASE GROUP_CYAN
                            attractionValue = ParticleGroups(GROUP_GREEN).rule3.attraction
                            radiusValue = ParticleGroups(GROUP_GREEN).rule3.radius
                        CASE GROUP_YELLOW
                            attractionValue = ParticleGroups(GROUP_GREEN).rule4.attraction
                            radiusValue = ParticleGroups(GROUP_GREEN).rule4.radius
                    END SELECT

                CASE GROUP_CYAN
                    SELECT CASE g2
                        CASE GROUP_RED
                            attractionValue = ParticleGroups(GROUP_CYAN).rule1.attraction
                            radiusValue = ParticleGroups(GROUP_CYAN).rule1.radius
                        CASE GROUP_GREEN
                            attractionValue = ParticleGroups(GROUP_CYAN).rule2.attraction
                            radiusValue = ParticleGroups(GROUP_CYAN).rule2.radius
                        CASE GROUP_CYAN
                            attractionValue = ParticleGroups(GROUP_CYAN).rule3.attraction
                            radiusValue = ParticleGroups(GROUP_CYAN).rule3.radius
                        CASE GROUP_YELLOW
                            attractionValue = ParticleGroups(GROUP_CYAN).rule4.attraction
                            radiusValue = ParticleGroups(GROUP_CYAN).rule4.radius
                    END SELECT

                CASE GROUP_YELLOW
                    SELECT CASE g2
                        CASE GROUP_RED
                            attractionValue = ParticleGroups(GROUP_YELLOW).rule1.attraction
                            radiusValue = ParticleGroups(GROUP_YELLOW).rule1.radius
                        CASE GROUP_GREEN
                            attractionValue = ParticleGroups(GROUP_YELLOW).rule2.attraction
                            radiusValue = ParticleGroups(GROUP_YELLOW).rule2.radius
                        CASE GROUP_CYAN
                            attractionValue = ParticleGroups(GROUP_YELLOW).rule3.attraction
                            radiusValue = ParticleGroups(GROUP_YELLOW).rule3.radius
                        CASE GROUP_YELLOW
                            attractionValue = ParticleGroups(GROUP_YELLOW).rule4.attraction
                            radiusValue = ParticleGroups(GROUP_YELLOW).rule4.radius
                    END SELECT
            END SELECT

            AttractionRulesCache(g1, g2) = attractionValue / ATTRACTION_MIN
            RadiusRulesCache(g1, g2) = radiusValue
        NEXT
    NEXT
END SUB

SUB RunUniverseSimulation
    $CHECKING:OFF

    DIM AS SINGLE fx, fy, dx, dy, d2, f, g, r2
    DIM AS LONG i, j, g1, g2, totalParticles, particlesPerGroup, startIdx, endIdx
    DIM AS SINGLE vmix

    totalParticles = UBOUND(AllParticles)
    particlesPerGroup = Universe.particlesPerGroup
    vmix = 1! - Universe.viscosity

    ' Accumulate forces
    FOR i = 1 TO totalParticles
        fx = 0!
        fy = 0!
        g1 = AllParticles(i).groupId

        FOR g2 = 1 TO GROUPS_COUNT
            g = AttractionRulesCache(g1, g2)
            r2 = RadiusRulesCache(g1, g2) * RadiusRulesCache(g1, g2)
            IF r2 > 0! THEN
                startIdx = (g2 - 1) * particlesPerGroup + 1
                endIdx = g2 * particlesPerGroup
                FOR j = startIdx TO endIdx
                    IF i = j THEN _CONTINUE

                    dx = AllParticles(i).position.x - AllParticles(j).position.x
                    dy = AllParticles(i).position.y - AllParticles(j).position.y
                    d2 = dx * dx + dy * dy

                    IF d2 > 0! _ANDALSO d2 < r2 THEN
                        f = g / SQR(d2)
                        fx = fx + dx * f
                        fy = fy + dy * f
                    END IF
                NEXT
            END IF
        NEXT

        ' Wall repel
        IF Universe.wallRepel > 0! THEN
            IF AllParticles(i).position.x < Universe.wallRepel THEN fx = fx + (Universe.wallRepel - AllParticles(i).position.x) * Universe.wallRepelStrength
            IF AllParticles(i).position.x > Universe.size.x - Universe.wallRepel THEN fx = fx + (Universe.size.x - Universe.wallRepel - AllParticles(i).position.x) * Universe.wallRepelStrength
            IF AllParticles(i).position.y < Universe.wallRepel THEN fy = fy + (Universe.wallRepel - AllParticles(i).position.y) * Universe.wallRepelStrength
            IF AllParticles(i).position.y > Universe.size.y - Universe.wallRepel THEN fy = fy + (Universe.size.y - Universe.wallRepel - AllParticles(i).position.y) * Universe.wallRepelStrength
        END IF

        fy = fy + Universe.gravity

        ' Update velocity
        AllParticles(i).velocity.x = AllParticles(i).velocity.x * vmix + fx * Universe.timeScale
        AllParticles(i).velocity.y = AllParticles(i).velocity.y * vmix + fy * Universe.timeScale
    NEXT

    ' Update positions and bounce
    FOR i = 1 TO totalParticles
        AllParticles(i).position.x = AllParticles(i).position.x + AllParticles(i).velocity.x
        AllParticles(i).position.y = AllParticles(i).position.y + AllParticles(i).velocity.y

        ' Bounce
        IF AllParticles(i).position.x < 0! THEN
            AllParticles(i).position.x = -AllParticles(i).position.x
            AllParticles(i).velocity.x = -AllParticles(i).velocity.x
        ELSEIF AllParticles(i).position.x >= Universe.size.x THEN
            AllParticles(i).position.x = 2! * Universe.size.x - AllParticles(i).position.x
            AllParticles(i).velocity.x = -AllParticles(i).velocity.x
        END IF

        IF AllParticles(i).position.y < 0! THEN
            AllParticles(i).position.y = -AllParticles(i).position.y
            AllParticles(i).velocity.y = -AllParticles(i).velocity.y
        ELSEIF AllParticles(i).position.y >= Universe.size.y THEN
            AllParticles(i).position.y = 2! * Universe.size.y - AllParticles(i).position.y
            AllParticles(i).velocity.y = -AllParticles(i).velocity.y
        END IF
    NEXT

    $CHECKING:ON
END SUB

SUB DrawStringRightAligned (text AS STRING, x AS LONG, y AS LONG)
    $CHECKING:OFF
    _PRINTSTRING (x - LEN(text) * _FONTWIDTH, y), text
    $CHECKING:ON
END SUB

SUB DrawSimulationUILabels
    $CHECKING:OFF

    IF NOT UI.hideLabels THEN
        COLOR BGRA_GRAY

        DIM AS LONG x, y

        x = Universe.size.x - UI_PUSH_BUTTON_WIDTH_LARGE - 1 - UI_WIDGET_SPACE - _FONTWIDTH
        y = (UI_WIDGET_HEIGHT + UI_WIDGET_SPACE) * 6 + (UI_WIDGET_HEIGHT + UI_WIDGET_SPACE) \ 2 - _FONTHEIGHT \ 2
        DrawStringRightAligned "Particles / Group:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Particle radius:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Viscosity:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Time Scale:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Gravity:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Wall Repel:", x, y
        y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
        DrawStringRightAligned "Wall Strength:", x, y

        ' Rule labels
        DIM AS LONG g1, g2
        DIM AS STRING groupNames: groupNames = "RGCY"
        FOR g1 = 1 TO GROUPS_COUNT
            FOR g2 = 1 TO GROUPS_COUNT
                y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
                DrawStringRightAligned "Attract " + MID$(groupNames, g1, 1) + " <-> " + MID$(groupNames, g2, 1) + ":", x, y
                y = y + UI_WIDGET_HEIGHT + UI_WIDGET_SPACE
                DrawStringRightAligned "Radius " + MID$(groupNames, g1, 1) + " <-> " + MID$(groupNames, g2, 1) + ":", x, y
            NEXT
        NEXT
    END IF

    $CHECKING:ON
END SUB

SUB DrawSimulationUniverse
    $CHECKING:OFF

    DIM totalParticles AS LONG: totalParticles = UBOUND(AllParticles)
    DIM i AS LONG
    FOR i = 1 TO totalParticles
        Graphics_DrawFilledCircle AllParticles(i).position.x, AllParticles(i).position.y, Universe.particleRadius, ParticleGroups(AllParticles(i).groupId).color
    NEXT

    $CHECKING:ON
END SUB

SUB DrawSimulationFPS
    $CHECKING:OFF

    IF PushButtonDepressed(UI.cmdShowFPS) THEN
        COLOR BGRA_WHITE
        _PRINTSTRING (0, 0), _TOSTR$(Time_GetHertz) + " FPS @" + STR$(Universe.size.x) + " x" + STR$(Universe.size.y)
    END IF

    $CHECKING:ON
END SUB
