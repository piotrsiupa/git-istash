@echo off
setlocal
pushd "%~dp0" || exit /b
if "%~1"=="/?" (
	call "..\run-git-bash.bat" -- run.sh --help
) else (
	call "..\run-git-bash.bat" -- run.sh %*
)
