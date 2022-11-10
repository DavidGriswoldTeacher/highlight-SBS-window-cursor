#Include ./Utils.ahk
#SingleInstance, Force
#NoEnv
#MaxThreadsPerHotkey 3
#installmousehook
#MaxHotkeysPerInterval 100

SetBatchLines, -1
SetWinDelay, -1
CoordMode, mouse, screen
SetWorkingDir, %A_ScriptDir%

ClickEvents := []

SetupMouseSpotlight2()
{
    global
    SETTINGS := ReadConfigFile("settings.ini")
    InitializeSpotlightGUI2()
}

InitializeSpotlightGUI2(){ 
    global CursorSpotlightHwnd2, SETTINGS
    if (SETTINGS.cursorSpotlight.enabled == True)
    { 
        global CursorSpotlightDiameter := SETTINGS.cursorSpotlight.spotlightDiameter
        spotlightOuterRingWidth := SETTINGS.cursorSpotlight.spotlightOuterRingWidth
        Gui, CursorSpotlightWindow2: +HwndCursorSpotlightHwnd2 +AlwaysOnTop -Caption +ToolWindow +E0x20 ;+E0x20 click thru
        Gui, CursorSpotlightWindow2: Color, % SETTINGS.cursorSpotlight.spotlightColor
        Gui, CursorSpotlightWindow2: Show, x0 y0 w%CursorSpotlightDiameter% h%CursorSpotlightDiameter% NA
        WinSet, Transparent, % SETTINGS.CursorSpotlight.spotlightOpacity, ahk_id %CursorSpotlightHwnd2%
        ; Create a ring region to highlight the cursor
        finalRegion := DllCall("CreateEllipticRgn", "Int", 0, "Int", 0, "Int", CursorSpotlightDiameter / 2, "Int", CursorSpotlightDiameter)
        if (spotlightOuterRingWidth < CursorSpotlightDiameter/2)
        {
            inner := DllCall("CreateEllipticRgn", "Int", spotlightOuterRingWidth, "Int", spotlightOuterRingWidth, "Int", CursorSpotlightDiameter-spotlightOuterRingWidth, "Int", CursorSpotlightDiameter-spotlightOuterRingWidth)
            DllCall("CombineRgn", "UInt", finalRegion, "UInt", finalRegion, "UInt", inner, "Int", 3) ; RGN_XOR = 3                                      
            DllCall("DeleteObject", UInt, inner)
        }
        DllCall("SetWindowRgn", "UInt", CursorSpotlightHwnd2, "UInt", finalRegion, "UInt", true)
        SetTimer, DrawSpotlight2, 10
        Return


        DrawSpotlight2:
         ; SETTINGS.cursorSpotlight.enabled can be changed by other script such as Annotation.ahk
            if (SETTINGS.cursorSpotlight.enabled == True)
            {
                MouseGetPos, X, Y, WinID
                X -= CursorSpotlightDiameter / 4
                Offset := SETTINGS.cursorSpotlight.screenWidth / 2
                if (X > Offset)
                {
                    X -= Offset
                } else {
                    X += Offset
                }
                Y -= CursorSpotlightDiameter / 2
                WinMove, ahk_id %CursorSpotlightHwnd2%, , %X%, %Y%
                WinSet, AlwaysOnTop, On, ahk_id %CursorSpotlightHwnd2%
            }
            else
            {
                 WinMove, ahk_id %CursorSpotlightHwnd2%, , -999999999, -999999999
            }

        Return

    }
}

SetupMouseSpotlight2()
