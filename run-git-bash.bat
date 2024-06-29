@echo off
setlocal
if "%~1"=="/?" (
	echo %~n0 - Run a command in Git bash.
	echo(
	echo Usage: %~n0 ^<command^> [^<argument^>...]
	echo    or: %~n0 /^?
	exit /b 0
)
set GIT_EXE_PATH=
for /f "tokens=*" %%i in ('where git 2^>nul') do set GIT_EXE_PATH=%%i
if not defined GIT_EXE_PATH (
	echo Cannot run the script "%1%" - git.exe not found. 1>&2
	exit /b 1
)
set GIT_CMD_DIR=%GIT_EXE_PATH:\git.exe=%
set SH_EXE_PATH=%GIT_CMD_DIR%\..\bin\sh.exe
if not exist "%SH_EXE_PATH%" (
	echo Cannot run the script "%1" - sh.exe not found in "%SH_EXE_PATH%" 1>&2
	exit /b 1
)
"%SH_EXE_PATH%" %*
