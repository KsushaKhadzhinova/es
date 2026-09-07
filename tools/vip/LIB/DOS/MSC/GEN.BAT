rem Generate CMAIN.OBJ INIT.OBJ MSCINIT.OBJ  for DOS (Microsoft Visual C 1.5 16bit)
@echo off

if not "%prodir%" == ""  goto Usual
call ..\..\..\foreign\setpath.bat
call ..\..\..\foreign\generate.bat nodebug nodummy dos msc
goto End

:Usual
call %prodir%foreign\generate.bat nodebug nodummy dos msc


:End
echo End generation
