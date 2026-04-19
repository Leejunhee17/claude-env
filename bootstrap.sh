#!/usr/bin/env bash
set -euo pipefail

# ── 설정 ────────────────────────────────────────────────────────────────────
REPO_SSH="git@github.com:Leejunhee17/claude-env.git"
REPO_HTTPS="https://github.com/Leejunhee17/claude-env.git"
REPO_DIR="${HOME}/workspace/claude-env"
CLAUDE_SOURCE="${REPO_DIR}/claude"
CLAUDE_TARGET="${HOME}/.claude"
DEVC_REPO="https://github.com/trailofbits/claude-code-devcontainer"
DEVC_DIR="${HOME}/.claude-devcontainer"
SHELL_RC="${HOME}/.bashrc"
[ -f "${HOME}/.zshrc" ] && SHELL_RC="${HOME}/.zshrc"

# ── 헬퍼 ────────────────────────────────────────────────────────────────────
step() { echo ""; echo "▶ $*"; }
ok()   { echo "  ✓ $*"; }
warn() { echo "  ⚠ $*"; }
fail() { echo "  ✗ $*"; exit 1; }

# ── 1. claude-env 저장소 ─────────────────────────────────────────────────────
step "claude-env 저장소 준비"
if [ -d "${REPO_DIR}/.git" ]; then
    ok "이미 존재 → git pull"
    git -C "$REPO_DIR" pull --ff-only
else
    mkdir -p "$REPO_DIR"
    if git clone "$REPO_SSH" "$REPO_DIR" 2>/dev/null; then
        ok "Clone 완료 (SSH)"
    else
        warn "SSH 실패 → HTTPS로 재시도"
        git clone "$REPO_HTTPS" "$REPO_DIR"
        ok "Clone 완료 (HTTPS)"
    fi
fi

# ── 2. claude 폴더 확인 ──────────────────────────────────────────────────────
step "claude 폴더 확인"
if [ ! -d "$CLAUDE_SOURCE" ]; then
    mkdir -p "$CLAUDE_SOURCE"
    ok "생성 완료: $CLAUDE_SOURCE"
else
    ok "이미 존재"
fi

# ── 3. 기존 ~/.claude 처리 ───────────────────────────────────────────────────
step "기존 ~/.claude 처리"
if [ -e "$CLAUDE_TARGET" ] && [ ! -L "$CLAUDE_TARGET" ]; then
    BACKUP="${CLAUDE_TARGET}.bak_$(date +%Y%m%d_%H%M%S)"
    warn "기존 디렉토리 발견 → $BACKUP 으로 백업"
    mv "$CLAUDE_TARGET" "$BACKUP"
fi

# ── 4. symlink 생성 ──────────────────────────────────────────────────────────
step "symlink 생성: ~/.claude → $CLAUDE_SOURCE"
if [ -L "$CLAUDE_TARGET" ] && [ "$(readlink "$CLAUDE_TARGET")" = "$CLAUDE_SOURCE" ]; then
    ok "이미 올바른 symlink 존재 → 건너뜀"
elif [ -L "$CLAUDE_TARGET" ]; then
    warn "다른 symlink 존재 → 업데이트"
    ln -sfn "$CLAUDE_SOURCE" "$CLAUDE_TARGET"
    ok "symlink 업데이트 완료"
else
    ln -sfn "$CLAUDE_SOURCE" "$CLAUDE_TARGET"
    ok "symlink 생성 완료"
fi

# ── 5. devc CLI 설치 ─────────────────────────────────────────────────────────
step "devcontainers CLI(devc) 확인 및 설치"
if command -v devc &>/dev/null; then
    ok "devc 이미 설치됨"
else
    if ! grep -q 'local/bin' "$SHELL_RC" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
        warn "PATH 추가됨 ($SHELL_RC)"
    fi
    export PATH="$HOME/.local/bin:$PATH"

    if [ ! -d "$DEVC_DIR" ]; then
        git clone "$DEVC_REPO" "$DEVC_DIR"
    fi

    bash "${DEVC_DIR}/install.sh" self-install
    ok "devc 설치 완료"
fi

# ── 완료 ─────────────────────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════════════"
ok "부트스트랩 완료"
echo ""
echo "  저장소   : $REPO_DIR"
echo "  ~/.claude : $CLAUDE_TARGET → $CLAUDE_SOURCE"
echo "  shell rc  : $SHELL_RC"
echo ""
echo "  다음 단계:"
echo "    cd $REPO_DIR"
echo "    devc up && devc shell   # 컨테이너 시작 + 접속"
echo "    # 또는 VS Code: code . → 'Reopen in Container'"
echo ""
echo "  첫 실행 시 Claude 로그인:"
echo "    claude auth login"
echo "    # 이후 토큰이 ~/.claude/.credentials.json 에 저장되어 자동 유지"
echo ""
echo "  설정 변경 후 커밋:"
echo "    cd $REPO_DIR"
echo "    git add claude/"
echo "    git commit -m \"chore: update claude settings\""
echo "    git push"
echo "══════════════════════════════════════════════════════"

exec "$SHELL" -l
