@echo off
REM Deletes all files and folders in the specified directory

SET "TARGET=%TEMP%\webtorrent"

echo Deleting all contents of %TARGET%...
REM Delete all files
del /f /q "%TARGET%\*.*"

REM Delete all subfolders
for /d %%i in ("%TARGET%\*") do rd /s /q "%%i"

echo DONE
pause

