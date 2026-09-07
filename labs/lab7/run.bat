@echo off
chcp 65001 >nul
cd /d %~dp0
set VIP=%~dp0..\..\tools\vip
echo Compiling LAB7.PRO ...
"%VIP%\BIN\WIN\32\PRO.EXE" LAB7.PRO
if errorlevel 1 (echo COMPILE ERROR & pause & exit /b 1)
echo Linking LAB7.exe ...
"%VIP%\BIN\WIN\32\pdclink.exe" -TPE -E_PDCPrologStart -SCUI -MLAB7.map -oLAB7.exe "%VIP%\LIB\WIN32\MSC\init32.obj" "%VIP%\LIB\WIN32\MSC\cmain.obj" LAB7.obj LAB7.sym "%VIP%\LIB\WIN32\PROLOG.LIB" "%VIP%\LIB\WIN32\MSC\WIN32.LIB"
if errorlevel 1 (echo LINK ERROR & pause & exit /b 1)
echo Done. Starting LAB7.exe ...
echo.
.\LAB7.exe
pause
