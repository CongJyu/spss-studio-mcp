# Release Notes — v1.0.0

> **Language:** [English](release_notes_v1.0.md) · [繁體中文（香港）](release_notes_v1.0.zh-Hant-HK.md)

> Status: release-ready | Compiled from `docs/technical_report.md` and the verification records

## Overview

`spss-studio-mcp` is an MCP server for IBM SPSS Statistics that gives Codex /
Claude / Cursor a four-in-one capability: statistics engine + chart factory +
structured consumption + safety guardrails. All features have been verified on
a real SPSS Statistics 32.0.0.0 for Mac installation.

## Highlights

- **Paper-ready chart export**: 11 `spss_chart_*` tools, PNG/TIFF @300 dpi (1950×1500); the returned file path can be submitted directly.
- **Deep result parsing**: OMS text → Markdown + JSON tables + statistical summaries for 16 analysis families (t/F/R/B/Wald/α/χ²/p/effect sizes).
- **All 37+ tools verified on a real machine**: 26 analysis methods + 11 supporting tools all pass; 8 SPSS 32 syntax compatibility issues were fixed.
- **Full-format boxplot fix**: as of 0.3.1 the box plot uses the `EXAMINE /PLOT BOXPLOT` template, resolving the GGRAPH-schema `outlier was found inside fences` error on SPSS 32 and the 0-byte export problem (the Windows-only EMF format this fixed has since been removed).
- **Mediation / moderation**: `spss_mediation` (Baron & Kenny + Sobel) and `spss_moderation` (mean-centred interaction regression).
- **Safe execution**: dangerous-command blocking, data-path allowlist, `dry_run`, JSONL audit logging.
- **Unified response**: `{markdown, json, files, warnings}`, ready for Agents to consume programmatically.

## Key Compatibility Notes

- SPSS 32 removed `OMS FORMAT=IMAGE` / `IMAGEROOT`; the project instead extracts charts from the HTML export as PNG (converted to TIFF on request). The Windows-era DOCX/EMF pipeline has been removed in the macOS-only release (see `docs/poc_chart_pipeline.md`).
- As of 0.3.1 the box plot uses the `EXAMINE` legacy chart template; PNG / TIFF have been verified on a real machine (the former EMF format is removed).

## Resources

- Technical report: `docs/technical_report.md`
- Tutorial: `docs/tutorial.md`
- Method verification: `docs/method_verification.md`
- Ecosystem listing: `docs/ecosystem.md`

## Installation

```bash
pip install spss-studio-mcp
spss-studio-mcp status
```

On macOS, SPSS Statistics for Mac is auto-discovered inside its `.app` bundle
under `/Applications`; for a repo install, `scripts/install_macos.sh` sets
everything up in one step.

## Version

- Current version: `0.3.1` (0.3.0 completed the P3/P4 features; 0.3.1 fixed the full-format boxplot export)

## Acknowledgements

Upstream: `Exekiel179/SPSS-MCP` (MIT).
