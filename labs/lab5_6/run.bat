@echo off
chcp 65001 >nul
cd /d %~dp0
set VIP=%~dp0..\..\tools\vip
echo Compiling LAB5_6.PRO ...
"%VIP%\BIN\WIN\32\PRO.EXE" LAB5_6.PRO
if errorlevel 1 (echo COMPILE ERROR & pause & exit /b 1)
echo Linking LAB5_6.exe ...
"%VIP%\BIN\WIN\32\pdclink.exe" -TPE -E_PDCPrologStart -SCUI -MLAB5_6.map -oLAB5_6.exe "%VIP%\LIB\WIN32\MSC\init32.obj" "%VIP%\LIB\WIN32\MSC\cmain.obj" LAB5_6.obj LAB5_6.sym "%VIP%\LIB\WIN32\PROLOG.LIB" "%VIP%\LIB\WIN32\MSC\WIN32.LIB"
if errorlevel 1 (echo LINK ERROR & pause & exit /b 1)
echo Done. Starting LAB5_6.exe (knowledge base file: volkan.dba) ...
echo.
.\LAB5_6.exe
pause
