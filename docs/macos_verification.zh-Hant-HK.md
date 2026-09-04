# macOS 真機驗證報告（SPSS Statistics 32 for Mac）

> **語言：** [English](macos_verification.md) · 繁體中文（香港）

> 驗證日期：2026-09-03
> 作業系統：macOS（Darwin 24.6.0，Apple Silicon）
> SPSS：IBM SPSS Statistics **32.0.0.0（for Mac）**，位於
> `/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app`，內建
> Python 3.13.1（`statisticspython3`）
> 專案執行環境：Python 3.14（`.venv`）

本報告記錄 `spss-studio-mcp` 移植至 macOS 後的**真機驗證**結果。單元測試可於
無 SPSS 環境執行；以下方法／工具／圖表驗證均於本機真實 SPSS 32 for Mac 上運行。

## 結果總覽

| 項目 | 結果 |
|---|---|
| 單元測試（`pytest`） | **105 / 105** 通過 |
| Reproduction manifest（10 個真實案例，經完整 MCP 工具鏈） | 全部通過 |
| 方法真機驗證（`scripts/method_verification.py`） | **26 / 26** 通過 |
| 工具真機驗證（`scripts/tool_verification.py`） | **11 / 11** 通過 |
| 圖表 PNG 匯出（11 類圖表 × 真機） | **11 / 11** 通過（1950×1500 @300 dpi，Pillow 驗證） |
| 圖表 TIFF 匯出（11 類圖表 × 真機） | **11 / 11** 通過（LZW 壓縮） |
| 圖表 EMF 匯出 | 已移除——不再提供（見下文） |

逐案例結果已存於 `docs/method_verification_macos.json` 及
`docs/tool_verification_macos.json`。

## 移植期間發現並修正的 macOS 差異

### 1. 引擎子程序跨事件迴圈的生命週期
真實 SPSS 引擎由一個 `asyncio` 子程序承載。當測試（或任何 multi-loop 用戶端）
逐案例以新事件迴圈呼叫工具時，引擎會綁定到已關閉的迴圈卻仍被視為存活，導致下一案例
報 `Task ... attached to a different loop`。
**修正**（`spss_engine.py`）：引擎記錄其啟動所在的事件迴圈；只有當子程序隸屬於
目前迴圈時 `is_alive()` 才回傳 `True`，跨迴圈時會拆解並重建引擎。`stop()` 對
跨迴圈的子程序直接執行 `kill`，不再嘗試優雅關閉。
另外 `tests/test_reproduction_manifest.py` 現於單一事件迴圈內執行 10 個真實案例
（與真實 MCP 用戶端一致），引擎只啟動一次。

### 2. 相對 `GET FILE` 資料路徑
macOS 的 SPSS 引擎子程序啟動時的工作目錄與 MCP 伺服器不同，因此
`GET FILE='examples/data/x.sav'` 會報 `The filename is not valid`。
**修正**（`spss_runner.py`）：`data_file` 及語法內所有 `GET FILE='...'` 於送交前
解析為絕對路徑（以伺服器 cwd 為基準，並展開 `~`）。此舉令相對路徑的處理更穩健。

### 3. 自動開啟 `.spv` 檢視器
在 macOS，以 `open` 指令開啟 `.spv` Viewer，並預設關閉，除非設定
`SPSS_OPEN_VIEWER=1`，以免 headless／批次驗證時每次成功分析都彈出 GUI。

### 4. EMF 輸出已被移除
真機檢查：SPSS 32 for Mac 的 `OMS FORMAT=DOC` 匯出只在 DOCX 內寫入
`word/media/imageN.eps`，其內容實際是 **PNG 點陣圖**——完全沒有 Windows EMF
中繼檔成員，因此 macOS 無法產生 Windows EMF 向量圖表。
**決定**：EMF 匯出已從產品中**移除**；圖表輸出格式僅餘 **PNG 與 TIFF**
（兩者皆為 300 dpi、可直接投稿的出版格式）。相關的 DOCX→EMF 抽取程式碼
（`extract_docx_emf`／`validate_emf`）及其測試亦已刪除。

## 建議的 macOS 使用方式

- 分析工具（t 檢定／ANOVA／迴歸／中介／調節／存活分析……）：全部可用。
- 圖表：使用 `PNG` 或 `TIFF`（300 dpi，可直接投稿）；EMF 輸出已移除。
- 資料路徑：相對或絕對皆可（相對路徑會自動解析為絕對路徑）。
- 安裝與設定：`scripts/install_macos.sh` 及 README／QUICK_START 的安裝章節。

另見 [方法真機驗證](method_verification.zh-Hant-HK.md) 及其所述的逐案例 JSON 結果。
