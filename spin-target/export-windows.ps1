# Экспорт Windows (release). Нужны Godot 4.4.1 и шаблоны той же версии.
# Редактор: переменная GODOT, или Godot в PATH, или tools\Godot_win64 (портативная сборка 4.4.1).
$ErrorActionPreference = "Stop"
$projectRoot = $PSScriptRoot
$outDir = Join-Path (Split-Path $projectRoot -Parent) "build\pc"
$outExe = Join-Path $outDir "SpinTarget.exe"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$godot = $env:GODOT
if (-not $godot) {
  $cmd = Get-Command godot -ErrorAction SilentlyContinue
  if ($cmd) { $godot = $cmd.Source }
}
if (-not $godot) {
  $cand = Join-Path $projectRoot "tools\Godot_win64\Godot_v4.4.1-stable_win64_console.exe"
  if (Test-Path $cand) { $godot = $cand }
}
if (-not $godot -or -not (Test-Path $godot)) {
  Write-Error "Godot не найден. Укажите GODOT, добавьте godot в PATH или распакуйте Godot_v4.4.1-stable_win64.exe.zip в tools\Godot_win64\"
}

& $godot --headless --path $projectRoot --export-release "Windows Desktop" $outExe
Write-Host "Done: $outExe"
