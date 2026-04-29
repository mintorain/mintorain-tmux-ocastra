# 보안 정책 (Security Policy)

## 🛡 지원 버전

본 키트는 단일 메인 브랜치(`main`)만 유지합니다. 항상 최신 커밋이 권장 버전입니다.

## 🚨 취약점 신고

보안 취약점을 발견하셨다면, **공개 이슈로 등록하지 마시고** 다음 채널로 비공개 신고해주세요:

- 📧 신고 페이지: https://mintorain.duonedu.net (문의 폼 → 보안 카테고리)
- 🔒 GitHub Security Advisory: [신고 링크](https://github.com/mintorain/mintorain-tmux-ocastra/security/advisories/new)

### 신고 시 포함 정보
1. 취약점 영향 (예: 시크릿 노출, 원격 명령 실행, 권한 우회)
2. 재현 절차 (스크립트, 명령어, 입력값)
3. 영향 받는 파일 / 커밋 해시
4. 가능하면 PoC (Proof of Concept) 코드

## ⏱ 응답 시간

- **수신 확인**: 영업일 기준 48시간 이내
- **취약점 평가**: 7일 이내
- **수정 패치**: 심각도에 따라
  - Critical: 24시간 이내
  - High: 7일 이내
  - Medium: 30일 이내
  - Low: 다음 정기 업데이트

## 🔐 본 키트의 보안 대책

이 저장소가 자체적으로 적용하는 자동 검사:

| 검사 | 위치 | 동작 |
|------|------|------|
| 시크릿 하드코딩 차단 | `.claude/hooks.json` PreToolUse | `sk-*`, `AKIA*`, `ghp_*`, `password=` 패턴 발견 시 저장 차단 |
| `console.log` 경고 | `.claude/hooks.json` PostToolUse | TS/JS 파일 저장 시 경고 |
| `.env*` 격리 | `.gitignore` | 환경변수 파일 git 추적 제외 |

## 📋 권장 운영 수칙

1. `.env`, `.env.local`, 크레덴셜 JSON은 **절대 커밋 금지**
2. n8n 워크플로 백업 시 크레덴셜 ID 제거
3. Supabase Service Role Key는 **서버 사이드에서만** 사용
4. Solapi / 카카오 OAuth 토큰은 50분 주기 자동 갱신 워크플로 운영
5. 의심 활동 발견 시 즉시 키 회전 (rotation) 후 신고
