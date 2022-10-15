'---------------------------------------------------------------------------------------------------------
' Common header
' Copyright (c) 2022 Samuel Gomes
'---------------------------------------------------------------------------------------------------------

$If COMMON_BI = UNDEFINED Then
    $Let COMMON_BI = TRUE

    '-----------------------------------------------------------------------------------------------------
    ' METACOMMANDS
    '-----------------------------------------------------------------------------------------------------
    $if COMMON_LIBRARY = UNDEFINED Then
        ' We don't want an underscore prefix as we are writing this from scratch.
        ' Leading underscores are ugly. However, this will only be enabled if COMMON_LIBRARY is undefined
        ' COMMON_LIBRARY should be defined when developing libraries
        ' This will ensure the library works even if $NoPrefix is used
        $NoPrefix
    $End If

    ' All identifiers must default to long (32-bits). This results in fastest code execution on x86 & x64
    DefLng A-Z

    ' Force all variables to be defined
    Option Explicit

    ' Force all arrays to be defined
    Option ExplicitArray

    ' Start array lower bound from 1. If 0 is required this should be explicitly specified as (0 To X)
    Option Base 1

    ' All arrays should be static. If dynamic arrays are required use "ReDim"
    '$Static

    ' We want our window to be resizeable. "Smooth" is a personal preference. Use "Stretch" if preferred
    $Resize:Smooth

    ' We want all color constants
    $Color:32
    '-----------------------------------------------------------------------------------------------------

    '-----------------------------------------------------------------------------------------------------
    ' CONSTANTS
    '-----------------------------------------------------------------------------------------------------
    ' Some common and useful constants
    Const FALSE = 0, TRUE = Not FALSE
    Const NULL = 0
    Const NULLSTRING = ""
    '-----------------------------------------------------------------------------------------------------
$End If
'---------------------------------------------------------------------------------------------------------

