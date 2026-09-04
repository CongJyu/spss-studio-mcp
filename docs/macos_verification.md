# macOS Verification Report (SPSS Statistics 32 for Mac)

> **Language:** [English](macos_verification.md) · [繁體中文（香港）](macos_verification.zh-Hant-HK.md)

> Verified: 2026-09-03
> OS: macOS (Darwin 24.6.0, Apple Silicon)
> SPSS: IBM SPSS Statistics **32.0.0.0 (for Mac)** at
> `/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app`, with the bundled
> Python 3.13.1 (`statisticspython3`)
> Project runtime: Python 3.14 (`examples` venv)

This report records the **real-machine verification** of `spss-studio-mcp` after
its port to macOS. The unit tests run without SPSS; the method / tool / chart
verifications below all ran against a live SPSS 32 for Mac on this machine.

## Results overview

| Item | Result |
|---|---|
| Unit tests (`pytest`) | **109 / 109** passed |
| Reproduction manifest (10 real cases through the full MCP tool chain) | all passed |
| Method verification (`scripts/method_verification.py`) | **26 / 26** passed |
| Tool verification (`scripts/tool_verification.py`) | **11 / 11** passed |
| Chart PNG export (11 chart kinds × real machine) | **11 / 11** passed (1950×1500 @300 dpi, Pillow-validated) |
| Chart TIFF export (11 chart kinds × real machine) | **11 / 11** passed (LZW-compressed) |
| Chart EMF export (11 chart kinds × real machine) | unsupported on macOS (see below) |

Per-case results are archived in `docs/method_verification_macos.json` and
`docs/tool_verification_macos.json` (`docs/method_verification.json` /
`docs/tool_verification.json` keep the Windows baseline — identical case sets,
all passing).

## macOS-specific differences found and fixed during the port

### 1. Engine subprocess lifecycle across event loops
A real SPSS engine is hosted in one `asyncio` subprocess. When tests (or any
multi-loop client) call tools from a fresh event loop per case, the engine was
bound to an already-closed loop yet reported alive, so the next case failed with
`Task ... attached to a different loop`.
**Fix** (`spss_engine.py`): the engine records the loop it started in;
`is_alive()` is `True` only when the subprocess belongs to the current loop, and
the engine is torn down and rebuilt across loops. `stop()` kills a cross-loop
subprocess directly instead of attempting a graceful drain.
Also `tests/test_reproduction_manifest.py` now runs its 10 real cases inside a
single event loop (as a real MCP client would), so the engine boots only once.

### 2. Relative `GET FILE` data paths
The macOS SPSS engine subprocess starts in a different working directory than the
MCP server, so `GET FILE='examples/data/x.sav'` failed with
`The filename is not valid`.
**Fix** (`spss_runner.py`): `data_file` and every `GET FILE='...'` in the syntax
are resolved to absolute paths (against the server cwd, expanding `~`) before
submission. Windows benefits too — behaviour is more robust everywhere.

### 3. Auto-opening the `.spv` viewer
Windows used `os.startfile()` to open the SPSS Viewer.
**Fix** (`spss_runner.py`): on macOS the file is opened with `open`, and this is
off by default unless `SPSS_OPEN_VIEWER=1`, so headless / batch verification
does not pop a GUI per successful analysis.

### 4. EMF (Windows metafile) is not produced on macOS
Real-machine inspection: SPSS 32 for Mac's `OMS FORMAT=DOC` export writes only
`word/media/imageN.eps` into the DOCX, whose content is actually **PNG raster** —
no EMF members at all.
**Decision**: EMF stays a **Windows** feature. When EMF is requested on macOS,
`oms_image.extract_docx_emf` inspects the DOCX after the run and returns a
precise error — "SPSS did not produce vector EMF output on macOS … request PNG
or TIFF instead" — rather than silently degrading. PNG / TIFF are the supported
publication formats on macOS.

## Recommended macOS usage

- Analysis tools (t-test / ANOVA / regression / mediation / moderation /
  survival …): identical to Windows — all available.
- Charts: use `PNG` or `TIFF` (300 dpi, submission-ready); **do not use `EMF`**.
- Data paths: relative or absolute both work (relative paths are resolved to
  absolute automatically).
- Install & configure: `scripts/install_macos.sh` and the "macOS" sections of
  the README / QUICK_START.

See also [method verification](method_verification.md) and the per-case JSON
results referenced there.
