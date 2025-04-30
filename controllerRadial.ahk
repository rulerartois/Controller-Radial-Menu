/*  XInput by Lexikos
 *  Requires AutoHotkey 1.1+.
 */

/*
    Function: XInput_Init

    Initializes XInput.ahk with the given XInput DLL.

    Parameters:
        dll     -   The path or name of the XInput DLL to load.
*/
XInput_Init(dll:="")
{
    global
    if _XInput_hm
        return

    ;======== CONSTANTS DEFINED IN XINPUT.H ========

    ; NOTE: These are based on my outdated copy of the DirectX SDK.
    ;       Newer versions of XInput may require additional constants.

    ; Device types available in XINPUT_CAPABILITIES
    XINPUT_DEVTYPE_GAMEPAD          := 0x01

    ; Device subtypes available in XINPUT_CAPABILITIES
    XINPUT_DEVSUBTYPE_GAMEPAD       := 0x01

    ; Flags for XINPUT_CAPABILITIES
    XINPUT_CAPS_VOICE_SUPPORTED     := 0x0004

    ; Constants for gamepad buttons
    XINPUT_GAMEPAD_DPAD_UP          := 0x0001
    XINPUT_GAMEPAD_DPAD_DOWN        := 0x0002
    XINPUT_GAMEPAD_DPAD_LEFT        := 0x0004
    XINPUT_GAMEPAD_DPAD_RIGHT       := 0x0008
    XINPUT_GAMEPAD_START            := 0x0010
    XINPUT_GAMEPAD_BACK             := 0x0020
    XINPUT_GAMEPAD_LEFT_THUMB       := 0x0040
    XINPUT_GAMEPAD_RIGHT_THUMB      := 0x0080
    XINPUT_GAMEPAD_LEFT_SHOULDER    := 0x0100
    XINPUT_GAMEPAD_RIGHT_SHOULDER   := 0x0200
    XINPUT_GAMEPAD_GUIDE            := 0x0400
    XINPUT_GAMEPAD_A                := 0x1000
    XINPUT_GAMEPAD_B                := 0x2000
    XINPUT_GAMEPAD_X                := 0x4000
    XINPUT_GAMEPAD_Y                := 0x8000

    ; Gamepad thresholds
    XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  := 7849
    XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE := 8689
    XINPUT_GAMEPAD_TRIGGER_THRESHOLD    := 30

    ; Flags to pass to XInputGetCapabilities
    XINPUT_FLAG_GAMEPAD             := 0x00000001

    ;=============== END CONSTANTS =================

    if (dll = "")
        Loop %A_WinDir%\System32\XInput1_*.dll
            dll := A_LoopFileName
    if (dll = "")
        dll := "XInput1_3.dll"

    _XInput_hm := DllCall("LoadLibrary" ,"str",dll ,"ptr")

    if !_XInput_hm
        throw Exception("Failed to initialize XInput: " dll " not found.")

   (_XInput_GetState        := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"ptr",100 ,"ptr"))
|| (_XInput_GetState        := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputGetState" ,"ptr"))
    _XInput_SetState        := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputSetState" ,"ptr")
    _XInput_GetCapabilities := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputGetCapabilities" ,"ptr")

    if !(_XInput_GetState && _XInput_SetState && _XInput_GetCapabilities)
    {
        XInput_Term()
        throw Exception("Failed to initialize XInput: function not found.")
    }
}

/*
    Function: XInput_GetState

    Retrieves the current state of the specified controller.

    Parameters:
        UserIndex   -   [in] Index of the user's controller. Can be a value from 0 to 3.

    Returns:
        The current state of the controller as an associative array.

    ErrorLevel:
        If the function succeeds, ErrorLevel is ERROR_SUCCESS (zero).
        If the controller is not connected, ErrorLevel is ERROR_DEVICE_NOT_CONNECTED (1167).
        If the function fails, ErrorLevel is an error code defined in Winerror.h.
            http://msdn.microsoft.com/en-us/library/ms681381.aspx

    Remarks:
        XInput.dll returns controller state as a binary structure:
            http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.xinput_state
            http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.xinput_gamepad
*/
XInput_GetState(UserIndex)
{
    global _XInput_GetState

    VarSetCapacity(xiState,16)

    if ErrorLevel := DllCall(_XInput_GetState ,"uint",UserIndex ,"uint",&xiState)
        return 0

    return {
    (Join,
        dwPacketNumber: NumGet(xiState,  0, "UInt")
        wButtons:       NumGet(xiState,  4, "UShort")
        bLeftTrigger:   NumGet(xiState,  6, "UChar")
        bRightTrigger:  NumGet(xiState,  7, "UChar")
        sThumbLX:       NumGet(xiState,  8, "Short")
        sThumbLY:       NumGet(xiState, 10, "Short")
        sThumbRX:       NumGet(xiState, 12, "Short")
        sThumbRY:       NumGet(xiState, 14, "Short")
    )}
}

/*
    Function: XInput_SetState

    Sends data to a connected controller. This function is used to activate the vibration
    function of a controller.

    Parameters:
        UserIndex       -   [in] Index of the user's controller. Can be a value from 0 to 3.
        LeftMotorSpeed  -   [in] Speed of the left motor, between 0 and 65535.
        RightMotorSpeed -   [in] Speed of the right motor, between 0 and 65535.

    Returns:
        If the function succeeds, the return value is 0 (ERROR_SUCCESS).
        If the controller is not connected, the return value is 1167 (ERROR_DEVICE_NOT_CONNECTED).
        If the function fails, the return value is an error code defined in Winerror.h.
            http://msdn.microsoft.com/en-us/library/ms681381.aspx

    Remarks:
        The left motor is the low-frequency rumble motor. The right motor is the
        high-frequency rumble motor. The two motors are not the same, and they create
        different vibration effects.
*/
XInput_SetState(UserIndex, LeftMotorSpeed, RightMotorSpeed)
{
    global _XInput_SetState
    return DllCall(_XInput_SetState ,"uint",UserIndex ,"uint*",LeftMotorSpeed|RightMotorSpeed<<16)
}

/*
    Function: XInput_GetCapabilities

    Retrieves the capabilities and features of a connected controller.

    Parameters:
        UserIndex   -   [in] Index of the user's controller. Can be a value in the range 0–3.
        Flags       -   [in] Input flags that identify the controller type.
                                0   - All controllers.
                                1   - XINPUT_FLAG_GAMEPAD: Xbox 360 Controllers only.

    Returns:
        The controller capabilities, as an associative array.

    ErrorLevel:
        If the function succeeds, ErrorLevel is 0 (ERROR_SUCCESS).
        If the controller is not connected, ErrorLevel is 1167 (ERROR_DEVICE_NOT_CONNECTED).
        If the function fails, ErrorLevel is an error code defined in Winerror.h.
            http://msdn.microsoft.com/en-us/library/ms681381.aspx

    Remarks:
        XInput.dll returns capabilities via a binary structure:
            http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.xinput_capabilities
*/
XInput_GetCapabilities(UserIndex, Flags)
{
    global _XInput_GetCapabilities

    VarSetCapacity(xiCaps,20)

    if ErrorLevel := DllCall(_XInput_GetCapabilities ,"uint",UserIndex ,"uint",Flags ,"ptr",&xiCaps)
        return 0

    return,
    (Join
        {
            Type:                   NumGet(xiCaps,  0, "UChar"),
            SubType:                NumGet(xiCaps,  1, "UChar"),
            Flags:                  NumGet(xiCaps,  2, "UShort"),
            Gamepad:
            {
                wButtons:           NumGet(xiCaps,  4, "UShort"),
                bLeftTrigger:       NumGet(xiCaps,  6, "UChar"),
                bRightTrigger:      NumGet(xiCaps,  7, "UChar"),
                sThumbLX:           NumGet(xiCaps,  8, "Short"),
                sThumbLY:           NumGet(xiCaps, 10, "Short"),
                sThumbRX:           NumGet(xiCaps, 12, "Short"),
                sThumbRY:           NumGet(xiCaps, 14, "Short")
            },
            Vibration:
            {
                wLeftMotorSpeed:    NumGet(xiCaps, 16, "UShort"),
                wRightMotorSpeed:   NumGet(xiCaps, 18, "UShort")
            }
        }
    )
}

/*
    Function: XInput_Term
    Unloads the previously loaded XInput DLL.
*/
XInput_Term() {
    global
    if _XInput_hm
        DllCall("FreeLibrary","uint",_XInput_hm), _XInput_hm :=_XInput_GetState :=_XInput_SetState :=_XInput_GetCapabilities :=0
}

/*
	Function: Naive_Circle
	Naively obtains the quadrant the joystick is in
*/
Naive_Circle_Quadrant(sThumbX, sThumbY){
	if (sThumbX > 200) { ;possibility to do it via pie quadrants?
		if (sThumbX <= 16384) and (sThumbY >= 16384) {
			;MsgBox, 1
			ControlSend , , {Numpad1 down}, FINAL FANTASY XIV
		}
		else if (sThumbX >= 16384) and (sThumbY >= 16384) {
			;MsgBox, 2
			ControlSend , , {Numpad2 down}, FINAL FANTASY XIV
		}
		else if ((sThumbX >= 16384) and (sThumbY >= -16384) or (sThumbX >= 16384 and sThumbY < 16384)) {
			;MsgBox, 3
			ControlSend , , {Numpad3 down}, FINAL FANTASY XIV
		}
		else if (sThumbX <= 16384) and (sThumbY <= -16384) {
			;MsgBox, 4
			ControlSend , , {Numpad4 down}, FINAL FANTASY XIV
		}
	}
	else if (sThumbX < 200) {
		if (sThumbX >= -16384) and (sThumbY <= -16384) {
			ControlSend , , {Numpad5 down}, FINAL FANTASY XIV
		}
		;untested

		else if (sThumbX <= -16384) and (sThumbY >= 16384) {
			ControlSend , , {Numpad7 down}, FINAL FANTASY XIV
		}
		else if (sThumbX >= -16384) and (sThumbY >= 16384) {
			ControlSend , , {Numpad8 down}, FINAL FANTASY XIV
		}
		else if (sThumbX <= -16384) and (sThumbY >= -16384) {
			ControlSend , , {Numpad6 down}, FINAL FANTASY XIV
		}
	}
}


Tan_Circle_Quadrant(sThumbX, sThumbY) {
	angle := atan2(sThumbX, sThumbY) * 57.2957795
	;FileAppend, %angle%`n, C:/Users/D/Downloads/xinput.des
	;MsgBox % angle
	return angle
}

atan2(y,x) { ; y then x
  if (x > 0)
    return atan(y/x)
  if (x < 0) ; && (y <> 0)
    return atan(y/x) + 3.1415926535898 * ((y >= 0) ? 1.0 : -1.0)
  if (y <> 0) ; && (x = 0)
    return 1.5707963267949 * ((y >= 0) ? 1.0 : -1.0)
  return 0.0
} ; by Raccoon 2019


Braindead_Switch(angle, debug) {
    ;global adjustedAngle
    if (angle < 112.5) and (angle > 67.5) {
        ControlSend , , {Numpad1 down}, FINAL FANTASY XIV
        Sleep 100
        ControlSend , , {Numpad1 up}, FINAL FANTASY XIV
    }
    else if (angle < 67.5) and (angle > 22.5) {
        ControlSend , , {Numpad2 down}, FINAL FANTASY XIV
        Sleep 100
        ControlSend , , {Numpad2 up}, FINAL FANTASY XIV
    }
    else if (angle < 22.5) and (angle > -22.5) {
        ControlSend , , {Numpad3 down}, FINAL FANTASY XIV
        Sleep 100
        ControlSend , , {Numpad3 up}, FINAL FANTASY XIV
    }
    else if (angle < -22.5) and (angle > -67.5) {
        ControlSend , , {Numpad4 down}, FINAL FANTASY XIV
        Sleep 100
        ControlSend , , {Numpad4 up}, FINAL FANTASY XIV
    }
    else if (angle < -67.5) and (angle > -112.5) {
        ControlSend , , {Numpad5 down}, FINAL FANTASY XIV
        Sleep 100
        ControlSend , , {Numpad5 up}, FINAL FANTASY XIV
    }
    else if (angle < -112.5) and (angle > -157.5) {
        ControlSend , , {Numpad6 down}, FINAL FANTASY XIV
        Sleep 100
        ControlSend , , {Numpad6 up}, FINAL FANTASY XIV
    }
    else if (angle < -157.5 and angle > -181) or (angle > 157.5 and angle < 181)  {
        ControlSend , , {Numpad7 down}, FINAL FANTASY XIV
        Sleep 100
        ControlSend , , {Numpad7 up}, FINAL FANTASY XIV
    }     
    else if (angle < 157.5) and (angle > 112.5) {
        ControlSend , , {Numpad8 down}, FINAL FANTASY XIV
        Sleep 100
        ControlSend , , {Numpad8 up}, FINAL FANTASY XIV
    }
	if (debug) {
		MsgBox, %angle%
	}
}

;MsgBox, desu
;adjustedAngle = -22.5
; TODO: XInputEnable, 'GetBatteryInformation and 'GetKeystroke.
XInput_Init()
Loop {
    Loop, 4 {
        if State := XInput_GetState(A_Index-1) {
			debug = 0
			sThumbLX := State.sThumbLX
			sThumbLY := State.sThumbLY
			sThumbRX := State.sThumbRX
			sThumbRY := State.sThumbRY
			;String := %sThumbLX% , %sThumbLY%
			;MsgBox % String ;State.sThumbLX + , + State.sThumbLY
			sThumbX := sThumbRX
			sThumbY := sThumbRY
			butone := State.wButtons + 0 ;force this to be an int
			;MsgBox, Butone: %butone% ;uncomment for testing vVv

			If (butone & 256) ;Should work if LShoulder is pressed. Can contain any combination of numbers. 256 is LShoulder. 512 is RShoulder. 64 is L3
			{
				if (sThumbX > 10000 or sThumbY > 10000 or sThumbX < -10000 or sThumbY < -10000) ;we don't want deadzoned values
					{
					;MsgBox, "We're in"
					;Naive_Circle_Quadrant(sThumbLX, sThumbLY)
					x := sThumbY/sThumbX
					angle := 0
					angle := Tan_Circle_Quadrant(sThumbRY, sThumbRX)
					Braindead_Switch(angle, debug)
					;32768
					;sThumbLX := State.sThumbLX
					;String := StrGet(sThumbLX) ;, %MsgBox % Y:%State.sThumbLY%
					;MsgBox % %sThumbLX% + 0
				}
			}
			;If (butone = 16) {
			;	Exit
			;}
			ControlSend , , B down}, testingKeys.txt - Notepad
            ;LT := State.bLeftTrigger
			; MsgBox % State.bLeftTrigger
            ;RT := State.bRightTrigger
            ;XInput_SetState(A_Index-1, LT*257, RT*257)
        }
    }
    Sleep, 20
}