# GM Arcball Camera
 A Blender-like viewport camera for GameMaker

To get started:
1. Simply import the script to your project.
2. Create the camera struct in an objects create-event like this: ```cam = new arcball_camera(); ```
3. Set the cameras projection matrix using ```cam.set_projection(_proj)```
5. In that same objects step-event call the update function like this: ```cam.update();```
6. In that objects draw event you can then apply the camera using ```cam.apply();```
7. Have Fun! Default values can be changed inside the script.
   
The controls mimic that of the Blender view-port camera fairly accurately. 
- Holding the middle-mouse button you can orbit around the target position.
- If you hold shift with the middle-mouse button you will instead pan against the viewing axis.
- The Number pad buttons will snap the camera to be axis aligned, except for 2, 4, 8, 6, which rotate the camera on the View-Up and View-Right axis respectively.
- The scroll-wheel will zoom the camera in and out.

Things to note:
- This camera uses a combination of quaternions and vectors all represented and stored in small arrays. This script would be much cleaner using a seperate vector/quaternion library though for the purposes of an all-in-one solution I included everything needed for the base system inside of a single script.
- Over-writing values (specifically the vectors) inside of the camera every frame can cause issues such as cause Gimble-Lock, which is one of the primary issues this camera is intended to avoid. If you do this make sure you know what you are doing.
- If you want to modify the way the controls work then you can simply look for the ```control()``` function inside of the script. You will find the default controls in there.
- The ```dir``` value in the struct is misleading, and points from the center to the view_pos rather than the opposite.
- The intended use of this is primarily as a convienent system for quick prototyping or to use while showing off other systems.

Pro Tip! I recommend setting up an input response for the period-key that resets the target_pos of the camera to the position of a selected object. This has been a very useful shortcut for me, and is also based on Blender as well. 
