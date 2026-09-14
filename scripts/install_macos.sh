#!/usr/bin/env bash
# spss-studio-mcp one-command macOS installer
#
# Usage:
#   bash scripts/install_macos.sh               # install + configure-claude
#   bash scripts/install_macos.sh --codex       # install + configure-codex
#   bash scripts/install_macos.sh --local       # Claude Code -> settings.local.json
#   bash scripts/install_macos.sh --no-link     # skip the ~/.local/bin symlink
#
# Steps:
#   1. Check Python (>=3.10; prefer uv, otherwise python3)
#   2. Create .venv and pip install -e ".[dev]"
#   3. Symlink the entrypoint into ~/.local/bin (skipped with --no-link)
#   4. Run `spss-studio-mcp status` to verify SPSS detection
#   5. Write the MCP client config (Claude Code or Codex)
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"

CONFIGURE="configure-claude"
LINK=true
EXTRA=()

while [ $# -gt 0 ]; do
  case "$1" in
    --codex) CONFIGURE="configure-codex"; shift ;;
    --local) EXTRA+=("--local"); shift ;;
    --no-link) LINK=false; shift ;;
    --help|-h)
      sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; sed -n '2,15p' "$0"; exit 1 ;;
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
  info "[2/5] Installing spss-studio-mcp (editable) ..."
  if command -v uv >/dev/null 2>&1; then
    uv pip install --python "$ROOT/.venv/bin/python" -e ".[dev]"
  else
    "$ROOT/.venv/bin/python" -m pip install --upgrade pip
    "$ROOT/.venv/bin/python" -m pip install -e ".[dev]"
  fi
  ok "Dependencies installed"
}

# Put the entrypoint on PATH so every MCP client config can use the plain
# command name instead of a hardcoded absolute path.
link_entrypoint() {
  if [ "$LINK" != true ]; then
    info "[3/5] Skipping PATH symlink (--no-link)"
    return
  fi

  local bin_dir="$HOME/.local/bin"
  local target="$ROOT/.venv/bin/spss-studio-mcp"
  local link="$bin_dir/spss-studio-mcp"

  info "[3/5] Linking entrypoint onto PATH ..."
  mkdir -p "$bin_dir"

  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    ok "Symlink already current: $link"
  elif [ -e "$link" ] && [ ! -L "$link" ]; then
    fail "$link exists and is not a symlink - leaving it untouched"
    info "Remove it yourself, then re-run; or pass --no-link and use absolute paths"
    return
  else
    ln -sfn "$target" "$link"
    ok "Linked $link -> $target"
  fi

  case ":$PATH:" in
    *":$bin_dir:"*) ok "$bin_dir is on PATH" ;;
    *)
      info "$bin_dir is NOT on PATH. Add it to your shell profile:"
      info "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
      info "Until then, use the absolute path in MCP client configs."
      ;;
  esac
}

run_status() {
  info "[4/5] Verifying install (auto-detecting SPSS) ..."
  "$ROOT/.venv/bin/spss-studio-mcp" status || true
  if "$ROOT/.venv/bin/spss-studio-mcp" status 2>&1 | grep -q "SPSS batch : NOT FOUND"; then
    info "SPSS not detected - only the file-based tools are available."
    info "If SPSS is installed but not found, set SPSS_INSTALL_PATH to the engine directory (normally unnecessary: /Applications is auto-discovered)"
  fi
}

configure_client() {
  info "[5/5] Writing MCP client config: spss-studio-mcp $CONFIGURE ${EXTRA[*]:-}"
  "$ROOT/.venv/bin/spss-studio-mcp" "$CONFIGURE" "${EXTRA[@]:-}"
  ok "Configuration written"
}

echo "========================================"
echo "  spss-studio-mcp macOS one-command installer"
echo "========================================"
check_python
create_venv
install_deps
link_entrypoint
run_status
configure_client

echo "========================================"
echo "  Installation complete!"
echo "========================================"
ok "Next: restart Claude Code (or Codex), then ask: check SPSS status"
info "Docs: README.md / docs/tutorial.md / docs/macos_verification.md"
info "Tip: charts export as PNG or TIFF at 300 dpi, submission-ready"
