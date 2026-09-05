# SPSS Studio MCP for Mac

> 令 SPSS 成為 Agent 的「統計引擎 + 製圖工廠」：達到投稿水準的圖片、深度結果剖析、方法真機驗證、安全執行。

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
