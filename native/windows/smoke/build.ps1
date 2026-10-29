param(
    [string]$SdkDir = $env:DISCORD_SOCIAL_SDK_DIR,
    [ValidateSet('debug', 'release')]
    [string]$Configuration = 'release'
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($SdkDir)) {
    throw 'Pass -SdkDir or define DISCORD_SOCIAL_SDK_DIR.'
}

$SdkDir = [System.IO.Path]::GetFullPath($SdkDir)
$Header = Join-Path $SdkDir 'include\discordpp.h'
$ImportLibrary = Join-Path $SdkDir "lib\$Configuration\discord_partner_sdk.lib"
$RuntimeLibrary = Join-Path $SdkDir "bin\$Configuration\discord_partner_sdk.dll"
foreach ($RequiredFile in @($Header, $ImportLibrary, $RuntimeLibrary)) {
    if (-not (Test-Path -LiteralPath $RequiredFile -PathType Leaf)) {
        throw "Missing Discord Social SDK file: $RequiredFile"
    }
}

$VsWhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path -LiteralPath $VsWhere -PathType Leaf)) {
    throw 'Visual Studio Installer vswhere.exe was not found.'
}

$VsInstall = & $VsWhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if ([string]::IsNullOrWhiteSpace($VsInstall)) {
    throw 'Visual Studio C++ x64 build tools were not found.'
}

$VcVars = Join-Path $VsInstall 'VC\Auxiliary\Build\vcvars64.bat'
if (-not (Test-Path -LiteralPath $VcVars -PathType Leaf)) {
    throw "vcvars64.bat was not found under $VsInstall"
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputDir = Join-Path $ScriptDir "build\$Configuration"
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$Source = Join-Path $ScriptDir 'main.cpp'
$Executable = Join-Path $OutputDir 'hxdiscordsocial-smoke.exe'

$CompilerCommand = 'cl.exe /nologo /std:c++20 /EHsc /MD /W4 /utf-8 '
$CompilerCommand += "/I`"$SdkDir\include`" `"$Source`" `"$ImportLibrary`" "
$CompilerCommand += "/Fe:`"$Executable`" /Fo:`"$OutputDir\main.obj`""

& cmd.exe /d /s /c "`"$VcVars`" >nul && $CompilerCommand"
if ($LASTEXITCODE -ne 0) {
    throw "MSVC failed with exit code $LASTEXITCODE"
}

Copy-Item -LiteralPath $RuntimeLibrary -Destination $OutputDir -Force
Write-Output $Executable

