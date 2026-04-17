@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0"
set "SRC_DIR=%ROOT_DIR%src"
set "DATA_DIR=%ROOT_DIR%data"
set "LOG_FILE=%DATA_DIR%\setup.log"
set "ENV_NAME=autotask"

if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
cd /d "%ROOT_DIR%" || exit /b 1

echo AutoTask first-time setup
echo Keep this window open until setup finishes.
echo.

call :find_conda
if not defined CONDA_BIN (
  echo Conda was not found. Install Anaconda or Miniconda, then double-click setup_windows.bat again.
  echo Conda was not found. Install Anaconda or Miniconda, then double-click setup_windows.bat again.>>"%LOG_FILE%"
  pause
  exit /b 1
)
echo Using Conda: %CONDA_BIN%
echo Using Conda: %CONDA_BIN%>>"%LOG_FILE%"

echo.
echo Checking Conda environment: %ENV_NAME%
call "%CONDA_BIN%" run -n "%ENV_NAME%" python --version >nul 2>&1
if errorlevel 1 (
  echo Creating Conda environment: %ENV_NAME%
  echo Creating Conda environment: %ENV_NAME%>>"%LOG_FILE%"
  call "%CONDA_BIN%" create -y -n "%ENV_NAME%" python=3.13 >>"%LOG_FILE%" 2>&1
) else (
  echo Updating Conda environment: %ENV_NAME%
  echo Updating Conda environment: %ENV_NAME%>>"%LOG_FILE%"
  call "%CONDA_BIN%" update -y -n "%ENV_NAME%" python >>"%LOG_FILE%" 2>&1
)
if errorlevel 1 (
  echo Conda environment setup failed. Check data\setup.log.
  pause
  exit /b 1
)

echo.
echo Verifying AutoTask.
echo Verifying AutoTask.>>"%LOG_FILE%"
call "%CONDA_BIN%" run -n "%ENV_NAME%" python "%SRC_DIR%\server.py" --self-test >>"%LOG_FILE%" 2>&1
if errorlevel 1 (
  echo Verification failed. Check data\setup.log.
  pause
  exit /b 1
)

echo.
echo AutoTask is ready. Use start_monitor_windows.bat or start_runner_windows.bat next.
echo AutoTask is ready.>>"%LOG_FILE%"
pause
exit /b 0

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
