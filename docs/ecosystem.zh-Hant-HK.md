# 生態收錄與 Release v1.0 準備

> **語言：** [English](ecosystem.md) · 繁體中文（香港）

> 2026-08-05 ｜ 提交類操作需要發佈帳號；本文件提供可直接使用的條目與說明。

## 1. 項目速覽（供生態收錄／發佈用）

- **名稱**：spss-studio-mcp
- **一句話**：令 SPSS 成為 Agent 的「統計引擎 + 製圖工廠」：達到投稿水準的圖表、深度結果剖析、方法真機驗證、安全執行。
- **類別**：data-analysis / statistics / mcp-server
- **標籤**：`spss` `statistics` `mcp` `chart` `result-parsing` `psychology` `social-science`
- **核心能力（取自技術報告）**：
  - 11 類達到投稿水準的圖表（PNG/TIFF，300 dpi）
  - 16 類分析統計摘要（t/F/R/B/Wald/p/效應量）
  - 37+ 個工具全量真機驗收（SPSS 32）
  - 中介／調節工具（Baron & Kenny + Sobel）
  - 安全層（指令攔截／白名單／`dry_run`／審計）

## 2. LobeHub 收錄條目

平台：LobeHub（Lobe Chat MCP／插件市場）。提交方式：通常是向 GitHub 儲存庫提交描述檔或 PR。可複製以下條目：

- 儲存庫：https://github.com/flupke91/spss-studio-mcp
- LobeHub 插件市場提交入口：https://github.com/lobehub/lobe-chat-plugins
  （建立 `plugins/<plugin-name>/` 目錄，內含 `plugin.json` + `README.md`）

```yaml
# LobeHub 收錄條目示例
name: spss-studio-mcp
description: >-
  SPSS Studio MCP：達到投稿水準的圖表匯出（11 類圖 PNG/TIFF @300dpi）、
  深度結果剖析（Markdown + JSON + 統計摘要）、37+ 個方法真機驗證、中介／調節分析
  與安全執行（危險指令攔截／白名單／dry_run／審計）。適用於心理學／管理學／社科研究。
category: data-analysis
tags: [spss, statistics, chart, mcp]
```

## 3. PulseMCP 收錄條目

平台：PulseMCP（MCP 伺服器目錄）。提交方式：網站表單或 GitHub PR。
建議填寫：

- 提交入口：https://www.pulsemcp.com/submit
- 儲存庫：https://github.com/flupke91/spss-studio-mcp

- **Name**: spss-studio-mcp
- **Short description**: Paper-ready charts, deep result parsing and safe execution for IBM SPSS Statistics via MCP.
- **Long description**: 引用 `README.zh-Hant-HK.md` 的功能清單與 `docs/technical_report.zh-Hant-HK.md` 的摘要。
- **Transport**: stdio
- **Auth**: none（由本機 SPSS 授權）
- **OS**: macOS

## 4. GitHub Release v1.0 草稿

見 `docs/release_notes_v1.0.zh-Hant-HK.md`（可直接貼到 Release 頁面）。

## 5. 提交前檢查清單

- [x] 功能與驗證：37 個工具真機驗收（26 個方法 + 11 個工具）、11 類圖 × PNG/TIFF
- [x] boxplot 修復（0.3.1）：改用 `EXAMINE` 模板後 PNG/TIFF 正常（EMF 已於 macOS 改版移除）
- [x] 文件：README / QUICK_START / docs（教學、技術報告、出圖、剖析、驗證、安全）
- [x] 安全：攔截／白名單／`dry_run`／審計 + `docs/security.zh-Hant-HK.md`
- [x] CI：`.github/workflows/ci.yml`（lint + pytest）
- [x] 授權：MIT（含上游說明）
- [x] 範例圖：`examples/charts/*.png` 已用 0.3.1 範本重新歸檔（11 張，含修復後的 boxplot）
- [ ] 發佈帳號操作：建立 GitHub release、提交 LobeHub／PulseMCP 條目
- [ ] （建議）GitHub 儲存庫公開前檢查：無敏感路徑、無本機日誌入庫（`logs/` 已列於 gitignore）

## 7. GitHub 發佈步驟（發佈帳號操作）

- [x] 建立公開儲存庫 `flupke91/spss-studio-mcp` 並推送 `master`（2026-08-05）；
- [x] 打 tag `v1.0.0` 並建立 Release（正文 = `docs/release_notes_v1.0.zh-Hant-HK.md`）；
- [ ] 提交 LobeHub 條目（lobe-chat-plugins PR）；
- [ ] 提交 PulseMCP 條目（pulsemcp.com/submit 表單）。

## 6. 對外材料（② 的成果，可直接引用）

- 技術報告（論文稿）：`docs/technical_report.zh-Hant-HK.md`
- 使用教學：`docs/tutorial.zh-Hant-HK.md`
- 範例圖：`examples/charts/*.png`（可作 README／收錄頁截圖）
- 驗證紀錄：`docs/method_verification.zh-Hant-HK.md`（逐案例：
  `docs/method_verification_macos.json`、`docs/tool_verification_macos.json`）
