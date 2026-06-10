---
description: Review current git changes for readability, correctness, and project conventions
---

Review my current uncommitted git changes.

Focus primarily on readability and correctness. Also check whether the changes follow the existing practices and conventions used in this codebase.

Use git to inspect the changes:
- Start with `git status`
- Review unstaged changes with `git diff`
- Review staged changes with `git diff --staged`
- Inspect surrounding code where needed to understand conventions and intent

Review priorities:

1. Readability
   - Is the code easy to understand?
   - Are names clear and consistent?
   - Is the structure simple enough?
   - Are there unnecessary abstractions, clever tricks, or duplicated logic?
   - Would another developer understand the intent without excessive context?

2. Correctness
   - Does the code do what it appears intended to do?
   - Are edge cases handled properly?
   - Are there likely bugs, race conditions, null/undefined issues, off-by-one errors, or error-handling gaps?
   - Are tests needed or missing for the changed behavior?
   - Do existing tests need to be updated?

3. Project practices and conventions
   - Infer conventions from the surrounding code.
   - Check naming, file organization, error handling, logging, testing style, dependency usage, formatting, typing, and API patterns.
   - Do not impose external preferences unless they clearly improve readability, correctness, or consistency with the project.

Important behavior:
- If you are not absolutely certain about something, ask a clarifying question instead of making an assumption.
- Do not guess at intent when the code or context is ambiguous.
- Clearly distinguish between definite issues, likely issues, suggestions, and questions.
- Prioritize meaningful findings over nitpicks.
- Do not make changes automatically unless explicitly asked.
- If you recommend a change, explain why it improves readability, correctness, or consistency with project practices.

Output format:
1. Brief overall summary of the changes.
2. Findings grouped by severity:
   - Critical: likely correctness bugs, data loss, security issues, or broken behavior.
   - Major: important readability, maintainability, or convention problems.
   - Minor: smaller improvements or cleanup.
   - Questions: anything that needs clarification before judging.
3. For each finding, include:
   - File and location if available.
   - What the issue is.
   - Why it matters.
   - Suggested fix or next step.
4. Recommended tests or verification steps.
