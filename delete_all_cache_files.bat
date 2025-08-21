@echo off
REM Delete all subfolders under %TEMP%\webtorrent

SET "TARGET=%TEMP%\webtorrent"

echo Deleting all subfolders in %TARGET%...

for /d %%i in ("%TARGET%\*") do rd /s /q "%%i"




