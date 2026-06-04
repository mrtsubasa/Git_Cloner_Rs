@echo off

where go >nul 2>&1
if %errorlevel% == 0 (
    echo Go is installed:
    go version
     go run "%~dp0/Go/cloner.go"
) else (
    set /p resp="Go is not installed. Install or use bat script? [I = Install / S = Bat script]: "

    if /i "%resp%" == "I" (
        set GO_VERSION=1.22.3
        echo Downloading Go %GO_VERSION%...
        curl -L "https://go.dev/dl/go%GO_VERSION%.windows-amd64.zip" -o "%temp%\go.zip"

        echo Installing...
        rmdir /s /q "C:\Program Files\Go"
        tar -xf "%temp%\go.zip" -C "C:\Program Files"
        del "%temp%\go.zip"

        setx PATH "%PATH%;C:\Program Files\Go\bin"
        echo Go successfully installed.
    ) else if /i "%resp%" == "S" (
        echo Starting bat script...
        call "%~dp0/Bash/cloner.bat"
    ) else (
        echo Invalid input. Exiting.
        exit /b 1
    )
)