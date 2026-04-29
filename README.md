# MINTORAIN Tmux Ocastra

> **MINTORAIN 바이브코딩 교육센터** — Claude Code 팀 에이전트 tmux 자동화 키트
> 5분할 tmux 패인에서 리더 + 기획자 + 프론트엔드 + 백엔드 + 검수자 팀이 동시에 일합니다.

---

## ✨ 핵심 기능

- **🪟 tmux 5분할 팀 모드**: 리더 + 4명의 전문 에이전트가 동시 작업
- **🤖 자동 에이전트 위임**: planner / code-reviewer / landing-builder / n8n-architect / debug-resolver / funnel-designer / shorts-producer / content-creator / kakao-integrator / seo-optimizer (총 10종)
- **🛠️ 10개 검증된 스킬**: 랜딩페이지, n8n 자동화, 퍼널 마케팅, 카카오 연동, Supabase, 콘텐츠 변환 등
- **🔒 보안 훅 자동 적용**: API 키 하드코딩 차단, console.log 경고, 시크릿 노출 방지
- **🇰🇷 한국 시장 특화**: 네이버 SEO, 카카오톡 알림톡, Solapi, 모바일 퍼스트

---

## 🚀 빠른 시작

### 1. 사전 요구사항

#### 🍎 macOS
```bash
brew install tmux tmuxp                       # tmux + tmuxp
npm install -g @anthropic-ai/claude-code      # Claude Code CLI
```

#### 🐧 Linux (Ubuntu/Debian)
```bash
sudo apt-get install -y tmux python3-pip
pip3 install --user tmuxp
npm install -g @anthropic-ai/claude-code
```

#### 🪟 Windows (옵션 A: WSL 없이 네이티브 실행 — 추천)
tmux 대신 **Zellij** (Rust 기반 모던 멀티플렉서) 를 사용하면 Windows 네이티브로 100% 동일한 5분할 팀 워크플로가 가능합니다.
```powershell
winget install Zellij-Contributors.Zellij
winget install Microsoft.PowerShell
npm install -g @anthropic-ai/claude-code
```
상세 가이드: [`docs/windows-zellij-guide.md`](./docs/windows-zellij-guide.md)

#### 🪟 Windows (옵션 B: WSL2 사용)
기존 .sh 스크립트를 그대로 쓰고 싶다면 WSL2 + Ubuntu에서 위 Linux 절차를 따르세요.
```powershell
# PowerShell 관리자 권한
wsl --install -d Ubuntu-22.04
```

### 2. 팀 에이전트 실행

```bash
# 작업할 프로젝트 폴더로 이동 후
cd /path/to/your-project
```

**🍎 macOS:** 더블클릭 또는 명령어
```bash
./mintorain-team.command
```

**🐧 Linux / WSL2:** 직접 실행
```bash
bash /path/to/mintorain-tmuxp.sh
```

**🪟 Windows 네이티브 (Zellij):** PowerShell에서
```powershell
pwsh /path/to/mintorain-team.ps1
```

### 3. 리더 패인에서 자연어로 지시
```
"기획자랑 프론트엔드 소환해서 랜딩페이지 만들어줘"
"n8n으로 인스타 자동 포스팅 워크플로 설계해줘"
"백엔드한테 Supabase RLS 정책 검토 요청"
```

---

## 📁 프로젝트 구조

```
mintorain-tmux-ocastra-main/
├── CLAUDE.md                  # 에이전트 두뇌 (세션 시작 시 자동 로드)
├── AGENTS.md                  # 에이전트 팀 가이드
├── MEMORY.md                  # 자동 기억 저장소
├── orchestration.md           # 시스템 제어 및 충돌 조율
│
├── mintorain-team.command     # macOS 더블클릭 실행 파일
├── mintorain-tmux.sh          # 순수 tmux 5분할 스크립트 (Linux/macOS/WSL)
├── mintorain-tmuxp.sh         # tmuxp 기반 5분할 스크립트 (Linux/macOS/WSL)
├── mintorain-tmux.yaml        # tmuxp 세션 정의
├── mintorain-team.ps1         # Windows 네이티브 PowerShell 런처 (Zellij)
├── mintorain-zellij.kdl       # Zellij 5분할 레이아웃 (Windows/cross-platform)
├── invoke-pane.ps1            # 리더가 다른 패인 소환 시 호출 (Windows)
│
├── .claude/                   # Claude Code 전용 설정
│   ├── hooks.json             # 보안/품질 훅 (시크릿 차단, console.log 경고)
│   ├── agents/                # 10종 전문 에이전트
│   ├── commands/              # 슬래시 명령어 9종 (/plan, /build, /review 등)
│   ├── contexts/              # 모드별 추가 컨텍스트 (dev/review/deploy)
│   └── skills/                # 10종 도메인 스킬
│       ├── landing-page/
│       ├── funnel-marketing/
│       ├── n8n-automation/
│       ├── kakao-integration/
│       ├── nextjs-vibecoding/
│       ├── supabase-patterns/
│       ├── email-automation/
│       ├── content-repurpose/
│       ├── youtube-shorts/
│       └── mcp-setup/
│
└── docs/                      # 심화 문서 (Progressive Disclosure)
    ├── tmux-team-guide.md     # tmux 5분할 운영 규칙
    ├── meta-ads-playbook.md
    ├── n8n-recipes.md
    ├── seo-checklist.md
    └── troubleshooting.md
```

---

## 🎯 5분할 tmux 레이아웃

```
┌──────────────────────┬─────────────────────┐
│ 👑 총괄 리더 | Leader│ 📋 기획자 | Planner │
│                      ├─────────────────────┤
│   (claude 실행 중)   │ 🎨 프론트엔드|Front │
│                      ├─────────────────────┤
│                      │ ⚙️  백엔드 | Backend│
│                      ├─────────────────────┤
│                      │ 🔍 검수자 | QA      │
└──────────────────────┴─────────────────────┘
```

**세션 이름:** `mintorain`
**리더 패인:** 좌측 — 사용자가 대화하는 메인 패인
**우측 4분할:** 각 전문 에이전트 대기

리더가 자연어로 *"프론트엔드 소환해줘"* 라고 말하면,
플랫폼별로 다음 명령이 자동 실행되어 해당 패인에 실제 Claude 에이전트가 뜹니다:

| OS | 멀티플렉서 | 자동 소환 명령 |
|------|-----------|----------------|
| 🍎 macOS / 🐧 Linux / 🪟 WSL2 | tmux | `tmux send-keys -t mintorain:1.3 claude C-m` |
| 🪟 Windows 네이티브 | Zellij | `pwsh invoke-pane.ps1 -Pane frontend -Command claude` |

---

## 🤖 슬래시 명령어

| 명령어 | 설명 |
|--------|------|
| `/plan {기능}` | 기능 구현 계획 수립 (planner 에이전트) |
| `/build` | 빌드 에러 자동 분석 및 수정 |
| `/review [파일]` | 코드 리뷰 (보안/품질/스타일) |
| `/n8n {워크플로}` | n8n 워크플로 설계 + JSON 생성 |
| `/landing {주제}` | 전환율 높은 랜딩페이지 빌드 |
| `/funnel {목표}` | 4단계 퍼널 구조 + 이메일 시퀀스 설계 |
| `/shorts {시리즈}` | 유튜브 쇼츠 자동 생성 파이프라인 |
| `/deploy` | 배포 전 체크리스트 실행 |
| `/learn` | 세션에서 발견한 패턴을 MEMORY.md에 저장 |

---

## 🔧 핵심 기술 스택

| 영역 | 도구 |
|------|------|
| 프론트엔드 | Next.js 15, React, TailwindCSS |
| 백엔드/DB | Supabase (Auth + DB + Storage + RLS) |
| 배포 | Vercel (프론트), Railway (n8n/백엔드) |
| 자동화 | n8n, Zapier, Make |
| 메시징 | Solapi (SMS/카카오톡), Gmail, ConvertKit |
| AI 생성 | OpenAI, ElevenLabs, D-ID, Replicate, Suno |
| MCP | Context7, Filesystem, n8n, Figma, Notion |

---

## 🔐 보안 원칙

본 키트의 `.claude/hooks.json` 은 자동으로 다음을 검사합니다:

- ❌ `sk-...`, `AKIA...`, `ghp_...`, `password=...` 하드코딩 시 **저장 차단**
- ⚠️ `.ts/.tsx/.js/.jsx` 파일에 `console.log` 발견 시 경고
- 💡 `npm run dev` 명령어 사용 시 tmux 권장 메시지
- 🧠 세션 종료 시 `MEMORY.md` 에 타임스탬프 자동 기록

> **OS 호환성 주의:** 훅 명령어는 `#!/bin/bash` 기반입니다. macOS / Linux / WSL2 / Git Bash 환경에서 작동하며, Windows 네이티브 cmd / PowerShell 에서는 침묵 실패합니다. Windows 사용자는 WSL2 또는 Git Bash 안에서 Claude Code를 실행하세요.

---

## 📚 더 깊이 들어가기

- [`CLAUDE.md`](./CLAUDE.md) — 에이전트 운영 매뉴얼 (Level 0)
- [`AGENTS.md`](./AGENTS.md) — 에이전트 팀 / 스킬 / 명령어 목차 (Level 1)
- [`docs/tmux-team-guide.md`](./docs/tmux-team-guide.md) — tmux 5분할 운영 규칙 상세 가이드
- [`docs/`](./docs/) — Meta 광고, n8n 레시피, SEO 체크리스트, 트러블슈팅
- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — 기여 가이드라인
- [`SECURITY.md`](./SECURITY.md) — 보안 취약점 신고

---

## 📜 라이선스

MIT License — 자유롭게 사용, 수정, 재배포 가능합니다.

---

## 🙋 만든 사람

**두온교육 바이브코딩 교육센터(by mintorain)**
비전공자가 AI 도구로 결과물을 만드는 '바이브코딩'을 기반으로 합니다.

> 🌐 홈페이지: https://mintorain.duonedu.net
> 💬 문의: https://mintorain.duonedu.net
