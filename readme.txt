Conputer Vision Challenge - Group 33

Instructions for running the challenge

Option 1: run from GUI

- execute start_gui.m
- click on "Choose Folder"
- select folder that contains all necessary files (im0.png, im1.png, ...)
- click on "Open"
- click on "Challenge"
- function challenge will be executed
- click on "Unittest"
- challenge will be run again, results of unit tests will be displayed
- unittests can also be run, before challenge, but no disparity map will be displayed
- elapsed time will be shown in command window

Option 2: execute challenge function

- execute challenge(%PATH_TO_FOLDER)
- disparity map will be shown as colormap
- results for disparity map, Rotation, Translation, PSNR can be obtained from return values
- elapsed time will be shown in command window

Option 3: execute unittests

- execute unittest(%PATH_TO_FOLDER)
- challenge.m will be run
- results of unittests will be shown in command window


