@echo off
setlocal
pushd "%~dp0" || exit /b
set condition=n
if "%~1"=="/?" set condition=y
if "%~1"=="--help" set condition=y
if "%condition%"=="y" (
	echo warning: The below is the help text for Linux version of the script.
	echo On Windows there are no options beside the flag "--uninstall".
	echo The flag "--global" is implied.
	echo (Just run the script. It just works.^)
	echo(
	call "run-git-bash.bat" -- install.sh --help
)
if "%condition%"=="n" (
	call "run-git-bash.bat" -- install.sh --global %*
	pause
)
