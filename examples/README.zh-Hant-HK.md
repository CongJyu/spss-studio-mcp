# 真機樣例圖歸檔（P1）

> **語言：** [English](README.md) · 繁體中文（香港）

> 生成日期：2026-08-04 ｜ 引擎：IBM SPSS Statistics 32.0.0（for Mac） ｜ 圖片：PNG 1950×1500 @300 dpi

四組貼近論文場景的樣例資料及其代表性圖表，用於示範與迴歸驗證 `spss_chart_*` 工具。

## 目錄

- `data/` — 四個場景的 SPSS 資料檔（.sav，含變項／值標籤）
- `charts/` — 用真實 SPSS 引擎匯出的 11 張 PNG 圖

## 資料集

| 檔案 | 場景 | 樣本量 | 關鍵變項 |
|------|------|--------|----------|
| `data/survey_study.sav` | 問卷：大學生學習投入 | 200 | `gender`/`major`/`q1`-`q12`/`cognitive`/`affective`/`behavioral`/`engagement_total` |
| `data/experiment_study.sav` | 實驗：記憶訓練前後測 | 120 | `group`（訓練／對照）/`pretest`/`posttest`/`gain` |
| `data/survival_study.sav` | 存活：治療方案隨訪 | 150 | `treatment`/`time`/`status`（1=死亡，0=刪失） |
| `data/mediation_study.sav` | 中介：工作自主性→滿意度→績效 | 300 | `autonomy`/`satisfaction`/`performance` |

## 圖表清單（examples/charts）

| 圖表 | 場景 | 工具 |
|------|------|------|
| `survey_engagement_histogram_density.png` | 問卷 | `spss_chart_histogram_density` |
| `survey_engagement_by_major.png` | 問卷 | `spss_chart_bar_error` |
| `survey_engagement_by_gender.png` | 問卷 | `spss_chart_errorbar` |
| `experiment_posttest_boxplot.png` | 實驗 | `spss_chart_boxplot` |
| `experiment_gain_errorbar.png` | 實驗 | `spss_chart_errorbar` |
| `experiment_posttest_bar.png` | 實驗 | `spss_chart_bar` |
| `survival_km_curve.png` | 存活 | `spss_chart_km_curve` |
| `survival_time_histogram.png` | 存活 | `spss_chart_histogram` |
| `mediation_autonomy_performance_scatter.png` | 中介 | `spss_chart_scatter` |
| `mediation_satisfaction_performance_scatter.png` | 中介 | `spss_chart_scatter` |
| `mediation_performance_histogram_density.png` | 中介 | `spss_chart_histogram_density` |

## 重現

```bash
# 1) 重新產生樣例資料（固定隨機種子，可重現）
.venv/bin/python scripts/make_sample_data.py

# 2) 真機匯出並歸檔圖表（需 SPSS + 授權）
.venv/bin/python scripts/archive_sample_charts.py
```

## 在 MCP 工具中使用

任選一個 `.sav` 作為 `data_file` 傳給圖表工具即可，例如：

- 存活曲線：`spss_chart_km_curve(time="time", status="status", group="treatment", data_file="examples/data/survival_study.sav")`
- 問卷分佈：`spss_chart_histogram_density(variable="engagement_total", data_file="examples/data/survey_study.sav")`
- 實驗箱線圖：`spss_chart_boxplot(variable="posttest", category="group", data_file="examples/data/experiment_study.sav")`
