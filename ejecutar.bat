@echo off
setlocal
cd /d "%~dp0"

if not exist ".venv\Scripts\pythonw.exe" (
    echo.
    echo No se encontro el entorno virtual .venv
    echo.
    echo Ejecuta primero estos comandos:
    echo   python -m venv .venv
    echo   .venv\Scripts\activate
    echo   pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

if not exist ".env" (
    if exist ".env.example" (
        copy ".env.example" ".env" >nul
        echo Se creo el archivo .env a partir de .env.example.
        echo Revisa el nombre de tu instancia de SQL Server antes de continuar.
        echo.
    )
)

rem pythonw.exe abre la aplicacion sin la ventana negra de consola.
start "" ".venv\Scripts\pythonw.exe" Programa.py
exit /b 0
