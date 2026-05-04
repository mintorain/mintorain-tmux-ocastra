#!/bin/bash
# ============================================
# MINTORAIN Tmux 자동 분할 세팅 v5
# Claude Team Agent 최적화 모드
# ============================================

SESSION="mintorain"
# 키트(스크립트) 폴더 — Leader 가 prompts/leader.txt 와 invoke-pane.ps1 을 찾을 때 사용
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 작업 폴더 결정 (우선순위: 인자 $1 → PWD)
# - ./mintorain-tmux.sh                       → 현재 폴더에서 시작
# - ./mintorain-tmux.sh /path/to/project      → 지정 폴더에서 시작
WORK_DIR="${1:-$PWD}"
# tmux 자식 패인에 상속될 환경변수 (Leader 가 위임 명령 작성 시 참조)
export MINTORAIN_KIT_DIR="$SCRIPT_DIR"
echo "📁 작업 폴더: $WORK_DIR"
echo "🧰 키트 폴더: $SCRIPT_DIR"

# 환경 변수 (팀 모드 및 컬러 강제)
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
export TERM=xterm-256color
export COLORTERM=truecolor
export FORCE_COLOR=1

# 기존 세션 및 팀 세션 정보 초기화 (충돌 방지)
tmux kill-session -t $SESSION 2>/dev/null
rm -rf ~/.claude/teams/* 2>/dev/null

# ===========================================
# 새 세션 생성 (리더 패인 1.1) — -c 로 작업 폴더 지정
# ===========================================
tmux new-session -d -s $SESSION -x 220 -y 55 -c "$WORK_DIR"

# ===========================================
# 레이아웃 분할 — 모든 패인을 WORK_DIR 에서 시작 (-c 옵션)
# ===========================================
# 1. 좌우 분할
tmux split-window -h -t "$SESSION:1.1" -c "$WORK_DIR"

# 2. 우측 4분할
tmux split-window -v -t "$SESSION:1.2" -c "$WORK_DIR"
tmux split-window -v -t "$SESSION:1.3" -c "$WORK_DIR"
tmux split-window -v -t "$SESSION:1.4" -c "$WORK_DIR"

# 3. 크기 조정 (리더 패인 넓게)
tmux resize-pane -t "$SESSION:1.1" -x 110

# ===========================================
# 패인 타이틀 설정 (claude 덮어쓰기 방지)
# ===========================================
tmux set-option -pt "$SESSION:1.1" @pane_name "👑 총괄 리더 | Leader"
tmux set-option -pt "$SESSION:1.2" @pane_name "📋 기획자 | Planner"
tmux set-option -pt "$SESSION:1.3" @pane_name "🎨 프론트엔드 | Frontend"
tmux set-option -pt "$SESSION:1.4" @pane_name "⚙️  백엔드 | Backend"
tmux set-option -pt "$SESSION:1.5" @pane_name "🔍 검수자 | QA"

# ===========================================
# 패인 색상 설정
# ===========================================
tmux select-pane -t "$SESSION:1.1" -P "fg=colour15,bg=colour234"
tmux select-pane -t "$SESSION:1.2" -P "fg=colour226,bg=colour234"
tmux select-pane -t "$SESSION:1.3" -P "fg=colour46,bg=colour234"
tmux select-pane -t "$SESSION:1.4" -P "fg=colour39,bg=colour234"
tmux select-pane -t "$SESSION:1.5" -P "fg=colour196,bg=colour234"

# ===========================================
# 패인별 초기화 (리더가 인식할 수 있도록 대기 메시지 출력)
# ===========================================
tmux send-keys -t "$SESSION:1.2" "cd $WORK_DIR && clear && echo '=== 📋 기획자 (Planner) 대기 중 ===' && echo '리더는 이 패인에 [ tmux send-keys -t mintorain:1.2 claude C-m ] 명령으로 나를 소환해주세요.'" C-m
tmux send-keys -t "$SESSION:1.3" "cd $WORK_DIR && clear && echo '=== 🎨 프론트엔드 (Frontend) 대기 중 ===' && echo '리더는 이 패인에 [ tmux send-keys -t mintorain:1.3 claude C-m ] 명령으로 나를 소환해주세요.'" C-m
tmux send-keys -t "$SESSION:1.4" "cd $WORK_DIR && clear && echo '=== ⚙️ 백엔드 (Backend) 대기 중 ===' && echo '리더는 이 패인에 [ tmux send-keys -t mintorain:1.4 claude C-m ] 명령으로 나를 소환해주세요.'" C-m
tmux send-keys -t "$SESSION:1.5" "cd $WORK_DIR && clear && echo '=== 🔍 검수자 (QA) 대기 중 ===' && echo '리더는 이 패인에 [ tmux send-keys -t mintorain:1.5 claude C-m ] 명령으로 나를 소환해주세요.'" C-m

# ===========================================
# 리더 패인: 인지 강화 및 실행
# ===========================================
tmux select-pane -t "$SESSION:1.1"

# 화면 정리 및 시작 메시지
tmux send-keys -t "$SESSION:1.1" "cd $WORK_DIR" C-m
tmux send-keys -t "$SESSION:1.1" "clear" C-m
tmux send-keys -t "$SESSION:1.1" "echo '------------------------------------------------'" C-m
tmux send-keys -t "$SESSION:1.1" "echo '🚀 MINTORAIN Claude Team Agent Mode Activated'" C-m
tmux send-keys -t "$SESSION:1.1" "echo '우측 패인: 2=기획자, 3=프론트엔드, 4=백엔드, 5=검수자'" C-m
tmux send-keys -t "$SESSION:1.1" "echo '💡 팁: 번거롭게 명령어를 칠 필요 없이, 그냥 \"기획자 프론트엔드 소환해줘\" 라고만 말해도 알아서 우측 화면에 띄웁니다!'" C-m
tmux send-keys -t "$SESSION:1.1" "echo '------------------------------------------------'" C-m

# Claude 실행 (네이티브 기능 완전 차단 + Leader 시스템 프롬프트 적용)
# prompts/leader.txt 의 내용을 --append-system-prompt 인자로 전달해
# Leader 가 우측 패인 자동 위임을 시도할 수 있도록 함
tmux send-keys -t "$SESSION:1.1" "export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=0 && claude --dangerously-skip-permissions --name Leader --append-system-prompt \"\$(cat \"$SCRIPT_DIR/prompts/leader.txt\")\"" C-m

# 세션 연결
tmux attach-session -t $SESSION
