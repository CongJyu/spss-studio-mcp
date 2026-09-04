# Method Verification

> **Language:** [English](method_verification.md) · [繁體中文（香港）](method_verification.zh-Hant-HK.md)

> Verified against real IBM SPSS Statistics 32 — on **Windows** (baseline) and
> **macOS** — using the bundled datasets in `examples/data/*.sav`. All cases are
> executed end-to-end through the MCP tools against a live SPSS engine.

## Summary

- **26 method cases — 26/26 pass** on Windows and 26/26 on macOS.
- Coverage: descriptives / frequencies / correlations / crosstabs /
  normality & outliers / reliability (Cronbach's alpha) / factor analysis /
  scale scoring / univariate GLM / MANOVA / independent, paired and one-sample
  t-tests / Mann-Whitney & Wilcoxon non-parametric tests / repeated-measures
  ANOVA / hierarchical & two-step cluster / discriminant analysis /
  Kaplan-Meier & Cox survival / logistic, ordinal and linear regression /
  linear mixed and generalized linear mixed models.
- Every analysis tool returns the parsed Markdown plus a `### Statistical
  Summary` block; the "marker" column reports whether each output contained the
  expected result marker.
- Per-case machine-readable results: `docs/method_verification.json`
  (Windows baseline) and `docs/method_verification_macos.json` (macOS).

## Method cases (macOS, real SPSS 32 for Mac)

| Case | Tool | OK | Marker | Sec |
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

> Environment: IBM SPSS Statistics 32.0.0.0 for Mac (`/Applications/IBM SPSS
> Statistics/IBM SPSS Statistics.app`), bundled Python 3.13.1; project runtime
> Python 3.14. Companion reports: [macOS verification](macos_verification.md),
> chart matrix and EMF notes therein; supporting-tool results in
> `docs/tool_verification_macos.json`.
