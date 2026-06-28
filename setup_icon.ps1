# DeepHeal - Setup App Icon Script
# Copies and resizes the generated logo into all Android mipmap folders

param(
    [string]$SourceIcon = "C:\Users\home\.gemini\antigravity-ide\brain\42503ab1-6116-4560-8f9d-a3f8d88b50b7\deepheal_logo_1782675350934.png"
)

Add-Type -AssemblyName System.Drawing

function Resize-Image {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [int]$Width,
        [int]$Height
    )
    
    $srcImage = [System.Drawing.Image]::FromFile($InputPath)
    $destImage = New-Object System.Drawing.Bitmap($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($destImage)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.DrawImage($srcImage, 0, 0, $Width, $Height)
    $destImage.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $destImage.Dispose()
    $srcImage.Dispose()
    Write-Host "  Created: $OutputPath ($Width x $Height)"
}

$basePath = "C:\Users\home\StudioProjects\deepheal\android\app\src\main\res"

$densities = @{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
}

Write-Host "Setting up DeepHeal app icon..."
foreach ($density in $densities.GetEnumerator()) {
    $dir = Join-Path $basePath $density.Key
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
    $outputFile = Join-Path $dir "ic_launcher.png"
    Resize-Image -InputPath $SourceIcon -OutputPath $outputFile -Width $density.Value -Height $density.Value
}

Write-Host ""
Write-Host "Done! App icon set for all densities."
