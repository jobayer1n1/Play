@echo off
REM Deletes all files and folders in the specified directory

SET "TARGET=C:\Users\jobay\AppData\Local\Temp\webtorrent"

REM Delete all files
del /f /q "%TARGET%\*.*"

REM Delete all subfolders
for /d %%i in ("%TARGET%\*") do rd /s /q "%%i"

