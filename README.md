# Microbit More - Offline for Windows

An offline copy of the [Microbit More](https://microbit-more.github.io/) editor (Scratch 3 + micro:bit) that runs from a folder on any Windows 10/11 PC. **No internet needed**, **no installation** and **no admin rights**. It connects a **micro:bit V2 over the USB cable**.

## Download

👉 **[Download the zip (about 118 MB)](https://github.com/Jcfh772/microbit-more-offline/archive/refs/heads/main.zip)**

This is the same as clicking **Code → Download ZIP** on this page.

## Quick start

1. **Extract** the zip (right-click → *Extract All*). Don't run it from inside the zip.
2. **Once per micro:bit:** plug it in and double-click **`Install program on micro-bit.bat`**.
   When the micro:bit shows *TILT TO FILL SCREEN*, tilt it around until every LED is lit.
3. **Every time:** double-click **`Start Microbit More.bat`**. The editor opens in its own Microsoft Edge window (or Chrome if there's no Edge).
   A minimized *Microbit More* window also appears on the taskbar. Keep it open while you work and close it when you're done.
4. **Connect over USB:** hold **Shift** and click the orange **!** at the top of the *MicroBit More* blocks, then choose the micro:bit from the list.
   (Clicking **!** without Shift connects over Bluetooth instead.)

## Good to know

- **USB works with micro:bit V2 only.** The Microbit More program leaves the USB feature out on V1 boards because they don't have enough memory, so V1 boards can only connect over Bluetooth.
- **Projects** auto-save in the browser on that PC. To move one between PCs, or from the online editor, use *File → Save to your computer* (`.sb3`) and *File → Load from your computer*.
- **Offline limits:** the Sprite/Backdrop/Sound libraries, Text-to-Speech, Translate and Face Sensing need internet. Painting, uploading your own images and sounds, and all micro:bit blocks work offline.
- **Windows security warning** ("Windows protected your PC"): click *More info → Run anyway*. To avoid it, right-click the zip → *Properties* → tick **Unblock** before extracting.
- To use Chrome instead of Edge, edit `Start Microbit More.bat` and set `MBM_BROWSER=chrome`.

## How it works

Browsers only allow USB (Web Serial) access from a secure address, and a page opened by double-clicking a file doesn't count. So `Start Microbit More.bat` runs `app/server.ps1`, a tiny web server built on Windows PowerShell's built-in `HttpListener`. It serves `app/editor/` on `http://localhost:8765` and opens it in Edge or Chrome in app mode. The port stays the same every time so auto-saved projects keep working. Nothing is reachable from other computers.

| Path | What it is |
|---|---|
| `Start Microbit More.bat` | Starts the local server and opens the editor |
| `Install program on micro-bit.bat` | Copies the Microbit More program onto any plugged-in micro:bit |
| `app/editor/` | The Microbit More editor build (v2-0.3.2, from the official site, source maps removed) |
| `app/firmware/` | `microbit-mbit-more-v2-0_2_5.hex`, the micro:bit program linked by the official site |
| `app/server.ps1`, `app/flash.ps1` | The PowerShell scripts behind the two `.bat` files |

## Credits

Microbit More is made by Koji Yokokawa / [Yengawa Lab](https://lab.yengawa.com/) and built on Scratch 3.0 by the Scratch Foundation and MIT. This repo only repackages the official build for offline use and isn't affiliated with either. See [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for licences.

- Editor source: <https://github.com/microbit-more/microbit-more.github.io>
- Extension source: <https://github.com/microbit-more/mbit-more-v2>
- micro:bit program source: <https://github.com/microbit-more/pxt-mbit-more-v2>
