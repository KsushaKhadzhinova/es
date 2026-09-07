@echo off
chcp 65001 >nul
cd /d %~dp0
set VIP=%~dp0..\..\tools\vip
echo [TEST] Compiling LAB4.PRO ...
"%VIP%\BIN\WIN\32\PRO.EXE" LAB4.PRO >nul
if errorlevel 1 (echo [TEST] COMPILE ERROR & exit /b 1)
"%VIP%\BIN\WIN\32\pdclink.exe" -TPE -E_PDCPrologStart -SCUI -MLAB4.map -oLAB4.exe "%VIP%\LIB\WIN32\MSC\init32.obj" "%VIP%\LIB\WIN32\MSC\cmain.obj" LAB4.obj LAB4.sym "%VIP%\LIB\WIN32\PROLOG.LIB" "%VIP%\LIB\WIN32\MSC\WIN32.LIB" >nul
if errorlevel 1 (echo [TEST] LINK ERROR & exit /b 1)
echo [TEST] Running LAB4.exe (no input needed - full enumeration) ...
.\LAB4.exe > actual_output.txt
type actual_output.txt
echo.
fc /A expected_output.txt actual_output.txt >nul
if errorlevel 1 (
    echo [TEST] RESULT: DIFFERENCES FOUND
    fc /A expected_output.txt actual_output.txt
) else (
    echo [TEST] RESULT: PASSED
)
pause
