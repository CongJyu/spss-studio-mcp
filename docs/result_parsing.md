# P2 Result Parsing: Markdown + JSON + Statistical Summary

> **Language:** [English](result_parsing.md) · [繁體中文（香港）](result_parsing.zh-Hant-HK.md)

> Implementation date: 2026-08-05 | Developed against the real OMS TEXT output of SPSS Statistics 32.0.0

## Goal

Turn SPSS text output into machine-readable JSON (at table level), automatically extract the key statistics needed for reporting in a paper (t / F / r / B / Wald / p / effect sizes, etc.), and finally unify everything into the `{markdown, json, files, warnings}` return structure.

## Modules

`src/spss_mcp/result_parser.py`

| Function | Purpose |
|------|------|
| `parse_tables(raw_text)` | Line-scanning state machine that splits SPSS table blocks into `[{title, headers, rows}]` (JSON-friendly) |
| `summarize_analysis(raw_text)` | Identifies the analysis type from the table title, extracts statistics, and generates a plain-language conclusion |
| `build_result_payload(result)` | Assembles the unified structure `{markdown, json, files, warnings}` |

`src/spss_mcp/spss_runner.py`: the return value of `run_syntax` now includes additional `tables` / `summary` / `files` fields (additive; existing tools are not broken).

`src/spss_mcp/server.py`: adds a new tool, **`spss_structured_result`**, which runs arbitrary syntax and returns a unified JSON structure; at the same time, `_format_run_result` automatically appends the statistical summary to the end of the return of every analysis tool (`spss_t_test` / `spss_regression` / `spss_anova`, etc.), as a `### Statistical Summary` section.

## Parsing Rule Highlights (Real SPSS TEXT Layout)

- Table titles are short standalone lines at the start of a line with no indentation; indented lines are part of a header/data row and are never mistaken for a new table.
- Cells joined by a single space (row-label-to-value concatenations such as `Kolmogorov-Smirnov(a) Shapiro-Wilk`) are handled by an "entire-line text + numeric regex" approach rather than relying on strict column alignment.
- Header-detection heuristic: a first line containing decimals (`.000`, `-3.875`) is treated as a data row; otherwise it is treated as a header (headers that contain integers, such as `-2 Log likelihood`, are still correctly classified as headers).
- A subtitle (e.g., `Dependent Variable xxx`) is merged into the title only once, and only when the line is plain text containing no digits.
- `Notes` blocks are skipped entirely; numbers carrying an `(a)` footnote can still be parsed; p values of `.000` are reported as `<.001`.

## Statistical Summary Coverage (Verified on 16 Real Outputs)

| Analysis | Tables | Extracted items | Example output |
|------|----|--------|----------|
| Descriptives | `Descriptive Statistics` | Per-variable N/Min/Max/Mean/Std | `score: N=120, Mean=54.20, SD=11.23` |
| Independent-samples t test | `Independent Samples Test` / `Group Statistics` | t, df, p, mean difference, group statistics | `t(118) = -3.88, p < .001, MD = -7.52` |
| Paired-samples t test | `Paired Samples Test` | t, df, p, mean difference | `t(119) = -12.84, p < .001, MD = -9.88` |
| One-way ANOVA | `ANOVA` + Levene | F, df1, df2, p, Levene F | `F(1, 118) = 15.01, p < .001` |
| Factorial ANOVA | `Tests of Between-Subjects Effects` | Per-effect F/df1/p/partial η² | `gender: F(1, 194) = .34, η² = .002` |
| Correlation | `Correlations` | r, p | `y-x: r = .42, p < .001` |
| Linear regression | `Model Summary` / `ANOVA` / `Coefficients` | R, R², F, B/Beta/t/p | `R = .82, R² = .68; x: B = .92, Beta = .48` |
| Logistic regression | `Model Summary` / `Variables in the Equation` | -2LL, Cox & Snell/Nagelkerke R², B/SE/Wald/Exp(B)/p | `x: B = .19, Wald = .16, p = .69, OR = 1.21` |
| Frequencies | `Statistics` | N/Mean/Median/Mode/Std | `N=120, Mean=.50` |
| Chi-square | `Chi-Square Tests` | χ², df, p | `χ²(2) = .61, p = .739` |
| Reliability | `Reliability Statistics` | Cronbach's α, number of items | `α = .82 (12 items)` |
| Nonparametric | `Test Statistics` | Mann-Whitney U/Wilcoxon Z/K-W H, df, p | `U = 1088.50, z = -3.72, p < .001` |
| Normality | `Tests of Normality` | Shapiro-Wilk W, K-S D, df, p | `W(200) = .99, p = .101` |
| Factor analysis | `KMO and Bartlett's Test` / `Total Variance Explained` | KMO, Bartlett χ², eigenvalues, cumulative variance | `KMO = .50, χ²(66) = 64.68` |

## Tests

- 16 real-output fixtures: `tests/fixtures/spss_outputs/*.txt`
- `tests/test_result_parser.py`: 23 assertions cover parsing, summaries, and the unified structure for all types
- Real-machine verification: `run_syntax` returns complete `summary` and `tables` for T-TEST

## Usage

```python
from spss_mcp.spss_runner import run_syntax
result = await run_syntax("T-TEST GROUPS=g(0 1) /VARIABLES=score.")
result["summary"]["text"]   # plain-language conclusion
result["summary"]["summaries"]  # structured statistics
result["tables"]            # JSON-friendly tables
```

MCP clients can call `spss_structured_result` to get the unified JSON return.
