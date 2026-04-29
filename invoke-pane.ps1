# =====================================================
# invoke-pane.ps1
# 리더 (👑) 가 다른 패인에 명령을 자동으로 입력시키는 헬퍼
#
# 사용법 (리더 패인의 Claude가 호출):
#   pwsh invoke-pane.ps1 -Pane planner  -Command claude
#   pwsh invoke-pane.ps1 -Pane frontend -Command claude
#   pwsh invoke-pane.ps1 -Pane backend  -Command claude
#   pwsh invoke-pane.ps1 -Pane qa       -Command claude
#   pwsh invoke-pane.ps1 -Pane planner  -Command "npm run lint"
#
# 동작 원리:
#   1. zellij action focus-next-pane 을 N회 호출하여 대상 패인으로 이동
#   2. write-chars 로 명령어 입력
#   3. write 13 (Enter) 로 실행
#   4. 다시 리더 패인으로 포커스 복귀
# =====================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)]
    [ValidateSet("planner", "frontend", "backend", "qa")]
    [string]$Pane,

    [Parameter(Mandatory, Position=1)]
    [string]$Command,

    [string]$Session = "mintorain"
)

# 리더(0) 기준 우측 4개 패인의 focus-next-pane 호출 횟수
$paneOffset = @{
    "planner"  = 1
    "frontend" = 2
    "backend"  = 3
    "qa"       = 4
}

$offset = $paneOffset[$Pane.ToLower()]

# 1. 대상 패인으로 이동
for ($i = 0; $i -lt $offset; $i++) {
    zellij --session $Session action focus-next-pane | Out-Null
    Start-Sleep -Milliseconds 80
}

# 2. 명령어 입력
zellij --session $Session action write-chars $Command | Out-Null
Start-Sleep -Milliseconds 100

# 3. Enter 입력 (ASCII 13)
zellij --session $Session action write 13 | Out-Null
Start-Sleep -Milliseconds 100

# 4. 리더로 포커스 복귀
for ($i = 0; $i -lt $offset; $i++) {
    zellij --session $Session action focus-previous-pane | Out-Null
    Start-Sleep -Milliseconds 80
}

Write-Host "✅ [$Pane] 패인에 '$Command' 입력 완료" -ForegroundColor Green
