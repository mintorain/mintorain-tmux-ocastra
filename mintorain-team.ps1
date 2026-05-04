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

# 2. 기존 동일 세션 정리 (kill + delete 둘 다 호출 — idempotent, 없어도 무해)
#    list-sessions 출력에 ANSI 색상 코드가 포함되어 정규식 매칭이 어려우므로
#    조건 검사 없이 항상 정리 시도가 가장 안전.
Write-Host "♻️  기존 mintorain 세션 정리 중..." -ForegroundColor Yellow
zellij kill-session mintorain 2>$null | Out-Null
Start-Sleep -Milliseconds 300
zellij delete-session mintorain 2>$null | Out-Null
Start-Sleep -Milliseconds 200

# 3. 작업 폴더로 이동
if (-not (Test-Path $WorkDir)) {
    Write-Host "❌ 작업 폴더가 존재하지 않습니다: $WorkDir" -ForegroundColor Red
    exit 1
}
Set-Location -Path $WorkDir

# 4. 레이아웃 템플릿 확인 + 작업 폴더 주입한 임시 KDL 생성
#    KDL 안의 {{WORK_DIR}} placeholder 를 실제 작업 폴더 경로로 치환해서
#    각 패인이 사용자가 실행한 그 폴더에서 시작되도록 한다.
$LayoutTemplate = Join-Path $ScriptDir "mintorain-zellij.kdl"
if (-not (Test-Path $LayoutTemplate)) {
    Write-Host "❌ 레이아웃 파일을 찾을 수 없습니다: $LayoutTemplate" -ForegroundColor Red
    exit 1
}

# Zellij KDL은 백슬래시 경로 처리에 민감하므로 forward slash 형태로 변환
$WorkDirForKdl = $WorkDir   -replace '\\', '/'
$KitDirForKdl  = $ScriptDir -replace '\\', '/'

# Leader 시스템 프롬프트 파일을 읽어 KDL string 으로 escape
# escape 순서: 백슬래시 → \\, 따옴표 → \", CRLF/LF → \n  (KDL spec)
$LeaderPromptPath = Join-Path $ScriptDir 'prompts/leader.txt'
if (-not (Test-Path $LeaderPromptPath)) {
    Write-Host "❌ Leader prompt 파일을 찾을 수 없습니다: $LeaderPromptPath" -ForegroundColor Red
    exit 1
}
$LeaderPromptRaw = Get-Content $LeaderPromptPath -Raw -Encoding UTF8
$LeaderPromptForKdl = $LeaderPromptRaw.Replace('\', '\\').Replace('"', '\"').Replace("`r`n", "`n").Replace("`n", '\n')

# zellij 자식 프로세스(claude 패인들)에 키트 폴더 경로 상속
# Leader 가 invoke-pane.ps1 을 호출할 때 사용
$env:MINTORAIN_KIT_DIR = $ScriptDir

# KDL placeholder 치환 — {{WORK_DIR}}, {{KIT_DIR}}, {{LEADER_PROMPT}}
$LayoutContent = (Get-Content $LayoutTemplate -Raw) `
    -replace '\{\{WORK_DIR\}\}',     $WorkDirForKdl `
    -replace '\{\{KIT_DIR\}\}',      $KitDirForKdl `
    -replace '\{\{LEADER_PROMPT\}\}', $LeaderPromptForKdl

# 임시 KDL 파일에 기록 (zellij 종료 후 삭제)
$LayoutFile = Join-Path $env:TEMP "mintorain-zellij-$PID.kdl"
$LayoutContent | Set-Content -Path $LayoutFile -Encoding UTF8

# 5. UTF-8 출력 강제 (한글/이모지 깨짐 방지)
$env:PYTHONIOENCODING = "utf-8"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 5.5 claude trust 다이얼로그 자동 우회 — 작업 폴더 사전 등록
#     ~/.claude.json 의 projects.<WorkDir>.hasTrustDialogAccepted = true
#     PowerShell 7+ 의 ConvertFrom-Json -Depth 옵션 필요 (mintorain-team.ps1 은 pwsh로 실행되어야 함)
$claudeJson = Join-Path $env:USERPROFILE '.claude.json'
if (Test-Path $claudeJson) {
    try {
        $cfg = Get-Content $claudeJson -Raw | ConvertFrom-Json -Depth 50
        $changed = $false

        if (-not $cfg.PSObject.Properties.Name.Contains('projects')) {
            $cfg | Add-Member -NotePropertyName 'projects' -NotePropertyValue ([PSCustomObject]@{}) -Force
            $changed = $true
        }

        # 작업 폴더와 키트 폴더 모두 자동 trust 등록
        $dirsToTrust = @($WorkDir, $ScriptDir) | Select-Object -Unique
        foreach ($dir in $dirsToTrust) {
            $existing = $cfg.projects.PSObject.Properties.Name -contains $dir
            if (-not $existing) {
                $cfg.projects | Add-Member -NotePropertyName $dir -NotePropertyValue ([PSCustomObject]@{
                    hasTrustDialogAccepted = $true
                    allowedTools = @()
                    history = @()
                }) -Force
                Write-Host "🔓 trust 자동 등록: $dir" -ForegroundColor Green
                $changed = $true
            } elseif ($cfg.projects.$dir.hasTrustDialogAccepted -ne $true) {
                $cfg.projects.$dir.hasTrustDialogAccepted = $true
                Write-Host "🔓 trust 갱신: $dir" -ForegroundColor Green
                $changed = $true
            }
        }

        if ($changed) {
            # 백업 후 저장
            if (-not (Test-Path "$claudeJson.bak")) {
                Copy-Item $claudeJson "$claudeJson.bak" -Force
            }
            $cfg | ConvertTo-Json -Depth 50 -Compress | Set-Content -Path $claudeJson -Encoding UTF8 -NoNewline
        }
    } catch {
        Write-Host "⚠️  trust 자동 등록 실패 (수동 'Yes, I trust this folder' 필요): $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "ℹ️  $claudeJson 없음 (claude 첫 실행 후 생성됨) — trust 등록 skip" -ForegroundColor Gray
}

# 6. Zellij 실행
#    --new-session-with-layout: 항상 새 세션 생성 (--session 단독은 기존 세션 attach용이라 "no active session" 오류 발생)
#    -s mintorain: 세션 이름 지정 (재연결: zellij attach mintorain)
Write-Host "🚀 Zellij 5분할 팀 세션을 시작합니다..." -ForegroundColor Green
Write-Host "   세션 종료: Ctrl+Q   |   패인 이동: Ctrl+P + 화살표" -ForegroundColor Gray
Write-Host "   재연결:    zellij attach mintorain" -ForegroundColor Gray
Write-Host ""

try {
    zellij --new-session-with-layout $LayoutFile -s mintorain
}
finally {
    # 임시 KDL 파일 정리 (zellij 정상/비정상 종료 모두 커버)
    Remove-Item $LayoutFile -ErrorAction SilentlyContinue
}
