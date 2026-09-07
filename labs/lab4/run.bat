@echo off
chcp 65001 >nul
cd /d %~dp0
set VIP=%~dp0..\..\tools\vip
echo Compiling LAB4.PRO ...
"%VIP%\BIN\WIN\32\PRO.EXE" LAB4.PRO
if errorlevel 1 (echo COMPILE ERROR & pause & exit /b 1)
echo Linking LAB4.exe ...
"%VIP%\BIN\WIN\32\pdclink.exe" -TPE -E_PDCPrologStart -SCUI -MLAB4.map -oLAB4.exe "%VIP%\LIB\WIN32\MSC\init32.obj" "%VIP%\LIB\WIN32\MSC\cmain.obj" LAB4.obj LAB4.sym "%VIP%\LIB\WIN32\PROLOG.LIB" "%VIP%\LIB\WIN32\MSC\WIN32.LIB"
if errorlevel 1 (echo LINK ERROR & pause & exit /b 1)
echo Done. Starting LAB4.exe ...
echo.
.\LAB4.exe
pause
