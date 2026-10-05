# ==============================================================================
#  Restaurador do Cursor Original de Fabrica
#  Pacote de Tradução por: Emerson Teles
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
$Host.UI.RawUI.WindowTitle = "Restaurar Cursor Original - Emerson Teles"

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host " ==================================================================== " -ForegroundColor Yellow
    Write-Host "             RESTAURAR CURSOR ORIGINAL DE FÁBRICA                     " -ForegroundColor White
    Write-Host "              Pacote de Tradução por: Emerson Teles                   " -ForegroundColor Cyan
    Write-Host " ==================================================================== " -ForegroundColor Yellow
    Write-Host ""
}

function Copy-FileWithProgress {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label = "Restaurando"
    )

    if ((Test-Path -LiteralPath $Destination -PathType Leaf) -and
        (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash) {
        Write-Host "    [i] $Label já está original; restauração desnecessária." -ForegroundColor Cyan
        return
    }
    $script:restoreChanged = $true

    $sourceFile = New-Object System.IO.FileInfo($Source)
    $totalBytes = $sourceFile.Length
    $totalKB = [math]::Round($totalBytes / 1KB, 1)

    $bufferSize = 64KB
    $buffer = New-Object byte[] $bufferSize

    $sourceStream = [System.IO.File]::OpenRead($Source)
    $destStream = [System.IO.File]::Create($Destination)

    $totalRead = 0
    $lastPercent = -1

    Write-Host "  $Label..." -ForegroundColor Cyan

    try {
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
    }
    finally {
        if ($sourceStream) { $sourceStream.Close() }
        if ($destStream) { $destStream.Close() }
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

Write-Header

# 1. Fechar processos ativos do Cursor
$running = Get-Process | Where-Object { $_.ProcessName -like "*cursor*" }
if ($running) {
    Write-Host "[-] Fechando processos ativos do Cursor para restaurar arquivos..." -ForegroundColor Yellow
    $running | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# 2. Localizar instalação do Cursor
Write-Host "[1/3] Localizando instalação do Cursor no computador..." -ForegroundColor White
$cursorDir = Find-CursorInstallation

while (-not $cursorDir -or -not (Test-Path $cursorDir)) {
    Write-Host ""
    Write-Host "[!] Não foi possivel detectar o Cursor automaticamente." -ForegroundColor Yellow
    $userInput = Read-Host "Digite ou cole a pasta onde o Cursor esta instalado"
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        Write-Host "[x] Operacao cancelada." -ForegroundColor Red
        Exit 1
    }
    if (Test-Path (Join-Path $userInput "resources\app")) {
        $cursorDir = $userInput
    } else {
        Write-Host "[x] Pasta invalida!" -ForegroundColor Red
    }
}

Write-Host "    -> Cursor localizado em: $cursorDir" -ForegroundColor Green
$cursorAppDir = Join-Path $cursorDir "resources\app"
$targetReactDir = Join-Path $cursorAppDir "out\vs\workbench\react-runtime\react"

# Pasta padronizada de backup dentro do diretorio do programa
$cursorBackupDir = Join-Path $cursorDir "_backups"

# Detectar versão atual do Cursor
$currentVersion = $null
$pkgJsonPath = Join-Path $cursorAppDir "package.json"
if (Test-Path $pkgJsonPath) {
    try {
        $pkgObj = Get-Content $pkgJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($pkgObj.version) { $currentVersion = $pkgObj.version }
    } catch { }
}
if (-not $currentVersion) { throw "Não foi possível detectar a versão do Cursor em $pkgJsonPath. A restauração foi interrompida." }
Write-Host "    -> Versão detectada do Cursor: $currentVersion" -ForegroundColor Cyan

# 3. Localizar e Restaurar Backup
Write-Host ""
Write-Host "[2/3] Localizando arquivos de backup original (v$currentVersion)..." -ForegroundColor White

$appCommit = ""
try { $appCommit = (Get-Content (Join-Path $cursorAppDir "product.json") -Raw -Encoding UTF8 | ConvertFrom-Json).commit } catch { }
if (-not $appCommit) { throw "Não foi possível detectar o commit da instalação do Cursor. A restauração foi interrompida." }
$versionBackupDir = Join-Path (Join-Path $cursorBackupDir $currentVersion) $appCommit
$versionReactDir = Join-Path $versionBackupDir "react-runtime\react"

# A restauração exige o backup da compilação exata atualmente instalada.
if (Test-Path (Join-Path $versionBackupDir "workbench\workbench.desktop.main.js")) {
    $foundSourceDir = $versionReactDir
    $foundBaseBackup = $versionBackupDir
}

if (-not $foundSourceDir) {
    # Uma instalação atualizada pode estar limpa mesmo sem backup da compilação
    # exata. Nesse caso, só declare o estado original se não houver marcadores
    # conhecidos do patch PT-BR nos bundles que ele altera.
    $liveDesktop = Join-Path $cursorAppDir "out\vs\workbench\workbench.desktop.main.js"
    $liveGlass = Join-Path $cursorAppDir "out\vs\workbench\workbench.glass.main.js"
    $liveEntry = Join-Path $cursorAppDir "out\vs\code\electron-sandbox\workbench\workbench.js"
    $liveReactFiles = @(
        (Join-Path $targetReactDir "esm-jsx-runtime-production.js"),
        (Join-Path $targetReactDir "esm-index-production.js")
    )
    $knownTranslationMarkers = @(
        'cursor-pt-dict.js',
        'cursor-ptbr-glass-loader',
        'Emerson Teles'
    )
    $translationMarkersFound = [System.Collections.Generic.List[string]]::new()
    foreach ($candidate in @($liveDesktop, $liveGlass, $liveEntry) + $liveReactFiles) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            $candidateText = [IO.File]::ReadAllText($candidate)
            foreach ($marker in $knownTranslationMarkers) {
                if ($candidateText.Contains($marker)) {
                    $translationMarkersFound.Add("$marker em $candidate")
                }
            }
        }
    }

    if ($translationMarkersFound.Count -gt 0) {
        Write-Host "[x] Não encontrei um backup original desta versão/compilação:" -ForegroundColor Red
        Write-Host "    $versionBackupDir" -ForegroundColor Red
        Write-Host "[!] Há sinais de PT-BR, mas falta o backup original. Nenhum arquivo foi sobrescrito." -ForegroundColor Yellow
        $translationMarkersFound | Select-Object -Unique | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
        Write-Host "    Repare/instale a mesma versão oficial do Cursor por cima e tente novamente." -ForegroundColor Cyan
        Write-Host "    Mantenha as pastas de dados do usuário; os projetos ficam fora da pasta do programa." -ForegroundColor Cyan
        Pause
        Exit 1
    }

    Write-Host "    [i] Não há backup desta compilação, mas os bundles do Cursor não contêm os marcadores PT-BR do tradutor." -ForegroundColor Cyan
    $restoreChanged = $false
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $argvLocations = @(
        (Join-Path $env:USERPROFILE ".cursor\argv.json"),
        (Join-Path $env:APPDATA "Cursor\argv.json"),
        (Join-Path $env:APPDATA "Cursor\User\argv.json")
    )
    foreach ($ap in $argvLocations) {
        if (Test-Path -LiteralPath $ap -PathType Leaf) {
            try {
                $json = Get-Content -LiteralPath $ap -Raw -Encoding UTF8 | ConvertFrom-Json
                if ($json.locale -ne "en") {
                    $json.locale = "en"
                    [System.IO.File]::WriteAllText($ap, ($json | ConvertTo-Json -Depth 5), $utf8NoBom)
                    $verify = [System.IO.File]::ReadAllText($ap, $utf8NoBom) | ConvertFrom-Json
                    if ($verify.locale -ne "en") { throw "A preferência não confirmou o locale en após a gravação." }
                    $restoreChanged = $true
                }
            } catch {
                Write-Host "[x] Não foi possível restaurar o idioma em $ap. A restauração foi interrompida." -ForegroundColor Red
                throw
            }
        }
    }

    if ($restoreChanged) {
        Write-Host " Restauração do idioma concluída; os arquivos do aplicativo já estavam sem o patch PT-BR." -ForegroundColor Green
        $alreadyOriginal = $false
    } else {
        Write-Host " O Cursor já está no estado original detectável; restauração desnecessária." -ForegroundColor Cyan
        $alreadyOriginal = $true
    }

    Write-Host ""
    $exePath = Join-Path $cursorDir "Cursor.exe"
    if (Test-Path $exePath) {
        if (Read-OpenChoice "Deseja iniciar o Cursor original? [S = abrir | N/Enter/Esc = fechar]: ") {
            Write-Host "Iniciando Cursor de forma independente..." -ForegroundColor Cyan
            Start-CursorDetached -Executable $exePath -Locale 'en'
        }
    }
    Exit 0
}

$manifestPath = Join-Path $foundBaseBackup "translation-backup.json"
if (-not (Test-Path $manifestPath)) {
    Write-Host "[x] Backup original desta compilação ausente ou incompleto." -ForegroundColor Red
    Write-Host "    Repare/instale a mesma versão oficial do Cursor por cima e tente novamente; mantenha os dados do usuário." -ForegroundColor Cyan
    Read-OpenChoice "Pressione Enter ou Esc para sair."
    Exit 1
}
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($manifest.version -ne $currentVersion -or $manifest.commit -ne $appCommit) {
    Write-Host "[x] O backup não corresponde à versão/build instalada; não foi usado." -ForegroundColor Red
    Write-Host "    Repare/instale a versão oficial atual por cima e tente novamente; mantenha os dados do usuário." -ForegroundColor Cyan
    Read-OpenChoice "Pressione Enter ou Esc para sair."
    Exit 1
}
$backupDesktop = Join-Path $foundBaseBackup "workbench\workbench.desktop.main.js"
if (-not (Test-Path $backupDesktop) -or [IO.File]::ReadAllText($backupDesktop).Contains('import "./cursor-pt-dict.js";')) {
    throw "O workbench salvo não foi confirmado como original limpo. Restauração interrompida."
}

Write-Host "    -> Restaurando arquivos a partir da base original: $foundBaseBackup" -ForegroundColor Cyan

# 3.1 Restaurar arquivos React originais de fábrica
$restoreChanged = $false
$filesToRestore = @("esm-jsx-runtime-production.js", "esm-index-production.js")

foreach ($fn in $filesToRestore) {
    $src = Join-Path $foundSourceDir $fn
    $dst = Join-Path $targetReactDir $fn
    if ((Test-Path $src) -and (Test-Path $dst)) {
        Copy-FileWithProgress -Source $src -Destination $dst -Label "Restaurando $fn original"
    }
}

# 3.2 Restaurar workbench nativo original limpo
$targetWorkbenchDir = Join-Path $cursorAppDir "out\vs\workbench"
$wbFiles = @("workbench.glass.main.js", "workbench.desktop.main.js")
foreach ($wb in $wbFiles) {
    $wbSrc = Join-Path $foundBaseBackup $wb
    if (-not (Test-Path $wbSrc)) {
        $wbSrc = Join-Path (Join-Path $foundBaseBackup "workbench") $wb
    }
    $wbDst = Join-Path $targetWorkbenchDir $wb
    if ((Test-Path $wbSrc) -and (Test-Path $wbDst)) {
        Copy-FileWithProgress -Source $wbSrc -Destination $wbDst -Label "Restaurando $wb original"
    }
}

# Restaurar o carregador de entrada original usado pela tela Glass.
$entryBackup = Join-Path $foundBaseBackup "workbench-entry\workbench.js"
$entryTarget = Join-Path $cursorAppDir "out\vs\code\electron-sandbox\workbench\workbench.js"
if (Test-Path $entryBackup) {
    $entryContent = [IO.File]::ReadAllText($entryBackup)
    if ($entryContent.Contains('cursor-pt-dict.js')) { throw "O backup do ponto de entrada Glass não é original limpo. Restauração interrompida." }
    Copy-FileWithProgress -Source $entryBackup -Destination $entryTarget -Label "Restaurando ponto de entrada original do Cursor"
} elseif ((Test-Path $entryTarget) -and [IO.File]::ReadAllText($entryTarget).Contains('cursor-pt-dict.js')) {
    throw "O ponto de entrada Glass está traduzido, mas não existe backup original correspondente. Restauração interrompida para evitar perda de dados."
}

# 3.3 Restaurar product.json e nls.messages.json se houver backup
$prodBak = Join-Path $foundBaseBackup "product.json"
if (Test-Path $prodBak) {
    $prodTarget = Join-Path $cursorAppDir "product.json"
    if (-not (Test-Path $prodTarget) -or (Get-FileHash -LiteralPath $prodBak -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $prodTarget -Algorithm SHA256).Hash) { Copy-Item -LiteralPath $prodBak -Destination $prodTarget -Force; $restoreChanged = $true }
}
$nlsBak = Join-Path $foundBaseBackup "nls.messages.json"
if (Test-Path $nlsBak) {
    $nlsTarget = Join-Path $cursorAppDir "out\nls.messages.json"
    if (-not (Test-Path $nlsTarget) -or (Get-FileHash -LiteralPath $nlsBak -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $nlsTarget -Algorithm SHA256).Hash) { Copy-Item -LiteralPath $nlsBak -Destination $nlsTarget -Force; $restoreChanged = $true }
}

# 3.4 Remover dicionário customizado de todos os locais
$dictWorkbench = Join-Path $targetWorkbenchDir "cursor-pt-dict.js"
if (Test-Path $dictWorkbench) {
    Remove-Item -Path $dictWorkbench -Force -ErrorAction SilentlyContinue
    $restoreChanged = $true
    Write-Host "    -> Dicionário customizado removido de Workbench." -ForegroundColor Gray
}
$dictReact = Join-Path $targetReactDir "cursor-pt-dict.js"
if (Test-Path $dictReact) {
    Remove-Item -Path $dictReact -Force -ErrorAction SilentlyContinue
    $restoreChanged = $true
    Write-Host "    -> Dicionário customizado removido de React Runtime." -ForegroundColor Gray
}

# 3.5 Restaurar idioma oficial para inglês em argv.json
$argvLocations = @(
    (Join-Path $env:USERPROFILE ".cursor\argv.json"),
    (Join-Path $env:APPDATA "Cursor\argv.json"),
    (Join-Path $env:APPDATA "Cursor\User\argv.json")
)
foreach ($ap in $argvLocations) {
    if (Test-Path $ap) {
        try {
            $json = Get-Content $ap -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($json.locale -ne "en") {
                $json.locale = "en"
                $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
                [System.IO.File]::WriteAllText($ap, ($json | ConvertTo-Json -Depth 5), $utf8NoBom)
                $verify = [System.IO.File]::ReadAllText($ap, $utf8NoBom) | ConvertFrom-Json
                if ($verify.locale -ne "en") { throw "A preferência não confirmou o locale en após a gravação." }
                $restoreChanged = $true
            }
        } catch {
            Write-Host "[x] Não foi possível restaurar o idioma em $ap. A restauração foi interrompida." -ForegroundColor Red
            throw
        }
    }
}
Write-Host "    -> Preferências de idioma restauradas para 'en' em argv.json." -ForegroundColor Gray

# 3.6 Revalidar e sincronizar a integridade
$repairScript = Join-Path $PSScriptRoot "repair-integrity.js"
if (Test-Path $repairScript) {
    node $repairScript "$cursorDir"
    if ($LASTEXITCODE -ne 0) { throw "Falha ao validar a integridade do Cursor durante a restauração (código $LASTEXITCODE)." }
}

# Conclusao
Write-Host ""
if ($restoreChanged) {
    Write-Host " ==================================================================== " -ForegroundColor Green
    Write-Host "            CURSOR RESTAURADO PARA O ESTADO ORIGINAL                  " -ForegroundColor Green
    Write-Host " ==================================================================== " -ForegroundColor Green
    Write-Host "  Restauração concluída com sucesso." -ForegroundColor Green
} else {
    Write-Host " ==================================================================== " -ForegroundColor Cyan
    Write-Host "       O CURSOR JÁ ESTÁ NO ESTADO ORIGINAL; RESTAURAÇÃO DISPENSADA    " -ForegroundColor Cyan
    Write-Host " ==================================================================== " -ForegroundColor Cyan
    Write-Host "  O pacote original já está instalado; não é necessário restaurar." -ForegroundColor Cyan
}
Write-Host ""

$exePath = Join-Path $cursorDir "Cursor.exe"
if (Test-Path $exePath) {
    if (Read-OpenChoice "Deseja iniciar o Cursor original? [S = abrir | N/Enter/Esc = fechar]: ") {
        Write-Host "Iniciando Cursor de forma independente..." -ForegroundColor Cyan
        Start-CursorDetached -Executable $exePath -Locale 'en'
        Exit 0
    } else {
        Write-Host "Restauração concluída. Finalizando..." -ForegroundColor Gray
        Start-Sleep -Milliseconds 300
        Exit 0
    }
}
Exit 0
