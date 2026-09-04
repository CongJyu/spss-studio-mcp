# SPSS Studio MCP: A Research Assistant for Paper-Ready Chart Export, Deep Result Parsing, and Safe Execution

> **Language:** [English](technical_report.md) · [繁體中文（香港）](technical_report.zh-Hant-HK.md)

> Technical report | 2026-08-05 | Verified environment: Windows + IBM SPSS Statistics 32.0.0

## Abstract

SPSS is the de facto standard statistics software in psychology, management,
and social-science research, but the existing MCP (Model Context Protocol)
ecosystem only provides a thin wrapper that "hands the syntax to SPSS and
returns text tables": paper-ready images must be exported by hand in the
Viewer, results can be read but not consumed in a structured way, and
LLM-generated syntax lacks safety guardrails. This report presents **SPSS Studio
MCP** — an MCP server for SPSS that closes these gaps with four complementary
layers: (1) a **paper-ready chart pipeline**, exporting 11 chart kinds to
PNG/TIFF/EMF (300 dpi) in one call; (2) **deep result parsing**, turning OMS
text into Markdown + JSON tables and statistical summaries for 16 analysis
families; (3) **real-machine method verification**, with all 37 tools accepted
method by method on a real SPSS and 7+1 version-compatibility issues found and
fixed; and (4) a **safe execution layer** that blocks dangerous statements,
allowlists data paths, and provides `dry_run` and audit logs. Every capability
has been verified on a real SPSS 32 installation.

## 1 Background and Problem

### 1.1 Four gaps in the SPSS MCP ecosystem

A source review of existing SPSS MCP projects (reference `Exekiel179/SPSS-MCP`,
MIT) shows:

| Gap | Current state |
|------|------|
| G1 No paper-ready chart export | Only `OMS FORMAT=SPV` locks charts inside the binary .spv; the whole codebase has no OMS IMAGE/GGRAPH |
| G2 Shallow result parsing | Text-to-Markdown tables only; no JSON, no statistical summary |
| G3 Method code correctness unverified | 37 tools are implemented but have never been verified against real-machine samples |
| G4 Weak syntax safety layer | Syntax validation only; no allowlist / blocking / dry_run / audit |

### 1.2 Motivation

For a text-only LLM without multimodal ability, numeric statistics can be done
in Python, but **paper-ready images cannot be produced end-to-end on its own** —
SPSS's deterministic rendering (given the syntax, an image comes out, at
journal-grade type sizes / DPI) is the one irreplaceable value. This project
packages a "statistics engine + chart factory" as a deliverable and makes the
results machine-consumable.

## 2 System Design

```
Client (Codex / Claude / Cursor)
        │  MCP stdio
        ▼
Tool layer    37+ analysis methods + 11 charts + mediation/moderation + structured results
        ▼
Engine layer  SPSS Python3 XD API persistent session (spss.StartSPSS / spss.Submit)
        ▼
Output layer  OMS TEXT (tables) / HTML (PNG) / DOCX (EMF) + safety gate + audit
```

- **Persistent engine**: a single resident SPSS Python3 subprocess avoids the
  15–20 s startup cost on every call.
- **Templated syntax**: all charting and analysis goes through predefined
  templates (validated with Pydantic); the LLM cannot freely generate GPL /
  syntax.
- **Unified return**: `{markdown, json, files, warnings}`.

## 3 Key Implementation and Version-Compatibility Findings

### 3.1 SPSS 32 removes `OMS FORMAT=IMAGE` (key finding)

The planning phase relied on the legacy `OMS /DESTINATION FORMAT=IMAGE
IMAGEROOT=...`, which a real SPSS 32 rejects (`Unknown keyword or subcommand:
IMAGE`). Real-machine test matrix (excerpt):

| Variant | SPSS 32 result |
|------|-------------|
| `FORMAT=IMAGE ... IMAGEROOT=...` | ✗ Unsupported |
| `FORMAT=HTML IMAGES=YES OUTFILE=...` | ✓ Charts embedded as base64 PNG |
| `FORMAT=DOC OUTFILE=...` | ✓ Produces a .docx; charts are vector EMF |
| `FORMAT=HTML IMAGEWIDTH/HEIGHT` | ✗ Fatal error |

**Final solution**: PNG/TIFF go through HTML → base64 extraction → Pillow
post-processing (1950×1500 @300 dpi, TIFF as LZW); EMF goes through DOCX → zip
extraction of the vector EMF. The boxplot EMF is a 0-byte bug in SPSS 32 itself
(PNG/TIFF are fine); since 0.3.1 it has been fixed by switching to the classic
`EXAMINE /PLOT BOXPLOT` chart template (see the verification in Section 4).

### 3.2 Result parsing: from text to statistical summary

`result_parser.py` uses a line-scanning state machine to split SPSS table
blocks (handling Notes skipping, multi-line headers, single-space-glued cells,
`(a)` footnotes, `.000`→`<.001`), and extracts the key statistics for 16
analysis families:

t-tests (independent/paired), one-way / multi-way ANOVA (including Levene,
partial η²), correlations, linear / logistic / ordinal regression, frequencies,
chi-square, Cronbach's α, nonparametric tests
(Mann-Whitney / Wilcoxon / Kruskal-Wallis), Shapiro-Wilk normality, factor
analysis (KMO / Bartlett / cumulative variance), and descriptive statistics.

### 3.3 Fixes driven by real-machine method verification

26 analysis-method use cases were accepted on a real SPSS 32, exposing and
fixing 8 template issues: `TAILS(2)→TWOTAIL`, the comma in the `MEAN` argument,
the `=` after the TWOSTEP subcommands and the distance values, the discriminant
/ MANOVA factor-value ranges, the deprecated METHOD subcommand, PLUM
`TEST=PARALLEL`, GENLINMIXED subject nominalisation, and GENLIN
`DISTRIBUTION` folded into MODEL, among others.

### 3.4 Safety layer

`security.py`: dangerous commands (`HOST` / `ERASE` / `DELETE FILE`, etc.) are
blocked by start-of-line matching, a data-file path allowlist
(`SPSS_ALLOWED_DIRS`), `dry_run`, and JSONL audit logging — all wired
uniformly through `run_syntax` so they cover every tool.

## 4 Real-Machine Verification Results

| Category | Result |
|------|------|
| Analysis methods | 26/26 passed |
| Supplementary tools (file / status / syntax / structured / genlin) | 11/11 passed |
| Charts × PNG/EMF/TIFF | All 11 kinds passed in every format (0.3.1 fixed the boxplot EMF with the `EXAMINE` template; EMF ≈ 19 KB, non-zero) |
| Mediation / moderation | Passed on a real machine (Sobel z=6.75, p<.001; interaction p=.639) |
| Unit tests | 109 passed (including a real-machine reproduction manifest with self-contained sample data) |

Sample data and archived charts: `examples/` (survey / experiment / survival /
mediation / longitudinal).

## 5 Discussion and Limitations

- Embedded HTML PNGs are fixed at about 800×500, so a 300 dpi export means
  upscaling plus re-stamped DPI; for a strictly high-resolution bitmap from a
  vector chart, EMF + GDI+ rendering can be used (verified, Windows-only, left
  for future work).
- Mediation / moderation is implemented with three-step regression plus a Sobel
  test; for rigorous reporting, a PROCESS bootstrap cross-check is recommended.
- Ecosystem listings (LobeHub / PulseMCP) and official Releases are
  publishing-account operations; see `docs/ecosystem.md`.

## 6 Conclusion

SPSS Studio MCP demonstrates that the combination of a "statistics engine +
chart factory + structured consumption + safety guardrails" is achievable on a
real SPSS 32: all 37 tools fully accepted on a real machine, automated
paper-ready charts, summaries for 16 result families, and execution-safety
auditing. The project documentation is complete (chart-export PoC, result
parsing, method verification, security), providing a reusable MCP service for
agent workflows in psychology / management / social-science research.

## Appendix: Reproduction

```powershell
pip install -e ".[dev]"
python scripts/make_sample_data.py
python scripts/method_verification.py    # 26 methods
python scripts/tool_verification.py      # 11 tools
python -m spss_mcp.poc_chart --format PNG|EMF|TIFF
python scripts/archive_sample_charts.py  # archive the 11 sample charts
```
