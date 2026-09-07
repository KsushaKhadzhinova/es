@echo off
chcp 65001 >nul
cd /d %~dp0
set VIP=%~dp0..\..\tools\vip
echo Compiling LAB3.PRO ...
"%VIP%\BIN\WIN\32\PRO.EXE" LAB3.PRO
if errorlevel 1 (echo COMPILE ERROR & pause & exit /b 1)
echo Linking LAB3.exe ...
"%VIP%\BIN\WIN\32\pdclink.exe" -TPE -E_PDCPrologStart -SCUI -MLAB3.map -oLAB3.exe "%VIP%\LIB\WIN32\MSC\init32.obj" "%VIP%\LIB\WIN32\MSC\cmain.obj" LAB3.obj LAB3.sym "%VIP%\LIB\WIN32\PROLOG.LIB" "%VIP%\LIB\WIN32\MSC\WIN32.LIB"
if errorlevel 1 (echo LINK ERROR & pause & exit /b 1)
echo Done. Starting LAB3.exe (database file: lab3.dba) ...
echo.
.\LAB3.exe
pause
