## Explanation:

This is a small ahk script that allows you to switch targets in your party list by using your controller's joystick to select the player and a button to confirm.
This currently only works on XBox Controllers. I have heard of success with using DS4 on Playstation Controllers.

## Demonstration:
https://www.youtube.com/watch?v=B6f7q-x4PP4

![healer controller-3](https://github.com/user-attachments/assets/67f3c8fc-d03b-4139-be45-0a4193be75e4)

## To use:

Download the controllerRadial.exe or other variant you want in the releases https://github.com/rulerartois/Controller-Radial-Menu/releases. Currently there are:
  - controllerRadial.exe which uses the LB to trigger and select where the Right Joystick is currently facing.
  - controllerRadial-L3.exe which uses the L3 button to trigger and select where the Right Joystick is currently facing.

If you'd like a custom one using a different button configuration made please feel free to message me and I'll try to accomodate but no promises...

This will now require some setup on your end.

 - Simply download the relevant .exe file (if you don't feel comfortable downloading random .exe's from strangers then I've provided the source code (called controllerRadial.ahk) you can use to check and compile yourself (https://www.autohotkey.com/) or alternatively just don't use it.)
 - In FFXIV go to Keybind (/keybind) -> Targeting -> Target Member 1 in Party List -> Numpad1
 - Repeat for Numpad2-8
![Hotkeys Numpad](https://github.com/user-attachments/assets/183127c8-664d-4d84-8a52-78bc33487b21)

Now in-game while in a party rotate your Right Joystick and press your trigger button (ex. LB) and you should see your target change.

## TODO:
Add a GUI showing the Octants and where your joystick currently is (and what it's selecting)

Make that window configurable!

Make it configurable via the user so they can change which buttons/joysticks perform the 2 relevant actions

Potentially have a "snapback" that reverts back to the previous target (when LB was held down) that runs the command (/targetlastenemy) since there's no way of reading data from the game.
