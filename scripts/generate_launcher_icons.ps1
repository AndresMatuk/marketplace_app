Add-Type -AssemblyName System.Drawing

$root = Split-Path $PSScriptRoot -Parent
$source = Join-Path $root "assets\icon\app_icon.png"
if (-not (Test-Path $source)) {
    Write-Error "No se encontró $source"
    exit 1
}

function Save-ResizedIcon {
    param(
        [string]$DestPath,
        [int]$Size
    )

    $bmp = [System.Drawing.Image]::FromFile($source)
    $resized = New-Object System.Drawing.Bitmap $Size, $Size
    $graphics = [System.Drawing.Graphics]::FromImage($resized)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.DrawImage($bmp, 0, 0, $Size, $Size)

    $directory = Split-Path $DestPath -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $resized.Save($DestPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $resized.Dispose()
    $bmp.Dispose()
}

$androidSizes = @{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($folder in $androidSizes.Keys) {
    $dest = Join-Path $root "android\app\src\main\res\$folder\ic_launcher.png"
    Save-ResizedIcon -DestPath $dest -Size $androidSizes[$folder]
}

$iosIcons = @{
    "Icon-App-20x20@1x.png"     = 20
    "Icon-App-20x20@2x.png"     = 40
    "Icon-App-20x20@3x.png"     = 60
    "Icon-App-29x29@1x.png"     = 29
    "Icon-App-29x29@2x.png"     = 58
    "Icon-App-29x29@3x.png"     = 87
    "Icon-App-40x40@1x.png"     = 40
    "Icon-App-40x40@2x.png"     = 80
    "Icon-App-40x40@3x.png"     = 120
    "Icon-App-60x60@2x.png"     = 120
    "Icon-App-60x60@3x.png"     = 180
    "Icon-App-76x76@1x.png"     = 76
    "Icon-App-76x76@2x.png"     = 152
    "Icon-App-83.5x83.5@2x.png" = 167
    "Icon-App-1024x1024@1x.png" = 1024
}

$iosDir = Join-Path $root "ios\Runner\Assets.xcassets\AppIcon.appiconset"
foreach ($entry in $iosIcons.GetEnumerator()) {
    Save-ResizedIcon -DestPath (Join-Path $iosDir $entry.Key) -Size $entry.Value
}

$webDir = Join-Path $root "web\icons"
Save-ResizedIcon -DestPath (Join-Path $webDir "Icon-192.png") -Size 192
Save-ResizedIcon -DestPath (Join-Path $webDir "Icon-512.png") -Size 512
Save-ResizedIcon -DestPath (Join-Path $webDir "Icon-maskable-192.png") -Size 192
Save-ResizedIcon -DestPath (Join-Path $webDir "Icon-maskable-512.png") -Size 512

$favicon = Join-Path $root "web\favicon.png"
Save-ResizedIcon -DestPath $favicon -Size 32

Write-Host "Iconos generados correctamente desde $source"
