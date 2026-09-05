# SPSS Studio MCP for Mac

> Make SPSS an Agent's "statistics engine + chart factory": paper-ready charts, deep result parsing, verified methods, and safe execution.

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

## Ecosystem & Release

- Status: P0–P4 milestones complete, **v1.0.0 released**
  ([GitHub Releases](https://github.com/flupke91/spss-studio-mcp/releases));
- LobeHub / PulseMCP listing drafts and submission checklist:
  [docs/ecosystem.md](docs/ecosystem.md);
- Release v1.0.0 notes: [docs/release_notes_v1.0.md](docs/release_notes_v1.0.md).

## License

MIT (upstream: `flupke91/spss-studio-mcp`, MIT).

MIT (upstream: `Exekiel179/SPSS-MCP`, MIT).
