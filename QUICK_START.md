# SPSS Studio MCP — Quick Start

> **Language:** [English](QUICK_START.md) · [繁體中文（香港）](QUICK_START.zh-Hant-HK.md)

> Deploy in 3 steps and start within 5 minutes. Verified on real IBM SPSS
> Statistics 32 for macOS.

---

## Step 1 — Install

**macOS** (Python ≥3.10; SPSS Statistics 32 for Mac is auto-discovered inside
the `.app` bundle under `/Applications`):

```bash
cd ~/Code/spss-studio-mcp
bash scripts/install_macos.sh          # creates .venv, installs deps, configure-claude
.venv/bin/spss-studio-mcp status       # SPSS batch: OK
```

## Step 2 — Configure the MCP client

```bash
.venv/bin/spss-studio-mcp configure-codex     # Codex (~/.codex/config.toml)
.venv/bin/spss-studio-mcp configure-claude    # Claude Code (~/.claude.json)
.venv/bin/spss-studio-mcp setup-info          # print the manual config snippet
```

## Step 3 — Use it

### Statistical analysis

Describe the task to your client in natural language, e.g.:

- `Run descriptive statistics and reliability analysis on examples/data/survey_study.sav`
- `Independent-samples t-test on examples/data/experiment_study.sav (grouping: group, dependent: posttest)`
- `Mediation analysis on examples/data/mediation_study.sav: autonomy → satisfaction → performance`

### Paper-ready charts

- `Histogram with normal density of engagement_total in examples/data/survey_study.sav, PNG 300dpi`
- `Kaplan-Meier survival curves grouped by treatment on examples/data/survival_study.sav`
- `Boxplot of posttest scores by group on examples/data/experiment_study.sav`

Every chart tool returns a 1950×1500 @300 dpi file path ready for submission.

### Structured results

- Call `spss_structured_result` to get the unified structure
  `{markdown, json, files, warnings}`; the statistical summary
  (t / F / r / B / p, ...) is appended at the end of every analysis tool's
  output under a `### Statistical Summary` heading.

## Safety

- Dangerous commands (`HOST` / `ERASE` / `DELETE FILE`, ...) are blocked;
- Data files must live under `examples/`, the system temp dir, or a directory
  declared in `SPSS_ALLOWED_DIRS`;
- `spss_run_syntax(..., dry_run=True)` validates without executing;
- Audit logs are written to `logs/audit.jsonl` by default
  (override with `SPSS_AUDIT_LOG`).

## Samples & docs

- Sample datasets and archived charts: `examples/`
- Documentation: `docs/` (chart-pipeline PoC, result parsing, verification records)
- Full agent tutorial: [`docs/tutorial.md`](docs/tutorial.md)

## FAQ

- **Slow startup**: first engine start takes ~15–20 s; afterwards it stays
  resident as a persistent session.
- **"Not licensed"**: make sure an SPSS trial or full license is available, and
  avoid running several SPSS sessions at once.
- **Data file rejected**: put the file under `examples/data/`, or declare its
  directory with `SPSS_ALLOWED_DIRS`.
