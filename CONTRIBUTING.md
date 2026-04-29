# 기여 가이드 (Contributing)

> **두온교육 바이브코딩 교육센터(by mintorain)** 가 운영하는 오픈 키트입니다.
> 비전공자도 부담 없이 기여할 수 있도록 한국어를 우선 사용합니다.

## 🚀 기여 절차 (Quick Start)

1. 저장소 Fork → 본인 계정으로 클론
2. 기능 브랜치 생성: `feature/짧은-설명` 또는 `fix/이슈번호`
3. 변경사항 커밋 (아래 커밋 메시지 규칙 참조)
4. PR 생성 → 변경 이유 + 테스트 방법 명시
5. 리뷰 후 머지

## 🧱 변경 가능 영역

| 영역 | 위치 | 우선순위 |
|------|------|----------|
| 신규 에이전트 | `.claude/agents/*.md` | ⭐⭐⭐ |
| 신규 스킬 | `.claude/skills/*/SKILL.md` | ⭐⭐⭐ |
| 슬래시 명령어 | `.claude/commands/*.md` | ⭐⭐ |
| 보안/품질 훅 | `.claude/hooks.json` | ⭐⭐ |
| tmux 스크립트 | `mintorain-tmux*.sh`, `*.yaml` | ⭐ |
| 심화 문서 | `docs/*.md` | ⭐⭐ |

## ✅ 코드 스타일

- **언어**: 한국어 우선 (주석, 커밋 메시지, 문서 모두)
- **TypeScript**: strict mode, 함수 50줄 이내, 파일 800줄 이내
- **셸 스크립트**: `#!/bin/bash` + `set -euo pipefail` 권장
- **마크다운**: H1 한 개, H2~H3 계층 명확하게

## 📝 커밋 메시지 규칙

[Conventional Commits](https://www.conventionalcommits.org/) 한국어 변형:

```
feat: 신규 에이전트 'data-analyst' 추가
fix: tmux 세션명 충돌 시 종료되도록 수정
docs: 트러블슈팅에 Solapi 발신번호 등록 절차 추가
refactor: hooks.json Stop 훅 cross-platform 분기
test: 카카오 알림톡 변수 매핑 단위 테스트 추가
chore: .gitignore에 .turbo/ 패턴 추가
```

## 🔒 보안 / 시크릿

- `.env`, `.env.local`, 크레덴셜 파일은 **절대 커밋 금지**
- API 키는 항상 환경변수로 관리 (`.env.example` 패턴 참조)
- 보안 취약점 발견 시 → [`SECURITY.md`](./SECURITY.md) 참조

## 🧪 PR 체크리스트

- [ ] 변경 사항이 1가지 주제에 집중되어 있다 (refactor + feat 동시 X)
- [ ] 한국어 주석/문서로 동기 설명
- [ ] 신규 환경변수 추가 시 `.env.example` 갱신
- [ ] 신규 에이전트/스킬 추가 시 `AGENTS.md` 와 `README.md` 표 갱신
- [ ] tmux 스크립트 변경 시 macOS / Linux / WSL2 모두에서 검증

## 💬 논의

- 큰 구조 변경은 PR 전에 [Issue](https://github.com/mintorain/mintorain-tmux-ocastra/issues) 로 먼저 제안
- 질문/문의: https://mintorain.duonedu.net
