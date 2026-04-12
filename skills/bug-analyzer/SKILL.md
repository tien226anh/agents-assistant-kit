---
name: bug-analyzer
description: Deep-dive triage of bugs, logs, stack traces, and crash reports. Use when the user asks to analyze a bug, perform root cause analysis (RCA), understand why a crash happened, or review logs to find an anomaly. Generates diagnostic reports instead of just patching code.
---

# Bug Analyzer Workflow

## When to use
Use this skill when you need to understand *why* a complex bug is occurring via logs, stack traces, and code analysis, rather than just writing a quick fix. This is for Root Cause Analysis (RCA).

## ⚠️ Command Safety
This skill involves forensic analysis. You may run **read-only diagnostic commands** (e.g., viewing logs via `cat \/var\/log\/...` or `kubectl logs`). Never execute scripts that modify data or code without explicit user permission.

## Bug Analysis Process

When analyzing a bug, execute the following steps in order:

### 1. Information Gathering
- Identify the exact error message, stack trace, or unexpected behavior.
- Use `grep_search` to find where the error message originates in the codebase.
- Look for accompanying logs or metrics leading up to the failure.
- Ask the user clarifying questions about the environment (OS, dependencies, recent changes) if necessary.

### 2. State & Data Flow Tracing
- Trace the variables involved in the stack trace backward through the call stack.
- Identify external inputs (API requests, database reads, env vars) that could have triggered the faulty state.
- Formulate a hypothesis for how the application entered the invalid state.

### 3. Hypothesis Validation
- Cross-reference the hypothesized state against the code. Are there missing null checks? Race conditions? Type mismatches?
- If permitted, write a temporary minimal reproducible script to isolate the issue, or mentally simulate the edge case.

### 4. Root Cause Analysis (RCA) Report
Provide a structured response using this format:

```markdown
### 🐞 Bug Analysis Report

**Symptom:**
(What is the observable failure?)

**Root Cause:**
(Why did it fail? Explain the exact code execution path and the data payload that triggered it.)

**Impact:**
(Is this limited to an edge case or a critical system flaw?)

**Proposed Fixes:**
1. [Ideal Solution]: (Architectural or comprehensive fix)
2. [Quick Patch]: (Immediate tactical fix to restore functionality)
```

## Anti-Patterns
- **Do not guess:** If a log file is missing, ask the user to provide it.
- **Do not mix analysis with execution:** Keep the RCA report separate from the code fix. Only write the code fix after the root cause is confirmed by the user.
