@echo off
setlocal enabledelayedexpansion

:: Get current state
for /f "tokens=3" %%A in ('reg query "HKCU\Control Panel\Mouse" /v SwapMouseButtons 2^>nul') do set swap=%%A
echo From registry: [%swap%]

:: Toggle the value
if "%swap%"=="1" (
    reg add "HKCU\Control Panel\Mouse" /v SwapMouseButtons /t REG_DWORD /d 0 /f
    set new_swap=0
) else if "%swap%"=="0" (
    reg add "HKCU\Control Panel\Mouse" /v SwapMouseButtons /t REG_DWORD /d 1 /f
    set new_swap=1
) else (
    echo Unexpected value: %swap%
    pause
    exit /b 1
)

echo new swap: [%new_swap%]


:: Critical Fix: Pass the value correctly to PowerShell
powershell -Command "$NewVal = %new_swap%; Add-Type -Name Win32 -Namespace UI -MemberDefinition '[DllImport(\"user32.dll\")] public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);'; [UI.Win32]::SystemParametersInfo(0x0021, $NewVal, [IntPtr]::Zero, 1)"

:: Verify
for /f "tokens=3" %%A in ('reg query "HKCU\Control Panel\Mouse" /v SwapMouseButtons 2^>nul') do set swap=%%A
echo From registry: [%swap%]

pause