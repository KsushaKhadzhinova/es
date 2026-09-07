@echo off
chcp 65001 >nul
cd /d %~dp0
set VIP=%~dp0..\..\tools\vip
echo [TEST] Compiling LAB1.PRO ...
"%VIP%\BIN\WIN\32\PRO.EXE" LAB1.PRO >nul
if errorlevel 1 (echo [TEST] COMPILE ERROR & exit /b 1)
"%VIP%\BIN\WIN\32\pdclink.exe" -TPE -E_PDCPrologStart -SCUI -MLAB1.map -oLAB1.exe "%VIP%\LIB\WIN32\MSC\init32.obj" "%VIP%\LIB\WIN32\MSC\cmain.obj" LAB1.obj LAB1.sym "%VIP%\LIB\WIN32\PROLOG.LIB" "%VIP%\LIB\WIN32\MSC\WIN32.LIB" >nul
if errorlevel 1 (echo [TEST] LINK ERROR & exit /b 1)
echo [TEST] Running with test_input.txt ...
.\LAB1.exe < test_input.txt > actual_output.txt
echo.
echo [TEST] --- Expected output (expected_output.txt) ---
type expected_output.txt
echo.
echo [TEST] --- Actual output (actual_output.txt) ---
type actual_output.txt
echo.
fc /A expected_output.txt actual_output.txt >nul
if errorlevel 1 (
    echo [TEST] RESULT: DIFFERENCES FOUND - see comparison below
    fc /A expected_output.txt actual_output.txt
) else (
    echo [TEST] RESULT: PASSED - actual output matches expected output
)
pause
