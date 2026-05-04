# =====================================================
# invoke-pane.ps1
# 리더 (👑) 가 우측 4개 패인의 claude REPL 에 메시지를 자동 주입하는 헬퍼
#
# 사용법 (리더 패인의 Claude 가 Bash 도구로 호출):
#   pwsh -NoProfile -File invoke-pane.ps1 -Pane planner  -Command "회원가입 기능 기획해줘"
#   pwsh -NoProfile -File invoke-pane.ps1 -Pane frontend -Command "Next.js 랜딩페이지 만들어줘"
#   pwsh -NoProfile -File invoke-pane.ps1 -Pane backend  -Command "Supabase RLS 정책 짜줘"
#   pwsh -NoProfile -File invoke-pane.ps1 -Pane qa       -Command "방금 작성한 코드 보안 점검해줘"
#
# 참고: 우측 4개 패인은 mintorain-team.ps1 시작 시 이미 claude 가 자동 실행되어 있음.
#      따라서 -Command 에는 "claude" 같은 명령이 아니라 "전달할 메시지"를 넣어야 함.
#
# 동작 원리:
#   1. zellij action move-focus right     → 우측 영역으로 이동
#   2. zellij action move-focus down N-1  → 대상 패인까지 아래로 이동
#   3. zellij action write-chars <메시지> → 입력 주입
#   4. zellij action write 13             → Enter (ASCII 13)
#   5. zellij action move-focus up N-1    → 위로 복귀
#   6. zellij action move-focus left      → 좌측 Leader 로 복귀
# =====================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)]
    [ValidateSet("planner", "frontend", "backend", "qa")]
    [string]$Pane,

    [Parameter(Mandatory, Position=1)]
    [string]$Command,

    [string]$Session = "mintorain",

    [int]$DelayMs = 200
)

if ([string]::IsNullOrWhiteSpace($Command)) {
    Write-Host "❌ -Command 가 비어있습니다. 우측 패인의 claude 에 전달할 메시지를 넣어주세요." -ForegroundColor Red
    Write-Host "   예) pwsh -NoProfile -File invoke-pane.ps1 -Pane planner -Command '회원가입 기능 기획해줘'" -ForegroundColor Yellow
    exit 1
}

# 리더(좌측) 기준 우측 4개 패인의 위→아래 순서 매핑
$paneOffset = @{
    "planner"  = 1  # 우측 1번 (가장 위)
    "frontend" = 2
    "backend"  = 3
    "qa"       = 4  # 우측 4번 (가장 아래)
}
$offset = $paneOffset[$Pane.ToLower()]

Write-Verbose "[$Pane] offset=$offset, session=$Session, delay=${DelayMs}ms"

function Invoke-ZellijAction {
    param([string[]]$Args)
    & zellij --session $Session action @Args 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "zellij action 실패 (exit=$LASTEXITCODE): $Args"
    }
    Start-Sleep -Milliseconds $DelayMs
}

try {
    # 1. 좌측 Leader → 우측 영역(첫 패인=Planner)으로 이동
    Invoke-ZellijAction @('move-focus', 'right')

    # 2. 우측 영역에서 아래로 (offset-1)회 이동
    for ($i = 1; $i -lt $offset; $i++) {
        Invoke-ZellijAction @('move-focus', 'down')
    }

    # 3. 메시지 입력
    Invoke-ZellijAction @('write-chars', $Command)

    # 4. Enter (ASCII 13)
    Invoke-ZellijAction @('write', '13')

    # 5. 위로 (offset-1)회 복귀
    for ($i = 1; $i -lt $offset; $i++) {
        Invoke-ZellijAction @('move-focus', 'up')
    }

    # 6. 좌측 Leader 로 복귀
    Invoke-ZellijAction @('move-focus', 'left')

    Write-Host "✅ [$Pane] 패인에 메시지 주입 완료: $Command" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host "❌ 자동 위임 실패: $_" -ForegroundColor Red
    Write-Host "   fallback: Ctrl+P + 화살표로 [$Pane] 패인으로 이동해 직접 메시지를 입력해주세요." -ForegroundColor Yellow
    exit 1
}
