# P1 PoC: Real-machine verification of the full GGRAPH → chart → PNG pipeline

> **Language:** [English](poc_chart_pipeline.md) · [繁體中文（香港）](poc_chart_pipeline.zh-Hant-HK.md)

> Verification date: 2026-08-04
> Environment: Windows + IBM SPSS Statistics **32.0.0** (`C:\Program Files\IBM\SPSS Statistics\stats.exe`)
> Conclusion: **SPSS 32 has removed `OMS FORMAT=IMAGE` / `IMAGEROOT`**; the charting approach has been changed to "extract the HTML-embedded base64 PNG" + "extract the vector EMF embedded in the DOCX"

---

## 1. Background

The first milestone of P1 was to run the full "GGRAPH → OMS IMAGE → PNG"
pipeline end-to-end and record the real behaviour of the current SPSS version.
The original design relied on `OMS /DESTINATION FORMAT=IMAGE IMAGEROOT=...`
(referencing upstream code and older IBM documentation), which is rejected on
SPSS 32.

## 2. Real-machine verification matrix (SPSS 32.0.0)

| # | Variant | Result |
|---|------|------|
| 1 | `FORMAT=IMAGE IMAGEFORMAT=PNG IMAGEROOT=...` | ✗ `Unknown keyword or subcommand: IMAGE` |
| 2 | `FORMAT=HTML IMAGES=YES IMAGEFORMAT=PNG IMAGEROOT=...` | ✗ `IMAGEROOT` is not recognised |
| 3 | `FORMAT=HTML IMAGES=YES IMAGEFORMAT=PNG OUTFILE=...` | ✓ Produces HTML with charts embedded as base64 PNG |
| 4 | `FORMAT=HTML OUTFILE=...` (minimal variant) | ✓ Same as above (still embeds PNG) |
| 5 | `FORMAT=HTML IMAGES=YES IMAGEFORMAT=TIFF/EMF` | ✓ Syntax accepted, but **still outputs PNG** (HTML ignores IMAGEFORMAT) |
| 6 | `FORMAT=HTML ... IMAGEWIDTH=1950 IMAGEHEIGHT=1500` | ✗ Fatal error (HTML does not accept size keywords) |
| 7 | `FORMAT=DOC OUTFILE=...` (no extension) | ✓ Produces `xxx.docx` (zip); charts are `word/media/imageN.emf` (vector) |
| 8 | `FORMAT=DOC OUTFILE=xxx.doc` | ✓ Produces an RTF `.doc`; charts are PNGs embedded as `\pict\pngblip` |
| 9 | Multiple GGRAPHs in the same OMS block | ✓ One data URI / one EMF member per chart, extracted in order |
| 10 | **boxplot EMF export** | ✗→✓ With the original GGRAPH `ELEMENT: schema` approach, `imageN.emf` in the DOCX was **0 bytes**; since 0.3.1 the template uses the classic `EXAMINE /PLOT BOXPLOT` chart, and the EMF has been verified non-zero on a real machine (about 19 KB); PNG/TIFF are also fine |

### Key facts

- **Naming rule**: `OUTFILE` is used exactly as given (no sequence number, no
  automatic extension added); there is no `IMAGEROOT` concept.
- **Dimensions**: HTML-embedded PNGs are the Viewer default size of about
  799×499 px, with no DPI metadata; the EMF inside the DOCX is a vector chart in
  an 800×500 viewport and can be rasterised at any resolution.
- **Multiple charts**: in HTML, each `<img>` carries one
  `data:image/png;base64,...`; in the DOCX, each chart has one
  `word/media/imageN.emf`.
- **`INPUT PROGRAM` + `EXECUTE` produce no OMS output items**: when submitted on
  their own, OMS TEXT is empty and the run is judged a failure; an output
  command (such as `DESCRIPTIVES`) must be appended after the sample-data block.
- **Q-Q (PPLOT) generates 2 charts at a time** (a Q-Q plot + a detrended Q-Q
  plot); the tool returns all the paths.

## 3. Final approach (SPSS 32)

| Target format | Pipeline |
|----------|------|
| PNG / TIFF | `OMS FORMAT=HTML IMAGES=YES IMAGEFORMAT=PNG OUTFILE='<root>.html'` → extract the base64 with a regex → decode the PNG → scale it with Pillow to the target size (default 1950×1500) and write the 300 dpi metadata (TIFF is converted from PNG, LZW) |
| EMF | `OMS FORMAT=DOC OUTFILE='<root>.docx'` → unzip `word/media/imageN.emf` → deliver the vector EMF as-is (journal line art can be used directly; boxplot excepted, see above) |

### High-DPI notes

- HTML-embedded PNGs are only about 800×500. Two remedies have been tested on a
  real machine:
  1. **Pillow Lanczos upscaling** (current implementation): pure Python, simple,
     with slightly soft text edges;
  2. **Windows GDI+ vector rasterisation** (.NET `System.Drawing` renders the
     EMF; verified to output a sharp 1950×1500 PNG): if strictly paper-ready
     bitmaps are needed later, EMF can go through this path (Windows-only, a
     PowerShell subprocess).

## 4. GPL/syntax issues found and fixed during real-machine verification

The following issues were each exposed on a real SPSS 32 and fixed
(`src/spss_mcp/chart_templates.py`):

| Issue | Symptom | Fix |
|------|------|------|
| No trailing newline at the end of the generated syntax | `END GPL.OMSEND ...` lands on the same line; the OMS block is not closed, the HTML is not written to disk, and tag-cascade conflicts occur | Append `\n` after every generated command; normalise at the concatenation points |
| Multi-variable GRAPHDATASET repeats keywords | `VARIABLES=x VARIABLES=y` → `repeated keyword (VARIABLES)` | Changed to `VARIABLES=x y` |
| bar uses inline `summary.mean(val)` | `position(cat*summary.mean(val))` → GPL error | Precompute `MEAN(var)[name="MEAN_var"]` in GRAPHDATASET; `position(cat*agg)` |
| line uses `color.exterior` | Not accepted by the line element | Changed to `color.interior` |
| Pie chart `shape.pie` | `shape.pie` is undefined in SPSS 32 GPL | P1 does not provide a pie-chart tool; falling back to `GRAPH /PIE` can be a future extension |

## 5. Chart library (11 `spss_chart_*` tools; all verified on a real machine on 2026-08-04)

| Tool | Type | Implementation |
|------|------|------|
| `spss_chart_histogram` | Histogram | GGRAPH `summary.count(bin.rect())` |
| `spss_chart_scatter` | Scatter | GGRAPH `point(position(x*y))` |
| `spss_chart_bar` | Bar (mean / sum) | GGRAPH precomputes `MEAN/SUM(var)[name=...]` |
| `spss_chart_line` | Line | GGRAPH `line(position(x*y))` |
| `spss_chart_boxplot` | Boxplot | GGRAPH `schema(position(cat*var))` |
| `spss_chart_errorbar` | Error bar (mean ± CI) | GGRAPH precomputes `MEANCI(var pct)[name=...]` |
| `spss_chart_qqplot` | Normal Q-Q plot | `PPLOT /TYPE=Q-Q /FRACTION=BLOM` |
| `spss_chart_km_curve` | KM survival curve | `KM time BY group /STATUS=... /PLOT SURVIVAL` |
| `spss_chart_area` | Area | GGRAPH `area(position(x*y))` |
| `spss_chart_histogram_density` | Histogram + normal density | GGRAPH `interval` + `line(density.normal())` |
| `spss_chart_bar_error` | Bar + error bar | GGRAPH precomputes `MEANCI` + bar element |

## 6. Reproduction

```powershell
cd D:\opencode\spss-studio-mcp
python scripts/poc_chart_pipeline.py    # engine startup ~15–20 s + two variants
python -m spss_mcp.poc_chart --format PNG   # 11 chart kinds × PNG
python -m spss_mcp.poc_chart --format EMF   # 11 chart kinds × EMF (boxplot is expected to error, prompting a fallback)
```

Outputs (default `%TEMP%\spss-studio-mcp\results`):
- `poc_histogram_001.png` (1950×1500 @300 dpi, upscaled from about 800×500)
- `poc_histogram_emf_001.emf` (vector)

## 7. Impact on the code

- `src/spss_mcp/oms_image.py`: `build_oms_image_block` now generates an HTML OMS
  block; adds `build_oms_doc_block` / `extract_html_images` /
  `extract_docx_emf` / `validate_emf` / `oms_doc_end_block`.
- `src/spss_mcp/chart_service.py`: `export_chart` selects the HTML or DOC
  pipeline by format; PNG/TIFF go through upscaling + DPI post-processing.
- `src/spss_mcp/chart_spec.py`: 11 ChartSpec models.
- `src/spss_mcp/chart_templates.py`: 11 template builders (GGRAPH / PPLOT / KM).
- `src/spss_mcp/server.py`: registers the 11 `spss_chart_*` tools.
