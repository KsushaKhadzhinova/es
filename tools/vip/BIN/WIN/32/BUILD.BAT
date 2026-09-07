rem Use setpath.bat to set prolog directory.
call setpath.bat
%PRODIR%bin\win\32\pro -c -I.;%PRODIR%include %1
pdclink -TPE -E_PDCPrologStart -SCUI -M%1.map -o%1.exe %PRODIR%lib\win32\msc\Init32.obj %PRODIR%lib\win32\msc\cmain.obj %1.obj %1.sym %PRODIR%lib\win32\prolog.lib %PRODIR%lib\win32\msc\win32.lib