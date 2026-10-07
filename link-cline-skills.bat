@echo off
setlocal

rem The real skills folder is the "skills" folder next to this .bat file
set "TARGET=%~dp0skills"

rem Cline global skills path (the link will be created here)
set "LINK=%USERPROFILE%\.cline\skills"

echo This script is in: %~dp0
echo Skills target:    %TARGET%
echo Link to create:   %LINK%
echo.

if not exist "%TARGET%\" (
  echo ERROR: "skills" folder not found next to this .bat file.
  echo Make sure this file is saved in the .cline folder, beside the skills folder.
  echo.
  dir "%~dp0" /a
  pause
  exit /b 1
)

if not exist "%USERPROFILE%\.cline" mkdir "%USERPROFILE%\.cline"

rem Back up any existing real skills folder so mklink can succeed
if exist "%LINK%" (
  echo Existing skills folder found. Renaming to skills_backup
  if exist "%USERPROFILE%\.cline\skills_backup" rmdir "%USERPROFILE%\.cline\skills_backup" 2>nul
  ren "%LINK%" skills_backup
)

mklink /J "%LINK%" "%TARGET%"
if errorlevel 1 (
  echo.
  echo Link FAILED. See the message above.
  pause
  exit /b 1
)

echo.
echo Done. Contents of the linked folder:
dir "%LINK%"
pause