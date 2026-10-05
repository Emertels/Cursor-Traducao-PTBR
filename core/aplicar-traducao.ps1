# ==============================================================================
#  Instalador Universal de Tradução PT-BR para Cursor
#  Tradução e Personalizacao por: Emerson Teles
#  Padrão: Uso exclusivo do termo "aplicativo" / "aplicativos" (nunca "app")
# ==============================================================================
$utf8Console = New-Object System.Text.UTF8Encoding($false)
[Console]::InputEncoding = $utf8Console
[Console]::OutputEncoding = $utf8Console
$OutputEncoding = $utf8Console

function Read-OpenChoice([string]$Prompt) {
    Write-Host $Prompt -NoNewline -ForegroundColor White
    while ($true) {
        $key = [Console]::ReadKey($true)
        if ($key.KeyChar -eq 's' -or $key.KeyChar -eq 'S') { Write-Host 'S'; return $true }
        if ($key.KeyChar -eq 'n' -or $key.KeyChar -eq 'N') { Write-Host 'N'; return $false }
        if ($key.Key -eq [ConsoleKey]::Enter) { Write-Host 'Enter'; return $false }
        if ($key.Key -eq [ConsoleKey]::Escape) { Write-Host 'Esc'; return $false }
    }
}

function Start-CursorDetached([string]$Executable, [string]$Locale) {
    if (-not ('CursorProcessLauncher' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;

public static class CursorProcessLauncher {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct STARTUPINFO {
        public int cb;
        public string lpReserved;
        public string lpDesktop;
        public string lpTitle;
        public int dwX, dwY, dwXSize, dwYSize, dwXCountChars, dwYCountChars, dwFillAttribute, dwFlags;
        public short wShowWindow, cbReserved2;
        public IntPtr lpReserved2, hStdInput, hStdOutput, hStdError;
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct PROCESS_INFORMATION {
        public IntPtr hProcess, hThread;
        public int dwProcessId, dwThreadId;
    }
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    static extern bool CreateProcess(string applicationName, StringBuilder commandLine,
        IntPtr processAttributes, IntPtr threadAttributes, bool inheritHandles,
        uint creationFlags, IntPtr environment, string currentDirectory,
        ref STARTUPINFO startupInfo, out PROCESS_INFORMATION processInformation);
    [DllImport("kernel32.dll")]
    static extern bool CloseHandle(IntPtr handle);

    public static void Start(string executable, string locale) {
        var startup = new STARTUPINFO();
        startup.cb = Marshal.SizeOf(typeof(STARTUPINFO));
        var info = new PROCESS_INFORMATION();
        var command = new StringBuilder("\"" + executable + "\" --locale=" + locale);
        const uint DETACHED_PROCESS = 0x00000008;
        if (!CreateProcess(executable, command, IntPtr.Zero, IntPtr.Zero, false,
            DETACHED_PROCESS, IntPtr.Zero, System.IO.Path.GetDirectoryName(executable),
            ref startup, out info)) {
            throw new Win32Exception(Marshal.GetLastWin32Error());
        }
        CloseHandle(info.hThread);
        CloseHandle(info.hProcess);
    }
}
'@
    }
    [CursorProcessLauncher]::Start($Executable, $Locale)
}
$Host.UI.RawUI.WindowTitle = "Instalador Cursor PT-BR - Emerson Teles"

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host " ==================================================================== " -ForegroundColor Cyan
    Write-Host "             TRADUÇÃO CURSOR PARA PORTUGUÊS DO BRASIL                 " -ForegroundColor Green
    Write-Host "           Desenvolvido e Personalizado por: Emerson Teles            " -ForegroundColor Yellow
    Write-Host " ==================================================================== " -ForegroundColor Cyan
    Write-Host ""
}

function Copy-FileWithProgress {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label = "Copiando"
    )

    $sourceFile = New-Object System.IO.FileInfo($Source)
    $totalBytes = $sourceFile.Length
    $totalKB = [math]::Round($totalBytes / 1KB, 1)

    $bufferSize = 64KB
    $buffer = New-Object byte[] $bufferSize

    $retryCount = 0
    $maxRetries = 5
    $success = $false

    while (-not $success -and $retryCount -lt $maxRetries) {
        try {
            $destParent = Split-Path $Destination -Parent
            if (-not (Test-Path $destParent)) {
                New-Item -ItemType Directory -Path $destParent -Force | Out-Null
            }

            $sourceStream = [System.IO.File]::OpenRead($Source)
            $destStream = [System.IO.File]::Create($Destination)

            $totalRead = 0
            $lastPercent = -1

            Write-Host "  $Label..." -ForegroundColor Cyan

            while (($bytesRead = $sourceStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $destStream.Write($buffer, 0, $bytesRead)
                $totalRead += $bytesRead
                $percent = [math]::Floor(($totalRead / $totalBytes) * 100)

                if ($percent -ne $lastPercent) {
                    $lastPercent = $percent
                    $copiedKB = [math]::Round($totalRead / 1KB, 1)
                    $barLen = 22
                    $filled = [math]::Floor(($percent / 100) * $barLen)
                    $bar = ('=' * $filled) + (' ' * ($barLen - $filled))
                    $msg = "`r    [$bar] $percent% ($copiedKB KB / $totalKB KB)   "
                    Write-Host -NoNewline $msg
                    Start-Sleep -Milliseconds 5
                }
            }
            Write-Host ""
            $success = $true
        }
        catch {
            $retryCount++
            Write-Host "`n    [!] Arquivo temporariamente em uso. Tentativa $retryCount de $maxRetries em 2 segundos..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
        finally {
            if ($sourceStream) { $sourceStream.Close() }
            if ($destStream) { $destStream.Close() }
        }
    }

    if (-not $success) {
        Write-Host "[x] Erro: Não foi possivel copiar para $Destination. Verifique se ha processos abertos." -ForegroundColor Red
        throw "Falha na copia do arquivo"
    }
}

function Find-CursorInstallation {
    $candidates = @()

    $proc = Get-Process -Name "Cursor" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc -and $proc.Path) {
        $candidates += (Split-Path $proc.Path -Parent)
    }

    $candidates += (Join-Path $env:LOCALAPPDATA "Programs\cursor")
    $candidates += (Join-Path $env:LOCALAPPDATA "Programs\Cursor")
    $candidates += (Join-Path $env:ProgramFiles "Cursor")
    $candidates += (Join-Path $env:ProgramFiles "cursor")
    if (${env:ProgramFiles(x86)}) {
        $candidates += (Join-Path ${env:ProgramFiles(x86)} "Cursor")
        $candidates += (Join-Path ${env:ProgramFiles(x86)} "cursor")
    }
    $candidates += (Join-Path $env:APPDATA "cursor")

    $regPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($rp in $regPaths) {
        try {
            $keys = Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*Cursor*" }
            foreach ($k in $keys) {
                if ($k.InstallLocation -and (Test-Path $k.InstallLocation)) {
                    $candidates += $k.InstallLocation
                }
            }
        } catch { }
    }

    $drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Root
    foreach ($d in $drives) {
        $candidates += (Join-Path $d "cursor")
        $candidates += (Join-Path $d "Cursor")
        $candidates += (Join-Path $d "Programs\cursor")
    }

    foreach ($cand in ($candidates | Where-Object { $_ } | Select-Object -Unique)) {
        if ((Test-Path (Join-Path $cand "resources\app")) -or (Test-Path (Join-Path $cand "Cursor.exe"))) {
            return $cand
        }
    }

    return $null
}

# Inicio
Write-Header

# 1. Fechar processos ativos do Cursor
$running = Get-Process | Where-Object { $_.ProcessName -like "*cursor*" }
if ($running) {
    Write-Host "[-] Fechando processos ativos do Cursor para atualizar arquivos com segurança..." -ForegroundColor Yellow
    $running | Stop-Process -Force -ErrorAction SilentlyContinue
    
    $timeout = 10
    while ($timeout -gt 0) {
        $check = Get-Process | Where-Object { $_.ProcessName -like "*cursor*" }
        if (-not $check) { break }
        Start-Sleep -Seconds 1
        $timeout--
    }
    Start-Sleep -Seconds 2
}

# 2. Localizar instalação do Cursor
Write-Host "[1/6] Procurando instalação do Cursor no computador..." -ForegroundColor White
$cursorDir = Find-CursorInstallation

while (-not $cursorDir -or -not (Test-Path $cursorDir)) {
    Write-Host ""
    Write-Host "[!] Não foi possivel detectar o Cursor automaticamente." -ForegroundColor Yellow
    $userInput = Read-Host "Por favor, digite ou cole a pasta onde o Cursor esta instalado"
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        Write-Host "[x] Operacao cancelada pelo usuario." -ForegroundColor Red
        Exit 1
    }
    if (Test-Path (Join-Path $userInput "resources\app")) {
        $cursorDir = $userInput
    } else {
        Write-Host "[x] Pasta invalida ou 'resources\app' não encontrado!" -ForegroundColor Red
    }
}

Write-Host "    -> Cursor localizado em: $cursorDir" -ForegroundColor Green
$cursorAppDir = Join-Path $cursorDir "resources\app"
$targetReactDir = Join-Path $cursorAppDir "out\vs\workbench\react-runtime\react"
$targetWorkbenchDir = Join-Path $cursorAppDir "out\vs\workbench"

# Pasta padronizada de backup dentro do diretorio do programa
$cursorBackupDir = Join-Path $cursorDir "_backups"

$coreDir = $PSScriptRoot
if (-not $coreDir) { $coreDir = (Get-Location).Path }

# 3. Backup e Protecao Inteligente do arquivo original de fábrica na pasta do programa
# (Nota: Nenhum arquivo temporario e gravado na pasta do instalador/pendrive, garantindo portabilidade total)

# Detectar versão atual do Cursor
$currentVersion = $null
$pkgJsonPath = Join-Path $cursorAppDir "package.json"
if (Test-Path $pkgJsonPath) {
    try {
        $pkgObj = Get-Content $pkgJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($pkgObj.version) { $currentVersion = $pkgObj.version }
    } catch { }
}
if (-not $currentVersion) { throw "Não foi possível detectar a versão do Cursor em $pkgJsonPath. Nenhum arquivo do aplicativo foi alterado." }
Write-Host "    -> Versão detectada do Cursor: $currentVersion" -ForegroundColor Cyan

# 3.1 Criar / Verificar backup imutavel da instalação e versão atuais
Write-Host ""
Write-Host "[2/6] Verificando backup original de segurança de fábrica (v$currentVersion)..." -ForegroundColor White

$appCommit = ""
try { $appCommit = (Get-Content (Join-Path $cursorAppDir "product.json") -Raw -Encoding UTF8 | ConvertFrom-Json).commit } catch { }
if (-not $appCommit) { throw "Não foi possível detectar o commit da instalação do Cursor. Nenhum arquivo do aplicativo foi alterado." }
$versionBackupDir = Join-Path (Join-Path $cursorBackupDir $currentVersion) $appCommit
$versionReactDir = Join-Path $versionBackupDir "react-runtime\react"
$versionWorkbenchDir = Join-Path $versionBackupDir "workbench"
$versionEntryDir = Join-Path $versionBackupDir "workbench-entry"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$liveDesktop = Join-Path $targetWorkbenchDir "workbench.desktop.main.js"
$backupDesktop = Join-Path $versionWorkbenchDir "workbench.desktop.main.js"
if (-not (Test-Path $backupDesktop)) {
    $desktopSource = $liveDesktop
    if (-not (Test-Path $desktopSource)) { throw "Bundle principal do Cursor não encontrado: $liveDesktop" }
    $desktopContent = [System.IO.File]::ReadAllText($desktopSource)
    if (($desktopContent.Contains('import "./cursor-pt-dict.js";') -or $desktopContent.Contains("import './cursor-pt-dict.js';")) -and $desktopSource -eq $liveDesktop) {
        Write-Host "[ERRO] O Cursor instalado já está traduzido ou modificado, e o backup original desta compilação não existe." -ForegroundColor Red
        Write-Host "       Versão: $currentVersion | Commit: $appCommit" -ForegroundColor Yellow
        Write-Host "       Nenhum arquivo foi alterado. Repare/instale o Cursor oficial por cima e tente novamente." -ForegroundColor Cyan
        Write-Host "       Mantenha as pastas de dados do usuário; seus projetos ficam fora da pasta do programa." -ForegroundColor Cyan
        exit 1
    }
        New-Item -ItemType Directory -Path $versionReactDir,$versionWorkbenchDir -Force | Out-Null
    Copy-Item -LiteralPath $desktopSource -Destination $backupDesktop
}

# O bundle Glass e os runtimes React ficam de fábrica. O ponto de entrada do Workbench
# é preservado para carregar o dicionário na tela Glass sem modificar o bundle React/Glass.
foreach ($name in @("workbench.glass.main.js")) {
    $src = Join-Path $targetWorkbenchDir $name; $dst = Join-Path $versionWorkbenchDir $name
    if (-not (Test-Path $dst) -and (Test-Path $src)) {
        $content = [System.IO.File]::ReadAllText($src)
        if ($content.Contains('cursor-pt-dict.js')) { throw "O bundle Glass foi alterado e não há backup original confiável para a versão $currentVersion. Reinstale essa versão do Cursor antes de aplicar a tradução." }
        Copy-Item -LiteralPath $src -Destination $dst
    }
}
$entrySource = Join-Path $cursorAppDir "out\vs\code\electron-sandbox\workbench\workbench.js"
$entryBackup = Join-Path $versionEntryDir "workbench.js"
if (-not (Test-Path $entryBackup)) {
    if (-not (Test-Path $entrySource)) { throw "Ponto de entrada do Workbench não encontrado: $entrySource" }
    $entryContent = [System.IO.File]::ReadAllText($entrySource)
    if ($entryContent.Contains('cursor-pt-dict.js')) { throw "O ponto de entrada do Cursor já foi alterado e não existe backup original confiável para $currentVersion. Nenhum arquivo foi alterado." }
    New-Item -ItemType Directory -Path $versionEntryDir -Force | Out-Null
    Copy-Item -LiteralPath $entrySource -Destination $entryBackup
}
foreach ($name in @("esm-jsx-runtime-production.js","esm-index-production.js")) {
    $src = Join-Path $targetReactDir $name; $dst = Join-Path $versionReactDir $name
    if (-not (Test-Path $dst) -and (Test-Path $src)) {
        $content = [System.IO.File]::ReadAllText($src)
        if ($content.Contains('cursor-pt-dict') -or $content.Contains('Emerson Teles')) { throw "Runtime React alterado detectado ($name), sem backup original confiável para $currentVersion. Reinstale essa versão do Cursor antes de aplicar a tradução." }
        Copy-Item -LiteralPath $src -Destination $dst
    }
}
foreach ($pair in @(
    @{ Source = (Join-Path $cursorAppDir "product.json"); Name = "product.json" },
    @{ Source = (Join-Path $cursorAppDir "out\nls.messages.json"); Name = "nls.messages.json" }
)) {
    $dst = Join-Path $versionBackupDir $pair.Name
    if (-not (Test-Path $dst) -and (Test-Path $pair.Source)) { Copy-Item -LiteralPath $pair.Source -Destination $dst }
}
$manifestPath = Join-Path $versionBackupDir "translation-backup.json"
if (Test-Path $manifestPath) {
    $existingManifest = Get-Content $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($existingManifest.version -ne $currentVersion -or $existingManifest.commit -ne $appCommit) {
        throw "O manifesto do backup não corresponde à instalação detectada ($currentVersion / $appCommit). Nenhum arquivo do Cursor foi alterado."
    }
} else {
    $manifest = [ordered]@{ version = $currentVersion; commit = $appCommit; backupCreated = (Get-Date).ToString("o"); source = "installed-version" }
    [System.IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json), $utf8NoBom)
}
$cursorTranslationDetected = $false
$liveDesktopContent = if (Test-Path -LiteralPath $liveDesktop) { [IO.File]::ReadAllText($liveDesktop) } else { "" }
foreach ($candidate in @($liveDesktop, $entrySource)) {
    if (Test-Path -LiteralPath $candidate) {
        $candidateText = if ($candidate -eq $liveDesktop) { $liveDesktopContent } else { [IO.File]::ReadAllText($candidate) }
        if ($candidateText.Contains('cursor-pt-dict.js') -or $candidateText.Contains('cursor-ptbr-glass-loader')) {
            $cursorTranslationDetected = $true
            break
        }
    }
}
$liveEntryContent = if (Test-Path -LiteralPath $entrySource) { [IO.File]::ReadAllText($entrySource) } else { "" }
$liveGlass = Join-Path $targetWorkbenchDir "workbench.glass.main.js"
$liveGlassContent = if (Test-Path -LiteralPath $liveGlass) { [IO.File]::ReadAllText($liveGlass) } else { "" }
$glassCreditInstalled = $liveGlassContent.Contains('Tradução PT-BR: Emerson Teles')
$dictionaryInstalled = Test-Path -LiteralPath (Join-Path $targetWorkbenchDir "cursor-pt-dict.js")
$cursorAlreadyTranslated = $liveDesktopContent.Contains('import "./cursor-pt-dict.js";') -and $liveEntryContent.Contains('cursor-pt-dict.js') -and $dictionaryInstalled -and $glassCreditInstalled
if ($cursorAlreadyTranslated) {
    Write-Host ''
    Write-Host '    [i] Cursor já está em Português (Brasil); verificando atualizações do dicionário PT-BR.' -ForegroundColor Cyan
    Write-Host "        Backup original preservado: $versionBackupDir" -ForegroundColor Gray
    $dictSrc = Join-Path $coreDir "cursor-pt-dict.js"
    $dictDst = Join-Path $targetWorkbenchDir "cursor-pt-dict.js"
    if ((Test-Path -LiteralPath $dictSrc) -and (Test-Path -LiteralPath $dictDst)) {
        $sourceDictHash = (Get-FileHash -LiteralPath $dictSrc -Algorithm SHA256).Hash
        $installedDictHash = (Get-FileHash -LiteralPath $dictDst -Algorithm SHA256).Hash
        if ($sourceDictHash -ne $installedDictHash) {
            Copy-FileWithProgress -Source $dictSrc -Destination $dictDst -Label "Atualizando dicionário PT-BR"
            Write-Host '    [OK] Dicionário PT-BR atualizado; os arquivos originais e backups foram preservados.' -ForegroundColor Green
            Write-Host '        Reinicie o Cursor para carregar as traduções atualizadas.' -ForegroundColor Cyan
        } else {
            Write-Host '    [i] Dicionário PT-BR já está atualizado.' -ForegroundColor Cyan
        }
    }
    $exePath = Join-Path $cursorDir "Cursor.exe"
    if (Test-Path $exePath) {
        if (Read-OpenChoice "Deseja iniciar o aplicativo Cursor? [S = abrir | N/Enter/Esc = fechar]: ") {
            Start-CursorDetached -Executable $exePath -Locale 'pt-br'
        }
    }
    Exit 0
}
if ($cursorTranslationDetected) {
    if (-not $glassCreditInstalled) {
        Write-Host '    [i] Cursor já está traduzido; o crédito do diálogo Sobre será corrigido usando o backup original preservado.' -ForegroundColor Cyan
    } else {
        Write-Host '    [i] Tradução PT-BR parcial ou incompleta detectada; será reconstruída a partir do backup original limpo.' -ForegroundColor Cyan
    }
} else {
    Write-Host '    [OK] Backup original desta compilação validado e preservado; ele não será substituído.' -ForegroundColor Green
}
Write-Host "        $versionBackupDir" -ForegroundColor Gray

# 4. Copiar arquivos de runtime e dicionário traduzidos
Write-Host ""
Write-Host "[3/6] Instalando runtime e dicionário em Português do Brasil..." -ForegroundColor White

if (-not (Test-Path $targetReactDir)) {
    New-Item -ItemType Directory -Path $targetReactDir -Force | Out-Null
}
if (-not (Test-Path $targetWorkbenchDir)) {
    New-Item -ItemType Directory -Path $targetWorkbenchDir -Force | Out-Null
}

# 4.1 Instalar dicionário tanto no Workbench quanto no React Runtime
$dictSrc = Join-Path $coreDir "cursor-pt-dict.js"
if (Test-Path $dictSrc) {
    Copy-FileWithProgress -Source $dictSrc -Destination (Join-Path $targetWorkbenchDir "cursor-pt-dict.js") -Label "Instalando dicionário no Workbench"
}

# 4.2 Os runtimes React são preservados; o dicionário não intercepta JSX.

# O atualizador oficial do Cursor permanece intacto para receber versões posteriores.

# 5. Instalar Language Pack Oficial PT-BR
Write-Host ""
Write-Host "[4/6] Verificando pacote de idioma oficial PT-BR..." -ForegroundColor White
$cursorExtDir = Join-Path $env:USERPROFILE ".cursor\extensions"
$langPackName = "ms-ceintl.vscode-language-pack-pt-br-1.128.0-universal"
$langPackSource = Join-Path $coreDir $langPackName
$langPackTarget = Join-Path $cursorExtDir $langPackName

if (Test-Path $langPackSource) {
    if (-not (Test-Path $cursorExtDir)) {
        New-Item -ItemType Directory -Path $cursorExtDir -Force | Out-Null
    }
    if (-not (Test-Path $langPackTarget)) {
        Write-Host "    -> Instalando pacote de idioma oficial..." -ForegroundColor Cyan
        Copy-Item -Path $langPackSource -Destination $langPackTarget -Recurse -Force
        Write-Host "    [OK] Pacote de idioma oficial instalado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "    -> Pacote de idioma oficial ja presente nas extensoes." -ForegroundColor Gray
    }
}

# 6. Configurar idioma pt-br nas preferências
Write-Host ""
Write-Host "[5/6] Configurando preferências de idioma e registro de extensoes..." -ForegroundColor White
$setupScript = Join-Path $coreDir "setup-locale.js"
if (Test-Path $setupScript) {
    node $setupScript
    if ($LASTEXITCODE -ne 0) { throw "Falha ao configurar o idioma PT-BR do Cursor (código $LASTEXITCODE)." }
}

# 6.0 Restaurar o bundle Glass somente do backup desta instalação e versão.
$cleanGlassSrc = Join-Path $versionWorkbenchDir "workbench.glass.main.js"
$targetGlass = Join-Path $targetWorkbenchDir "workbench.glass.main.js"
if (Test-Path $cleanGlassSrc) {
    Copy-Item -Path $cleanGlassSrc -Destination $targetGlass -Force
    Write-Host "    -> Bundle Glass original restaurado do backup; crédito do Sobre será reaplicado pontualmente." -ForegroundColor Green
}

# 6.1 Aplicar patches nativos no workbench (Acoes, Menus e Dialogos)
Write-Host ""
Write-Host "[5.1/6] Aplicando tradução nas acoes nativas e dialogos..." -ForegroundColor White
$patchScript = Join-Path $coreDir "patch-workbench.js"
if (Test-Path $patchScript) {
    node $patchScript "$cursorDir" "$versionBackupDir"
    if ($LASTEXITCODE -ne 0) { throw "Falha ao aplicar os textos PT-BR do Workbench (código $LASTEXITCODE)." }
}

# 6.2 Carregar o mesmo dicionário na tela Glass através do carregador do Workbench.
$entryPatchScript = Join-Path $coreDir "patch-workbench-entry.js"
if (-not (Test-Path $entryPatchScript)) { throw "Patcher da tela Glass não encontrado: $entryPatchScript" }
node $entryPatchScript "$cursorDir" "$versionBackupDir"
if ($LASTEXITCODE -ne 0) { throw "Falha ao habilitar a tradução da tela Glass (código $LASTEXITCODE)." }

# 7. Validar e Reparar Integridade do Cursor (Checksums)
Write-Host ""
Write-Host "[6/6] Validando e reparando integridade do Cursor (Checksums)..." -ForegroundColor White
$repairScript = Join-Path $coreDir "repair-integrity.js"
if (Test-Path $repairScript) {
    node $repairScript "$cursorDir"
    if ($LASTEXITCODE -ne 0) { throw "Falha ao validar a integridade do Cursor (código $LASTEXITCODE)." }
}

# Conclusao
Write-Host ""
Write-Host " ==================================================================== " -ForegroundColor Green
Write-Host "             TRADUÇÃO CURSOR INSTALADA COM SUCESSO!                   " -ForegroundColor Green
Write-Host " ==================================================================== " -ForegroundColor Green
Write-Host ""
Write-Host "  O Cursor agora esta configurado em Português do Brasil." -ForegroundColor White
Write-Host "  Seu backup original de fábrica esta seguro em:" -ForegroundColor Gray
Write-Host "  $cursorBackupDir" -ForegroundColor Yellow
Write-Host ""

$exePath = Join-Path $cursorDir "Cursor.exe"
if (Test-Path $exePath) {
    if (Read-OpenChoice "Deseja iniciar o aplicativo Cursor? [S = abrir | N/Enter/Esc = fechar]: ") {
        Write-Host "Iniciando Cursor de forma independente..." -ForegroundColor Cyan
        # Inicia sem console herdado para que os logs internos do Electron não
        # mantenham a janela do instalador aberta.
        Start-CursorDetached -Executable $exePath -Locale 'pt-br'
        Exit 0
    } else {
        Write-Host "Instalação concluída. Finalizando..." -ForegroundColor Gray
        Start-Sleep -Milliseconds 300
        Exit 0
    }
}
Exit 0
