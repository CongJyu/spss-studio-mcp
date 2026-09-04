# SPSS Studio MCP: A Beginner-Friendly Tutorial for Agents

> **Language:** [English](tutorial.md) · [繁體中文（香港）](tutorial.zh-Hant-HK.md)

> Turn SPSS into a statistical engine and chart factory that Agents can call.
>
> Applies to: v0.3+ | Recommended environment: macOS, Python 3.10+, IBM SPSS Statistics for Mac (32 verified)

This tutorial is written for users who are coming to MCP, SPSS-MCP, or Agent workflows for the first time. You do not need to learn MCP first or memorize tool names. After installation, just tell the Agent in natural language where your data is, what question you want to answer, and what results you want.

## 1. Understand what it can do first

The traditional workflow is usually: open SPSS → import data → find the menus → set the parameters → run → tidy up the tables → export the images → write up the results.

SPSS Studio MCP hands most of that repetitive work over to the Agent:

- The Agent reads `.sav` / `.zsav` data and checks the variables, labels, missing values, and sample size;
- The Agent chooses descriptive statistics, t-tests, ANOVA, regression, mediation, moderation, survival analysis, and other methods according to the research question;
- MCP invokes the real IBM SPSS Statistics engine to run the analysis, rather than letting the language model guess the results;
- It returns Markdown tables, structured JSON, statistical summaries, `.sps` syntax, and `.spv` Viewer files;
- It exports 300 dpi charts in PNG or TIFF format as needed;
- It applies safety checks to dangerous syntax, data directories, and the execution process, and writes an audit log.

It suits thesis analysis, questionnaire research, experimental data, medical follow-ups, coursework, research assistants, and statistical workflows that need to be run repeatedly.

## 2. The fastest way: send this passage to your Agent

The passage below can be copied straight to Codex, Claude Code, or another MCP-capable Agent. It is a good idea to state the project directory, data directory, and the client you are currently using.

```text
Please install and configure SPSS Studio MCP for me so that you can call IBM SPSS Statistics directly for statistical analysis and publication-grade charts.

Project URL:
https://github.com/flupke91/spss-studio-mcp

Please follow this order and do not skip any check:

1. Check whether the current system has Python 3.10 or later, pip, and IBM SPSS Statistics installed.
2. If the project is not in the current directory, clone it; if the project already exists, go into the project directory and check whether it is the latest available code.
3. Install the project dependencies: pip install -e ".[dev]".
4. Run spss-studio-mcp status and tell me the status of pyreadstat, pandas, and SPSS batch.
5. Configure MCP automatically according to the Agent I am currently using:
   - If it is Codex, run spss-studio-mcp configure-codex;
   - If it is Claude Code, run spss-studio-mcp configure-claude;
   - If the client does not support automatic configuration, run spss-studio-mcp setup-info and give me the manual configuration snippet.
6. Check whether the configuration file was written successfully; if the configuration was changed, ask me to restart the Agent.
7. Install the skills that ship with the project (if the current project contains a skills directory) and explain where they were installed.
8. After the restart, run a minimal test with examples/data/survey_study.sav: read the variables, run descriptive statistics, and run a Cronbach's alpha reliability analysis.
9. Finally, tell me: whether the installation succeeded, which tools can be called, where the example result files are, and how I can make analysis requests in natural language next.

When an error occurs, first decide whether it is a Python, dependency, SPSS path, license, MCP configuration, or data path problem, then give the minimal fix. Do not delete my data, and do not modify the original data files.
```

If the Agent is not allowed to execute commands, ask it to explain the commands one at a time, run them in your terminal, and paste the output back. The Agent can then continue configuration and troubleshooting from the output.

## 3. Manual installation: follow along step by step

### 3.1 Check the environment

Run the following in a terminal:

```bash
python3 --version
python3 -m pip --version
```

Python should be 3.10 or later. Then confirm that IBM SPSS Statistics is installed and that its license is usable. SPSS Studio MCP's file-reading tools can work without the SPSS engine, but genuine statistical analysis and chart export require SPSS.

### 3.2 Get the project and install it

```bash
git clone https://github.com/flupke91/spss-studio-mcp.git
cd spss-studio-mcp
python3 -m pip install -e ".[dev]"
```

If the project is already on your machine, simply go into the project directory and run the install command. The development dependencies include testing and formatting tools; if you only want to run the service, you can also use `pip install -e .`.

### 3.3 Check the SPSS status

```bash
spss-studio-mcp status
```

Under normal conditions you will see something like the following:

```text
=== SPSS MCP Capability Status ===
pyreadstat : OK v...
pandas     : OK v...
SPSS batch : OK - /Applications/IBM SPSS Statistics/IBM SPSS Statistics.app/Contents/bin/spssengine
```

If it shows `SPSS batch : NOT FOUND`, do not rush to reinstall the dependencies. Set `SPSS_INSTALL_PATH` as described in Section 10, then run `status` again.

### 3.4 Automatically configure Codex

If you use Codex:

```bash
spss-studio-mcp configure-codex
```

The command updates Codex's `~/.codex/config.toml` and creates a backup before modifying any existing file. Restart Codex after it finishes so that it reloads the MCP server.

### 3.5 Automatically configure Claude Code

If you use Claude Code:

```bash
spss-studio-mcp configure-claude
```

The command updates Claude Code's user configuration and creates a backup when needed. Restart Claude Code after it finishes.

### 3.6 Manually configure other clients

First generate the configuration hint:

```bash
spss-studio-mcp setup-info
```

A common MCP configuration looks like this:

```json
{
  "mcpServers": {
    "spss": {
      "command": "spss-studio-mcp",
      "args": ["serve", "--transport", "stdio"]
    }
  }
}
```

The configuration file location and field names vary from client to client; defer to the client's documentation and to the `setup-info` output. After configuring, you must restart the client, or it may still not see the new tools.

## 4. First verification: have the Agent run a minimal task

After restarting the client, do not jump straight to testing with your own thesis data. Send the following passage to the Agent:

```text
First call spss_check_status and tell me which capabilities are currently available.
Then examine examples/data/survey_study.sav:
1. List the variable names, variable labels, variable types, and missing-value information;
2. Preview the first 10 rows of data;
3. Compute the mean, standard deviation, minimum, maximum, and sample size of engagement_total;
4. Run a Cronbach's alpha reliability analysis on q1 through q12;
5. Do not modify the original data; only return the analysis results and the paths of any generated files.
```

You should get:

- the data file and variable information;
- descriptive statistics tables;
- reliability statistics results;
- automatically generated statistical summaries;
- `.sps` and `.spv` file paths when relevant.

If this step succeeds, the Agent is able to discover the MCP tools and call SPSS Studio MCP.

## 5. How to give instructions to the Agent

Do not just say "help me analyze". A high-quality request contains at least five items:

1. **Data file**: a clear `.sav` file path;
2. **Research question**: what you want to compare, predict, explain, or describe;
3. **Variable roles**: dependent variable, independent variable, grouping variable, mediator, moderator;
4. **Analysis requirements**: whether assumption checks, effect sizes, post-hoc comparisons, and visualization are needed;
5. **Deliverable format**: a thesis results paragraph, Markdown table, syntax file, image, or structured JSON.

You can reuse this general template:

```text
Please analyze [data file path].

Research question: [state in one sentence the question you want to answer]
Dependent variable: [variable name and its meaning]
Independent or grouping variable: [variable name and its meaning]
Other variables: [covariate / mediator / moderator / time / individual ID]

Please follow this procedure:
1. First check the sample size, variable types, missing values, outliers, and any required assumptions;
2. If my chosen statistical method is not appropriate, explain why and choose a more suitable one;
3. Run the analysis and report the key statistics, p-values, confidence intervals, and effect sizes;
4. Provide an interpretation suitable for a thesis results section, but do not present correlations as causal relationships;
5. Save reproducible SPSS syntax and leave the original data unchanged;
6. If appropriate, generate publication-grade images and tell me their paths and formats.
```

## 6. Common research scenarios

### 6.1 Questionnaire: descriptive statistics, reliability, and between-group differences

```text
Please analyze examples/data/survey_study.sav.
First check the sample size, variable labels, missing values, and the value ranges of q1-q12.
Then complete the following:
1. Run a Cronbach's alpha reliability analysis on q1-q12;
2. Run descriptive statistics and a normality check on engagement_total;
3. Compare engagement_total by gender, first deciding whether an independent-samples t-test is appropriate;
4. Compare engagement_total by major using a one-way ANOVA, with post-hoc comparisons when needed;
5. Plot a histogram and a Q-Q plot of engagement_total;
6. Output the tables, statistical summary, thesis results paragraph, SPSS syntax, and image paths.
```

### 6.2 Experiment: pretest-posttest and between-group comparisons

```text
Please analyze examples/data/experiment_study.sav.
The variables are group, pretest, posttest, and gain.
First check the coding of group and the sample size of each group, then:
1. Report descriptive statistics of pretest and posttest for the two groups;
2. Compare whether posttest differs between the two groups;
3. Compare whether gain differs between the two groups;
4. Run a paired-samples t-test between pretest and posttest within the same subjects;
5. Report the mean difference, 95% CI, t, df, p, and effect size;
6. Generate a boxplot of posttest grouped by group;
7. Write a cautious result interpretation suitable for a thesis.
```

### 6.3 Correlation and regression: avoid presenting correlation as causation

```text
Please run correlation and regression analyses on examples/data/mediation_study.sav.
The research question concerns the relationships among autonomy, satisfaction, and performance.
First check the variable distributions and outliers, then complete the following:
1. Compute a Pearson correlation matrix;
2. Run a multiple linear regression with performance as the dependent variable and autonomy and satisfaction as predictors;
3. Report R², adjusted R², the model test, standardized coefficients, confidence intervals, and collinearity diagnostics;
4. Plot a scatter plot of satisfaction against performance;
5. Describe the results in terms of "association" and "prediction"; do not claim causal relationships directly.
```

### 6.4 Mediation analysis

```text
Please run a mediation analysis on examples/data/mediation_study.sav:
X = autonomy, M = satisfaction, Y = performance.

First check the sample size, missing values, and basic distributions of the three variables, then call the appropriate mediation analysis tool.
Report the total effect, direct effect, indirect effect a×b, the Sobel test, and the regression results of each step.
State clearly which statistical conclusions this analysis supports and which causal conclusions it cannot support,
and save the complete SPSS syntax and result files.
```

### 6.5 Moderation analysis

```text
Please run a moderation analysis on examples/data/mediation_study.sav:
X = autonomy, W = satisfaction, Y = performance.

Center X and W, and build a regression model that includes the main effects and the X×W interaction term.
Report the interaction coefficient, standard error, t, p, confidence interval, and the change in the model's explanatory power.
If the interaction is significant, explain the direction of moderation it indicates; if it is not significant, state clearly that a moderation effect is not supported.
Do not judge moderation from the main effects alone.
```

### 6.6 Survival analysis

```text
Please analyze examples/data/survival_study.sav.
The variables are treatment, time, and status, where status=1 means the event occurred.
Please complete the following:
1. Check the coding of time and status;
2. Plot Kaplan-Meier survival curves by treatment;
3. Compare survival between the groups;
4. Report the median survival time, confidence intervals, and log-rank results;
5. Explain how censored data are handled;
6. Output publication-grade PNG images and reproducible syntax.
```

## 7. Publication-grade charts

SPSS Studio MCP provides a range of `spss_chart_*` tools. Common choices are:

| Tool | Use case |
|------|----------|
| `spss_chart_histogram_density` | Displaying the distribution and normality of a continuous variable |
| `spss_chart_qqplot` | Normal Q-Q check |
| `spss_chart_scatter` | Relationship between two continuous variables |
| `spss_chart_bar_error` | Group means with 95% CI |
| `spss_chart_boxplot` | Between-group distributions, outliers, and medians |
| `spss_chart_errorbar` | Means and confidence intervals |
| `spss_chart_line` / `spss_chart_area` | Time-series or repeated-measures trends |
| `spss_chart_km_curve` | Kaplan-Meier survival curves |

A direct chart request to the Agent:

```text
Please use examples/data/survey_study.sav.
Using engagement_total as the variable, draw a publication-grade histogram overlaid with a normal density curve.
Requirements: PNG, 300 dpi, 1950×1500 pixels, with the title "Distribution of Total Engagement Scores".
Check whether the image was generated successfully, return its absolute path, and explain which section of the thesis this chart belongs in.
```

The image tools return usable file paths by default. Before submission you should still check fonts, axis titles, legends, resolution, and the journal's formatting requirements.

## 8. Output files and reproduction

A single analysis can produce the following results:

| File or field | Purpose |
|------------|------|
| Markdown | Read directly and copy into notes or reports |
| JSON | Consumed by scripts, web pages, or downstream Agents |
| `.sps` | Saves the SPSS syntax that was actually executed, for reproducibility |
| `.spv` | View the full output in SPSS Viewer |
| PNG / TIFF | For theses, presentations, or further typesetting |
| `logs/audit.jsonl` | Records the execution process and security audit information |

When data transformation is involved, explicitly ask the Agent to save to a new file:

```text
You may create derived variables, but do not overwrite the original data.sav.
Save the transformed data as data_derived.sav, and list the computation rule for each new variable in the results.
Use only data_derived.sav for subsequent analysis.
```

Note: each submission usually reloads the data file, so temporary variables created by a previous round of `COMPUTE` are not retained automatically. When you need to keep them, use `SAVE OUTFILE=...` to save to a new dataset.

## 9. Safety recommendations

- Let the Agent read the metadata first, and only then allow it to run complex analyses;
- Do not upload data containing ID numbers, bank card numbers, passwords, or other unnecessary sensitive information to an untrusted client;
- Ask the Agent not to overwrite the original data and to save derived data to new files;
- Validate unfamiliar syntax with `dry_run=True` rather than executing it directly;
- Keep the `.sps` syntax and audit logs so they can be reviewed later;
- Restrict the data directories the Agent may access to the project directory or a dedicated analysis directory.

The project blocks dangerous commands such as `HOST`, `ERASE`, and `DELETE FILE` by default and restricts data file paths. For the detailed rules, see the [security layer documentation](security.md).

## 10. SPSS path and environment variables

### 10.1 Set the SPSS install path

If automatic detection fails, create a `.env` file in the project directory.
`SPSS_INSTALL_PATH` may point at the SPSS engine, its `Contents/bin` directory,
or the `.app` bundle:

```ini
SPSS_INSTALL_PATH=/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app
```

You can also set it temporarily in the current shell session:

```bash
export SPSS_INSTALL_PATH="/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app"
spss-studio-mcp status
```

### 10.2 Adjust the timeouts

Starting the SPSS engine for the first time is usually slower than later calls. If the first startup times out, add the following to `.env`:

```ini
SPSS_STARTUP_TIMEOUT=300
SPSS_TIMEOUT=120
```

`SPSS_STARTUP_TIMEOUT` controls the first startup of the engine, and `SPSS_TIMEOUT` controls a single analysis task. For complex models you can raise the latter appropriately.

### 10.3 Set a data whitelist

If the data is stored outside the project directory, you can set the directories that are allowed to be accessed. See the configuration documentation of the current project version for the exact format; it is recommended to add only dedicated research data directories rather than opening up the whole disk.

## 11. Frequently asked questions

### `SPSS batch : NOT FOUND`

First confirm the actual location of the SPSS `.app` bundle (or the `spssengine` binary inside `Contents/bin`), then set `SPSS_INSTALL_PATH`. After setting it, reopen the terminal or run `status` again.

### The Agent cannot see the SPSS tools

Check the following in order:

1. whether the correct `configure-codex` or `configure-claude` was run;
2. whether the client has been restarted;
3. whether `spss-studio-mcp status` runs successfully;
4. whether the command in the client's configuration can be found in the current terminal;
5. whether multiple old SPSS MCP configurations are conflicting with one another.

### The first analysis is slow or times out

The first engine startup takes about 15–20 seconds, after which the engine usually stays resident. Do not open several SPSS sessions at once; raise `SPSS_STARTUP_TIMEOUT` or `SPSS_TIMEOUT` when necessary.

### A license warning appears, or image export fails

Confirm that the IBM SPSS Statistics license is valid, and check whether leftover `spssengine` processes are occupying the trial seats. End the leftover processes and retry, and avoid starting several SPSS sessions at the same time.

### The data file is rejected

Put the data in `examples/data/`, in the system temporary directory, or in a configured allowed directory. Do not try to bypass the safety restrictions by renaming files; set the data whitelist properly instead.

### Chinese variable labels are not displayed correctly

Prefer using variable names in the Prompt and ask the Agent to read the variable labels first. Internally the tools try to build a mapping between variable names and labels, but the statistical syntax should still use the variable names that actually exist in SPSS.

## 12. Final template for completing a full analysis in one go

Once you are familiar with the basic operations, you can send the following template directly to the Agent:

```text
Please act as my SPSS statistical analysis assistant. Analyze [data file path] and do not modify the original file.

Research background: [research subjects, research purpose, and hypotheses]
Data description: [sample size, meaning of the variables, grouping scheme, time structure]
Core question: [the statistical question you want to answer]

Please complete the following strictly in order:
1. Read the metadata and check variable types, labels, value ranges, missing values, and sample size;
2. Explain which statistical method is appropriate for each research question and why;
3. Run the required assumption checks and outlier checks;
4. Run the formal analysis and report estimates, standard errors, confidence intervals, test statistics, degrees of freedom, p-values, and effect sizes;
5. Generate publication-grade charts that match the research questions, in PNG at 300 dpi;
6. Provide a results explanation and a thesis results paragraph that can be edited and pasted directly into the paper;
7. Save the complete SPSS syntax, Viewer output, and image files;
8. Return the Markdown results, a structured summary, all output paths, and any warnings;
9. Finally, list the limitations of the results, and do not present cross-sectional correlations as causal relationships.

If the variable coding, study design, or statistical assumptions are unclear, point out the problem and ask me before proceeding; do not make assumptions on your own.
```

## 13. Developers and advanced users

Run the following in the project root directory:

```bash
python scripts/make_sample_data.py
python scripts/method_verification.py
python scripts/tool_verification.py
python scripts/archive_sample_charts.py
pytest
```

For implementation, result parsing, method verification, and safety boundaries, see respectively:

- [Technical report](technical_report.md)
- [Chart pipeline](poc_chart_pipeline.md)
- [Result parsing](result_parsing.md)
- [Method verification](method_verification.md)
- [Security layer](security.md)

If you want to hand a fixed research workflow to your team for repeated use, you can turn the prompt of "data checking → method selection → analysis → charting → thesis interpretation" into a team skill, and ask for `.sps` syntax and audit records on every run.
