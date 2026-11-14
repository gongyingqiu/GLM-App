@echo off
rem Double-click to start the GLM tool with the package versions in renv.lock
setlocal
set "RSCRIPT="

rem R 4.4.1 installed for all users, or for the current user only (no admin rights needed)
for %%P in ("%ProgramFiles%\R\R-4.4.1\bin\Rscript.exe" "%LOCALAPPDATA%\Programs\R\R-4.4.1\bin\Rscript.exe" "%USERPROFILE%\Documents\R\R-4.4.1\bin\Rscript.exe") do (
  if not defined RSCRIPT if exist %%P set "RSCRIPT=%%~P"
)
rem otherwise any Rscript on the PATH
if not defined RSCRIPT for /f "delims=" %%P in ('where Rscript 2^>nul') do if not defined RSCRIPT set "RSCRIPT=%%P"

if not defined RSCRIPT (
  echo R was not found on this computer.
  echo Please install R 4.4.1 from https://cran.r-project.org/bin/windows/base/old/4.4.1/
  pause
  exit /b 1
)
if "%~1"=="--check" ( echo Using %RSCRIPT% & exit /b 0 )

echo Using %RSCRIPT%
"%RSCRIPT%" "%~dp0run_app.R" "%~dp0."
pause
