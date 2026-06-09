---
name: graphify-cost-estimator
description: Estimate token usage, chunk counts, and optional dollar cost before generating a graph with graphify. Use when the user asks how expensive graphifying a repo will be, wants a preflight estimate before `/graphify` or `graphify extract`, compares graphify backends, or wants to identify the largest semantic extraction cost drivers without making LLM calls.
---

# Graphify Cost Estimator

Use this skill to estimate graphify semantic extraction cost before creating a graph. It is intentionally a preflight workflow: do not run semantic extraction, do not require API keys, and do not create or update `graphify-out/`.

## Workflow

Run the portable estimator command from the target repo:

```bash
graphify-estimate-cost .
```

For a specific repo or folder:

```bash
graphify-estimate-cost /path/to/repo
```

For machine-readable output:

```bash
graphify-estimate-cost /path/to/repo --json
```

## Options

- Use `--backend NAME` to price one graphify backend.
- Use `--all-backends` to compare common packaged graphify backends.
- Use `--price-input-usd-per-m N --price-output-usd-per-m N` when the user provides current or custom pricing.
- Use `--output-ratios 0.10,0.25,0.50` to change the low/base/high output-token assumptions.
- Use `--token-budget N` to match a planned `graphify extract --token-budget N` run.

## Interpreting Results

- Code files are local AST work and do not add semantic LLM token cost.
- Docs, papers, and images drive semantic extraction cost.
- Dollar estimates use graphify's packaged pricing table unless explicit price override flags were provided.
- Video/audio files are reported as a warning; transcribe them first for a complete token estimate.
- Output tokens are a range because graph density depends on the corpus and model behavior.
