rem For DOS version.
rem Use setpath.bat to set prolog directory.
call setpath.bat

%prodir%bin\dos\pro -c -S2000 -C4000 -PDOS -I.;%prodir%include %1
echo -TD -C %prodir%lib\dos\init.obj>%TEMP%\_pdclink.tmp
echo %1.obj %1.sym -o%1.exe -M%1.map>>%TEMP%\_pdclink.tmp
echo %prodir%lib\dos\prolog.lib>>%TEMP%\_pdclink.tmp
%prodir%bin\dos\pdclink -F%TEMP%\_pdclink.tmp
if exist %TEMP%\_pdclink.tmp del %TEMP%\_pdclink.tmp