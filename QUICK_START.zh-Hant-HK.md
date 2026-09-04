# SPSS Studio MCP — 快速開始

> **語言：** [English](QUICK_START.md) · 繁體中文（香港）

> 3 步完成部署，5 分鐘內開始使用。已在真實 IBM SPSS Statistics 32
> **Windows 及 macOS** 上真機驗證。

---

## 第 1 步 — 安裝

**Windows**（PowerShell）：

```powershell
cd D:\opencode\spss-studio-mcp
pip install -e ".[dev]"
spss-studio-mcp status   # 應顯示 SPSS batch: OK
```

**macOS**（需 Python ≥3.10；自動發現位於
`/Applications/IBM SPSS Statistics` 的 SPSS 32 for Mac）：

```bash
cd ~/Code/spss-studio-mcp
bash scripts/install_macos.sh          # 建立 .venv、安裝依賴、configure-claude
.venv/bin/spss-studio-mcp status       # SPSS batch: OK
```

## 第 2 步 — 設定 MCP 用戶端

```powershell
spss-studio-mcp configure-codex     # Codex（~/.codex/config.toml）
spss-studio-mcp configure-claude    # Claude Code（~/.claude.json）
spss-studio-mcp setup-info          # 印出手動設定片段
```

## 第 3 步 — 使用

### 統計分析

直接向用戶端用自然語言描述任務，例如：

- `對 examples/data/survey_study.sav 做描述性統計同信度分析`
- `用 examples/data/experiment_study.sav 做獨立樣本 t 檢定（group 分組，posttest 做依變項）`
- `對 examples/data/mediation_study.sav 做中介分析：autonomy → satisfaction → performance`

### 達到投稿水準的圖表

- `將 examples/data/survey_study.sav 的 engagement_total 畫成帶常態密度的直方圖，PNG 300dpi`
- `用 examples/data/survival_study.sav 畫按 treatment 分組的 KM 存活曲線`
- `用 examples/data/experiment_study.sav 畫後測成績按 group 分組的箱線圖`

每個圖表工具都會回傳 1950×1500 @300 dpi 的檔案路徑，可直接投稿。

### 結構化結果

- 呼叫 `spss_structured_result` 獲得統一結構 `{markdown, json, files, warnings}`；
  統計摘要（t / F / r / B / p 等）會自動附加在每個分析工具輸出的末尾
  （`### Statistical Summary` 標題之下）。

## 安全

- 危險指令（`HOST` / `ERASE` / `DELETE FILE` 等）會被攔截；
- 資料檔案必須位於 `examples/`、系統暫存目錄，或 `SPSS_ALLOWED_DIRS` 所宣告的目錄；
- `spss_run_syntax(..., dry_run=True)` 先校驗、不執行；
- 審計日誌預設寫入 `logs/audit.jsonl`（可用 `SPSS_AUDIT_LOG` 更改路徑）。

## 範例與文件

- 範例資料與歸檔圖表：`examples/`
- 文件：`docs/`（圖表管線 PoC、結果剖析、驗證記錄）
- 完整 Agent 教學：[`docs/tutorial.zh-Hant-HK.md`](docs/tutorial.zh-Hant-HK.md)

## 常見問題

- **啟動慢**：首次引擎啟動約需 15–20 秒，之後為常駐工作階段。
- **顯示未授權**：確保 SPSS 試用／正式授權可用，並避免同時開啟多個 SPSS 工作階段。
- **資料檔案被拒**：將檔案放入 `examples/data/`，或用 `SPSS_ALLOWED_DIRS` 宣告所在目錄。
