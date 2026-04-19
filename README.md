# claude-env

Claude Code + OMC 설정을 버전 관리하고, Docker devcontainer로 어디서든 동일한 환경을 재현.

## 요구 사항

- macOS / Linux
- Docker ([Docker Desktop](https://www.docker.com/products/docker-desktop/) 또는 [Docker Engine](https://docs.docker.com/engine/install/))

## 시작하기

```bash
# 1. 호스트 설정 (최초 1회)
git clone https://github.com/Leejunhee17/claude-env.git ~/workspace/claude-env
cd ~/workspace/claude-env
./bootstrap.sh

# 2. 컨테이너 시작
cd ~/workspace/claude-env
devc up && devc shell

# 3. 컨테이너 안에서 로그인 (최초 1회)
claude auth login
```

인증 토큰은 `~/.claude/.credentials.json`에 저장되어 재시작 후에도 유지됨.

> VS Code 사용 시: `code .` → "Reopen in Container" 클릭 (선택사항)

## 설정 동기화

```bash
git add claude/ && git commit -m "chore: update settings" && git push
# 다른 머신에서: git pull 후 devcontainer 재시작
```

## 보안

컨테이너 마운트: `~/.claude` (rw), `~/.gitconfig` (ro), shell history, gh config  
의도적으로 제외: `~/.ssh`, `~/.aws`, 그 외 자격증명

## 구조

```
claude/
├── agents/       ← 에이전트 정의
├── skills/       ← 스킬
├── hooks/        ← 훅 스크립트
├── settings.json
└── CLAUDE.md
.devcontainer/    ← Dockerfile, devcontainer.json, post_install.py
bootstrap.sh
```
