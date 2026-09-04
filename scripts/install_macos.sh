#!/usr/bin/env bash
# spss-studio-mcp one-command macOS installer
#
# Usage:
#   bash scripts/install_macos.sh               # install + configure-claude
#   bash scripts/install_macos.sh --codex       # install + configure-codex
#   bash scripts/install_macos.sh --local       # Claude Code -> settings.local.json
#
# Steps:
#   1. Check Python (>=3.10; prefer uv, otherwise python3)
#   2. Create .venv and pip install -e ".[dev]"
#   3. Run `spss-studio-mcp status` to verify SPSS detection
#   4. Write the MCP client config (Claude Code or Codex)
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"

CONFIGURE="configure-claude"
EXTRA=()

while [ $# -gt 0 ]; do
  case "$1" in
    --codex) CONFIGURE="configure-codex"; shift ;;
    --local) EXTRA+=("--local"); shift ;;
    --help|-h)
      sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; sed -n '2,11p' "$0"; exit 1 ;;
  esac
done

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { printf "${GREEN}[✓]${NC} %s\n" "$*"; }
info() { printf "${YELLOW}[i]${NC} %s\n" "$*"; }
fail() { printf "${RED}[✗]${NC} %s\n" "$*"; }

check_python() {
  if command -v uv >/dev/null 2>&1; then
    info "uv detected - using uv to manage the environment"
    return 0
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    fail "python3 not found. Install Python 3.10+: https://www.python.org/downloads/macos/ (or install uv)"
    exit 1
  fi
  local v
  v="$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
  if python3 -c 'import sys; exit(0 if sys.version_info >= (3,10) else 1)'; then
    ok "Python ${v} (>=3.10)"
  else
    fail "Python >=3.10 required, found ${v}. Upgrade: https://www.python.org/downloads/macos/ (or install uv)"
    exit 1
  fi
}

create_venv() {
  if [ -x "$ROOT/.venv/bin/python" ]; then
    ok ".venv already exists"
    return
  fi
  if command -v uv >/dev/null 2>&1; then
    info "uv venv --python 3.10 .venv"
    uv venv --python 3.10 "$ROOT/.venv"
  else
    info "python3 -m venv .venv"
    python3 -m venv "$ROOT/.venv"
  fi
  ok ".venv created"
}

install_deps() {
  info "[2/4] Installing spss-studio-mcp (editable) ..."
  if command -v uv >/dev/null 2>&1; then
    uv pip install --python "$ROOT/.venv/bin/python" -e ".[dev]"
  else
    "$ROOT/.venv/bin/python" -m pip install --upgrade pip
    "$ROOT/.venv/bin/python" -m pip install -e ".[dev]"
  fi
  ok "Dependencies installed"
}

run_status() {
  info "[3/4] Verifying install (auto-detecting SPSS) ..."
  "$ROOT/.venv/bin/spss-studio-mcp" status || true
  if "$ROOT/.venv/bin/spss-studio-mcp" status 2>&1 | grep -q "SPSS batch : NOT FOUND"; then
    info "SPSS not detected - only the file-based tools are available."
    info "If SPSS is installed but not found, set SPSS_INSTALL_PATH to the engine directory (normally unnecessary: /Applications is auto-discovered)"
  fi
}

configure_client() {
  info "[4/4] Writing MCP client config: spss-studio-mcp $CONFIGURE ${EXTRA[*]:-}"
  "$ROOT/.venv/bin/spss-studio-mcp" "$CONFIGURE" "${EXTRA[@]:-}"
  ok "Configuration written"
}

echo "========================================"
echo "  spss-studio-mcp macOS one-command installer"
echo "========================================"
check_python
create_venv
install_deps
run_status
configure_client

echo "========================================"
echo "  Installation complete!"
echo "========================================"
ok "Next: restart Claude Code (or Codex), then ask: check SPSS status"
info "Docs: README.md / QUICK_START.md / docs/macos_verification.md"
info "Tip: charts export as PNG or TIFF at 300 dpi, submission-ready"
