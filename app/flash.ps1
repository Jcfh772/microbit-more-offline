# Copies the Microbit More program (.hex) onto every plugged-in micro:bit.
# You only need to do this once per micro:bit.

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$hex = Get-ChildItem -LiteralPath (Join-Path $scriptDir 'firmware') -Filter '*.hex' | Select-Object -First 1

if (-not $hex) {
    Write-Host 'The micro:bit program (.hex) was not found in app\firmware.' -ForegroundColor Red
    exit 1
}

$disks = @(Get-WmiObject Win32_LogicalDisk)
$microbits = @($disks | Where-Object { $_.VolumeName -eq 'MICROBIT' })
$maintenance = @($disks | Where-Object { $_.VolumeName -eq 'MAINTENANCE' })

if ($microbits.Count -eq 0) {
    if ($maintenance.Count -gt 0) {
        Write-Host 'A micro:bit is in MAINTENANCE mode.' -ForegroundColor Yellow
        Write-Host 'Unplug it and plug it back in WITHOUT holding the reset button, then run this again.'
    } else {
        Write-Host 'No micro:bit found.' -ForegroundColor Yellow
        Write-Host 'Plug the micro:bit into a USB port with a data cable. It should appear in'
        Write-Host 'File Explorer as a drive called MICROBIT. Then run this again.'
    }
    exit 1
}

foreach ($d in $microbits) {
    $target = $d.DeviceID + '\'
    Write-Host "Copying $($hex.Name) to micro:bit on $($d.DeviceID) ..."
    Copy-Item -LiteralPath $hex.FullName -Destination $target -Force
}

Write-Host ''
Write-Host 'Done! The yellow light on the back of the micro:bit flashes while it installs.' -ForegroundColor Green
Write-Host 'When it shows "TILT TO FILL SCREEN", tilt it in every direction until all LEDs'
Write-Host 'are lit (this calibrates the compass). After that it is ready to connect.'
