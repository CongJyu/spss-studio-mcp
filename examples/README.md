# Archived Real-Machine Sample Charts (P1)

> **Language:** [English](README.md) · [繁體中文（香港）](README.zh-Hant-HK.md)

> Generated: 2026-08-04 | Engine: IBM SPSS Statistics 32.0.0 | Images: PNG 1950×1500 @300 dpi

Four sets of sample data close to paper scenarios, together with their
representative charts, are used to demonstrate and regression-test the
`spss_chart_*` tools.

## Contents

- `data/` — SPSS data files for the four scenarios (.sav, with variable / value labels)
- `charts/` — 11 PNG charts exported with the real SPSS engine

## Datasets

| File | Scenario | N | Key variables |
|------|----------|------|----------|
| `data/survey_study.sav` | Survey: university students' learning engagement | 200 | `gender`/`major`/`q1`-`q12`/`cognitive`/`affective`/`behavioral`/`engagement_total` |
| `data/experiment_study.sav` | Experiment: memory-training pre-test / post-test | 120 | `group` (training/control)/`pretest`/`posttest`/`gain` |
| `data/survival_study.sav` | Survival: treatment-arm follow-up | 150 | `treatment`/`time`/`status` (1=death, 0=censored) |
| `data/mediation_study.sav` | Mediation: work autonomy → satisfaction → performance | 300 | `autonomy`/`satisfaction`/`performance` |

## Chart List (examples/charts)

| Chart | Scenario | Tool |
|-------|----------|------|
| `survey_engagement_histogram_density.png` | Survey | `spss_chart_histogram_density` |
| `survey_engagement_by_major.png` | Survey | `spss_chart_bar_error` |
| `survey_engagement_by_gender.png` | Survey | `spss_chart_errorbar` |
| `experiment_posttest_boxplot.png` | Experiment | `spss_chart_boxplot` |
| `experiment_gain_errorbar.png` | Experiment | `spss_chart_errorbar` |
| `experiment_posttest_bar.png` | Experiment | `spss_chart_bar` |
| `survival_km_curve.png` | Survival | `spss_chart_km_curve` |
| `survival_time_histogram.png` | Survival | `spss_chart_histogram` |
| `mediation_autonomy_performance_scatter.png` | Mediation | `spss_chart_scatter` |
| `mediation_satisfaction_performance_scatter.png` | Mediation | `spss_chart_scatter` |
| `mediation_performance_histogram_density.png` | Mediation | `spss_chart_histogram_density` |

## Reproduction

```bash
# 1) Regenerate the sample data (fixed random seed; reproducible)
python scripts/make_sample_data.py

# 2) Export and archive the charts on a real machine (requires SPSS for Mac + a licence)
python scripts/archive_sample_charts.py
```

## Using the Charts with MCP Tools

Just pass any `.sav` file as `data_file` to a chart tool, for example:

- Survival curve: `spss_chart_km_curve(time="time", status="status", group="treatment", data_file="examples/data/survival_study.sav")`
- Survey distribution: `spss_chart_histogram_density(variable="engagement_total", data_file="examples/data/survey_study.sav")`
- Experiment box plot: `spss_chart_boxplot(variable="posttest", category="group", data_file="examples/data/experiment_study.sav")`
