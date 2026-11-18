MICROBIT MORE - OFFLINE EDITOR FOR WINDOWS
==========================================

The Microbit More editor (https://microbit-more.github.io/editor), packaged to run
from this folder with no internet. No installation and no admin rights needed.
Works on Windows 10 / 11 with Microsoft Edge (built in) or Google Chrome.

Editor: Microbit More v2-0.3.2 (copy of the online editor as of 2026-10-07)
micro:bit program: microbit-mbit-more-v2-0_2_5.hex (the one the official site links)


FIRST TIME SETUP
----------------
1. Extract the whole zip file (right-click > Extract All). Do not run it from
   inside the zip. You can copy the extracted folder to a USB stick or any PC.

2. Put the Microbit More program on each micro:bit (once per micro:bit):
   - Plug the micro:bit in with a USB data cable.
   - Double-click "Install program on micro-bit.bat".
     (Or drag app\firmware\microbit-mbit-more-v2-0_2_5.hex onto the MICROBIT drive.)
   - When the micro:bit shows "TILT TO FILL SCREEN", tilt it around until all
     LEDs are lit.


EVERY TIME
----------
1. Double-click "Start Microbit More.bat".
   The editor opens in its own window. A minimized "Microbit More" window also
   appears on the taskbar - leave it open while you work, close it when done.

2. The "MicroBit More" blocks are already loaded - click "MicroBit More" at the
   bottom of the block categories on the left.

3. Connect over USB:
   - Plug the micro:bit in with the USB cable.
   - HOLD the SHIFT key and click the orange "!" button at the top of the
     MicroBit More blocks.
   - A small window lists serial ports. Pick the micro:bit (shown as
     "mbed Serial Port" or "BBC micro:bit CMSIS-DAP") and click Connect.
   - The "!" turns into a green tick when connected.

   Clicking "!" WITHOUT Shift connects over Bluetooth instead.


GOOD TO KNOW
------------
* USB connection works with micro:bit V2 only. Older V1 boards don't have
  room for the USB feature and can only connect over Bluetooth.
* Close other programs that use the micro:bit's serial port first (MakeCode,
  Mu, Arduino serial monitor, another editor tab) - only one can use it at a time.
* Your work auto-saves in the browser on this PC. To move a project to another
  PC, use File > "Save to your computer" (.sb3) and File > "Load from your
  computer" on the other PC.
  Projects auto-saved on the online site do not appear here (different address),
  so save them as .sb3 from the online editor first, then load them here.
* Without internet, the Sprite / Backdrop / Sound libraries show no pictures
  and can't be added. You can still paint your own, upload image/sound files,
  and use the default cat. Text-to-Speech, Translate and Face Sensing need
  internet too.
* To use Chrome instead of Edge, open "Start Microbit More.bat" in Notepad and
  change   set "MBM_BROWSER=auto"   to   set "MBM_BROWSER=chrome"


TROUBLESHOOTING
---------------
* "Windows protected your PC" / security warning: click "More info" > "Run
  anyway". To stop the warnings, right-click the zip > Properties > tick
  "Unblock" > OK, BEFORE extracting.
* Nothing happens when starting: some school or company PCs block PowerShell.
  Ask the IT admin to allow it, or use the online editor.
* The micro:bit isn't in the USB list: try a different cable (some cables are
  charge-only), make sure the micro:bit program was installed (step 2 above),
  and close MakeCode or other apps using the micro:bit.
* Editor shows an old version after updating this folder: press Ctrl+F5 in the
  editor window.

Microbit More is made by Yengawa Lab (https://lab.yengawa.com/) and is based on
Scratch 3.0 by the Scratch Foundation. See https://microbit-more.github.io/ for
documentation and licences.
