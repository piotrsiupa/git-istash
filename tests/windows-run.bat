@echo off
setlocal
pushd "%~dp0" || exit /b
call ..\run-git-bash.bat --login -- run.sh %*
