# P2 結果剖析：Markdown + JSON + 統計摘要

> **語言：** [English](result_parsing.md) · 繁體中文（香港）

> 實作日期：2026-08-05 ｜ 依據 SPSS Statistics 32.0.0 真實 OMS TEXT 輸出開發

## 目標

把 SPSS 文字輸出轉成機器可讀的 JSON（表格層級），自動抽取論文報告所需的關鍵統計量（t / F / r / B / Wald / p / 效應量等），最後統一為 `{markdown, json, files, warnings}` 回傳結構。

## 模組

`src/spss_mcp/result_parser.py`

| 函數 | 作用 |
|------|------|
| `parse_tables(raw_text)` | 以逐行掃描的狀態機把 SPSS 表格區塊切分成 `[{title, headers, rows}]`（JSON 友善） |
| `summarize_analysis(raw_text)` | 依表標題識別分析類型，抽取統計量並生成自然語言結論 |
| `build_result_payload(result)` | 組裝統一結構 `{markdown, json, files, warnings}` |

`src/spss_mcp/spss_runner.py`：`run_syntax` 的回傳新增 `tables` / `summary` / `files` 欄位（增量式，不會破壞現有工具）。

`src/spss_mcp/server.py`：新增工具 **`spss_structured_result`**，可執行任意語法並回傳統一 JSON 結構；同時 `_format_run_result` 會自動把統計摘要附加到所有分析工具（`spss_t_test` / `spss_regression` / `spss_anova` 等）回傳的末尾，作為 `### Statistical Summary` 一節。

## 剖析規則要點（SPSS TEXT 真實版面）

- 表標題是行首沒有縮排的獨立短行；有縮排的行屬於表頭／資料的一部分，不會被誤判為新表格。
- 以單一空格相連的儲存格（行標籤與數值黏連、`Kolmogorov-Smirnov(a) Shapiro-Wilk` 等），會以「整行文字 + 數值正規表達式」的方式處理，不依賴嚴格的欄位對齊。
- 表頭判定啟發式：若首行包含小數（`.000`、`-3.875`），視為資料行；否則視為表頭（`-2 Log likelihood` 這類含有整數的表頭仍會正確歸類為表頭）。
- 子標題（如 `Dependent Variable xxx`）只併入標題一次，且必須是純文字、不含數字的行。
- `Notes` 區塊會整體略過；帶 `(a)` 腳註的數值仍可剖析；p 值 `.000` 會彙報為 `<.001`。

## 統計摘要覆蓋（16 類真實輸出驗證）

| 分析 | 表格 | 提取項目 | 示例輸出 |
|------|------|----------|----------|
| 描述統計 | `Descriptive Statistics` | 每變項 N/Min/Max/Mean/Std | `score: N=120, Mean=54.20, SD=11.23` |
| 獨立樣本 t 檢定 | `Independent Samples Test` / `Group Statistics` | t、df、p、平均差、組別統計 | `t(118) = -3.88, p < .001, MD = -7.52` |
| 配對樣本 t 檢定 | `Paired Samples Test` | t、df、p、平均差 | `t(119) = -12.84, p < .001, MD = -9.88` |
| 單因子 ANOVA | `ANOVA` + Levene | F、df1、df2、p、Levene F | `F(1, 118) = 15.01, p < .001` |
| 多因子 ANOVA | `Tests of Between-Subjects Effects` | 各效應 F/df1/p/偏 η² | `gender: F(1, 194) = .34, η² = .002` |
| 相關 | `Correlations` | r、p | `y-x: r = .42, p < .001` |
| 線性迴歸 | `Model Summary` / `ANOVA` / `Coefficients` | R、R²、F、B/Beta/t/p | `R = .82, R² = .68; x: B = .92, Beta = .48` |
| Logistic 迴歸 | `Model Summary` / `Variables in the Equation` | -2LL、Cox & Snell/Nagelkerke R²、B/SE/Wald/Exp(B)/p | `x: B = .19, Wald = .16, p = .69, OR = 1.21` |
| 頻數 | `Statistics` | N/Mean/Median/Mode/Std | `N=120, Mean=.50` |
| 卡方 | `Chi-Square Tests` | χ²、df、p | `χ²(2) = .61, p = .739` |
| 信度 | `Reliability Statistics` | Cronbach's α、題項數 | `α = .82 (12 items)` |
| 無母數檢定 | `Test Statistics` | Mann-Whitney U/Wilcoxon Z/K-W H、df、p | `U = 1088.50, z = -3.72, p < .001` |
| 常態性 | `Tests of Normality` | Shapiro-Wilk W、K-S D、df、p | `W(200) = .99, p = .101` |
| 因素分析 | `KMO and Bartlett's Test` / `Total Variance Explained` | KMO、Bartlett χ²、特徵值、累計變異量 | `KMO = .50, χ²(66) = 64.68` |

## 測試

- 16 個真實輸出 fixture：`tests/fixtures/spss_outputs/*.txt`
- `tests/test_result_parser.py`：23 項斷言涵蓋全部類型的剖析、摘要與統一結構
- 真機驗證：`run_syntax` 對 T-TEST 回傳完整 `summary` 與 `tables`

## 使用

```python
from spss_mcp.spss_runner import run_syntax
result = await run_syntax("T-TEST GROUPS=g(0 1) /VARIABLES=score.")
result["summary"]["text"]   # 自然語言結論
result["summary"]["summaries"]  # 結構化統計量
result["tables"]            # 適合 JSON 的表格
```

MCP 用戶端可呼叫 `spss_structured_result` 取得統一 JSON 回傳。
