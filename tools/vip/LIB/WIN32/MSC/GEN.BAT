rem Generate CMAIN.OBJ PDCGROUP.OBJ  for WINDOW - 32 (Microsoft C 2.0 4.2 32bit)
@echo off

if not "%prodir%" == ""  goto Usual
call ..\..\..\foreign\setpath.bat
call ..\..\..\foreign\generate.bat nodebug nodummy win32 msc
goto End

:Usual
call %prodir%foreign\generate.bat nodebug nodummy win32 msc

:End
echo End generation


