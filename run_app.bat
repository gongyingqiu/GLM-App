@echo off
rem Double-click to start the GLM tool with the package versions in renv.lock
set "RSCRIPT=C:\Program Files\R\R-4.4.1\bin\Rscript.exe"
if not exist "%RSCRIPT%" (
  echo R 4.4.1 was not found at "%RSCRIPT%".
  echo Please install R 4.4.1 from https://cran.r-project.org/bin/windows/base/old/4.4.1/
  pause
  exit /b 1
)
"%RSCRIPT%" "%~dp0run_app.R" "%~dp0."
pause
