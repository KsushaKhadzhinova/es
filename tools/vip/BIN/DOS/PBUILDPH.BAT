rem For Phar Lap DOS version.
rem Use setpath.bat to set prolog directory.
call setpath.bat

%prodir%bin\dos\pro  -c -b- -I.;%PRODIR%include -PPH %1

echo -TN -C %prodir%lib\dosx16\init.obj>%TEMP%\_pdclink.tmp
echo %1.obj %1.sym -o%1.exe -M%1.map>>%TEMP%\_pdclink.tmp
echo %prodir%lib\dosx16\prolog.lib>>%TEMP%\_pdclink.tmp
echo %prodir%lib\dosx16\phapi.lib>>%TEMP%\_pdclink.tmp

%prodir%bin\dos\pdclink -F%TEMP%\_pdclink.tmp

if exist %TEMP%\_pdclink.tmp del %TEMP%\_pdclink.tmp

echo %PHAR_PATH%rtk\run286b.exe       > $$$.$$$
echo %1.exe                         >> $$$.$$$
echo -dll %PHAR_PATH%rtk\doscalls.dll >> $$$.$$$
echo      %PHAR_PATH%rtk\viocalls.dll >> $$$.$$$
echo -exe %1.exe                    >> $$$.$$$

%PHAR_PATH%bin\bind286 @$$$.$$$ -warn
if exist $$$.$$$ del $$$.$$$
