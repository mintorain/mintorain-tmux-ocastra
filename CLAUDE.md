# CLAUDE.md — MINTORAIN 바이브코딩 에이전트 운영 매뉴얼

> 이 파일은 Claude Code가 세션 시작 시 자동으로 읽는 최상위 지시 문서입니다.
> 150~500줄 이내로 유지하세요. 상세 내용은 docs/ 참조.

## 프로젝트 정체성

- **브랜드:** 두온교육 바이브코딩 교육센터(by mintorain)
- **철학:** 비전공자가 AI 도구로 결과물을 만드는 '바이브코딩'
- **대상:** 1인 기업가, 지식 창업자, 소상공인
- **언어:** 한국어 우선 (코드 주석, 커밋 메시지, 문서 모두 한국어)

## 핵심 기술 스택

| 영역 | 도구 |
|------|------|
| 프론트엔드 | Next.js 15 (App Router), React, TailwindCSS |
| 백엔드/DB | Supabase (Auth + DB + Storage + RLS) |
| 배포 | Vercel (프론트), Railway (n8n/백엔드) |
| 자동화 | n8n, Zapier, Make |
| 메시징 | Solapi (SMS/카카오톡), Gmail, ConvertKit |
| AI 생성 | OpenAI, ElevenLabs, D-ID, Replicate, Suno |
| 영상 | FFmpeg, n8n-nodes-mediafx |
| MCP | Context7, Figma, Slack, Notion, Google Drive |

## 필수 규칙 (절대 위반 금지)

### 1. 바이브코딩 원칙
- 코드보다 **의도(Intent)**를 먼저 파악하라
- 복잡한 설명 대신 **즉시 동작하는 결과물**을 만들어라
- 비전공자가 이해할 수 있는 **한국어 주석** 필수
- 한 번에 너무 많이 하지 말고 **작은 단위로 검증**하라

### 2. 코드 스타일
- TypeScript 사용 (strict mode)
- 파일당 200~400줄, 최대 800줄
- 함수당 50줄 이내
- 불변성 원칙: 객체/배열 직접 수정 금지, 스프레드 연산자 사용
- console.log 프로덕션 코드 금지
- 에러 핸들링: try/catch + 사용자 친화적 메시지

### 3. 보안
- API 키, 시크릿 하드코딩 절대 금지 → .env 사용
- Supabase RLS 항상 활성화
- 모든 사용자 입력 Zod로 검증
- SQL 인젝션 방지 (파라미터화 쿼리)

### 4. 테스트
- 핵심 비즈니스 로직 테스트 필수
- API 엔드포인트 통합 테스트
- 배포 전 빌드 확인: `npm run build`

### 5. Git 워크플로
- 커밋 메시지: `feat: 기능설명` / `fix: 버그수정` / `docs: 문서수정`
- 브랜치: `feature/기능명`, `fix/버그명`
- main 브랜치 직접 푸시 금지

## 파일 구조 패턴

```
프로젝트/
├── CLAUDE.md          # 이 파일 (에이전트 두뇌)
├── AGENTS.md          # 에이전트 팀 가이드
├── MEMORY.md          # 자동 기억 저장소
├── src/
│   ├── app/           # Next.js App Router
│   ├── components/    # 재사용 UI 컴포넌트
│   ├── hooks/         # 커스텀 React 훅
│   ├── lib/           # 유틸리티 (supabase, api 등)
│   └── types/         # TypeScript 타입 정의
├── n8n/               # n8n 워크플로 백업 JSON
├── docs/              # 상세 문서 (Progressive Disclosure)
└── .env.local         # 환경변수 (git 제외)
```

## API 응답 표준 형식

```typescript
type ApiResponse<T> =
  | { success: true; data: T }
  | { success: false; error: string; code?: string }
```

## n8n 워크플로 규칙

- 워크플로 JSON은 반드시 `n8n/` 폴더에 백업
- 노드 이름은 한국어로 명확하게 작성
- Error Trigger 노드 필수 포함
- Webhook URL은 환경변수로 관리
- 크레덴셜은 절대 JSON에 포함하지 않음

## 에이전트 위임 규칙

복잡한 작업은 전문 에이전트에게 위임:
- 새 기능 기획 → `planner` 에이전트
- 랜딩페이지 → `landing-page` 스킬
- n8n 자동화 → `n8n-automation` 스킬
- 퍼널 설계 → `funnel-marketing` 스킬
- 유튜브 쇼츠 → `youtube-shorts` 스킬
- 상세 참조 → AGENTS.md 확인

## 팀 에이전트 실행 (5분할)

### 🍎 macOS / 🐧 Linux / 🪟 WSL2 (tmux 기반)
```bash
./mintorain-team.command         # macOS 더블클릭
bash ./mintorain-tmux.sh         # 순수 tmux 버전
bash ./mintorain-tmuxp.sh        # tmuxp YAML 버전
```

### 🪟 Windows 네이티브 (Zellij 기반, WSL 불필요)
```powershell
pwsh ./mintorain-team.ps1
```
사전 설치: `winget install Zellij-Contributors.Zellij Microsoft.PowerShell` + `npm install -g @anthropic-ai/claude-code`

### 운영 모델: 5개 패인 모두 claude 자동 실행

이 키트는 5분할 시작 시 **모든 패인에 claude가 동시에 실행**됩니다. 우측 4개 패인은 빈 컨텍스트로 시작하므로, 사용자가 해당 패인에 들어갔을 때 첫 메시지로 역할을 부여하세요:

```
너는 기획자(또는 프론트엔드/백엔드/QA) 역할이야.
CLAUDE.md, AGENTS.md, .claude/agents/<역할>.md 를 따라 답해줘.
```

#### 패인 이동 / 운영
- **패인 이동:** `Ctrl+P` → 화살표 (Zellij), `Ctrl+B` → 화살표 (tmux)
- **세션 분리 후 재연결:** `zellij attach mintorain` / `tmux attach -t mintorain`
- **세션 종료:** `Ctrl+Q` (Zellij) / `Ctrl+B + :kill-session` (tmux)

#### 리더의 역할
좌측 리더 패인은 **전체 작업 조율**과 **사용자와의 메인 대화**를 담당합니다. 사용자가 "기획자에게 시켜줘" 같은 요청을 하면, 리더는 다음 중 하나를 선택:

1. **수동 안내**: *"우측 1번 패인(📋 Planner)으로 이동해서 직접 지시해주세요"*
2. **자동 호출 시도**: 아래 명령을 도구로 실행 (Windows zellij 일부 빌드는 외부 IPC 미지원이라 실패 가능)
   - Windows: `invoke-pane.ps1 -Pane <planner|frontend|backend|qa> -Command "<지시문>"`
   - macOS/Linux: `tmux send-keys -t mintorain:1.<N> "<지시문>" C-m`

기본 동작은 **수동 안내**가 가장 안정적입니다. invoke-pane.ps1 자동 호출은 사용자가 명시적으로 요청할 때만 사용하세요.

## 환경변수 체크리스트

전체 템플릿은 `.env.example` 참조. 필수 환경변수:

```bash
# 필수
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# 선택 (기능별)
OPENAI_API_KEY=
ELEVENLABS_API_KEY=
SOLAPI_API_KEY=
SOLAPI_API_SECRET=
CONVERTKIT_API_SECRET=
```

## 빠른 참조 링크

- 팀/스킬/명령어 목차 → [`AGENTS.md`](./AGENTS.md)
- 충돌 조율 / 권한 매트릭스 → [`orchestration.md`](./orchestration.md)
- tmux 5분할 운영 매뉴얼 → [`docs/tmux-team-guide.md`](./docs/tmux-team-guide.md)
- 심화 문서 (Meta 광고, n8n 레시피, SEO, 트러블슈팅) → [`docs/`](./docs/)
