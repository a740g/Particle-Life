'---------------------------------------------------------------------------------------------------------
' QB64-PE Immediate mode GUI Library
'
' Based on Terry Ritchie's work: GLINPUT, RQBL, RQML
' Note this a combintion of the above libraries with a unified input manager
' As such some things have chaged and will not work as a drop in replacement for Terry's libraries
' This was born becuase I needed a small, fast and intuitive GUI libary for games and graphic applications
'
' Copyright (c) 2022 Samuel Gomes
'---------------------------------------------------------------------------------------------------------

'******************************************************************************
'*                                                                            *
'* Graphics Line Input Routines by Terry Ritchie, V2.0 06/11/12               *
'*                                                                            *
'* Revision history:                                                          *
'*                                                                            *
'* V1.0  - 05/06/12                                                           *
'*         Initial release                                                    *
'*                                                                            *
'* V2.0  - 06/11/12                                                           *
'*         Complete rewrite of code                                           *
'*         Added support for animated background images                       *
'*         Removed ON TIMER requirement leaving updating to programmer        *
'*         Added ability to create input fields that save/ignore background   *
'*         Added demo program to show features                                *
'*                                                                            *
'* V2.01 - 06/12/12                                                           *
'*         Fixed background color bug (background was always black)           *
'*         Streamlined code for better efficiency (faster)                    *
'*         Renamed input allowed constants (replaced _ with I)                *
'*         Subs and functions will exit immediatly if no active inputs        *
'*                                                                            *
'* V2.10 - 06/13/12                                                           *
'*         Added GLICURRENT command                                           *
'*         Created library documentation                                      *
'*                                                                            *
'* Email author at terry.ritchie@gmail.com with questions or concerns (bugs). *
'*                                                                            *
'* Written using QB64 V0.954 and released to public domain. No credit is      *
'* needed or expected for its use or modification.                            *
'*                                                                            *
'* Based on work started by SMcNeill at this thread:                          *
'* http://www.qb64.net/forum/index.php?topic=6018.0                           *
'*                                                                            *
'* Simulates the LINE INPUT command on a graphics screen at any x,y location. *
'* The routines identifies the current font and size in use when called and   *
'* adjust the input fields accordingly. Furthermore, operation is not         *
'* suspended at an input field, allowing the programmer to continue to        *
'* monitor and update background tasks.                                       *
'*                                                                            *
'* Keystrokes Supported:                                                      *
'*                                                                            *
'* INSERT      - alternates between INSERT/OVERWITE modes (cursor changes)    *
'* DELETE      - deletes the character at current cursor position             *
'* HOME        - moves cursor to beginning of input text line                 *
'* END         - moves cursor to end of input text line                       *
'* UP ARROW    - moves cursor to previous text input field (if multiple)      *
'* DOWN ARROW  - moves cursor to next text input field (if multiple)          *
'* RIGHT ARROW - moves cursor to the right one character                      *
'* LEFT ARROW  - moves cursor to the left one character                       *
'* BACKSPACE   - moves cursor to the left one character and deletes character *
'* TAB         - moves cursor to the next input field (if multiple)           *
'*                                                                            *
'* -------------------------------------------------------------------------- *
'*                                                                            *
'*                                COMMANDS:                                   *
'*                                                                            *
'* -------------------------------------------------------------------------- *
'*                                                                            *
'* GLIINPUT - sets up a new input field location on the graphics screen.      *
'*                                                                            *
'* Usage:                                                                     *
'*                                                                            *
'* handle% = GLIINPUT(x%, y%, allowedtext%, displaytext$, save%)              *
'*                                                                            *
'* handle%      - number identifying this input field                         *
'* x%           - x coordinate location of graphic input field                *
'* y%           - y coordinate location of graphic input field                *
'* allowedtext% - number signifying what type of text input is allowed        *
'* displaytext$ - text to display at beginning of input field                 *
'* save%        - -1 (TRUE) to save background, 0 (FALSE) to disregard it     *
'*                                                                            *
'* The following values can be used with allowedtext%:                        *
'*                                                                            *
'* 1   - alphabetic characters only               (GLIALPHA)                  *
'* 2   - numeric characters only                  (GLINUMERIC)                *
'* 4   - symbolic characters only                 (GLISYMBOLS)                *
'* 8   - dash (-) symbol only                     (GLIDASH)                   *
'* 16  - parenthesis () only                      (GLIPAREN)                  *
'* 32  - force all input to lower case            (GLILOWER)                  *
'* 64  - force all input to upper case            (GLIUPPER)                  *
'* 128 - password field displaying asterisks only (GLIPASSWORD)               *
'*                                                                            *
'* You can combine any of these combinations together to make custom inputs:  *
'*                                                                            *
'* all chars - 7   (1+2+4     or GLIALPHA+GLINUMERIC+GLISYMBOLS)              *
'* phone #s  - 26  (2+8+16    or GLINUMERIC+GLIDASH+GLIPAREN)                 *
'* uppercase - 71  (1+2+4+64  or GLIALPHA+GLINUMERIC+GLISYMBOLS+GLIUPPER)     *
'* password  - 135 (1+2+4+128 or GLIALPHA+GLINUMERIC+GLISYMBOLS+GLIPASSWORD)  *
'*                                                                            *
'* Examples:                                                                  *
'*                                                                            *
'* MyName% = GLIINPUT(10, 100, 1, "Name:", -1)                                *
'* Password% = GLIINPUT(50, 250, 135, "Password:", 0)                         *
'* PhoneNum% = GLIINPUT(20, 200, 26, "Home Phone:", -1)                       *
'*                                                                            *
'* -------------------------------------------------------------------------- *
'*                                                                            *
'* GLIOUTPUT$ - retrieves the text string from an input field.                *
'*                                                                            *
'* Usage:                                                                     *
'*                                                                            *
'* text$ = GLIOUTPUT$(handle%)                                                *
'*                                                                            *
'* text$   - the text returned by the routine                                 *
'* handle% - the number identifying the input field to get input text from    *
'*                                                                            *
'* Example:                                                                   *
'*                                                                            *
'* MyName$ = GLIOUTPUT$(MyName%)                                              *
'*                                                                            *
'* MyName% would have been previously created using GLIINPUT                  *
'*                                                                            *
'* Note:                                                                      *
'*                                                                            *
'* You can grab the output text from an input field at any time, but once the *
'* the field is closed the text is gone. (see GLICLOSE)                       *
'*                                                                            *
'* -------------------------------------------------------------------------- *
'*                                                                            *
'* GLIENTERED - reports if the ENTER key has been pressed on a certain input  *
'*             field or on all active input fields. The result is a boolean   *
'*             true or false.                                                 *
'*                                                                            *
'* Usage:                                                                     *
'*                                                                            *
'* entered% = GLIENTERED(handle%)                                             *
'*                                                                            *
'* entered% - the result of the ENTER key being pressed (0=FALSE, -1=TRUE)    *
'* handle%  - the number identifying the input field to test for ENTER key    *
'*                                                                            *
'* The following values can be used for handle%:                              *
'*                                                                            *
'*  0 - test all active input fields for the ENTER key having been pressed    *
'* >0 - test an individual handle for the ENTER key having been pressed       *
'*                                                                            *
'* Example:                                                                   *
'*                                                                            *
'* IF GLIENTERED(MyName%) then MyName$ = GLOUPUT$(MyName%)                    *
'*                                                                            *
'* -------------------------------------------------------------------------- *
'*                                                                            *
'* GLICLOSE - makes an input field stop allowing text input.                  *
'*                                                                            *
'* Usage:                                                                     *
'*                                                                            *
'* GLICLOSE handle%, behavior%                                                *
'*                                                                            *
'* handle%   - the number identifying the input field to close                *
'* behavior% - if set to TRUE (-1) the input field will disappear from screen *
'*                                                                            *
'* The following values can be used for handle%:                              *
'*                                                                            *
'*  0 - close all active input fields at once                                 *
'* >0 - close an individual input field                                       *
'*                                                                            *
'* Example:                                                                   *
'*                                                                            *
'* IF GLIENTERED(0) THEN '                  all fields been entered?          *
'*     MyName$ = GLOUPUT$(MyName%) '       yes, get the user name             *
'*     PhoneNum$ = GLIOUTPUT$(PhoneNum%) ' get the user phone number          *
'*     GLICLOSE 0, -1 '                    close and hide all input fields    *
'* END IF                                                                     *
'*                                                                            *
'* Note:                                                                      *
'*                                                                            *
'* Once all input fields have been closed the input text is lost forever.     *
'*                                                                            *
'* -------------------------------------------------------------------------- *
'*                                                                            *
'* GLIFORCE - forces the cursor to move to the next input field or a specific *
'*            input field.                                                    *
'*                                                                            *
'* Usage:                                                                     *
'*                                                                            *
'* GLIFORCE handle%                                                           *
'*                                                                            *
'* handle% - the input field to force the cursor to move to                   *
'*                                                                            *
'* The following values can be used for handle%:                              *
'*                                                                            *
'* -1 - force the cursor to the next input field                              *
'* >0 - force the cursor to a specific input field                            *
'*                                                                            *
'* Example:                                                                   *
'*                                                                            *
'* IF LEN(GLOUPUT$(ssn%)) = 9 THEN GLIFORCE -1                                *
'*                                                                            *
'* -------------------------------------------------------------------------- *
'*                                                                            *
'* GLICURRENT - returns the handle number of the current active input field.  *
'*              will return 0 if there are no active input fields.            *
'*                                                                            *
'* Usage:                                                                     *
'*                                                                            *
'* current% = GLICURRENT                                                      *
'*                                                                            *
'* Example:                                                                   *
'*                                                                            *
'* LOCATE 1, 1                                                                *
'* SELECT CASE GLICURRENT                                                     *
'*     CASE FirstName%                                                        *
'*         PRINT "Enter your first name"                                      *
'*     CASE LastName%                                                         *
'*         PRINT "Enter your last name"                                       *
'*     CASE Phone%                                                            *
'*         PRINT "Enter your phone number"                                    *
'* END SELECT                                                                 *
'*                                                                            *
'* -------------------------------------------------------------------------- *
'*                                                                            *
'* Known Issues / TODOs:                                                      *
'*                                                                            *
'* None currently - Please report any bugs found. Also, if you make           *
'*                  improvements or modifications please send updates to      *
'*                  author. If used in an official update credit of course    *
'*                  will be given where credit is due.                        *
'*                                                                            *
'* -------------------------------------------------------------------------- *
'*                                                                            *
'* Correct usage of commands:                                                 *
'*                                                                            *
'* A proper order of commands must be maintained in order for the GLI library *
'* to work properly. GLICLEAR must be the first command in your loop and      *
'* GLIUPDATE must be the last command. All GLIINPUT fields must be set up     *
'* beforehand, outside of the loop. For example:                              *
'*                                                                            *
'* MyName% = GLIINPUT(25, 25, GLIALPHA, "First Name: ", -1)                   *
'*                                                                            *
'* DO                                                                         *
'*     GLICLEAR '        clears the input text and restores background        *
'*     .                                                                      *
'*     .                                                                      *
'*     <your code here>      Maintain this order in your loops                *
'*     .                                                                      *
'*     .                                                                      *
'*     GLIUPDATE '      displays the input text on screen                     *
'*     _DISPLAY '       updates the screen with GLIUPDATE results             *
'*                                                                            *
'* LOOP UNTIL GLIENTERED(MyName%)                                             *
'*                                                                            *
'* MyName$ = GLIOUTPUT$(MyName%)                                              *
'* GLICLOSE MyName%, -1                                                       *
'*                                                                            *
'******************************************************************************

'******************************************************************************
'* Ritchie's QB64 Button Library                                              *
'* V1.0 - 06/21/2011                                                          *
'*                                                                            *
'* This library has been distributed as freeware. If you make any changes to  *
'* the code and wish to have it considered in an update, please email your    *
'* changes to the author at:                                                  *
'*                                                                            *
'* terry.ritchie@gmail.com                                                    *
'*                                                                            *
'* Proper credit will be given for your submission.                           *
'*                                                                            *
'* If you use this library in your project please credit the author.          *
'*                                                                            *
'* Credits:                                                                   *
'*                                                                            *
'* - Galleon, the creator of QB64, allowing old school programmers to keep    *
'*   their QuickBasic programming craft alive.                                *
'*                                                                            *
'* - All forum members of QB64.NET, for their never ending help to the QB64   *
'*   community.                                                               *
'*                                                                            *
'* Documentation:                                                             *
'*                                                                            *
'* - See RQBLV10.PDF for command syntax and use.                              *
'*                                                                            *
'* History:                                                                   *
'*                                                                            *
'* - 06/21/2011: Version 1.0 released                                         *
'*                                                                            *
'* Reporting errors and bugs: terry.ritchie@gmail.com                         *
'******************************************************************************

'******************************************************************************
'*                                                                            *
'* QB64 Menu Routines by Terry Ritchie, V1.0 08/01/12                         *
'*                                                                            *
'* Revision history:                                                          *
'*                                                                            *
'* V1.0  - 08/01/12                                                           *
'*         Initial release                                                    *
'*                                                                            *
'* Email author at terry.ritchie@gmail.com with questions or concerns (bugs). *
'*                                                                            *
'* Written using QB64 V0.954 and released to public domain. No credit is      *
'* needed or expected for its use or modification.                            *
'*                                                                            *
'* Creates a Windows-like menu system to be used in QB64 programs.            *
'*                                                                            *
'******************************************************************************

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
    Const IMGUI64_INPUT_ALPHA = 1 '                 alphabetic input allowed
    Const IMGUI64_INPUT_NUMERIC = 2 '               numeric input allowed
    Const IMGUI64_INPUT_SYMBOLS = 4 '               all symbols allowed
    Const IMGUI64_INPUT_DASH = 8 '                  dash (-) symbol allowed
    Const IMGUI64_INPUT_PAREN = 16 '                parenthesis allowed
    Const IMGUI64_INPUT_LOWER = 32 '                lower case only
    Const IMGUI64_INPUT_UPPER = 64 '                upper case only
    Const IMGUI64_INPUT_PASSWORD = 128 '            password * only
    '-----------------------------------------------------------------------------------------------------

    '-----------------------------------------------------------------------------------------------------
    ' USER DEFINED TYPES
    '-----------------------------------------------------------------------------------------------------
    Type __IMGUI64_InputSystemType '                A simple input management syetm type
        keyCode As Long '                           Buffered keyboard input
        mouseX As Long '                            Current mouse X position
        mouseY As Long '                            Current mouse Y position
        leftMouseButton As Byte '                   Current left mouse button down state
        rightMouseButton As Byte '                  Current right mouse button down state
    End Type

    Type __IMGUI64_InputInfoType '                  graphics line input array type
        x As Integer '                              x location of text
        y As Integer '                              y location of text
        Allow As Integer '                          allowed characters in input field
        Text As String * 255 '                      display text
        InUse As Integer '                          is this field in use (T/F)
        CurrentFont As Long '                       current font for this field
        FontHeight As Integer '                     current height of font for this field
        FontWidth As Integer '                      current width of font for this field
        MonoSpace As Integer '                      is the current font monospace (T/F)
        BackgroundColor As Long '                   background color for this input field
        DefaultColor As Long '                      foreground color for this input field
        TextWidth As Integer '                      width of display text
        CursorPosition As Integer '                 current cursor position within input field
        InputTextX As Integer '                     x location of input text field
        InputText As String * 255 '                 text being entered into input field
        ICursorHeight As Integer '                  INSERT mode cursor height
        OCursorHeight As Integer '                  OVERWRITE mode cursor height
        CursorX As Integer '                        cursor x location within input field
        ICursorY As Integer '                       INSERT mode cursor y location within input field
        OCursorY As Integer '                       OVERWRITE mode cursor y location within input field
        BlinkTimer As Single '                      timer controllling cursor blink rate
        CursorWidth As Integer '                    width of cursor on current location within input field
        InsertMode As Integer '                     current cursor insert mode (0 = INSERT, -1 = OVERWRITE)
        Entered As Integer '                        ENTER has been pressed on this input field (T/F)
        TextImage As Long '                         the image the text is drawn on
        Background As Long '                        the original background image under text
        Save As Integer '                           TRUE to save background, False to overwrite background
        Visible As Integer '                        TRUE if input field visible on screen, FALSE otherwise
    End Type

    Type __IMGUI64_ButtonInfoType '                 button information
        x As Integer '                              x location of button      (set by BUTTONPUT)
        y As Integer '                              y location of button      (set by BUTTONPUT)
        xs As Integer '                             x size (width) of button  (set by BUTTONNEW)
        ys As Integer '                             y size (height) of button (set by BUTTONNEW)
        out As Long '                               depressed image of button (set by BUTTONNEW, BUTTONFREE)
        in As Long '                                pressed image of button   (set by BUTTONNEW, BUTTONFREE)
        state As Integer '                          state of button           (set by BUTTONNEW, BUTTONTOGGLE)
        inuse As Integer '                          button is in use          (set by BUTTONNEW, BUTTONFREE)
        text As String '                            text of button            (set by ButtonText)
        shown As Integer '                          button shown first time   (set by BUTTONPUT)
        show As Integer '                           button on screen?         (set by BUTTONPUT)
        mouse As Integer '                          mouse status of button (1-left, 2-right, 3-hover)
    End Type

    Type __IMGUI64_MenuInfoType
        idnum As Integer '                          ID number of meny entry
        text As String * 64 '                       main and submenu entries text
        ljustify As String * 64 '                   text on left side of submenu entry
        rjustify As String * 64 '                   text right justified on submenu entry
        x As Integer '                              x location of main entry on menu bar image and submenu entry on submenu image
        y As Integer '                              y location of submenu entry on submenu image (main entry always 0)
        width As Integer '                          width of main and submenu entries
        live As Integer '                           TRUE (-1) if submenu entry is selectable, FALSE (0) otherwise
        hotkey As Long '                            hotkey that activates submenu entry
        altkey As Long '                            alt key combos for main and sub menus
        altkeycharacter As Integer '                the ASCII character that follows an ALT key
        altkeyx As Integer '                        the x location of the ALT underscore
        altkeywidth As Integer '                    the width of the ALT underscore
        drawline As Integer '                       TRUE (-1) if an ALT underscore is to be drawn, FALSE (0) otherwise
        active As Long '                            image of active main and submenu entries
        highlight As Long '                         image of highlighted main and submenu entries
        selected As Long '                          image of selected main entry
        inactive As Long '                          image of inactive submenu entry
        ihighlight As Long '                        image ofinactive highlighted submenu entry
        submenu As Long '                           image of main entry submenu
        undersubmenu As Long '                      saved image under submenu image
    End Type

    Type __IMGUI64_MenuSettingsType
        mainmenu As Integer '                       the current main menu field in use
        oldmainmenu As Integer '                    the previous main menu field in use
        menuactive As Integer '                     TRUE (-1) if menu is currently active, FALSE (0) otherwise
        submenuactive As Integer '                  TRUE (-1) if submenu is currently active (showing), FALSE (0) otherwise
        submenu As Integer '                        the current sub menu field in use
        oldsubmenu As Integer '                     the previous sub menu field in use
        width As Integer '                          the width of all the main menu entries combined in top bar
        height As Integer '                         the height of each menu entry
        spacing As Integer '                        the space to the right and left of menu entries
        centered As Integer '                       the center location of menu text
        indent As Integer '                         the master indent value for the entire menu
        alttweak As Integer '                       the amount to raise or lower the ALT key underscore
        texttweak As Integer '                      the amount to raise or lower the text in main and sub menu entries
        subtweak As Integer '                       the amount to raise or lower the sub menus
        mmbar3D As Integer '                        TRUE (-1) top menu bar in 3D, FALSE (0) otherwise
        smbar3D As Integer '                        TRUE (-1) sub menus in 3D, FALSE (0) otherwise
        mm3D As Integer '                           TRUE (-1) main menu entries in 3D, FALSE (0) otherwise
        sm3D As Integer '                           TRUE (-1) sub menu entries in 3D, FALSE (0) otherwise
        shadow As Integer '                         TRUE (-1) drop shadow under sub menus, FALSE (0) otherwise
        mmatext As _Unsigned Long '                 main menu active (normal) text color
        mmhtext As _Unsigned Long '                 main menu highlighted text color
        mmstext As _Unsigned Long '                 main menu selected text color
        smatext As _Unsigned Long '                 sub menu active (normal) text color
        smhtext As _Unsigned Long '                 sub menu highlight text color
        smitext As _Unsigned Long '                 sub menu inactive text color
        smihtext As _Unsigned Long '                sub menu inactive highlight text color
        mmabarbg As _Unsigned Long '                main menu bar background color
        mmhbarbg As _Unsigned Long '                main menu highlight bar background color
        mmsbarbg As _Unsigned Long '                main menu selected bar background color
        smabg As _Unsigned Long '                   sub menu active background color
        smhbg As _Unsigned Long '                   sub menu highlight background color
        smibg As _Unsigned Long '                   sub menu inactive background color
        smihbg As _Unsigned Long '                  sub menu inactive highlight background color
        showing As Integer '                        TRUE (-1) if MenuShow() called, FALSE (0) otherwise or MenuHide() called
        undermenu As Long '                         background image under top bar menu
        menubar As Long '                           the top menu bar
        menubarhighlight As Long '                  temporary bar created when drawing menu (freed from memory)
        menubarselected As Long '                   temporary bar created when drawing menu (freed from memory)
    End Type
    '-----------------------------------------------------------------------------------------------------

    '-----------------------------------------------------------------------------------------------------
    ' SHARED VARIABLES
    '-----------------------------------------------------------------------------------------------------
    ReDim __IMGUI64_InputInfo(1 To 1) As __IMGUI64_InputInfoType '          text input array
    Dim __IMGUI64_InputForced As Long '                                     used to pass GLIFORCE messages to GLIUPDATE
    Dim __IMGUI64_InputCurrent As Long '                                    current field user typing into

    ReDim __IMGUI64_ButtonInfo(1 To 1) As __IMGUI64_ButtonInfoType '        array defining button information
    Dim __IMGUI64_ButtonChecking As Byte '                                  button checking status

    ReDim __IMGUI64_MenuInfo(1 To 1, 1 To 1) As __IMGUI64_MenuInfoType '    menu entry array
    Dim __IMGUI64_MenuSettings As __IMGUI64_MenuSettingsType '              global menu settings

    Dim __IMGUI64_InputSystem As __IMGUI64_InputSystemType '                input manager global variable. Use this to check for input
    '-----------------------------------------------------------------------------------------------------
$End If
'---------------------------------------------------------------------------------------------------------

