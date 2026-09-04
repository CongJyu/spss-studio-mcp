# SPSS Studio MCP：論文級圖表匯出、深度結果剖析與安全執行的研究助手

> **語言：** [English](technical_report.md) · 繁體中文（香港）

> 技術報告 ｜ 2026-08-05 ｜ 實測環境：Windows + IBM SPSS Statistics 32.0.0

## 摘要

SPSS 是心理學、管理學與社會科學研究中事實上的標準統計軟件，但現有 MCP
（Model Context Protocol）生態只提供「把語法交給 SPSS、回傳文字表格」的薄封裝：
論文級圖片需在 Viewer 中手動匯出、結果只能閱讀而不能以結構化方式使用、LLM
產生的語法缺乏安全護欄。本報告介紹 **SPSS Studio MCP**——一個面向 SPSS 的 MCP
伺服器，以四個互補層填補上述缺口：（1）**論文級出圖管線**，一鍵將 11 類圖表匯出
為 PNG/TIFF/EMF（300 dpi）；（2）**深度結果剖析**，把 OMS 文字轉為 Markdown +
JSON 表格，並為 16 類分析產生統計摘要；（3）**方法真機驗證**，37 個工具在真實
SPSS 上逐方法驗收，並發現與修復 7+1 處版本相容問題；（4）**安全執行層**，攔截
危險陳述、設定資料路徑白名單、提供 `dry_run` 與審計日誌。全部能力已在 SPSS 32
真機驗證通過。

## 1 背景與問題

### 1.1 SPSS MCP 生態的四個缺口

對現有 SPSS MCP 項目（參考 `Exekiel179/SPSS-MCP`，MIT）的原始碼覆核顯示：

| 缺口 | 現況 |
|------|------|
| G1 缺少論文級出圖 | 只有 `OMS FORMAT=SPV` 把圖表鎖在二進位 .spv 內；整個程式庫沒有 OMS IMAGE/GGRAPH |
| G2 結果剖析過淺 | 只有文字→Markdown 表格，沒有 JSON、沒有統計摘要 |
| G3 方法程式碼正確性未經驗證 | 37 個工具已實作，但從未以真機樣例驗證 |
| G4 語法安全層薄弱 | 只有語法校驗，沒有白名單／攔截／dry_run／審計 |

### 1.2 動機

對沒有多模態能力的純文字 LLM 而言，數值統計可用 Python 完成，但**論文級圖片無法
靠它自行走完全程**——SPSS 的確定性渲染（語法一給便出圖，且具期刊級字型／DPI）
才是無可替代的價值。本項目把「統計引擎 + 製圖工廠」做成可交付的成果，並令結果
可供機器使用。

## 2 系統設計

```
用戶端 (Codex / Claude / Cursor)
        │  MCP stdio
        ▼
工具層   37+ 分析方法 + 11 圖表 + 中介/調節 + 結構化結果
        ▼
引擎層   SPSS Python3 XD API 持久會話 (spss.StartSPSS / spss.Submit)
        ▼
輸出層   OMS TEXT (表格) / HTML (PNG) / DOCX (EMF) + 安全閘 + 審計
```

- **持久引擎**：以單一常駐的 SPSS Python3 子程序，省去每次呼叫 15–20 秒的啟動開銷。
- **模板化語法**：所有出圖與分析都走預先定義的模板（以 Pydantic 校驗），LLM 不能
  自由產生 GPL／語法。
- **統一回傳**：`{markdown, json, files, warnings}`。

## 3 關鍵實作與版本相容性發現

### 3.1 SPSS 32 移除 `OMS FORMAT=IMAGE`（重要發現）

規劃階段依賴舊版 `OMS /DESTINATION FORMAT=IMAGE IMAGEROOT=...`，在 SPSS 32 真機上
被拒絕（`Unknown keyword or subcommand: IMAGE`）。實測矩陣（節選）：

| 變體 | SPSS 32 結果 |
|------|-------------|
| `FORMAT=IMAGE ... IMAGEROOT=...` | ✗ 不支援 |
| `FORMAT=HTML IMAGES=YES OUTFILE=...` | ✓ 圖表以 base64 PNG 內嵌 |
| `FORMAT=DOC OUTFILE=...` | ✓ 產生 .docx，圖表為向量 EMF |
| `FORMAT=HTML IMAGEWIDTH/HEIGHT` | ✗ 致命錯誤 |

**落定方案**：PNG／TIFF 走 HTML → base64 抽取 → Pillow 後處理（1950×1500 @300 dpi，
TIFF 以 LZW 壓縮）；EMF 走 DOCX → zip 抽取向量 EMF。boxplot 的 EMF 是 SPSS 32 自身
的 0 位元組缺陷（PNG／TIFF 正常），已在 0.3.1 藉改用 `EXAMINE /PLOT BOXPLOT` 傳統
圖模板根治（見第 4 節驗證）。

### 3.2 結果剖析：由文字到統計摘要

`result_parser.py` 以逐行掃描的狀態機切分 SPSS 表塊（處理 Notes 略過、多行表頭、
以單空格黏連的儲存格、`(a)` 腳註、`.000`→`<.001`），並為 16 類分析抽取關鍵統計量：

t 檢定（獨立／配對）、單因素／多因素 ANOVA（含 Levene、偏 η²）、相關、線性／
Logistic／序數迴歸、頻數、卡方、Cronbach's α、無母數檢定
（Mann-Whitney／Wilcoxon／Kruskal-Wallis）、Shapiro-Wilk 常態性、因子分析
（KMO／Bartlett／累計變異）、描述性統計。

### 3.3 由方法真機驗證驅動的修復

26 個分析方法用例在真實 SPSS 32 上驗收，暴露並修復 8 處模板問題：`TAILS(2)→TWOTAIL`、
`MEAN` 參數的逗號分隔、TWOSTEP 子指令的 `=` 與距離取值、判別分析／MANOVA 的因子值
範圍、已棄用的 METHOD 子指令、PLUM `TEST=PARALLEL`、GENLINMIXED subject 名義化、
GENLIN `DISTRIBUTION` 併入 MODEL 等。

### 3.4 安全層

`security.py`：以行首匹配攔截危險指令（`HOST`／`ERASE`／`DELETE FILE` 等）、資料檔案
路徑白名單（`SPSS_ALLOWED_DIRS`）、`dry_run`、JSONL 審計日誌——全部統一經
`run_syntax` 接入，覆蓋所有工具。

## 4 真機驗證結果

| 類別 | 結果 |
|------|------|
| 分析方法 | 26/26 通過 |
| 補充工具（檔案／狀態／語法／結構化／genlin） | 11/11 通過 |
| 圖表 × PNG/EMF/TIFF | 11 類全格式通過（0.3.1 修復 boxplot EMF：`EXAMINE` 模板，EMF 約 19 KB 非零） |
| 中介／調節 | 真機通過（Sobel z=6.75, p<.001；交互 p=.639） |
| 單元測試 | 109 個全部通過（含真機重現清單，附自包含樣例資料） |

樣例資料與歸檔圖表：`examples/`（問卷／實驗／存活／中介／縱向）。

## 5 討論與局限

- HTML 內嵌 PNG 固定約 800×500，故 300 dpi 出圖需放大並重新標示 DPI；若要把向量圖
  做成嚴格的高解像點陣圖，可行 EMF + GDI+ 渲染（已驗證，僅限 Windows，留待後續）。
- 中介／調節以三步迴歸實作，並附 Sobel 檢驗；嚴謹報告建議以 PROCESS 的 Bootstrap
  覆核。
- 生態收錄（LobeHub／PulseMCP）與正式 Release 均屬發佈帳號的操作，見
  `docs/ecosystem.md`。

## 6 結論

SPSS Studio MCP 證明了「統計引擎 + 製圖工廠 + 結構化消費 + 安全護欄」的組合可在
真實 SPSS 32 上落地：37 個工具全部真機驗收、論文級圖片自動化、16 類結果摘要、
執行安全審計。項目文件齊備（出圖 PoC、結果剖析、方法驗證、安全），為心理／管理
／社科研究的 agent 工作流提供了可重用的 MCP 服務。

## 附錄：復現

```powershell
pip install -e ".[dev]"
python scripts/make_sample_data.py
python scripts/method_verification.py    # 26 個方法
python scripts/tool_verification.py      # 11 個工具
python -m spss_mcp.poc_chart --format PNG|EMF|TIFF
python scripts/archive_sample_charts.py  # 歸檔 11 張樣例圖
```
