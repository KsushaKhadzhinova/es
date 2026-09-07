@echo off
chcp 65001 >nul
cd /d %~dp0
set VIP=%~dp0..\..\tools\vip
echo [TEST] Backing up lab3.dba before test (test adds a buyer and saves) ...
copy /Y lab3.dba lab3_backup_before_test.dba >nul
echo [TEST] Compiling LAB3.PRO ...
"%VIP%\BIN\WIN\32\PRO.EXE" LAB3.PRO >nul
if errorlevel 1 (echo [TEST] COMPILE ERROR & copy /Y lab3_backup_before_test.dba lab3.dba >nul & del lab3_backup_before_test.dba & exit /b 1)
"%VIP%\BIN\WIN\32\pdclink.exe" -TPE -E_PDCPrologStart -SCUI -MLAB3.map -oLAB3.exe "%VIP%\LIB\WIN32\MSC\init32.obj" "%VIP%\LIB\WIN32\MSC\cmain.obj" LAB3.obj LAB3.sym "%VIP%\LIB\WIN32\PROLOG.LIB" "%VIP%\LIB\WIN32\MSC\WIN32.LIB" >nul
if errorlevel 1 (echo [TEST] LINK ERROR & copy /Y lab3_backup_before_test.dba lab3.dba >nul & del lab3_backup_before_test.dba & exit /b 1)

echo [TEST] Running scenario: load, view, add buyer, view, save, exit ...
.\LAB3.exe < test_input.txt > actual_output.txt
type actual_output.txt
echo.
fc /A expected_output.txt actual_output.txt >nul
if errorlevel 1 (
    echo [TEST] CONSOLE OUTPUT RESULT: DIFFERENCES FOUND
    fc /A expected_output.txt actual_output.txt
) else (
    echo [TEST] CONSOLE OUTPUT RESULT: PASSED
)

echo.
echo [TEST] Checking lab3.dba now contains the newly added buyer ...
findstr /C:"NewCorp" lab3.dba >nul
if errorlevel 1 (
    echo [TEST] DATABASE SAVE RESULT: FAILED - new buyer not found in lab3.dba
) else (
    echo [TEST] DATABASE SAVE RESULT: PASSED - new buyer found in lab3.dba
)

echo.
echo [TEST] Restoring original lab3.dba ...
copy /Y lab3_backup_before_test.dba lab3.dba >nul
del lab3_backup_before_test.dba
echo [TEST] Done - lab3.dba restored to its original state.
pause
