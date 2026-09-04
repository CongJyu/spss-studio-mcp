# 發佈說明 — v1.0.0

> **語言：** [English](release_notes_v1.0.md) · 繁體中文（香港）

> 狀態：發佈準備就緒 ｜ 由 `docs/technical_report.zh-Hant-HK.md` 與驗證紀錄匯總

## 概述

`spss-studio-mcp` 是一個面向 IBM SPSS Statistics 的 MCP 伺服器，為 Codex /
Claude / Cursor 提供「統計引擎 + 製圖工廠 + 結構化消費 + 安全護欄」四合一能力。
全部功能已在真實 SPSS Statistics 32（for Mac，macOS）安裝上驗證。

## 亮點

- **達到投稿水準的出圖**：11 類 `spss_chart_*` 工具，PNG/TIFF @300 dpi（1950×1500），回傳的檔案路徑可直接投稿。
- **深度結果剖析**：OMS 文字 → Markdown + JSON 表格 + 16 類分析統計摘要（t/F/R/B/Wald/α/χ²/p/效應量）。
- **37+ 工具真機驗收**：26 個分析方法 + 11 個輔助工具全部通過；修復 8 處 SPSS 32 語法相容性問題。
- **boxplot 修復**：由 0.3.1 起箱線圖改用 `EXAMINE /PLOT BOXPLOT` 範本，解決 GGRAPH schema 於 SPSS 32 出現 `outlier was found inside fences` 錯誤而導致匯出 0 位元組圖片的問題（PNG／TIFF 現均正常）。
- **中介／調節**：`spss_mediation`（Baron & Kenny + Sobel）、`spss_moderation`（中心化交互迴歸）。
- **安全執行**：危險指令攔截、資料路徑白名單、`dry_run`、JSONL 審計日誌。
- **統一回傳**：`{markdown, json, files, warnings}`，Agent 可直接以程式方式取用。

## 關鍵相容性說明

- SPSS 32 已移除 `OMS FORMAT=IMAGE`／`IMAGEROOT`；本項目以 HTML 內嵌 PNG 為出圖
  管線，輸出 PNG／TIFF（詳見 `docs/poc_chart_pipeline.zh-Hant-HK.md`）。EMF 匯出
  已於 macOS 改版移除——SPSS for Mac 不產生 Windows EMF。
- 箱線圖由 0.3.1 起使用 `EXAMINE` 傳統圖表範本，PNG／TIFF 均真機驗證通過。

## 資源

- 技術報告：`docs/technical_report.zh-Hant-HK.md`
- 使用教學：`docs/tutorial.zh-Hant-HK.md`
- 方法驗證：`docs/method_verification.zh-Hant-HK.md`
- 生態收錄：`docs/ecosystem.zh-Hant-HK.md`

## 安裝（macOS）

```bash
bash scripts/install_macos.sh          # 建立 .venv、安裝依賴、configure-claude
.venv/bin/spss-studio-mcp status
```

## 版本

- 目前版本：`0.3.1`（0.3.0 完成 P3/P4 功能，0.3.1 修復 boxplot 匯出）

## 鳴謝

上游：`Exekiel179/SPSS-MCP`（MIT）。
