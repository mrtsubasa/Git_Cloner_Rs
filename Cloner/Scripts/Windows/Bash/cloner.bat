@echo off

set /p USER="GitHub username / orga name "

curl -sf "https://api.github.com/users/%USER%" >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: GitHub user '%USER%' not found.
    exit /b 1
)

mkdir "%USER%" 2>nul
cd "%USER%"

echo Fetching repositories for '%USER%'...

set page=1
set total=0
set failed=0

:loop
for /f "delims=" %%r in ('curl -s "https://api.github.com/users/%USER%/repos?per_page=100&page=%page%" ^| jq -r ".[].clone_url"') do (
    for /f "delims=" %%n in ('curl -s "https://api.github.com/users/%USER%/repos?per_page=100&page=%page%" ^| jq -r ".[].name"') do (
        if exist "%%n" (
            echo   [SKIP] %%n already exists, pulling latest...
            git -C "%%n" pull --quiet
        ) else (
            echo   [CLONE] %%r
            git clone --quiet "%%r"
            if %errorlevel% == 0 (set /a total+=1) else (
                echo   [ERROR] Failed to clone %%r
                set /a failed+=1
            )
        )
    )
)

set /a page+=1
curl -s "https://api.github.com/users/%USER%/repos?per_page=100&page=%page%" | jq -r ".[].clone_url" | findstr "." >nul 2>&1
if %errorlevel% == 0 goto loop

echo.
echo Done. %total% repositories cloned, %failed% failed.