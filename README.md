## Explanation:

This is a small script for Final Fantasy XIV that allows you to target players in your party list using your controller's joystick by selecting the player in a radial menu and triggering a button.
This is only supported on XBox Controllers. It might also work via [DS4](https://ds4-windows.com/) on Playstation Controllers.

## Demonstration:
https://www.youtube.com/watch?v=B6f7q-x4PP4

![healer controller-3](https://github.com/user-attachments/assets/82a02fa3-9a3d-4bde-a381-9c41e55897c2) 

Party member 1 will be targeted if the joystick is angled in the northmost octant and rotates clockwise sequentially.

## To use:

Download the controllerRadial.zip in the releases https://github.com/rulerartois/Controller-Radial-Menu/releases This contains multiple files:
  - `controllerRadial.exe` which (by default) uses the `LB` to trigger and selects where the `Right Joystick` is currently pushed towards.
  - `config.ini` - user configuration where you may change certain configurations such as if you'd like to use different buttons/joysticks. I've provided some (limited) data on which value correlate to specific buttons.
  - the other 2 files are images for the GUI.

This will now require some setup on your end.

 - Download the zip file, extract it and run the `controllerRadial.exe` (if you don't feel comfortable downloading random .exe's from strangers then I've provided the source code in the file named `controllerRadial.ahk`. You can use the source to check the code and compile yourself (https://www.autohotkey.com/ -> Download/Install and run Ahk2Exe with that file as the input).
   Alternatively if you're still feeing uncomfortable please don't use it.
 - In FFXIV go to Keybind `/keybind` -> Targeting -> Target Member 1 in Party List -> `Numpad1`
 - Repeat for `Numpad2-8`
![Hotkeys Numpad](https://github.com/user-attachments/assets/183127c8-664d-4d84-8a52-78bc33487b21)

Now start the program and in-game while in a party rotate your `Right Joystick` and press your trigger button (by default `LB` or Left Bumper) and you should see your target change.
To close the program please navigate to your system tray (`Win` + `B`) and right click the program and click Exit.

## TODO:
- Make the GUI configurable!
- Make it configurable via the user so they can change which buttons/joysticks perform the 2 relevant actions
- Potentially have a "snapback" that reverts back to the previous target (when LB was held down) that runs the command `/targetlastenemy` since there's no way of reading data from the game.
- Add automatic IniWriting in case the config.ini file is not present or a key is missing
- Add automatically downloading images from github to avoid having to package them in a zip file
