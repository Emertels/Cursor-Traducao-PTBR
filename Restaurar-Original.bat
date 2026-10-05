@echo off
title Restaurador Cursor Original - Emerson Teles
cls
echo ====================================================================
echo          RESTAURACAO DO CURSOR PARA O ESTADO ORIGINAL
echo           Desenvolvido e Personalizado por: Emerson Teles
echo ====================================================================
echo.
echo Iniciando a restauracao dos arquivos originais...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0core\restaurar-original.ps1"
set "PS_EXIT=%ERRORLEVEL%"
if not "%PS_EXIT%"=="0" (
    echo.
    echo [!] Se houver erro de permissao, execute como Administrador.
    echo.
    pause
)
exit /b %PS_EXIT%
