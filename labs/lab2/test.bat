@echo off
chcp 65001 >nul
cd /d %~dp0
set VIP=%~dp0..\..\tools\vip
echo [TEST] Compiling LAB2.PRO ...
"%VIP%\BIN\WIN\32\PRO.EXE" LAB2.PRO >nul
if errorlevel 1 (echo [TEST] COMPILE ERROR & exit /b 1)
"%VIP%\BIN\WIN\32\pdclink.exe" -TPE -E_PDCPrologStart -SCUI -MLAB2.map -oLAB2.exe "%VIP%\LIB\WIN32\MSC\init32.obj" "%VIP%\LIB\WIN32\MSC\cmain.obj" LAB2.obj LAB2.sym "%VIP%\LIB\WIN32\PROLOG.LIB" "%VIP%\LIB\WIN32\MSC\WIN32.LIB" >nul
if errorlevel 1 (echo [TEST] LINK ERROR & exit /b 1)

echo.
echo [TEST 1/2] Task 1 - list split, input: test_input_1.txt
.\LAB2.exe < test_input_1.txt > actual_output_1.txt
type actual_output_1.txt
fc /A expected_output_1.txt actual_output_1.txt >nul
if errorlevel 1 (
    echo [TEST 1/2] RESULT: DIFFERENCES FOUND
    fc /A expected_output_1.txt actual_output_1.txt
) else (
    echo [TEST 1/2] RESULT: PASSED
)

echo.
echo [TEST 2/2] Task 2 - country/sum query, input: test_input_2.txt
.\LAB2.exe < test_input_2.txt > actual_output_2.txt
type actual_output_2.txt
fc /A expected_output_2.txt actual_output_2.txt >nul
if errorlevel 1 (
    echo [TEST 2/2] RESULT: DIFFERENCES FOUND
    fc /A expected_output_2.txt actual_output_2.txt
) else (
    echo [TEST 2/2] RESULT: PASSED
)
pause
