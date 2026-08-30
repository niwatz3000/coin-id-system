```bat
@echo off
setlocal

REM ============================================
REM Push project to GitHub
REM Usage:
REM   push-to-github.bat <github-username> <repo-name>
REM ============================================

if "%~2"=="" (
    echo Usage: %~nx0 ^<github-username^> ^<repo-name^>
    exit /b 1
)

set "USERNAME=%~1"
set "REPO_NAME=%~2"

echo.
echo ============================================
echo Initializing Git repository...
echo ============================================

git init

echo.
echo Adding files...
git add .

echo.
echo Creating initial commit...
git commit -m "Initial commit: Online Coin Identification ^& Catalog System (MVP 1) scaffold"

echo.
echo Setting branch to main...
git branch -M main

echo.
echo Adding GitHub remote...
git remote add origin "https://github.com/%USERNAME%/%REPO_NAME%.git"

echo.
echo Pushing to GitHub...
git push -u origin main

echo.
echo ============================================
echo Pushed to:
echo https://github.com/%USERNAME%/%REPO_NAME%
echo ============================================

endlocal
```
