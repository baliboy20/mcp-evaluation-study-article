# Conventions

## Study IDs
Three-digit, zero-padded, plus a short kebab-case name: `001-tool-selection`.
The same ID names the study folder and its results folder.

## Results
`results/<study-id>/<YYYY-MM-DD>-run<N>/` containing:
- `run.json`: metadata (agent, model, MCP server version, data seed, start/end time)
- `transcripts/`: raw agent transcripts (JSONL)
- `metrics.csv`: one row per task/trial
- `notes.md`: anything unusual during the run

Keep raw outputs unedited; put derived analysis in `analysis/` beside them.

## Synthetic data
Every dataset must be reproducible: record the generator script and seed in a
`README.md` next to the data. Never commit real personal data or secrets.

## MCP servers
One folder per server under `mcp-servers/<name>/` with its own README describing
tools exposed, how to run it, and which studies use it.

## Articles
`articles/<YYYY-MM>-<slug>.md`. Cite studies by ID and link to their results.
