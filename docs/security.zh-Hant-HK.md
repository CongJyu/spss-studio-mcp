# 安全層（P4）

> **語言：** [English](security.md) · 繁體中文（香港）

> 實作日期：2026-08-05 ｜ 真機驗證：SPSS 32.0.0（dry_run / 危險指令攔截 / 審計全部通過）

## 模組

`src/spss_mcp/security.py`

| 能力 | 實作 |
|------|------|
| 危險指令攔截 | `check_syntax_safety(syntax)`：於行首比對 `HOST / ERASE / DELETE FILE / FILE HANDLE / INSERT FILE / SCRIPT / CD / SYSTEM`，避免變數名稱造成誤報 |
| 路徑白名單 | `validate_data_file(path)`：允許 `SPSS_ALLOWED_DIRS`（以分號分隔）、專案的 `examples/` 及系統暫存目錄；不存在或不在白名單內的路徑一律拒絕 |
| 審計日誌 | `audit(entry)`：以 JSONL 附加寫入 `logs/audit.jsonl`（可用 `SPSS_AUDIT_LOG` 更改路徑），寫入失敗不會阻斷分析 |
| dry_run | `spss_run_syntax(..., dry_run=True)`：只驗證語法安全與路徑，不啟動執行 |

## 整合點

- `spss_runner.run_syntax`：統一安全閘（所有工具共用）——先攔截危險指令，再驗證 `data_file` 參數以及語法中 `GET FILE='...'` 的路徑；每次成功執行都會寫入審計記錄。
- `server.spss_run_syntax`：新增 `dry_run` 參數；`spss_structured_result` 同樣會經過 `run_syntax` 的安全閘。

## 審計事件

| event | 含義 |
|-------|------|
| `blocked / dangerous_syntax` | 語法包含危險指令，未執行 |
| `blocked / path` | 資料檔案不存在或不在白名單內，未執行 |
| `dry_run` | dry_run 驗證請求（包含被攔截的指令清單） |
| `syntax_run` | 正常執行（包含語法首行摘要、data_file、success、error） |

## 真機驗證記錄

```
dry_run:          Dry run: syntax is safe to execute ...
HOST 語法:        Error: Syntax blocked: dangerous commands HOST.
正常分析:         通過（FREQUENCIES 正常回傳）
外部路徑:         Error: Data file does not exist: D:/outside/x.sav
審計日誌:         dry_run / blocked / syntax_run 事件均已寫入磁碟
```

## 配置

```powershell
$env:SPSS_ALLOWED_DIRS = "C:\data;D:\research\data"   # 額外容許的資料目錄
$env:SPSS_AUDIT_LOG    = "D:\logs\spss-audit.jsonl"   # 審計日誌位置
```
