@echo off
title Instalador Cursor PT-BR - Emerson Teles
cls
echo ====================================================================
echo             TRADUCAO CURSOR PARA PORTUGUES DO BRASIL
echo           Desenvolvido e Personalizado por: Emerson Teles
echo ====================================================================
echo.
echo Iniciando processo de instalacao da traducao...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0core\aplicar-traducao.ps1"
set "PS_EXIT=%ERRORLEVEL%"
if not "%PS_EXIT%"=="0" (
    echo.
    echo [!] Se houver erro de permissao, execute como Administrador.
    echo.
    pause
)
exit /b %PS_EXIT%
