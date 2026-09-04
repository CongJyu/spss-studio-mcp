# SPSS Studio MCP：給 Agent 的簡易使用教學

> **語言：** [English](tutorial.md) · 繁體中文（香港）

> 把 SPSS 變成 Agent 可以呼叫的統計引擎與製圖工廠。
>
> 適用版本：v0.3+ ｜ 建議環境：Windows 10/11、Python 3.10+、IBM SPSS Statistics 20–32

這篇教學專為第一次接觸 MCP、SPSS-MCP 或 Agent 工作流程的用戶而寫。你不需要先學會 MCP，也不需要記住工具名稱。完成安裝之後，直接用自然語言告訴 Agent：資料在哪裡、你想回答甚麼問題、以及希望得到甚麼結果。

## 1. 先了解它能做甚麼

傳統流程通常是：開啟 SPSS → 匯入資料 → 尋找功能表 → 設定參數 → 執行 → 整理表格 → 匯出圖片 → 撰寫結果。

SPSS Studio MCP 把當中的大量重複操作交給 Agent：

- Agent 讀取 `.sav` / `.zsav` 資料，檢查變數、標籤、缺失值與樣本數；
- Agent 會按照研究問題，選擇描述統計、t 檢定、變異數分析、迴歸、中介、調節、存活分析等方法；
- MCP 呼叫真實的 IBM SPSS Statistics 引擎執行分析，而不是只靠語言模型猜測結果；
- 傳回 Markdown 表格、結構化 JSON、統計摘要、`.sps` 語法與 `.spv` Viewer 檔案；
- 可按需要匯出 PNG、TIFF 或 EMF 格式、300 dpi 的圖表；
- 對危險語法、資料目錄與執行過程進行安全檢查，並寫入稽核日誌。

它適合論文分析、問卷研究、實驗資料、醫學追蹤、課堂作業、研究助理工作，以及需要重複執行的統計流程。

## 2. 最快方式：把這段文字傳給你的 Agent

以下這段可以直接複製給 Codex、Claude Code 或其他支援 MCP 的 Agent。建議清楚說明專案目錄、資料目錄，以及你目前使用的用戶端。

```text
請幫我安裝並設定 SPSS Studio MCP，讓你可以直接呼叫 IBM SPSS Statistics 進行統計分析與論文級出圖。

專案網址：
https://github.com/flupke91/spss-studio-mcp

請依照以下順序執行，不要跳過任何檢查：

1. 檢查目前系統是否已安裝 Python 3.10 或以上版本、pip，以及 IBM SPSS Statistics。
2. 如果目前目錄沒有這個專案，請先複製（clone）專案；如果專案已經存在，請進入專案目錄，並檢查是否為最新的可用程式碼。
3. 安裝專案依賴：pip install -e ".[dev]"。
4. 執行 spss-studio-mcp status，並告訴我 pyreadstat、pandas 與 SPSS batch 的狀態。
5. 根據我目前使用的 Agent 自動設定 MCP：
   - 如果是 Codex，執行 spss-studio-mcp configure-codex；
   - 如果是 Claude Code，執行 spss-studio-mcp configure-claude；
   - 如果用戶端不支援自動設定，執行 spss-studio-mcp setup-info，並提供手動設定片段。
6. 檢查設定檔是否成功寫入；如果修改了設定，請提示我重新啟動 Agent。
7. 安裝專案自帶的 skills（如果目前專案包含 skills 目錄），並說明安裝位置。
8. 重新啟動後，用 examples/data/survey_study.sav 做一次最小測試：讀取變數、執行描述統計與 Cronbach's alpha 信度分析。
9. 最後告訴我：安裝是否成功、可以呼叫哪些工具、範例結果檔案在哪裡，以及我下一步可以怎樣用自然語言提出分析需求。

遇到錯誤時，請先判斷是 Python、依賴、SPSS 路徑、授權、MCP 設定還是資料路徑的問題，再給出最小的修復方案。不要刪除我的資料，也不要修改原始資料檔案。
```

如果 Agent 沒有權限執行命令，就讓它逐條解釋命令，你在終端機執行後把輸出貼回去。Agent 可以根據輸出繼續完成設定與疑難排解。

## 3. 手動安裝：一步一步照做

### 3.1 檢查環境

在 PowerShell 中執行：

```powershell
python --version
pip --version
```

Python 應為 3.10 或以上版本。然後確認 IBM SPSS Statistics 已經安裝而且授權可用。SPSS Studio MCP 的檔案讀取工具可以在沒有 SPSS 引擎的情況下運作，但真正的統計分析與圖表匯出需要 SPSS。

### 3.2 取得專案並安裝

```powershell
git clone https://github.com/flupke91/spss-studio-mcp.git
cd spss-studio-mcp
pip install -e ".[dev]"
```

如果專案已經在本機，直接進入專案目錄再執行安裝指令即可。開發依賴包含測試與格式化工具；如果只想執行服務，也可以使用 `pip install -e .`。

### 3.3 檢查 SPSS 狀態

```powershell
spss-studio-mcp status
```

正常情況下會看到類似以下的結果：

```text
=== SPSS MCP Capability Status ===
pyreadstat : OK v...
pandas     : OK v...
SPSS batch : OK - C:\Program Files\IBM\SPSS Statistics\32\stats.exe
```

如果顯示 `SPSS batch : NOT FOUND`，先不要急著重裝依賴。請按照第 8 節設定 `SPSS_INSTALL_PATH`，再重新執行 `status`。

### 3.4 自動設定 Codex

如果你使用 Codex：

```powershell
spss-studio-mcp configure-codex
```

指令會更新 Codex 的 `~/.codex/config.toml`，並在修改現有檔案之前建立備份。執行完成後重新啟動 Codex，讓它重新載入 MCP 伺服器。

### 3.5 自動設定 Claude Code

如果你使用 Claude Code：

```powershell
spss-studio-mcp configure-claude
```

指令會更新 Claude Code 的用戶設定，並在需要時產生備份。執行完成後重新啟動 Claude Code。

### 3.6 手動設定其他用戶端

先產生設定提示：

```powershell
spss-studio-mcp setup-info
```

常見的 MCP 設定形式如下：

```json
{
  "mcpServers": {
    "spss": {
      "command": "spss-studio-mcp",
      "args": ["serve", "--transport", "stdio"]
    }
  }
}
```

不同用戶端的設定檔位置與欄位名稱可能不同，以用戶端文件與 `setup-info` 的輸出為準。設定完成後必須重新啟動用戶端，否則它可能仍然看不到新的工具。

## 4. 第一次驗證：讓 Agent 執行一個最小任務

重新啟動用戶端後，先不要直接拿自己的論文資料測試。請把以下這段傳給 Agent：

```text
請先呼叫 spss_check_status，告訴我目前有哪些功能可以使用。
然後檢查 examples/data/survey_study.sav：
1. 列出變數名稱、變數標籤、變數類型與缺失值資料；
2. 預覽前 10 列資料；
3. 對 engagement_total 計算平均值、標準差、最小值、最大值與樣本數；
4. 對 q1 至 q12 執行 Cronbach's alpha 信度分析；
5. 不要修改原始資料，只傳回分析結果與所產生檔案的路徑。
```

你應該會得到：

- 資料檔案與變數資料；
- 描述統計表；
- 信度統計結果；
- 自動產生的統計摘要；
- 需要時附上 `.sps` 與 `.spv` 檔案路徑。

如果這一步成功，代表 Agent 已經可以發現 MCP 工具並呼叫 SPSS Studio MCP。

## 5. 向 Agent 下達指令的正確方式

不要只說「幫我分析一下」。一個高品質的請求至少包含五項：

1. **資料檔案**：明確的 `.sav` 檔案路徑；
2. **研究問題**：你想比較、預測、解釋或描述甚麼；
3. **變數角色**：依變數、自變數、分組變數、中介變數、調節變數；
4. **分析要求**：是否需要前提檢驗、效應量、事後比較與視覺化；
5. **交付格式**：論文結果段落、Markdown 表格、語法檔案、圖片或結構化 JSON。

可以重複使用這個通用模板：

```text
請分析 [資料檔案路徑]。

研究問題：[用一句話說明想回答的問題]
依變數：[變數名稱與含義]
自變數或分組變數：[變數名稱與含義]
其他變數：[共變量 / 中介 / 調節 / 時間 / 受試者 ID]

請依照以下流程執行：
1. 先檢查樣本數、變數類型、缺失值、離群值與必要的前提假設；
2. 如果我選用的統計方法不適合，請解釋原因並選擇更合適的方法；
3. 執行分析並報告關鍵統計量、p 值、信賴區間與效應量；
4. 提供適合寫入論文結果部分的解釋，但不要把相關關係寫成因果關係；
5. 儲存可重現的 SPSS syntax，並保持原始資料不變；
6. 如果適合，請產生論文級圖片，並告訴我圖片路徑與格式。
```

## 6. 常見研究場景

### 6.1 問卷：描述統計、信度與組間差異

```text
請分析 examples/data/survey_study.sav。
先檢查樣本數、變數標籤、缺失值與 q1-q12 的數值範圍。
然後完成：
1. 對 q1-q12 執行 Cronbach's alpha 信度分析；
2. 對 engagement_total 執行描述統計與常態性檢驗；
3. 按 gender 比較 engagement_total，先判斷使用獨立樣本 t 檢定是否合適；
4. 按 major 比較 engagement_total，使用單因子變異數分析，並在需要時做事後比較；
5. 繪製 engagement_total 的直方圖與 Q-Q 圖；
6. 輸出表格、統計摘要、論文結果段落、SPSS syntax 與圖片路徑。
```

### 6.2 實驗：前測後測與組間比較

```text
請分析 examples/data/experiment_study.sav。
變數為 group、pretest、posttest 與 gain。
請先檢查 group 的編碼與每組樣本數，然後：
1. 報告兩組 pretest 與 posttest 的描述統計；
2. 比較兩組的 posttest 是否有差異；
3. 比較兩組的 gain 是否有差異；
4. 對同一批受試者的 pretest 與 posttest 執行配對樣本 t 檢定；
5. 報告平均差異、95% CI、t、df、p 與效應量；
6. 產生按 group 分組的 posttest 箱形圖；
7. 撰寫審慎、適合寫入論文的結果解釋。
```

### 6.3 相關與迴歸：避免把相關寫成因果

```text
請對 examples/data/mediation_study.sav 執行相關與迴歸分析。
研究問題是 autonomy、satisfaction 與 performance 之間的關係。
請先檢查變數分布與離群值，然後完成：
1. Pearson 相關矩陣；
2. 以 performance 為依變數、autonomy 與 satisfaction 為預測變數的多元線性迴歸；
3. 報告 R²、調整後 R²、模型檢定、標準化係數、信賴區間與共線性診斷；
4. 繪製 satisfaction 與 performance 的散點圖；
5. 用「相關」與「預測」來表述結果，不要直接宣稱存在因果關係。
```

### 6.4 中介分析

```text
請對 examples/data/mediation_study.sav 執行中介分析：
X = autonomy，M = satisfaction，Y = performance。

請先檢查三個變數的樣本數、缺失值與基本分布，再呼叫合適的中介分析工具。
報告總效應、直接效應、間接效應 a×b、Sobel 檢定與每一步的迴歸結果。
請清楚說明這個分析能支持的統計結論與不能支持的因果結論，
並儲存完整的 SPSS syntax 與結果檔案。
```

### 6.5 調節分析

```text
請對 examples/data/mediation_study.sav 執行調節分析：
X = autonomy，W = satisfaction，Y = performance。

請將 X 與 W 置中（中心化），建立包含主效應與 X×W 交互項的迴歸模型。
報告交互項係數、標準誤、t、p、信賴區間與模型解釋力的變化。
如果交互項顯著，請解釋它所表示的調節方向；如果不顯著，請明確表示不支持調節效應。
不要只根據主效應就判斷調節成立。
```

### 6.6 存活分析

```text
請分析 examples/data/survival_study.sav。
變數為 treatment、time 與 status，其中 status=1 表示事件發生。
請完成：
1. 檢查 time 與 status 的編碼；
2. 按 treatment 繪製 Kaplan-Meier 存活曲線；
3. 比較各組之間的存活情況；
4. 報告中位存活時間、信賴區間與 log-rank 結果；
5. 說明刪失（censored）資料如何被處理；
6. 輸出論文級 PNG 圖片與可重現的語法。
```

## 7. 論文級出圖

SPSS Studio MCP 提供多種 `spss_chart_*` 工具。常用選擇如下：

| 工具 | 適用場景 |
|------|----------|
| `spss_chart_histogram_density` | 連續變數的分布與常態性展示 |
| `spss_chart_qqplot` | 常態 Q-Q 檢驗 |
| `spss_chart_scatter` | 兩個連續變數之間的關係 |
| `spss_chart_bar_error` | 分組平均值與 95% CI |
| `spss_chart_boxplot` | 組間分布、離群值與中位數 |
| `spss_chart_errorbar` | 平均值與信賴區間 |
| `spss_chart_line` / `spss_chart_area` | 時間序列或重複測量趨勢 |
| `spss_chart_km_curve` | Kaplan-Meier 存活曲線 |

直接向 Agent 提出的出圖請求：

```text
請使用 examples/data/survey_study.sav。
以 engagement_total 為變數，繪製論文級直方圖並疊加常態密度曲線。
要求：PNG、300 dpi、1950×1500 像素，中文標題為「學習投入總分分佈」。
檢查圖片是否成功產生，傳回絕對路徑，並說明這張圖適合放在論文哪一部分。
```

圖片工具預設會傳回可用的檔案路徑。投稿前仍應檢查字型、座標軸標題、圖例、解析度與期刊的格式要求。

## 8. 輸出檔案與重現

一次分析可能產生以下結果：

| 檔案或欄位 | 用途 |
|------------|------|
| Markdown | 直接閱讀，並複製到筆記或報告 |
| JSON | 供腳本、網頁或後續 Agent 使用 |
| `.sps` | 儲存實際執行的 SPSS 語法，方便重現 |
| `.spv` | 在 SPSS Viewer 中檢視完整輸出 |
| PNG / TIFF / EMF | 用於論文、簡報或進一步排版 |
| `logs/audit.jsonl` | 記錄執行過程與安全稽核資料 |

涉及資料轉換時，明確要求 Agent 另存為新檔案：

```text
你可以產生衍生變數，但不要覆蓋原始的 data.sav。
請把轉換後的資料儲存為 data_derived.sav，並在結果中列出每個新變數的計算規則。
後續分析只使用 data_derived.sav。
```

注意：每次提交通常會重新載入資料檔案，上一輪 `COMPUTE` 產生的暫存變數不會自動保留。需要保留時，請使用 `SAVE OUTFILE=...` 另存為新的資料集。

## 9. 安全使用建議

- 先讓 Agent 讀取中繼資料，再允許它執行複雜分析；
- 不要把含有身分證號碼、銀行卡號碼、密碼或其他不必要敏感資料的資料上傳給不受信任的用戶端；
- 要求 Agent 不要覆蓋原始資料，並把衍生資料儲存到新檔案；
- 對陌生語法先使用 `dry_run=True` 驗證，不要直接執行；
- 保留 `.sps` 語法與稽核日誌，方便覆核；
- 把允許存取的資料目錄限制在專案目錄或專門的分析目錄。

專案預設會攔截 `HOST`、`ERASE`、`DELETE FILE` 等危險指令，並限制資料檔案路徑。詳細規則請參閱[安全層說明](security.zh-Hant-HK.md)。

## 10. SPSS 路徑與環境變數

### 10.1 設定 SPSS 安裝路徑

如果自動偵測失敗，請在專案目錄建立 `.env` 檔案：

```ini
SPSS_INSTALL_PATH=C:\Program Files\IBM\SPSS Statistics\32
```

也可以暫時在目前的 PowerShell 工作階段中設定：

```powershell
$env:SPSS_INSTALL_PATH = "C:\Program Files\IBM\SPSS Statistics\32"
spss-studio-mcp status
```

### 10.2 調整逾時

首次啟動 SPSS 引擎通常比之後的呼叫慢。如果首次啟動逾時，請在 `.env` 中加入以下設定：

```ini
SPSS_STARTUP_TIMEOUT=300
SPSS_TIMEOUT=120
```

`SPSS_STARTUP_TIMEOUT` 控制引擎的首次啟動，`SPSS_TIMEOUT` 控制單次分析任務。複雜模型可以適當地調高後者。

### 10.3 設定資料白名單

如果資料放在專案目錄之外，可以設定允許存取的目錄。具體格式以目前專案版本的設定說明為準；建議只加入專門的研究資料目錄，不要直接開放整個磁碟。

## 11. 常見問題

### `SPSS batch : NOT FOUND`

先確認 `stats.exe` 的實際位置，再設定 `SPSS_INSTALL_PATH`。設定後重新開啟終端機或重新執行 `status`。

### Agent 看不到 SPSS 工具

請依序檢查：

1. 是否執行了正確的 `configure-codex` 或 `configure-claude`；
2. 用戶端是否已重新啟動；
3. `spss-studio-mcp status` 是否能夠成功執行；
4. 用戶端設定中的指令是否能在目前終端機中找到；
5. 是否有多個舊的 SPSS MCP 設定互相衝突。

### 第一次分析很慢或逾時

第一次啟動引擎約需 15–20 秒，之後通常會保持常駐。不要同時開啟多個 SPSS 工作階段；必要時調高 `SPSS_STARTUP_TIMEOUT` 或 `SPSS_TIMEOUT`。

### 提示未經授權或圖片匯出失敗

確認 IBM SPSS Statistics 的授權有效，並檢查是否有殘留的 `stats.exe`、`spssengine` 或 `spsswers.dll` 程序佔用試用席次。結束殘留程序後再試，並避免同時啟動多個 SPSS 工作階段。

### 資料檔案被拒絕

把資料放入 `examples/data/`、系統暫存目錄或已設定的允許目錄。不要透過改名繞過安全限制；應該正確設定資料白名單。

### 中文變數標籤顯示異常

在 Prompt 中優先使用變數名稱，並讓 Agent 先讀取變數標籤。工具內部會盡量建立變數名稱與標籤之間的對應，但統計語法仍應使用 SPSS 中實際存在的變數名稱。

## 12. 一鍵完成完整分析的最終模板

當你已經熟悉基本操作，可以直接把下面的模板傳給 Agent：

```text
請作為我的 SPSS 統計分析助手。分析 [資料檔案路徑]，不要修改原始檔案。

研究背景：[研究對象、研究目的與假設]
資料說明：[樣本數、變數含義、分組方式、時間結構]
核心問題：[希望回答的統計問題]

請嚴格依照以下順序完成：
1. 讀取中繼資料，檢查變數類型、標籤、數值範圍、缺失值與樣本數；
2. 說明每一個研究問題適合使用甚麼統計方法，以及選擇的理由；
3. 執行必要的前提假設檢驗與離群值檢查；
4. 執行正式分析，報告估計值、標準誤、信賴區間、檢定統計量、自由度、p 值與效應量；
5. 產生與研究問題對應的論文級圖表，要求 PNG 300 dpi；
6. 提供結果解釋，以及可以直接修改並貼進論文的結果段落；
7. 儲存完整的 SPSS syntax、Viewer 輸出與圖像檔案；
8. 傳回 Markdown 結果、結構化摘要、所有輸出路徑與警告；
9. 最後列出結果的限制，不要把橫斷面相關關係表述為因果關係。

如果變數編碼、研究設計或統計假設不清楚，請先指出問題並向我提問，不要擅自假設。
```

## 13. 開發者與進階用戶

在專案根目錄執行：

```powershell
python scripts/make_sample_data.py
python scripts/method_verification.py
python scripts/tool_verification.py
python scripts/archive_sample_charts.py
pytest
```

實現、結果解析、方法驗證與安全邊界分別參閱：

- [技術報告](technical_report.zh-Hant-HK.md)
- [出圖管線](poc_chart_pipeline.zh-Hant-HK.md)
- [結果解析](result_parsing.zh-Hant-HK.md)
- [方法驗證](method_verification.zh-Hant-HK.md)
- [安全層](security.zh-Hant-HK.md)

如果你想把固定的研究流程交給團隊重複使用，可以把「資料檢查 → 方法選擇 → 分析 → 出圖 → 論文解釋」的 Prompt 固化為團隊 skill，並要求每次輸出 `.sps` 語法與稽核紀錄。
