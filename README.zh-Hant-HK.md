# SPSS Studio MCP for Mac

> 令 SPSS 成為 Agent 的「統計引擎 + 製圖工廠」：達到投稿水準的圖片、深度結果剖析、方法真機驗證、安全執行。

> 此 MCP **僅為 Mac** 提供支援，需要 Windows 版本之 MCP 請參閲 [flupke91/spss-studio-mcp](https://github.com/flupke91/spss-studio-mcp)。

[English](README.md) ｜ **繁體中文（香港）**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.14%2B-blue.svg)]()
[![Tests](https://img.shields.io/badge/tests-105%20passed-brightgreen.svg)]()

`spss-studio-mcp` 是一個面向 **IBM SPSS Statistics** 的 MCP（Model Context
Protocol）伺服器，為 Codex / Claude Code / Cursor 等 Agent 用戶端提供：

- **達到投稿水準的圖表**：11 類 `spss_chart_*` 工具，一鍵匯出 PNG / TIFF
  （1950×1500 @300 dpi），回傳檔案路徑可直接投稿；
- **深度結果剖析**：OMS 文字 → Markdown 表格 + 結構化 JSON + 16 類分析統計摘要
  （t / F / r / B / Wald / α / χ² / p / 效應量）；
- **方法真機驗證**：全部 37 個分析工具加 11 個輔助工具均在真實 SPSS 32 for Mac 上驗證；
- **中介 / 調節**：`spss_mediation`（Baron & Kenny 三步迴歸 + Sobel 檢驗）、
  `spss_moderation`（中心化交互迴歸）；
- **安全執行層**：危險指令攔截、資料路徑白名單、`dry_run` 預檢、JSONL 審計日誌。

一切能力已在 **IBM SPSS Statistics 32.0.0.0（macOS）** 真機驗證 —— 105 個單元
測試全部通過，包括一個自包含的真機重現清單。逐條結果見
[docs/macos_verification.zh-Hant-HK.md](docs/macos_verification.zh-Hant-HK.md)。

---

## 安裝

> **前置要求** —— macOS，並已安裝 IBM SPSS Statistics 32 for Mac，以及
> Python ≥3.10（或 [uv](https://docs.astral.sh/uv/)）。SPSS 會自動於
> `/Applications` 下的 `.app` bundle 內被偵測到；只有安裝在其他位置時，
> 才需要設定 `SPSS_INSTALL_PATH`。

### 步驟一 —— 安裝伺服器（只需做一次，所有用戶端共用）

```bash
git clone https://github.com/flupke91/spss-studio-mcp.git
cd spss-studio-mcp
python3 -m venv .venv
.venv/bin/python -m pip install -e .

.venv/bin/spss-studio-mcp status      # → SPSS batch : OK
.venv/bin/spss-studio-mcp setup-info  # → 你的用戶端所需的 command / args / env
```

亦可使用一鍵安裝腳本，它會完成上述步驟**並**替你寫入用戶端設定
（預設目標為 Claude Code，加 `--codex` 則為 Codex CLI）：

```bash
bash scripts/install_macos.sh            # 安裝 + configure-claude
bash scripts/install_macos.sh --codex    # 安裝 + configure-codex
```

以下範例假設專案複製於 `/Users/you/Code/spss-studio-mcp`，請以你自己的
`pwd` 取代。

### 步驟二 —— 在用戶端註冊伺服器

#### Claude Code

內建的設定工具會將設定項合併到 `~/.claude.json`（用戶層級：所有專案通用），
並先建立帶時間戳的備份：

```bash
.venv/bin/spss-studio-mcp configure-claude
```

或用 Claude Code CLI 註冊，效果完全相同：

```bash
claude mcp add --transport stdio --scope user spss \
  --env SPSS_INSTALL_PATH="/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin" \
  --env SPSS_TIMEOUT=120 \
  --env SPSS_STARTUP_TIMEOUT=300 \
  -- /Users/you/Code/spss-studio-mcp/.venv/bin/spss-studio-mcp serve --transport stdio
```

如改用 `--scope project`，則會寫入專案根目錄的共用 `.mcp.json`，可一併提交。
以 `claude mcp get spss` 驗證，或在對話中輸入 `/mcp` 查看。

寫入後的設定項如下（與 `configure-claude` 產生的完全一致）：

```json
{
  "mcpServers": {
    "spss": {
      "type": "stdio",
      "command": "/Users/you/Code/spss-studio-mcp/.venv/bin/spss-studio-mcp",
      "args": ["serve", "--transport", "stdio"],
      "env": {
        "SPSS_INSTALL_PATH": "/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin",
        "SPSS_TIMEOUT": "120",
        "SPSS_STARTUP_TIMEOUT": "300"
      }
    }
  }
}
```

#### Codex CLI

```bash
.venv/bin/spss-studio-mcp configure-codex   # 合併寫入 ~/.codex/config.toml
```

或用 Codex CLI：

```bash
codex mcp add spss \
  --env SPSS_INSTALL_PATH="/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin" \
  --env SPSS_TIMEOUT=120 \
  --env SPSS_STARTUP_TIMEOUT=300 \
  -- /Users/you/Code/spss-studio-mcp/.venv/bin/spss-studio-mcp serve --transport stdio
```

兩者都會在 `~/.codex/config.toml` 寫入同一段設定：

```toml
[mcp_servers.spss]
command = '/Users/you/Code/spss-studio-mcp/.venv/bin/spss-studio-mcp'
args = ["serve", "--transport", "stdio"]
env = { SPSS_INSTALL_PATH = '/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin', SPSS_TIMEOUT = '120', SPSS_STARTUP_TIMEOUT = '300' }
```

以 `codex mcp list` 驗證。

#### OpenCode

OpenCode 從 `mcp` 鍵（**不是** `mcpServers`）讀取伺服器設定，位置為
`~/.config/opencode/opencode.json`（全域）或專案根目錄的 `opencode.json`
（優先度較高）。目前尚未提供 `configure-opencode` 指令，請手動合併以下設定；
留意 `command` 是**陣列**：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "spss": {
      "type": "local",
      "command": [
        "/Users/you/Code/spss-studio-mcp/.venv/bin/spss-studio-mcp",
        "serve",
        "--transport",
        "stdio"
      ],
      "enabled": true,
      "timeout": 60000,
      "environment": {
        "SPSS_INSTALL_PATH": "/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin",
        "SPSS_TIMEOUT": "120",
        "SPSS_STARTUP_TIMEOUT": "300"
      }
    }
  }
}
```

> **記得設定 `timeout`**：OpenCode 的 MCP 逾時預設為 5 秒，但 SPSS 引擎首次
> 啟動需約 15–20 秒；設為 60000 毫秒（或更大）可避免誤判為啟動失敗。

### 步驟三 —— 驗證

重新啟動用戶端，然後以自然語言驅動它 —— 第一個提示詞可以是
`check SPSS status`。無需在 shell 額外匯出任何變數：伺服器會自行解析 SPSS，
並從你剛才加入的 `env` 區塊讀取 `SPSS_INSTALL_PATH`。

---

## 快速開始

**macOS**（自動發現 SPSS 32 for Mac；需 Python ≥3.10）：

```bash
cd spss-studio-mcp
bash scripts/install_macos.sh              # 建立 .venv、安裝依賴、configure-claude
.venv/bin/spss-studio-mcp status           # 應顯示 SPSS batch: OK
.venv/bin/spss-studio-mcp configure-codex  # 可選：Codex 設定
.venv/bin/spss-studio-mcp configure-claude # 可選：Claude Code 設定（~/.claude.json）
```

然後在用戶端直接用自然語言驅動，例如：

```text
對 examples/data/survey_study.sav 做描述性統計同信度分析
對 examples/data/experiment_study.sav 做獨立樣本 t 檢定（group 分組，posttest 做依變項）
對 examples/data/mediation_study.sav 做中介分析：autonomy → satisfaction → performance
將 examples/data/survey_study.sav 的 engagement_total 畫成帶常態密度的直方圖，PNG 300dpi
```

## 達到投稿水準的圖表（核心賣點）

| 工具                                                    | 用途                                |
| ------------------------------------------------------- | ----------------------------------- |
| `spss_chart_histogram` / `spss_chart_histogram_density` | 分佈直方圖 / 直方圖 + 常態密度      |
| `spss_chart_scatter`                                    | 兩變項散點圖                        |
| `spss_chart_bar` / `spss_chart_bar_error`               | 分類平均值長條圖 / 連 95% CI 誤差鬚 |
| `spss_chart_line` / `spss_chart_area`                   | 時間序列折線 / 面積圖               |
| `spss_chart_boxplot`                                    | 分組箱線圖                          |
| `spss_chart_errorbar`                                   | 平均值 ± CI 誤差條                  |
| `spss_chart_qqplot`                                     | 常態 Q-Q 圖                         |
| `spss_chart_km_curve`                                   | Kaplan-Meier 存活曲線               |

```python
spss_chart_histogram_density(
    variable="engagement_total",
    title="學習投入總分分佈（帶常態密度）",
    image_format="PNG",            # PNG / TIFF
    width_px=1950, height_px=1500, dpi=300,
    data_file="examples/data/survey_study.sav",
)
# → 回傳圖片檔案路徑，可直接投稿
```

> **macOS 注意**：本專案僅支援 macOS 上的 SPSS，圖表輸出格式為 PNG 與 TIFF。
> SPSS for Mac 只會產生點陣輸出，不會產生 Windows 向量 EMF（其 `OMS FORMAT=DOC`
> 封存內是 PNG 資料），因此 EMF 匯出已從產品中移除；請使用
> `image_format="PNG"` 或 `"TIFF"`。

## 結構化結果與統計摘要

```python
spss_structured_result(
    syntax="T-TEST GROUPS=group(1 2) /VARIABLES=posttest.",
    data_file="examples/data/experiment_study.sav",
)
# → {markdown, json: {tables, summary}, files, warnings}
```

`run_syntax` 回傳的 Markdown 末尾會附上一個 `### Statistical Summary` 區塊，
內含平白語言結論加上關鍵統計量。
16 類分析的抽取細節見：[docs/result_parsing.zh-Hant-HK.md](docs/result_parsing.zh-Hant-HK.md)。

## 範例資料

`examples/data/` 提供五組貼近論文場景的範例資料（固定隨機種子，可完整重現）：

| 檔案                                        | 場景                       | 關鍵變項                                             |
| ------------------------------------------- | -------------------------- | ---------------------------------------------------- |
| `survey_study.sav`                          | 問卷：200 位學生學習投入   | `gender` / `major` / `q1`–`q12` / `engagement_total` |
| `experiment_study.sav`                      | 實驗：120 人記憶訓練前後測 | `group` / `pretest` / `posttest` / `gain`            |
| `survival_study.sav`                        | 存活：150 例隨訪           | `treatment` / `time` / `status`                      |
| `mediation_study.sav`                       | 中介：300 名僱員           | `autonomy` / `satisfaction` / `performance`          |
| `longitudinal_study.sav` / `long_study.sav` | 縱向：60 人 3 次測量       | `id` / `group` / `time` / `score`                    |

## 安全執行

- 危險指令（`HOST` / `ERASE` / `DELETE FILE` 等）在行首即被攔截；
- 資料檔案必須位於 `examples/`、系統暫存目錄，或 `SPSS_ALLOWED_DIRS` 所宣告的目錄；
- `spss_run_syntax(..., dry_run=True)` 先校驗、不執行；
- 審計日誌預設寫入 `logs/audit.jsonl`（可用 `SPSS_AUDIT_LOG` 更改路徑）。

詳見 [docs/security.zh-Hant-HK.md](docs/security.zh-Hant-HK.md)。

## 文件

- [教學](docs/tutorial.zh-Hant-HK.md)
- [技術報告](docs/technical_report.zh-Hant-HK.md)
- [圖表管線 PoC 與 SPSS 32 發現](docs/poc_chart_pipeline.zh-Hant-HK.md)
- [結果剖析（16 類分析摘要）](docs/result_parsing.zh-Hant-HK.md)
- [方法真機驗證](docs/method_verification.zh-Hant-HK.md)
- [macOS 真機驗證報告（SPSS 32 for Mac）](docs/macos_verification.zh-Hant-HK.md)
- [安全層](docs/security.zh-Hant-HK.md)
- [更新日誌](CHANGELOG.zh-Hant-HK.md)

## 許可證

MIT（上游：`flupke91/spss-studio-mcp`，MIT）。

MIT（上游：`Exekiel179/SPSS-MCP`，MIT）。
