# 方法真機驗證

> **語言：** [English](method_verification.md) · 繁體中文（香港）

> 已於真實 IBM SPSS Statistics 32 **Windows（基線）及 macOS** 上驗證，使用
> `examples/data/*.sav` 內建的資料集。所有案例均經 MCP 工具鏈對一個執行中的
> SPSS 引擎端到端執行。

## 摘要

- **26 個方法案例 —— 26/26 通過**（Windows 及 macOS 均為 26/26）。
- 涵蓋範圍：描述性統計／次數分配／相關／交叉表／常態性與離群值／信度
  （Cronbach's alpha）／因素分析／量表計分／單變量 GLM／MANOVA／獨立樣本、
  配對及單一樣本 t 檢定／Mann-Whitney 與 Wilcoxon 無母數檢定／重複量數 ANOVA／
  階層與兩階段集群／判別分析／Kaplan-Meier 與 Cox 存活分析／邏輯斯、次序與
  線性迴歸／線性混合及廣義線性混合模型。
- 每個分析工具都會回傳經剖析的 Markdown 及一個 `### Statistical Summary`
  區塊；「Marker」欄反映每個輸出是否包含預期的結果標記。
- 逐案例、機器可讀的結果：`docs/method_verification.json`（Windows 基線）及
  `docs/method_verification_macos.json`（macOS）。

## 方法案例（macOS，真實 SPSS 32 for Mac）

| 案例 | 工具 | OK | Marker | 秒 |
|---|---|---|---|---|
| descriptives | `spss_descriptives` | ✓ | ✓ | 1.2 |
| frequencies | `spss_frequencies` | ✓ | ✓ | 0.4 |
| correlations | `spss_correlations` | ✓ | ✓ | 0.3 |
| crosstabs | `spss_crosstabs` | ✓ | ✓ | 0.4 |
| normality_outliers | `spss_normality_outliers` | ✓ | ✓ | 0.6 |
| reliability_alpha | `spss_reliability_alpha` | ✓ | ✓ | 0.4 |
| factor | `spss_factor` | ✓ | ✓ | 0.4 |
| compute_scale_score | `spss_compute_scale_score` | ✓ | ✓ | 0.3 |
| glm_univariate | `spss_glm_univariate` | ✓ | ✓ | 0.4 |
| cluster_hierarchical | `spss_cluster_hierarchical` | ✓ | ✓ | 0.8 |
| twostep_cluster | `spss_twostep_cluster` | ✓ | ✓ | 0.5 |
| discriminant | `spss_discriminant` | ✓ | ✓ | 0.4 |
| manova | `spss_manova` | ✓ | ✓ | 0.3 |
| ttest_independent | `spss_t_test` | ✓ | ✓ | 0.3 |
| ttest_paired | `spss_t_test` | ✓ | ✓ | 0.3 |
| ttest_one_sample | `spss_t_test` | ✓ | ✓ | 0.3 |
| nonparam_mann_whitney | `spss_nonparametric_tests` | ✓ | ✓ | 0.4 |
| nonparam_wilcoxon | `spss_nonparametric_tests` | ✓ | ✓ | 0.4 |
| repeated_measures_anova | `spss_repeated_measures_anova` | ✓ | ✓ | 0.4 |
| kaplan_meier | `spss_kaplan_meier` | ✓ | ✓ | 0.6 |
| cox_regression | `spss_cox_regression` | ✓ | ✓ | 0.4 |
| logistic_regression | `spss_logistic_regression` | ✓ | ✓ | 0.4 |
| regression | `spss_regression` | ✓ | ✓ | 0.4 |
| ordinal_regression | `spss_ordinal_regression` | ✓ | ✓ | 0.4 |
| mixed | `spss_mixed` | ✓ | ✓ | 0.5 |
| genlinmixed | `spss_genlinmixed` | ✓ | ✓ | 2.8 |

> 環境：IBM SPSS Statistics 32.0.0.0 for Mac（`/Applications/IBM SPSS
> Statistics/IBM SPSS Statistics.app`）、內建 Python 3.13.1；專案執行環境
> Python 3.14。相關報告：[macOS 真機驗證](macos_verification.zh-Hant-HK.md)、
> 圖表矩陣及當中之 EMF 說明；輔助工具結果見
> `docs/tool_verification_macos.json`。
