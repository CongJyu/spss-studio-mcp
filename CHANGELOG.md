# Changelog

> **Language:** [English](CHANGELOG.md) · [繁體中文（香港）](CHANGELOG.zh-Hant-HK.md)

## [Unreleased]

### Changed
- **macOS-only product**: all Windows-SPSS support has been removed. The MCP now
  targets IBM SPSS Statistics for macOS exclusively.
  - Removed the Windows installers (`install.bat`, `install.ps1`), Windows
    registry + `C:\...\stats.exe` filesystem detection, and the Windows
    SPSS-bundled Python launcher (`Python3/python.exe`)
  - Removed `os.startfile()` viewer handling; on macOS the `.spv` Viewer is
    opened with `open` and only when `SPSS_OPEN_VIEWER=1` is set
  - Removed the `Operating System :: Microsoft :: Windows` trove classifier
- **Chart output is PNG and TIFF only**: Windows EMF vector export was removed
  entirely — SPSS for macOS cannot produce EMF metafiles (its `OMS FORMAT=DOC`
  archive contains only raster PNG wrapped in `.eps`)
- Unit-test count is now **105** (the EMF export tests were removed); the
  Windows-baseline JSON files `docs/tool_verification.json` and
  `docs/method_verification.json` were deleted — per-case macOS results remain
  in `docs/tool_verification_macos.json` and `docs/method_verification_macos.json`

## [0.4.0] - 2026-09-04

### Added
- **macOS port**: verified on real SPSS Statistics 32 for Mac
  - Method verification **26/26** and tool verification **11/11**, fully aligned
    with the Windows baseline
  - Charts (11 kinds) PNG / TIFF **11/11** pass (1950×1500 @300 dpi); per-case
    results in `docs/method_verification_macos.json`,
    `docs/tool_verification_macos.json` and `docs/macos_verification.md`
- One-command installer `scripts/install_macos.sh` (creates a venv, installs
  deps, runs `configure-claude`)
- `pyproject.toml` now declares the `Operating System :: MacOS :: MacOS X`
  classifier

### Changed
- Engine subprocess is now event-loop safe: `spss_engine.py` records the loop it
  was started in, `is_alive()` only reports `True` on the same loop, and the
  engine is rebuilt across loops — fixes `Task attached to a different loop`
  seen in tests / multi-loop clients
- Relative data paths (`data_file` and in-syntax `GET FILE=`) are resolved to
  absolute paths before submission (`spss_runner.py`) — fixes
  `The filename is not valid` caused by the macOS engine's different working
  directory
- On macOS, opening the `.spv` viewer now uses `open` and is off by default
  unless `SPSS_OPEN_VIEWER=1`
- `server.py` line endings normalised from legacy CR to LF
- User-facing tool output localised to English: the summary is appended under a
  `### Statistical Summary` heading, and the `spss_mediation` /
  `spss_moderation` reports are in English

### Notes
- Documentation is maintained in **English** (primary, current filenames) and
  **Traditional Chinese (Hong Kong)** (mirrors named `*.zh-Hant-HK.md`); the two
  editions carry identical meaning.
- SPSS Statistics for Mac does not emit Windows EMF vector charts (its
  `OMS FORMAT=DOC` archive contains PNG raster); on macOS use PNG / TIFF. In
  this release EMF was still offered as a Windows feature; it has since been
  removed entirely (see [Unreleased] above).

## [0.3.1] - 2026-08-05

### Fixed
- `spss_chart_boxplot`: the GGRAPH `ELEMENT: schema` template raised
  `outlier was found inside fences` on SPSS 32 with real data (a case landed
  exactly on the whisker line) and exported 0-byte DOCX/EMF; switched to the
  classic `EXAMINE /PLOT BOXPLOT` template. PNG / TIFF / EMF all verified on a
  real machine (EMF 18996 bytes, non-zero). Triggered by a coursework
  verification; see project plan §5.3.

## [0.3.0] - 2026-08-05

### Added
- P3 method verification: 26 analysis methods accepted on a real machine plus
  `scripts/method_verification.py`
- Mediation / moderation tools: `spss_mediation` (three-step regression +
  Sobel), `spss_moderation` (mean-centred interaction)
- P4 safety layer: `security.py` (dangerous-command blocking / path allowlist /
  `dry_run` / JSONL audit)
- Supplementary tool acceptance: 6 file utilities + status / syntax /
  structured + `spss_genlin` (`scripts/tool_verification.py`)
- All 11 chart kinds × TIFF full-format verification
- Docs: tutorial, technical report, ecosystem / release preparation

### Fixed
- `spss_correlations`: `TAILS(2)` → `TWOTAIL`
- `spss_compute_scale_score`: comma-separated `MEAN` / `NVALID` arguments
- `spss_twostep_cluster`: removed `=` after subcommands, distance defaults to
  LIKELIHOOD, dropped invalid OUTLIERS/PRINT
- `spss_discriminant` / `spss_manova`: factor/group-value ranges; MANOVA drops
  the deprecated METHOD subcommand
- `spss_ordinal_regression`: dropped invalid `TEST=PARALLEL`
- `spss_genlinmixed`: subject nominalisation, dropped invalid PRINT
- `spss_genlin`: `DISTRIBUTION` folded into MODEL, PRINT without `=`

## [0.2.0] - 2026-08-04

### Added
- P1 chart pipeline: 11 chart-kind specs + GGRAPH templates + `spss_chart_*` tools
- Dual OMS export paths: HTML → base64 PNG extraction, DOCX → EMF extraction
  (SPSS 32 compatible)
- Image post-processing: Pillow resize to 1950×1500 + 300 dpi metadata
- P2 result parsing: `result_parser.py` (table JSON + 16-family statistical
  summaries)
- `spss_structured_result` unified return structure
- Sample data and archives: `examples/` (survey / experiment / survival /
  mediation / longitudinal)

### Fixed
- GGRAPH templates: trailing newline, `VARIABLES=x y`, bar pre-computes
  MEAN/MEANCI, line `color.interior`
- `poc_chart` sample data adds DESCRIPTIVES (INPUT PROGRAM produced no output)

## [0.1.0] - 2026-08-04

### Added
- P0 foundation: reuse of the MIT-licensed engine / runner / CLI, 37-tool baseline
- Project renamed to `spss-studio-mcp`, `configure-codex`, CI
  (black / isort / pytest)
