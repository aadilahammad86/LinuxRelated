# ============================================================
# Ollama + Open WebUI + Qwen 2.5 2B GGUF Setup Script
# Run as Administrator in PowerShell
# ============================================================

# ---------- CONFIGURATION — Edit these ----------
$GgufPath    = "$env:USERPROFILE\Downloads\Qwen3.5-2B-Q8_0.gguf"   # Full path to your GGUF file
$ModelName   = "qwen3.5-2B-Q8_0"                   # Name to register in Ollama
$NumCtx      = 32768                           # Context window size
$WebUIPort   = 3000                            # Open WebUI browser port
# ------------------------------------------------

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ollama + Open WebUI Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Install Ollama
Write-Host "[1/5] Checking for Ollama..." -ForegroundColor Yellow

$ollamaExists = Get-Command ollama -ErrorAction SilentlyContinue

if ($ollamaExists) {
    Write-Host "      Ollama is already installed. Skipping download and installation." -ForegroundColor Green
} else {
    Write-Host "      Ollama not found. Downloading and installing..." -ForegroundColor Yellow
    
    $ollamaInstaller = "$env:TEMP\ollama-installer.exe"
    Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" `
        -OutFile $ollamaInstaller -UseBasicParsing

    Start-Process -FilePath $ollamaInstaller -ArgumentList "/SILENT" -Wait

    Write-Host "      Ollama installed." -ForegroundColor Green
}

# Step 2: Start Ollama Service
Write-Host "[2/5] Starting Ollama service..." -ForegroundColor Yellow

Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden

# Wait for Ollama API to be ready
Write-Host "      Waiting for Ollama to be ready..."
$retries = 0
do {
    Start-Sleep -Seconds 2
    $retries++
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:11434" `
            -UseBasicParsing -ErrorAction Stop
        $ready = $true
    } catch {
        $ready = $false
    }
} while (-not $ready -and $retries -lt 15)

if (-not $ready) {
    Write-Host "      ERROR: Ollama did not start in time. Check manually." -ForegroundColor Red
    exit 1
}

Write-Host "      Ollama is running at http://localhost:11434" -ForegroundColor Green

# Step 3: Load GGUF Model into Ollama
Write-Host "[3/5] Loading GGUF model into Ollama..." -ForegroundColor Yellow

if (-not (Test-Path $GgufPath)) {
    Write-Host "      ERROR: GGUF file not found at: $GgufPath" -ForegroundColor Red
    Write-Host "      Edit the GgufPath variable at the top of this script." -ForegroundColor Red
    exit 1
}

# Write Modelfile
$ModelfilePath = "$env:TEMP\Modelfile"
@"
FROM $GgufPath
PARAMETER num_ctx $NumCtx
"@ | Out-File -FilePath $ModelfilePath -Encoding ASCII

# Create the model in Ollama
Write-Host "      Running: ollama create $ModelName ..."
& ollama create $ModelName -f $ModelfilePath

Write-Host "      Model '$ModelName' loaded successfully." -ForegroundColor Green

# Step 4: Install Docker Desktop
Write-Host "[4/5] Checking for Docker..." -ForegroundColor Yellow

$dockerExists = Get-Command docker -ErrorAction SilentlyContinue

if ($dockerExists) {
    Write-Host "      Docker already installed. Skipping." -ForegroundColor Green
} else {
    Write-Host "      Docker not found. Downloading Docker Desktop..."

    $dockerInstaller = "$env:TEMP\DockerDesktopInstaller.exe"
    Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" `
        -OutFile $dockerInstaller -UseBasicParsing

    Write-Host "      Installing Docker Desktop (this may take a few minutes)..."
    Start-Process -FilePath $dockerInstaller -ArgumentList "install --quiet" -Wait

    Write-Host "      Docker Desktop installed." -ForegroundColor Green
    Write-Host ""
    Write-Host "  !! IMPORTANT: Docker requires a system RESTART before continuing." -ForegroundColor Red
    Write-Host "  !! After restarting, re-run this script — it will skip to Step 5." -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to restart now, or Ctrl+C to restart manually later"
    Restart-Computer -Force
}

# Step 5: Run Open WebUI via Docker
Write-Host "[5/5] Starting Open WebUI container..." -ForegroundColor Yellow

# Stop existing container if running
docker rm -f open-webui 2>$null

# Run Open WebUI pointed at Ollama on host machine
docker run -d `
    --name open-webui `
    --restart always `
    -p "${WebUIPort}:8080" `
    -e OLLAMA_BASE_URL=http://host.docker.internal:11434 `
    -v open-webui:/app/backend/data `
    ghcr.io/open-webui/open-webui:main

Write-Host "      Open WebUI container started." -ForegroundColor Green

# Done
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Ollama API  ->  http://localhost:11434" -ForegroundColor White
Write-Host "  Open WebUI  ->  http://localhost:$WebUIPort" -ForegroundColor White
Write-Host "  Model Name  ->  $ModelName" -ForegroundColor White
Write-Host ""
Write-Host "  Open your browser and go to http://localhost:$WebUIPort" -ForegroundColor Green
Write-Host "  Select '$ModelName' from the model dropdown and start chatting!" -ForegroundColor Green
Write-Host ""