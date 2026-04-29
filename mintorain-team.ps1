# =====================================================
# MINTORAIN Claude Team Agent - Windows PowerShell 런처
# Zellij 기반 5분할 팀 에이전트 자동 세팅 (WSL 불필요)
#
# 사용법:
#   pwsh mintorain-team.ps1                    # 현재 디렉토리에서 실행
#   pwsh mintorain-team.ps1 C:\my-project      # 지정 디렉토리에서 실행
# =====================================================

[CmdletBinding()]
param(
    [string]$WorkDir = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " MINTORAIN Claude Team Agent (Windows / Zellij)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " 작업 폴더: $WorkDir" -ForegroundColor Gray
Write-Host ""

# 1. 필수 도구 확인
$missing = @()
foreach ($cmd in @("zellij", "claude", "pwsh")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        $missing += $cmd
    }
}

if ($missing.Count -gt 0) {
    Write-Host "❌ 다음 도구가 설치되어 있지 않습니다:" -ForegroundColor Red
    foreach ($cmd in $missing) {
        switch ($cmd) {
            "zellij" {
                Write-Host "   - zellij : winget install Zellij-Contributors.Zellij" -ForegroundColor Yellow
            }
            "claude" {
                Write-Host "   - claude : npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
            }
            "pwsh" {
                Write-Host "   - pwsh   : winget install Microsoft.PowerShell" -ForegroundColor Yellow
            }
        }
    }
    exit 1
}

# 2. 기존 동일 세션 정리
$existing = zellij list-sessions 2>$null | Select-String -Pattern "^mintorain"
if ($existing) {
    Write-Host "♻️  기존 mintorain 세션 정리 중..." -ForegroundColor Yellow
    zellij delete-session mintorain --force 2>$null | Out-Null
}

# 3. 작업 폴더로 이동
if (-not (Test-Path $WorkDir)) {
    Write-Host "❌ 작업 폴더가 존재하지 않습니다: $WorkDir" -ForegroundColor Red
    exit 1
}
Set-Location -Path $WorkDir

# 4. 레이아웃 파일 확인
$LayoutFile = Join-Path $ScriptDir "mintorain-zellij.kdl"
if (-not (Test-Path $LayoutFile)) {
    Write-Host "❌ 레이아웃 파일을 찾을 수 없습니다: $LayoutFile" -ForegroundColor Red
    exit 1
}

# 5. UTF-8 출력 강제 (한글/이모지 깨짐 방지)
$env:PYTHONIOENCODING = "utf-8"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 6. Zellij 실행
#    --new-session-with-layout: 항상 새 세션 생성 (--session 단독은 기존 세션 attach용이라 "no active session" 오류 발생)
#    -s mintorain: 세션 이름 지정 (재연결: zellij attach mintorain)
Write-Host "🚀 Zellij 5분할 팀 세션을 시작합니다..." -ForegroundColor Green
Write-Host "   세션 종료: Ctrl+Q   |   패인 이동: Ctrl+P + 화살표" -ForegroundColor Gray
Write-Host "   재연결:    zellij attach mintorain" -ForegroundColor Gray
Write-Host ""

zellij --new-session-with-layout $LayoutFile -s mintorain
