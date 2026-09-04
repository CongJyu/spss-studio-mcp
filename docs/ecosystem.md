# Ecosystem Listing and Release v1.0 Preparation

> **Language:** [English](ecosystem.md) · [繁體中文（香港）](ecosystem.zh-Hant-HK.md)

> 2026-08-05 | Submission-type operations require a publishing account; this document provides entries and instructions that are ready to use.

## 1. Project Snapshot (for Ecosystem Listings and Releases)

- **Name**: spss-studio-mcp
- **One-liner**: Make SPSS an Agent's "statistics engine + chart factory": paper-ready charts, deep result parsing, real-machine method verification, and safe execution.
- **Category**: data-analysis / statistics / mcp-server
- **Tags**: `spss` `statistics` `mcp` `chart` `result-parsing` `psychology` `social-science`
- **Core capabilities (from the technical report)**:
  - 11 families of paper-ready charts (PNG/TIFF, 300 dpi)
  - Statistical summaries for 16 analysis families (t/F/R/B/Wald/p/effect sizes)
  - All 37+ tools verified on a real SPSS 32 installation
  - Mediation / moderation tools (Baron & Kenny + Sobel)
  - Safety layer (command blocking / allowlist / `dry_run` / audit)

## 2. LobeHub Listing

Platform: LobeHub (Lobe Chat MCP / plugin marketplace). Submission method: typically by submitting a description file or a PR to a GitHub repository. You may copy the entry below:

- Repository: https://github.com/flupke91/spss-studio-mcp
- LobeHub plugin marketplace submission entry: https://github.com/lobehub/lobe-chat-plugins
  (create a `plugins/<plugin-name>/` directory containing `plugin.json` + `README.md`)

```yaml
# LobeHub listing example
name: spss-studio-mcp
description: >-
  SPSS Studio MCP: paper-ready chart export (11 chart types as PNG/TIFF
  @300 dpi), deep result parsing (Markdown + JSON + statistical summaries),
  37+ methods verified on a real machine, mediation/moderation analysis and
  safe execution (dangerous-command blocking / allowlist / dry_run / audit).
  Suitable for psychology / management / social-science research.
category: data-analysis
tags: [spss, statistics, chart, mcp]
```

## 3. PulseMCP Listing

Platform: PulseMCP (MCP server directory). Submission method: on-site form or GitHub PR.
Suggested values:

- Submission entry: https://www.pulsemcp.com/submit
- Repository: https://github.com/flupke91/spss-studio-mcp

- **Name**: spss-studio-mcp
- **Short description**: Paper-ready charts, deep result parsing and safe execution for IBM SPSS Statistics via MCP.
- **Long description**: Cite the feature list in `README.md` and the summary in `docs/technical_report.md`.
- **Transport**: stdio
- **Auth**: none (authorised by the local SPSS licence)
- **OS**: macOS

## 4. GitHub Release v1.0 Draft

See `docs/release_notes_v1.0.md` (can be pasted directly into the Release page).

## 5. Pre-Submission Checklist

- [x] Features and verification: 37 tools verified on a real machine (26 methods + 11 tools), 11 chart families x PNG/TIFF
- [x] Full-format boxplot fix (0.3.1): boxplot exports correctly in PNG / TIFF
- [x] Documentation: README / QUICK_START / docs (tutorial, technical report, charting, parsing, verification, security)
- [x] Security: blocking / allowlist / `dry_run` / audit + `docs/security.md`
- [x] CI: `.github/workflows/ci.yml` (lint + pytest)
- [x] Licence: MIT (with upstream attribution)
- [x] Sample charts: `examples/charts/*.png` re-archived with the 0.3.1 templates (11 images, including the fixed boxplot)
- [ ] Publishing-account operations: create the GitHub release, submit the LobeHub/PulseMCP entries
- [ ] (Recommended) Pre-publication check of the GitHub repository: no sensitive paths, no local logs committed (`logs/` is already gitignored)

## 7. GitHub Release Steps (Publishing-Account Operations)

- [x] Create the public repository `flupke91/spss-studio-mcp` and push `master` (2026-08-05);
- [x] Tag `v1.0.0` and create the Release (body = `docs/release_notes_v1.0.md`);
- [ ] Submit the LobeHub entry (lobe-chat-plugins PR);
- [ ] Submit the PulseMCP entry (pulsemcp.com/submit form).

## 6. External Materials (Deliverables of Item ②, Ready to Cite)

- Technical report (paper draft): `docs/technical_report.md`
- Tutorial: `docs/tutorial.md`
- Sample charts: `examples/charts/*.png` (can serve as README / listing screenshots)
- Verification records: `docs/method_verification.md`, `docs/macos_verification.md`, `docs/tool_verification_macos.json`
