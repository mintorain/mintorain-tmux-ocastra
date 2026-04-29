# Windows 네이티브 실행 가이드 (Zellij + PowerShell)

> WSL2 / MSYS2 / Cygwin 없이 **Windows 11 PowerShell만으로** mintorain 5분할 팀 에이전트를 사용하는 방법입니다.
> Zellij는 Rust 기반 모던 터미널 멀티플렉서로, tmux의 핵심 기능을 Windows 네이티브로 제공합니다.

---

## 🛠 사전 설치 (한 번만)

### 1) Zellij 설치
```powershell
winget install Zellij-Contributors.Zellij
# 또는
cargo install --locked zellij
```

설치 후 PowerShell 재시작 → `zellij --version` 으로 확인.

### 2) PowerShell 7+ (pwsh)
```powershell
winget install Microsoft.PowerShell
```
(`pwsh` 명령어가 동작하는지 확인. Windows 기본의 `powershell.exe`는 5.1이라 한글/이모지 처리에 제한 있음.)

### 3) Claude Code CLI
```powershell
npm install -g @anthropic-ai/claude-code
```

---

## 🚀 실행

### 방법 1: 더블클릭 또는 단일 명령
```powershell
# 작업할 프로젝트 폴더로 이동 후
cd C:\my-project

# 키트 폴더의 ps1 실행
pwsh C:\path\to\mintorain-tmux-ocastra-main\mintorain-team.ps1
```

### 방법 2: 작업 폴더를 인자로 전달
```powershell
pwsh mintorain-team.ps1 C:\my-project
```

실행되면 5분할 화면이 뜹니다:

```
┌──────────────────────┬─────────────────────┐
│ 👑 Leader            │ 📋 Planner          │
│  (claude 자동 실행)  ├─────────────────────┤
│                      │ 🎨 Frontend         │
│                      ├─────────────────────┤
│                      │ ⚙️  Backend         │
│                      ├─────────────────────┤
│                      │ 🔍 QA               │
└──────────────────────┴─────────────────────┘
```

좌측 리더에는 자동으로 `claude` 가 실행되어 있고,
우측 4개 패인은 PowerShell 환영 메시지 상태로 대기합니다.

---

## 🤖 자동 위임 (리더 → 다른 패인 소환)

리더 패인의 Claude 에게 **자연어로 요청**하면 됩니다:

> "기획자 소환해서 회원가입 기능 기획해줘"

리더 Claude는 내부적으로 다음 명령을 실행합니다:
```powershell
pwsh invoke-pane.ps1 -Pane planner -Command claude
```

`invoke-pane.ps1` 헬퍼가:
1. `zellij action focus-next-pane` 으로 대상 패인 이동
2. `write-chars claude` 로 명령어 입력
3. `write 13` (Enter) 로 실행
4. 리더 패인으로 포커스 복귀

### 패인 매핑
| 호칭 | -Pane 값 | 위치 |
|------|----------|------|
| 기획자 / Planner | `planner` | 우측 1번 |
| 프론트엔드 / Frontend | `frontend` | 우측 2번 |
| 백엔드 / Backend | `backend` | 우측 3번 |
| 검수자 / QA | `qa` | 우측 4번 |

### 임의 명령 입력 예시
```powershell
# QA 패인에서 npm test 실행
pwsh invoke-pane.ps1 -Pane qa -Command "npm test"

# 백엔드 패인에 Supabase RLS 검토 지시
pwsh invoke-pane.ps1 -Pane backend -Command claude
```

---

## ⌨️ Zellij 키보드 단축키 (자주 쓰는 것만)

| 동작 | 단축키 |
|------|--------|
| 패인 이동 | `Ctrl+P` → 화살표 |
| 패인 크기 조정 | `Ctrl+N` → `H/J/K/L` |
| 새 탭 | `Ctrl+T` → `N` |
| 세션 분리 (백그라운드 유지) | `Ctrl+O` → `D` |
| 세션 종료 | `Ctrl+Q` |
| 도움말 표시 | 화면 하단 status-bar 자동 노출 |

세션을 다시 붙이려면:
```powershell
zellij attach mintorain
```

---

## 🐛 트러블슈팅

### "zellij is not recognized"
- PowerShell을 재시작했는지 확인 (PATH 갱신)
- `winget install Zellij-Contributors.Zellij` 후 새 PowerShell 창

### 한글/이모지 깨짐
- PowerShell 5.1 (`powershell.exe`) 대신 PowerShell 7+ (`pwsh`) 사용
- 또는 글꼴을 `Cascadia Code`, `D2Coding`, `MesloLGS NF` 등으로 변경

### 리더에 claude 자동 실행 실패
- `claude` 명령어가 PATH에 있는지 확인: `where.exe claude`
- 없다면 npm 글로벌 경로 추가 또는 재설치

### invoke-pane.ps1 실행 시 "Execution policy" 오류
```powershell
# 현재 사용자에게만 RemoteSigned 허용 (한 번만)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### focus-next-pane이 엉뚱한 패인으로 이동
- Zellij 버전이 0.40+ 인지 확인 (`zellij --version`)
- 레이아웃 파일이 변경된 경우 첫 패인 인덱스가 달라질 수 있음 → 키트의 기본 KDL 사용 권장

---

## 📊 macOS/Linux tmux 버전 vs Windows Zellij 버전 비교

| 기능 | macOS/Linux (tmux) | Windows (Zellij) |
|------|---------------------|------------------|
| 5분할 자동 세팅 | `mintorain-tmux.sh` | `mintorain-team.ps1` |
| 레이아웃 파일 | `mintorain-tmux.yaml` (tmuxp) | `mintorain-zellij.kdl` |
| 다른 패인 명령 전송 | `tmux send-keys -t mintorain:1.3 claude C-m` | `pwsh invoke-pane.ps1 -Pane frontend -Command claude` |
| 세션 이름 | `mintorain` | `mintorain` |
| 패인 색상 | tmux color codes | KDL 기본 색상 |
| 세션 연결 | `tmux attach -t mintorain` | `zellij attach mintorain` |

**기능 동등성: 100%.** 단지 사용하는 멀티플렉서가 다를 뿐 자동 위임 워크플로 그대로 동작합니다.
