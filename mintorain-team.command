#!/bin/bash
# ============================================
# MINTORAIN Team Agent — 더블클릭 / 터미널 실행 겸용 런처
# ============================================
# 동작 방식 (작업 폴더 결정 우선순위):
#   1) 환경변수 MINTORAIN_WORKDIR (사전 지정)
#   2) 첫 번째 인자 ($1) — 예: ./mintorain-team.command /path/to/project
#   3) 현재 PWD — 터미널에서 cd 후 실행한 경우
#   4) Finder 더블클릭 등 PWD가 / 또는 $HOME 인 경우 → 스크립트(키트) 폴더로 fallback
# ============================================

# Homebrew PATH 보장
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# 스크립트(키트) 절대 경로 — cd 하지 않고 위치만 보존
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 작업 폴더 결정
WORK_DIR="${MINTORAIN_WORKDIR:-${1:-$PWD}}"

# Finder 더블클릭 등 의미 없는 PWD인 경우 키트 폴더로 fallback
if [ -z "$WORK_DIR" ] || [ "$WORK_DIR" = "/" ] || [ "$WORK_DIR" = "$HOME" ]; then
  WORK_DIR="$SCRIPT_DIR"
  echo "ℹ️  의미있는 작업 폴더가 감지되지 않아 키트 폴더로 fallback: $WORK_DIR"
fi

echo "📁 작업 폴더: $WORK_DIR"

# tmuxp 스크립트를 절대 경로로 실행하고 작업 폴더를 인자로 전달
exec bash "$SCRIPT_DIR/mintorain-tmuxp.sh" "$WORK_DIR"
