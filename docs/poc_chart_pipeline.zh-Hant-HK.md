# P1 PoC：GGRAPH → 圖表 → PNG 全鏈路真機驗證

> **語言：** [English](poc_chart_pipeline.md) · 繁體中文（香港）

> 驗證日期：2026-08-04
> 環境：Windows + IBM SPSS Statistics **32.0.0**（`C:\Program Files\IBM\SPSS Statistics\stats.exe`）
> 結論：**SPSS 32 已移除 `OMS FORMAT=IMAGE` / `IMAGEROOT`**，出圖方案改為「抽取 HTML 內嵌的 base64 PNG」+「抽取 DOCX 內嵌的向量 EMF」

---

## 1. 背景

P1 的第一個里程碑是跑通「GGRAPH → OMS IMAGE → PNG」的整條管線，並記錄目前 SPSS
版本的真實行為。原設計依賴 `OMS /DESTINATION FORMAT=IMAGE IMAGEROOT=...`（參考
上游程式碼及舊版 IBM 文件），在 SPSS 32 上被拒絕。

## 2. 真機驗證矩陣（SPSS 32.0.0）

| # | 變體 | 結果 |
|---|------|------|
| 1 | `FORMAT=IMAGE IMAGEFORMAT=PNG IMAGEROOT=...` | ✗ `Unknown keyword or subcommand: IMAGE` |
| 2 | `FORMAT=HTML IMAGES=YES IMAGEFORMAT=PNG IMAGEROOT=...` | ✗ `IMAGEROOT` 不被辨識 |
| 3 | `FORMAT=HTML IMAGES=YES IMAGEFORMAT=PNG OUTFILE=...` | ✓ 產生 HTML，圖表以 base64 PNG 內嵌 |
| 4 | `FORMAT=HTML OUTFILE=...`（最精簡變體） | ✓ 同上（仍然內嵌 PNG） |
| 5 | `FORMAT=HTML IMAGES=YES IMAGEFORMAT=TIFF/EMF` | ✓ 語法接受，但**仍然輸出 PNG**（HTML 忽略 IMAGEFORMAT） |
| 6 | `FORMAT=HTML ... IMAGEWIDTH=1950 IMAGEHEIGHT=1500` | ✗ 致命錯誤（HTML 不接受尺寸關鍵字） |
| 7 | `FORMAT=DOC OUTFILE=...`（無副檔名） | ✓ 產生 `xxx.docx`（zip），圖表為 `word/media/imageN.emf`（向量） |
| 8 | `FORMAT=DOC OUTFILE=xxx.doc` | ✓ 產生 RTF `.doc`，圖表為 `\pict\pngblip` 內嵌的 PNG |
| 9 | 同一 OMS 區塊內多個 GGRAPH | ✓ 每個圖表一個 data URI／一個 EMF 成員，依序抽取 |
| 10 | **boxplot EMF 匯出** | ✗→✓ 原本 GGRAPH `ELEMENT: schema` 的做法在 DOCX 內 `imageN.emf` 為 **0 位元組**；0.3.1 起模板改用經典 `EXAMINE /PLOT BOXPLOT` 圖，EMF 已在真機驗證為非零（約 19 KB），PNG/TIFF 亦正常 |

### 關鍵事實

- **命名規則**：`OUTFILE` 原樣使用（不加編號、不自動補副檔名）；不存在 `IMAGEROOT`
  概念。
- **尺寸**：HTML 內嵌 PNG 為 Viewer 預設尺寸約 799×499 px，沒有 DPI 中繼資料；
  DOCX 內的 EMF 是 800×500 視框的向量圖，可以任何解像度柵格化。
- **多圖表**：在 HTML 中，每個 `<img>` 一個 `data:image/png;base64,...`；在 DOCX 中，
  每個圖表一個 `word/media/imageN.emf`。
- **`INPUT PROGRAM` + `EXECUTE` 不產生任何 OMS 輸出項**：單獨提交時 OMS TEXT 為空，
  會被判定為失敗；需在樣例資料區塊之後補一個輸出指令（例如 `DESCRIPTIVES`）。
- **Q-Q（PPLOT）一次產生 2 張圖**（Q-Q 圖 + 去趨勢 Q-Q 圖），工具會回傳全部路徑。

## 3. 落定方案（SPSS 32）

| 目標格式 | 管線 |
|----------|------|
| PNG / TIFF | `OMS FORMAT=HTML IMAGES=YES IMAGEFORMAT=PNG OUTFILE='<root>.html'` → 用正規表達式抽取 base64 → 解碼 PNG → 用 Pillow 縮放至目標尺寸（預設 1950×1500）並寫入 300 dpi 中繼資料（TIFF 由 PNG 轉換，LZW） |
| EMF | `OMS FORMAT=DOC OUTFILE='<root>.docx'` → 解壓 `word/media/imageN.emf` → 原樣交付向量 EMF（期刊線稿可直接使用；boxplot 除外，見上） |

### 高 DPI 說明

- HTML 內嵌 PNG 只有約 800×500。已實測兩種補救方法：
  1. **Pillow Lanczos 放大**（目前實作）：純 Python，簡單，文字邊緣略軟；
  2. **Windows GDI+ 向量柵格化**（以 .NET `System.Drawing` 渲染 EMF，已實測可輸出
     1950×1500 的銳利 PNG）：日後若需要嚴格的論文級點陣圖，可讓 EMF 走此路徑
     （僅限 Windows，PowerShell 子程序）。

## 4. 真機驗證中發現並修復的 GPL／語法問題

以下問題均在真實 SPSS 32 上逐一暴露並已修復（`src/spss_mcp/chart_templates.py`）：

| 問題 | 現象 | 修復 |
|------|------|------|
| 生成的語法末尾沒有換行 | `END GPL.OMSEND ...` 落在同一行；OMS 區塊未關閉、HTML 未寫入磁碟、tag 級聯衝突 | 每個指令生成後補 `\n`；在拼接處正規化 |
| 多變數 GRAPHDATASET 重複關鍵字 | `VARIABLES=x VARIABLES=y` → `repeated keyword (VARIABLES)` | 改為 `VARIABLES=x y` |
| bar 內聯 `summary.mean(val)` | `position(cat*summary.mean(val))` → GPL error | 在 GRAPHDATASET 預先計算 `MEAN(var)[name="MEAN_var"]`；`position(cat*agg)` |
| line 使用 `color.exterior` | line 元素不接受 | 改為 `color.interior` |
| 餅圖 `shape.pie` | SPSS 32 GPL 未定義 `shape.pie` | P1 不提供餅圖工具；改用 `GRAPH /PIE` 可作為日後擴充 |

## 5. 圖表庫（11 個 `spss_chart_*` 工具，2026-08-04 真機全部出圖驗證）

| 工具 | 類型 | 實作 |
|------|------|------|
| `spss_chart_histogram` | 直方圖 | GGRAPH `summary.count(bin.rect())` |
| `spss_chart_scatter` | 散點圖 | GGRAPH `point(position(x*y))` |
| `spss_chart_bar` | 長條圖（平均值／總和） | GGRAPH 預先計算 `MEAN/SUM(var)[name=...]` |
| `spss_chart_line` | 折線圖 | GGRAPH `line(position(x*y))` |
| `spss_chart_boxplot` | 箱線圖 | GGRAPH `schema(position(cat*var))` |
| `spss_chart_errorbar` | 誤差條（平均值 ± CI） | GGRAPH 預先計算 `MEANCI(var pct)[name=...]` |
| `spss_chart_qqplot` | 常態 Q-Q 圖 | `PPLOT /TYPE=Q-Q /FRACTION=BLOM` |
| `spss_chart_km_curve` | KM 存活曲線 | `KM time BY group /STATUS=... /PLOT SURVIVAL` |
| `spss_chart_area` | 面積圖 | GGRAPH `area(position(x*y))` |
| `spss_chart_histogram_density` | 直方圖 + 常態密度 | GGRAPH `interval` + `line(density.normal())` |
| `spss_chart_bar_error` | 長條圖 + 誤差條 | GGRAPH 預先計算 `MEANCI` + 柱形元素 |

## 6. 復現

```powershell
cd D:\opencode\spss-studio-mcp
python scripts/poc_chart_pipeline.py    # 引擎啟動約 15-20 秒 + 兩個變體
python -m spss_mcp.poc_chart --format PNG   # 11 種圖表 × PNG
python -m spss_mcp.poc_chart --format EMF   # 11 種圖表 × EMF（boxplot 預計報錯並提示降級）
```

產物（預設 `%TEMP%\spss-studio-mcp\results`）：
- `poc_histogram_001.png`（1950×1500 @300 dpi，由約 800×500 放大）
- `poc_histogram_emf_001.emf`（向量）

## 7. 對程式碼的影響

- `src/spss_mcp/oms_image.py`：`build_oms_image_block` 改為產生 HTML OMS 區塊；新增
  `build_oms_doc_block`／`extract_html_images`／`extract_docx_emf`／`validate_emf`／
  `oms_doc_end_block`。
- `src/spss_mcp/chart_service.py`：`export_chart` 按格式選擇 HTML 或 DOC 管線；
  PNG/TIFF 走放大 + DPI 後處理。
- `src/spss_mcp/chart_spec.py`：11 種 ChartSpec 模型。
- `src/spss_mcp/chart_templates.py`：11 個模板建構器（GGRAPH／PPLOT／KM）。
- `src/spss_mcp/server.py`：註冊 11 個 `spss_chart_*` 工具。
