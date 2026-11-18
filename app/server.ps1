# Microbit More - offline launcher
# Serves the editor from this folder on http://localhost and opens it in Edge/Chrome.
# No install and no admin rights needed. Close this window to stop the editor.

param(
    [int]$Port = 8765,
    [string]$Browser = 'auto',   # auto | edge | chrome | default
    [switch]$NoBrowser
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = [IO.Path]::GetFullPath((Join-Path $scriptDir 'editor'))
if (-not $root.EndsWith('\') -and -not $root.EndsWith('/')) { $root += [IO.Path]::DirectorySeparatorChar }
$pingPath = '/__microbit_more_offline_ping'
$pingToken = 'microbit-more-offline-ok'

try { $Host.UI.RawUI.WindowTitle = 'Microbit More - keep this window open (close it to stop)' } catch { }

function Show-Error([string]$msg) {
    Write-Host ''
    Write-Host $msg -ForegroundColor Red
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [void][System.Windows.Forms.MessageBox]::Show($msg, 'Microbit More offline')
    } catch { }
}

function Test-OurServer([int]$p) {
    try {
        $req = [Net.HttpWebRequest]::Create("http://localhost:$p$pingPath")
        $req.Timeout = 2000
        $req.ReadWriteTimeout = 2000
        $req.Proxy = $null
        $resp = $req.GetResponse()
        try {
            $reader = New-Object IO.StreamReader($resp.GetResponseStream())
            $body = $reader.ReadToEnd()
        } finally { $resp.Close() }
        return ($body -eq $pingToken)
    } catch { return $false }
}

function Find-Exe([string[]]$candidates) {
    foreach ($c in $candidates) {
        if ($c -and (Test-Path -LiteralPath $c)) { return $c }
    }
    return $null
}

function Open-Editor([string]$url) {
    if ($NoBrowser) { return }
    $pf = $env:ProgramFiles
    $pf86 = ${env:ProgramFiles(x86)}
    $lad = $env:LOCALAPPDATA
    $edge = Find-Exe @(
        "$pf86\Microsoft\Edge\Application\msedge.exe",
        "$pf\Microsoft\Edge\Application\msedge.exe",
        "$lad\Microsoft\Edge\Application\msedge.exe")
    $chrome = Find-Exe @(
        "$pf\Google\Chrome\Application\chrome.exe",
        "$pf86\Google\Chrome\Application\chrome.exe",
        "$lad\Google\Chrome\Application\chrome.exe")

    $choice = $Browser.ToLower()
    $exe = $null
    if ($choice -eq 'edge') { $exe = $edge }
    elseif ($choice -eq 'chrome') { $exe = $chrome }
    elseif ($choice -ne 'default') {
        if ($edge) { $exe = $edge } else { $exe = $chrome }
    }

    try {
        if ($exe) {
            # --app opens the editor in its own window, like a desktop app.
            Start-Process -FilePath $exe -ArgumentList "--app=$url"
        } else {
            Write-Host 'Edge/Chrome not found - opening your default browser.' -ForegroundColor Yellow
            Write-Host 'USB connection needs Microsoft Edge or Google Chrome (version 89 or newer).' -ForegroundColor Yellow
            Start-Process $url
        }
    } catch {
        Show-Error "Could not open the browser automatically.`n`nOpen Microsoft Edge or Google Chrome and go to:`n$url"
    }
}

if (-not (Test-Path -LiteralPath (Join-Path $root 'index.html'))) {
    Show-Error "Editor files not found in:`n$root`n`nPlease extract the whole zip file first, then run 'Start Microbit More.bat' again."
    exit 1
}

$mime = @{
    '.html' = 'text/html; charset=utf-8'; '.htm' = 'text/html; charset=utf-8'
    '.js' = 'application/javascript; charset=utf-8'; '.mjs' = 'application/javascript; charset=utf-8'
    '.css' = 'text/css; charset=utf-8'; '.json' = 'application/json; charset=utf-8'
    '.txt' = 'text/plain; charset=utf-8'; '.svg' = 'image/svg+xml'
    '.png' = 'image/png'; '.gif' = 'image/gif'; '.jpg' = 'image/jpeg'; '.jpeg' = 'image/jpeg'
    '.ico' = 'image/x-icon'; '.cur' = 'image/x-icon'; '.webp' = 'image/webp'
    '.wav' = 'audio/wav'; '.mp3' = 'audio/mpeg'; '.ogg' = 'audio/ogg'
    '.wasm' = 'application/wasm'; '.woff' = 'font/woff'; '.woff2' = 'font/woff2'; '.ttf' = 'font/ttf'
    '.hex' = 'application/octet-stream'; '.tflite' = 'application/octet-stream'
}

# --- Pick a port: reuse a running copy, or start a new server -------------------
# The same port is used every time on purpose: the editor keeps its auto-saved
# projects in browser storage, which is tied to the address (including the port).
$listener = $null
$url = $null
for ($p = $Port; $p -lt $Port + 10; $p++) {
    if (Test-OurServer $p) {
        Write-Host "Microbit More is already running on http://localhost:$p/ - opening it."
        Open-Editor "http://localhost:$p/"
        exit 0
    }
    $l = New-Object System.Net.HttpListener
    $l.Prefixes.Add("http://localhost:$p/")
    try {
        $l.Start()
        $listener = $l
        $url = "http://localhost:$p/"
        break
    } catch {
        try { $l.Close() } catch { }
    }
}

if (-not $listener) {
    Show-Error "Could not start the local editor server (ports $Port-$($Port + 9) are busy or blocked).`n`nTry restarting the computer, then run 'Start Microbit More.bat' again."
    exit 1
}

if ($url -ne "http://localhost:$Port/") {
    Write-Host "Note: port $Port was busy, using $url instead." -ForegroundColor Yellow
    Write-Host 'Projects auto-saved under the usual port will not show up in this session.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host '  Microbit More (offline) is running at' -NoNewline
Write-Host " $url" -ForegroundColor Green
Write-Host ''
Write-Host '  Keep this window open while you use the editor.'
Write-Host '  Close this window (or press Ctrl+C) when you are done.'
Write-Host ''
Write-Host '  USB connection (micro:bit V2): hold SHIFT and click the Connect button.'
Write-Host ''

Open-Editor $url

# --- Serve files ----------------------------------------------------------------
$buffer = New-Object byte[] 262144

function Send-Text($res, [int]$code, [string]$text) {
    $bytes = [Text.Encoding]::UTF8.GetBytes($text)
    $res.StatusCode = $code
    $res.ContentType = 'text/plain; charset=utf-8'
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
}

function Handle-Request($ctx) {
    $req = $ctx.Request
    $res = $ctx.Response
    $res.AddHeader('X-Content-Type-Options', 'nosniff')

    if ($req.HttpMethod -ne 'GET' -and $req.HttpMethod -ne 'HEAD') {
        Send-Text $res 405 'Method not allowed'
        return
    }

    $path = [Uri]::UnescapeDataString($req.Url.AbsolutePath)
    if ($path -eq $pingPath) {
        Send-Text $res 200 $pingToken
        return
    }
    if ($path.EndsWith('/')) { $path += 'index.html' }

    $relative = $path.TrimStart('/').Replace('/', [IO.Path]::DirectorySeparatorChar)
    $full = $null
    try { $full = [IO.Path]::GetFullPath([IO.Path]::Combine($root, $relative)) } catch { $full = $null }
    if (-not $full -or -not $full.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) {
        Send-Text $res 403 'Forbidden'
        return
    }

    if ([IO.Directory]::Exists($full)) {
        $res.StatusCode = 301
        $res.RedirectLocation = $req.Url.AbsolutePath + '/'
        return
    }
    if (-not [IO.File]::Exists($full)) {
        Send-Text $res 404 'Not found'
        return
    }

    $info = New-Object IO.FileInfo($full)
    $ticks = $info.LastWriteTimeUtc.Ticks
    $ticks = $ticks - ($ticks % [TimeSpan]::TicksPerSecond)
    $modified = New-Object DateTime($ticks, [DateTimeKind]::Utc)
    $res.AddHeader('Last-Modified', $modified.ToString('r'))
    $res.AddHeader('Cache-Control', 'no-cache')

    $ims = $req.Headers['If-Modified-Since']
    if ($ims) {
        $since = [DateTime]::MinValue
        $styles = [Globalization.DateTimeStyles]::AdjustToUniversal -bor [Globalization.DateTimeStyles]::AssumeUniversal
        if ([DateTime]::TryParse($ims, [Globalization.CultureInfo]::InvariantCulture, $styles, [ref]$since)) {
            if ($modified -le $since) {
                $res.StatusCode = 304
                return
            }
        }
    }

    $ext = [IO.Path]::GetExtension($full).ToLower()
    $type = $mime[$ext]
    if (-not $type) { $type = 'application/octet-stream' }
    $res.StatusCode = 200
    $res.ContentType = $type
    $res.ContentLength64 = $info.Length

    if ($req.HttpMethod -eq 'HEAD') { return }

    $fs = [IO.File]::OpenRead($full)
    try {
        $out = $res.OutputStream
        while (($n = $fs.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $out.Write($buffer, 0, $n)
        }
    } finally {
        $fs.Dispose()
    }
}

try {
    while ($listener.IsListening) {
        $async = $listener.BeginGetContext($null, $null)
        # Wait in short steps so Ctrl+C can stop the server.
        while (-not $async.AsyncWaitHandle.WaitOne(500)) { }
        $ctx = $null
        try {
            $ctx = $listener.EndGetContext($async)
            Handle-Request $ctx
        } catch {
            # Browser closed the connection early, etc. Keep serving.
        } finally {
            if ($ctx) { try { $ctx.Response.Close() } catch { } }
        }
    }
} finally {
    try { $listener.Stop(); $listener.Close() } catch { }
}
