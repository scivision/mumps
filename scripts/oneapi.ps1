# This script sets up the environment for Intel oneAPI compilers and launches a new PowerShell session.
# Usage: . .\oneapi.ps1 [version]
#
# https://gist.github.com/scivision/196cfa0df761ad4fcace8ff269128f7b

param(
  [string]$version = "2025.2"
)

$basedir = "${Env:ProgramFiles(x86)}\Intel\oneAPI"

if (-not (Test-Path -Path $basedir)) {
    Write-Error "The Intel oneAPI install base directory does not exist: $basedir"
    exit 1
}

$verdir = Join-Path -Path $basedir -ChildPath $version
if (-not (Test-Path -Path $verdir)) {
    Write-Error "The specified Intel oneAPI version directory does not exist: $verdir"
    exit 1
}

$Env:CC="icx"
$Env:FC="ifx"
$Env:CXX="icx"

& $Env:COMSPEC /c "`"${verdir}\oneapi-vars.bat`" && pwsh"
