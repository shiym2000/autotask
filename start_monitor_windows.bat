@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0"
set "SRC_DIR=%ROOT_DIR%src"
set "DATA_DIR=%ROOT_DIR%data"
set "LOG_FILE=%DATA_DIR%\monitor.log"
set "ENV_NAME=autotask"

if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
cd /d "%ROOT_DIR%" || exit /b 1

echo AutoTask Monitor launcher
echo Keep this window open while Monitor is running.
echo.

call :find_conda
if not defined CONDA_BIN (
  echo Conda was not found. Install Anaconda or Miniconda, then double-click start_monitor_windows.bat again.
  pause
  exit /b 1
)

call "%CONDA_BIN%" run -n "%ENV_NAME%" python --version >nul 2>&1
if errorlevel 1 (
  echo AutoTask is not set up yet. Double-click setup_windows.bat first.
  pause
  exit /b 1
)

echo Starting AutoTask Monitor. The browser will open automatically.
echo Starting AutoTask Monitor.>>"%LOG_FILE%"
call "%CONDA_BIN%" run -n "%ENV_NAME%" python "%SRC_DIR%\server.py" --open --page monitor --app monitor --port 8765
exit /b %errorlevel%

:find_conda
for /f "delims=" %%I in ('where conda 2^>nul') do (
  set "CONDA_BIN=%%I"
  goto :eof
)
for %%I in (
  "%USERPROFILE%\miniconda3\Scripts\conda.exe"
  "%USERPROFILE%\miniconda3\condabin\conda.bat"
  "%USERPROFILE%\anaconda3\Scripts\conda.exe"
  "%USERPROFILE%\anaconda3\condabin\conda.bat"
  "C:\ProgramData\miniconda3\Scripts\conda.exe"
  "C:\ProgramData\miniconda3\condabin\conda.bat"
  "C:\ProgramData\anaconda3\Scripts\conda.exe"
  "C:\ProgramData\anaconda3\condabin\conda.bat"
) do (
  if exist "%%~I" (
    set "CONDA_BIN=%%~I"
    goto :eof
  )
)
goto :eof
