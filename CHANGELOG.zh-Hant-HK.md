# 更新日誌

> **語言：** [English](CHANGELOG.md) · 繁體中文（香港）

## [0.4.0] - 2026-09-04

### 新增
- **macOS 移植**：已在真實 SPSS Statistics 32 for Mac 上真機驗證
  - 方法真機驗證 **26/26**、工具真機驗證 **11/11**，與 Windows 基線完全對齊
  - 圖表（11 類）PNG / TIFF **11/11** 通過（1950×1500 @300 dpi）；逐條結果見
    `docs/method_verification_macos.json`、`docs/tool_verification_macos.json`
    及 `docs/macos_verification.md`
- 一鍵安裝程式 `scripts/install_macos.sh`（建立 venv、安裝依賴、執行 `configure-claude`）
- `pyproject.toml` 加入 `Operating System :: MacOS :: MacOS X` 分類器

### 變更
- 引擎子程序改為跨事件迴圈安全：`spss_engine.py` 記錄其啟動所在的 loop，
  `is_alive()` 只有在同一 loop 先回傳 `True`，跨 loop 會自動重建 —— 修正
  測試／multi-loop 用戶端出現的 `Task attached to a different loop`
- 相對資料路徑（`data_file` 及語法內 `GET FILE=`）在送交引擎前解析為絕對路徑
  （`spss_runner.py`）—— 修正因 macOS 引擎工作目錄不同而導致的
  `The filename is not valid`
- 在 macOS 開啟 `.spv` 檢視器改用 `open`，除非設 `SPSS_OPEN_VIEWER=1` 否則預設關閉
- `server.py` 換行符由舊式 CR 規範為 LF
- 使用者可見的工具輸出本地化為英文：摘要以 `### Statistical Summary` 標題附加，
  `spss_mediation` / `spss_moderation` 報告亦為英文

### 備註
- 文件以**英文**（主版，沿用現有檔名）及**繁體中文（香港）**（鏡像，檔名以
  `*.zh-Hant-HK.md` 命名）兩種語文維護；兩者含義完全一致。
- SPSS Statistics for Mac 不會產生 Windows EMF 向量圖表（其
  `OMS FORMAT=DOC` 封存內是 PNG 點陣）；在 macOS 請用 PNG / TIFF。EMF 僅在
  Windows 可用；在 macOS 請求 EMF 會收到明確錯誤。

## [0.3.1] - 2026-08-05

### 修正
- `spss_chart_boxplot`：GGRAPH `ELEMENT: schema` 模板在 SPSS 32 以真實資料執行時
  報 `outlier was found inside fences`（有個案值正好在箱鬚線上），且匯出 0 位元組
  DOCX/EMF；改用經典 `EXAMINE /PLOT BOXPLOT` 模板。PNG / TIFF / EMF 均已在
  真機驗證（EMF 18996 位元組、非零）。由功課驗證觸發；見項目規劃 §5.3。

## [0.3.0] - 2026-08-05

### 新增
- P3 方法驗證：26 個分析方法真機驗收 + `scripts/method_verification.py`
- 中介／調節工具：`spss_mediation`（三步迴歸 + Sobel）、`spss_moderation`（中心化交互）
- P4 安全層：`security.py`（危險指令攔截／路徑白名單／`dry_run`／JSONL 審計）
- 補充工具驗收：6 個檔案工具 + 狀態／語法／結構化 + `spss_genlin`
  （`scripts/tool_verification.py`）
- 全部 11 類圖 × TIFF 全格式驗證
- 文件：教學、技術報告、生態收錄／發佈準備

### 修正
- `spss_correlations`：`TAILS(2)` → `TWOTAIL`
- `spss_compute_scale_score`：`MEAN`／`NVALID` 參數以逗號分隔
- `spss_twostep_cluster`：子指令移除 `=`、距離預設 LIKELIHOOD、刪去無效 OUTLIERS/PRINT
- `spss_discriminant`／`spss_manova`：因子／組值範圍；MANOVA 刪去已棄用的 METHOD 子指令
- `spss_ordinal_regression`：刪去無效的 `TEST=PARALLEL`
- `spss_genlinmixed`：subject 名義化、刪去無效 PRINT
- `spss_genlin`：`DISTRIBUTION` 併入 MODEL，PRINT 無 `=`

## [0.2.0] - 2026-08-04

### 新增
- P1 圖表管線：11 類圖表 spec + GGRAPH 模板 + `spss_chart_*` 工具
- OMS 匯出雙管道：HTML → base64 PNG 抽取、DOCX → EMF 抽取（SPSS 32 相容）
- 圖片後處理：Pillow 縮放至 1950×1500 + 300 dpi 中繼資料
- P2 結果剖析：`result_parser.py`（表格 JSON + 16 類統計摘要）
- `spss_structured_result` 統一回傳結構
- 範例資料與歸檔：`examples/`（問卷／實驗／存活／中介／縱向）

### 修正
- GGRAPH 模板：結尾換行、`VARIABLES=x y`、bar 預先計算 MEAN/MEANCI、line `color.interior`
- `poc_chart` 範例資料補 DESCRIPTIVES（INPUT PROGRAM 無輸出的問題）

## [0.1.0] - 2026-08-04

### 新增
- P0 基礎：沿用 MIT 授權的引擎／runner／CLI，37 工具基線
- 項目改名為 `spss-studio-mcp`、`configure-codex`、CI（black / isort / pytest）
