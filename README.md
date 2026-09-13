# SPSS Studio MCP for Mac

> Make SPSS an Agent's "statistics engine + chart factory": paper-ready charts, deep result parsing, verified methods, and safe execution.

> This MCP is **Mac Only**, for Windows versions, see [flupke91/spss-studio-mcp](https://github.com/flupke91/spss-studio-mcp).

**English** ｜ [繁體中文（香港）](README.zh-Hant-HK.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.14%2B-blue.svg)]()
[![Tests](https://img.shields.io/badge/tests-105%20passed-brightgreen.svg)]()

`spss-studio-mcp` is an MCP (Model Context Protocol) server for **IBM SPSS
Statistics**. It gives Agent clients such as Codex / Claude Code / Cursor:

- **Paper-ready charts**: 11 `spss_chart_*` tools export PNG / TIFF
  (1950×1500 @300 dpi) in one call and return the file path for direct
  submission to journals;
- **Deep result parsing**: OMS text → Markdown tables + structured JSON +
  statistical summaries for 16 analysis families (t / F / r / B / Wald / α /
  χ² / p / effect sizes);
- **Verified methods**: all 37 analysis tools plus 11 supporting tools are
  verified on real SPSS Statistics 32 for Mac;
- **Mediation / moderation**: `spss_mediation` (Baron & Kenny three-step
  regression + Sobel test) and `spss_moderation` (mean-centred interaction
  regression);
- **Safety layer**: dangerous-command blocking, data path allowlist,
  `dry_run` preflight, and JSONL audit logging.

Everything is verified on **IBM SPSS Statistics 32.0.0.0 for macOS** — 105 unit
tests pass, including a self-contained real-machine reproduction manifest.
Per-case results: [docs/macos_verification.md](docs/macos_verification.md).

---

## Installation

> **Prerequisites** — macOS with IBM SPSS Statistics 32 for Mac installed, plus
> Python ≥3.10 (or [uv](https://docs.astral.sh/uv/)). SPSS is auto-discovered
> inside the `.app` bundle under `/Applications`; set `SPSS_INSTALL_PATH` only
> if yours is installed elsewhere.

### Step 1 — Install the server (once, shared by every client)

```bash
git clone https://github.com/flupke91/spss-studio-mcp.git
cd spss-studio-mcp
python3 -m venv .venv
.venv/bin/python -m pip install -e .

.venv/bin/spss-studio-mcp status      # → SPSS batch : OK
.venv/bin/spss-studio-mcp setup-info  # → the exact command / args / env for your client
```

Or use the one-command installer, which does the above **and** writes the client
config for you (default target: Claude Code; add `--codex` for Codex CLI):

```bash
bash scripts/install_macos.sh            # install + configure-claude
bash scripts/install_macos.sh --codex    # install + configure-codex
```

The examples below assume the clone is at `/Users/you/Code/spss-studio-mcp` —
replace that with your own `pwd`.

### Step 2 — Register the server with your client

#### Claude Code

The bundled configurator merges the entry into `~/.claude.json` (user scope:
available in all your projects) and writes a timestamped backup first:

```bash
.venv/bin/spss-studio-mcp configure-claude
```

Or register it with the Claude Code CLI — identical result:

```bash
claude mcp add --transport stdio --scope user spss \
  --env SPSS_INSTALL_PATH="/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin" \
  --env SPSS_TIMEOUT=120 \
  --env SPSS_STARTUP_TIMEOUT=300 \
  -- /Users/you/Code/spss-studio-mcp/.venv/bin/spss-studio-mcp serve --transport stdio
```

Use `--scope project` instead to write a shared `.mcp.json` at the repo root.
Verify with `claude mcp get spss`, or type `/mcp` inside a session.

The resulting entry (exactly what `configure-claude` writes):

```json
{
  "mcpServers": {
    "spss": {
      "type": "stdio",
      "command": "/Users/you/Code/spss-studio-mcp/.venv/bin/spss-studio-mcp",
      "args": ["serve", "--transport", "stdio"],
      "env": {
        "SPSS_INSTALL_PATH": "/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin",
        "SPSS_TIMEOUT": "120",
        "SPSS_STARTUP_TIMEOUT": "300"
      }
    }
  }
}
```

#### Codex CLI

```bash
.venv/bin/spss-studio-mcp configure-codex   # merges into ~/.codex/config.toml
```

Or with the Codex CLI:

```bash
codex mcp add spss \
  --env SPSS_INSTALL_PATH="/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin" \
  --env SPSS_TIMEOUT=120 \
  --env SPSS_STARTUP_TIMEOUT=300 \
  -- /Users/you/Code/spss-studio-mcp/.venv/bin/spss-studio-mcp serve --transport stdio
```

Both write the same block into `~/.codex/config.toml`:

```toml
[mcp_servers.spss]
command = '/Users/you/Code/spss-studio-mcp/.venv/bin/spss-studio-mcp'
args = ["serve", "--transport", "stdio"]
env = { SPSS_INSTALL_PATH = '/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin', SPSS_TIMEOUT = '120', SPSS_STARTUP_TIMEOUT = '300' }
```

Verify with `codex mcp list`.

#### OpenCode

OpenCode reads servers from the `mcp` key (**not** `mcpServers`) in
`~/.config/opencode/opencode.json` (global) or `opencode.json` at the project
root (higher precedence). There is no `configure-opencode` command yet — merge
this in by hand, noting that `command` is an **array**:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "spss": {
      "type": "local",
      "command": [
        "/Users/you/Code/spss-studio-mcp/.venv/bin/spss-studio-mcp",
        "serve",
        "--transport",
        "stdio"
      ],
      "enabled": true,
      "timeout": 60000,
      "environment": {
        "SPSS_INSTALL_PATH": "/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin",
        "SPSS_TIMEOUT": "120",
        "SPSS_STARTUP_TIMEOUT": "300"
      }
    }
  }
}
```

> **Set `timeout`**: OpenCode's MCP timeout defaults to 5 s, but the first SPSS
> engine start takes ~15–20 s. 60000 ms (or more) avoids a spurious startup
> failure.

### Step 3 — Verify

Restart the client, then drive it in natural language — `check SPSS status` is a
good first prompt. Nothing needs to be exported in your shell: the server
resolves SPSS itself and reads `SPSS_INSTALL_PATH` from the `env` block you just
added.

---

## Quick Start

**macOS** (SPSS Statistics 32 for Mac is auto-discovered inside the `.app`
bundle under `/Applications`; Python ≥3.10 required):

```bash
cd spss-studio-mcp
bash scripts/install_macos.sh              # creates .venv, installs deps, configure-claude
.venv/bin/spss-studio-mcp status           # SPSS batch: OK
.venv/bin/spss-studio-mcp configure-codex  # optional: Codex config
```

Then drive it from your client in natural language, e.g.:

```text
Run descriptive statistics and reliability analysis on examples/data/survey_study.sav
Independent-samples t-test on examples/data/experiment_study.sav (grouping: group, dependent: posttest)
Mediation analysis on examples/data/mediation_study.sav: autonomy → satisfaction → performance
Histogram with normal density of engagement_total in examples/data/survey_study.sav, PNG 300dpi
```

## Paper-Ready Charts (Core Feature)

| Tool                                                    | Purpose                                              |
| ------------------------------------------------------- | ---------------------------------------------------- |
| `spss_chart_histogram` / `spss_chart_histogram_density` | Histogram / histogram with normal density            |
| `spss_chart_scatter`                                    | Scatter plot of two variables                        |
| `spss_chart_bar` / `spss_chart_bar_error`               | Bar chart of category means / with 95% CI error bars |
| `spss_chart_line` / `spss_chart_area`                   | Time-series line / area charts                       |
| `spss_chart_boxplot`                                    | Grouped box-and-whisker plot                         |
| `spss_chart_errorbar`                                   | Mean ± CI error bar chart                            |
| `spss_chart_qqplot`                                     | Normal Q-Q plot                                      |
| `spss_chart_km_curve`                                   | Kaplan-Meier survival curve                          |

```python
spss_chart_histogram_density(
    variable="engagement_total",
    title="Engagement total distribution (with normal density)",
    image_format="PNG",            # PNG / TIFF
    width_px=1950, height_px=1500, dpi=300,
    data_file="examples/data/survey_study.sav",
)
# → returns the image file path, ready for submission
```

> **Format note**: chart output is **PNG and TIFF only**. Windows vector EMF
> export was removed because SPSS for macOS cannot produce EMF metafiles (its
> `OMS FORMAT=DOC` archive contains only raster PNG wrapped in `.eps`). Use
> `image_format="PNG"` or `"TIFF"`.

## Structured Results & Statistical Summaries

```python
spss_structured_result(
    syntax="T-TEST GROUPS=group(1 2) /VARIABLES=posttest.",
    data_file="examples/data/experiment_study.sav",
)
# → {markdown, json: {tables, summary}, files, warnings}
```

The Markdown returned by `run_syntax` ends with a `### Statistical Summary`
block containing a plain-language conclusion plus key statistics.
Extraction details for the 16 analysis families: [docs/result_parsing.md](docs/result_parsing.md).

## Sample Datasets

`examples/data/` ships five research-style datasets (fixed random seeds,
fully reproducible):

| File                                        | Scenario                                               | Key variables                                        |
| ------------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------- |
| `survey_study.sav`                          | Survey: 200 students' learning engagement              | `gender` / `major` / `q1`–`q12` / `engagement_total` |
| `experiment_study.sav`                      | Experiment: 120 participants, pre/post memory training | `group` / `pretest` / `posttest` / `gain`            |
| `survival_study.sav`                        | Survival: 150 follow-up cases                          | `treatment` / `time` / `status`                      |
| `mediation_study.sav`                       | Mediation: 300 employees                               | `autonomy` / `satisfaction` / `performance`          |
| `longitudinal_study.sav` / `long_study.sav` | Longitudinal: 60 people, 3 waves                       | `id` / `group` / `time` / `score`                    |

## Safe Execution

- Dangerous commands (`HOST` / `ERASE` / `DELETE FILE`, ...) are blocked at
  the start of a line;
- Data files must live under `examples/`, the system temp dir, or a directory
  declared in `SPSS_ALLOWED_DIRS`;
- `spss_run_syntax(..., dry_run=True)` validates without executing;
- Audit logs are written to `logs/audit.jsonl` by default
  (override with `SPSS_AUDIT_LOG`).

See [docs/security.md](docs/security.md).

## Documentation

- [Tutorial](docs/tutorial.md)
- [Technical report](docs/technical_report.md)
- [Chart pipeline PoC & SPSS 32 findings](docs/poc_chart_pipeline.md)
- [Result parsing (16 analysis families)](docs/result_parsing.md)
- [Method verification](docs/method_verification.md)
- [macOS verification report (SPSS 32 for Mac)](docs/macos_verification.md)
- [Security layer](docs/security.md)
- [Changelog](CHANGELOG.md)

## License

MIT (upstream: `flupke91/spss-studio-mcp`, MIT).

MIT (upstream: `Exekiel179/SPSS-MCP`, MIT).
