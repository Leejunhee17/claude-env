# claude-env

Claude Code + OMC(oh-my-claudecode) 설정을 GitHub로 공유·관리하고, 보안 격리된 Docker devcontainer 안에서 언제 어디서든 동일한 개발 환경을 재현하기 위한 레포지토리.

## 목적

- Claude Code 에이전트/스킬/훅 설정을 GitHub로 버전 관리
- Mac + Docker Desktop 환경에서 보안 격리된 컨테이너 안에 Claude를 실행
- 새 Mac에서 `clone → bootstrap → devcontainer` 3단계로 환경 복원

## 보안 모델

컨테이너는 아래 항목에만 접근 가능:

| 마운트 대상 | 유형 | 목적 |
|------------|------|------|
| `~/.claude` | bind (read-write) | OMC 설정 + 인증 토큰 영속 |
| `~/.gitconfig` | bind (read-only) | git 설정 |
| bash history | named volume | 셸 히스토리 유지 |
| gh CLI config | named volume | GitHub CLI 인증 유지 |

아래 항목은 **의도적으로 마운트하지 않음**: `~/.ssh`, `~/.aws`, 그 외 자격증명 디렉토리

## 기술 스택

| 구성 요소 | 방식 | 비고 |
|-----------|------|------|
| Claude Code | `curl install.sh` (바이너리) | Docker 빌드 시 설치 |
| Node.js LTS | devcontainer feature | OMC 훅 스크립트(.mjs) 실행용 |
| OMC (oh-my-claudecode) | `~/.claude` bind mount | `claude/` 디렉토리에서 런타임 제공 |
| Python 3.13 | uv | 스크립트/도구용 |
| gh CLI | devcontainer feature | GitHub 인증 |

## 사전 요구 사항

- macOS
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [VS Code](https://code.visualstudio.com/) + [Dev Containers 확장](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## 빠른 시작

### 1. 레포 클론 및 호스트 설정 (최초 1회)

```bash
git clone git@github.com:Leejunhee17/claude-env.git ~/workspace/claude-env
cd ~/workspace/claude-env
./bootstrap.sh
```

bootstrap.sh가 수행하는 작업:
- `~/.claude → ~/workspace/claude-env/claude` symlink 생성
- `devc` CLI 설치

### 2. devcontainer 실행

VS Code에서:
```bash
cd ~/workspace/claude-env
code .
# VS Code가 "Reopen in Container" 알림 표시 → 클릭
```

또는 CLI로:
```bash
devc up && devc shell
```

### 3. Claude 로그인 (최초 1회)

컨테이너 내부에서:
```bash
claude auth login
```

이후 인증 토큰은 `~/.claude/.credentials.json`에 저장되어 컨테이너 재시작 후에도 유지됨.

## Git 관리 대상

### 커밋 포함 (설정 파일)

```
claude/agents/      ← OMC 에이전트 정의 (19개)
claude/skills/      ← OMC 스킬 (33개+)
claude/hooks/       ← 훅 스크립트 (6개)
claude/hud/         ← 상태바 HUD
claude/settings.json
claude/CLAUDE.md
.devcontainer/      ← Dockerfile, devcontainer.json, post_install.py
bootstrap.sh
README.md
```

### 커밋 제외 (`.gitignore`)

```
claude/sessions/        ← 런타임 세션 상태
claude/projects/        ← 프로젝트 상태
claude/tasks/           ← 태스크 상태
claude/memory/          ← AI 메모리 (개인화)
claude/.claude.json     ← 인증 상태
claude/.credentials.json ← OAuth 토큰 (절대 커밋 금지)
claude/cache/           ← 캐시
.omc/                   ← OMC 런타임 상태
```

## 설정 변경 후 동기화

```bash
cd ~/workspace/claude-env
git add claude/
git commit -m "chore: update claude settings"
git push
```

다른 Mac에서:
```bash
cd ~/workspace/claude-env
git pull
# devcontainer 재시작으로 설정 자동 반영
```

## 디렉토리 구조

```
claude-env/
├── claude/
│   ├── agents/         ← 에이전트 정의
│   ├── skills/         ← 스킬 정의
│   ├── hooks/          ← 훅 스크립트
│   ├── hud/            ← 상태바 HUD
│   ├── settings.json   ← Claude Code 설정
│   └── CLAUDE.md       ← OMC 전역 지침
├── .devcontainer/
│   ├── Dockerfile      ← Ubuntu 24.04 + Claude Code
│   ├── devcontainer.json
│   └── post_install.py ← 컨테이너 초기화 스크립트
├── bootstrap.sh        ← 호스트 최초 설정
└── README.md
```
