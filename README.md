# MCP Evaluation Study

Practical studies and lab tests that evaluate Model Context Protocol (MCP) servers
with live agents, synthetic data, and custom MCP servers, plus the articles written
from the findings.

## Layout

| Folder | What goes there |
|---|---|
| `articles/` | Written articles and drafts (Markdown), one file or folder per article |
| `studies/` | One folder per study/lab test: hypothesis, setup, procedure, findings |
| `studies/_template/` | Copy this to start a new study |
| `results/` | Raw and processed run outputs, organised by study ID and run date |
| `mcp-servers/` | Source for custom MCP servers used in the studies |
| `synthetic-data/` | Generated datasets and the `generators/` that produce them |
| `agents/` | Agent configurations, prompts and harness scripts used for live runs |
| `docs/` | Methodology, conventions and evaluation criteria |

## Workflow

1. Copy `studies/_template` to `studies/NNN-short-name` (e.g. `studies/001-tool-selection`).
2. Fill in `study.md`: question, hypothesis, setup, metrics.
3. Build or reuse an MCP server in `mcp-servers/` and data in `synthetic-data/`.
4. Run the agents; save outputs to `results/NNN-short-name/YYYY-MM-DD-runN/`.
5. Record findings back in `study.md`; write up in `articles/`.

See `docs/conventions.md` for naming and result-file formats.
