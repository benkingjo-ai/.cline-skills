@echo off
setlocal
rem Check the skills library. Pauses only on failure.
set "SCRIPT=%~dp0skill-authoring\scripts\check-skills.ps1"
if not exist "%SCRIPT%" (
  echo ERROR: check script not found: %SCRIPT%
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (
  echo CHECK PASSED
  endlocal & exit /b 0
)
echo CHECK FAILED - exit %RC%
pause
endlocal & exit /b %RC%
