# OpenCode Web

Dockerized [OpenCode](https://opencode.ai) with [OpenChamber](https://github.com/openchamber/openchamber) as the browser/PWA frontend.

## What it does

This project runs OpenChamber in the container and lets OpenChamber start and keep OpenCode available in the background.

The stack inside the container:

- **OpenCode CLI** — the AI coding assistant
- **OpenChamber** — web frontend that starts and presents OpenCode
- **Node 20** — runtime

## Orchestrator agent workflow

The primary agent definition lives at `opencode-config/agent/orchestrator.md`.
It is the master coordinator for multi-step work: it decides how much process a
request needs, delegates focused work to specialist agents, and synthesizes their
results before responding.

The orchestrator is configured as `mode: primary`. It can delegate tasks to any
subagent and ask the user clarification questions, but it cannot write files,
edit files, or run bash commands. Any file change must be delegated to an editing
subagent, normally `coder` for implementation work. Command execution and
verification must go through agents with bash access.

### Priorities

The orchestrator follows these priorities, in order:

1. Choose the lightest safe workflow. Direct answers are preferred when no
   codebase investigation or edit is needed.
2. Fail fast when a required tool, permission, shell utility, or agent capability
   is missing. Do not ask an agent to work around missing permissions.
3. Ask before guessing when ambiguity affects behavior, compatibility, security,
   data shape, user experience, or scope.
4. Prefer existing project patterns and simple changes over clever or broad
   rewrites.
5. Parallelize independent exploration, implementation, or review work when it
   is safe to do so.
6. Verify with evidence when the risk justifies it, and clearly report anything
   that was not verified.
7. Synthesize subagent outputs into a clear result instead of forwarding raw
   reports.

### Routing tiers

| Tier | Use when | Workflow |
| --- | --- | --- |
| Tier 0: Direct response | The request is conversational, explanatory, or does not need repo-specific investigation or edits. | Answer directly. Use `scout` first only if current or external web information is needed. |
| Tier 1: Fast-path small clear work | The task is trivial or localized, the target files are obvious, and design trade-offs are not needed. | Send one focused task to `coder`. Use `validator` or `reviewer` only when risk, tests, user-facing behavior, or the user request calls for it. |
| Tier 2: Standard orchestration | The task is medium-sized, needs codebase context, or has some implementation sequencing or risk. | Use targeted `explore` work, ask blocking questions if needed, use `architect` for a plan when design judgment helps, then delegate implementation to `coder` and verify selectively. |
| Tier 3: Full orchestration | The task is large, ambiguous, cross-cutting, risky, user-facing, or affects public APIs, data models, security, or performance. | Explore first, clarify before implementation, use `architect` for a structured plan, split work into focused coder tasks, and use `validator` and/or `reviewer` before delivery. |

### Standard workflow

1. Triage the request. Decide whether it needs edits, codebase context, design,
   tests, review, or only a direct answer.
2. Understand the context. Use `scout` for current or external web research and
   `explore` for repo context. Run independent exploration in parallel.
3. Plan the work. For small work, write a focused coder instruction directly.
   For medium or larger work, use `architect` to produce scoped subtasks,
   dependencies, acceptance criteria, and verification guidance.
4. Implement through editing subagents. The orchestrator never edits files
   itself. It sends focused tasks to `coder`, running independent tasks in
   parallel and dependent tasks in sequence.
5. Verify the final state. Use `validator` for tests, builds, lint, typechecks,
   runtime checks, and acceptance criteria. Use `reviewer` for strict code review
   when changes are risky, broad, or user-facing.
6. Deliver a synthesized result. Summarize what changed, list modified files,
   report verification results, and call out assumptions, risks, or follow-up
   work when relevant.

### Subagent responsibilities

| Agent | Access | Primary responsibility | Use for | Not for |
| --- | --- | --- | --- | --- |
| `architect` | Read-only, no bash | Turn requirements and exploration findings into a scoped implementation plan. | Medium, large, ambiguous, cross-cutting, or risky work that needs sequencing, dependencies, acceptance criteria, or verification guidance. | Editing files, running commands, or inventing missing codebase details. |
| `coder` | Write/edit, no bash | Implement one assigned subtask with the smallest correct change. | Focused implementation work after scope is clear, using existing patterns and preserving unrelated behavior. | Running tests, builds, formatters, package installs, commits, or broad unassigned refactors. |
| `docs-writer` | Write/edit, no bash | Create or update technical documentation based on verified project facts. | README updates, API docs, guides, inline docs, and architecture docs. | Running commands, inventing functionality, or documenting unverified command output as fact. |
| `validator` | Read-only, bash allowed | Prove whether completed work satisfies the original request. | Tests, builds, lint, typecheck, runtime checks, acceptance criteria, and final evidence gathering. | Editing files, destructive commands, or declaring success without evidence. |
| `reviewer` | Read-only, no bash | Strictly review code for correctness, safety, maintainability, test coverage, and scope control. | Post-change review, risky logic, public behavior changes, security or performance-sensitive areas, and explicit review requests. | Fixing issues directly, running commands, or approving without inspected evidence. |
| `refactorer` | Write/edit, no bash | Improve code structure without changing external behavior. | Focused cleanup when refactoring is explicitly needed and the behavior is understood. | Feature work, behavior changes, command execution, or risky refactors that require tests before editing. |
| `debugger` | Read-only, bash allowed | Reproduce failures and identify root causes with evidence. | Failing tests, crashes, errors, logs, environment issues, dependency conflicts, and regression investigation. | Editing source code or applying fixes directly. |
| `executor` | Bash only, no file read/edit tools | Run shell commands requested by the caller and report stdout, stderr, and exit status. | Command-only work where no planning, file inspection, or code editing is needed. | General coding, research, planning, file edits, or non-command tasks. |
| `scout` | Built-in research agent | Gather current or external web information. | Fresh facts, external documentation, releases, web research, or anything that may have changed outside the repo. | Codebase exploration. |
| `explore` | Built-in codebase context agent | Inspect repository structure, ownership, patterns, and affected areas. | Non-trivial repo context, unfamiliar code paths, broad searches, and multiple possible affected areas. | Web research or current external information. |

### Fail-fast behavior

Every agent is expected to check its required capabilities before doing work.
When a required permission, tool, shell utility, or evidence source is missing,
the agent should return a `FAIL_FAST_*` result with the missing capability, why it
is required, and the next safe action. The orchestrator may reroute once to an
agent with the required capability; otherwise, it must report the failure clearly
instead of retrying the same blocked path.

## How to run

```bash
docker compose up -d
```

Open `http://localhost:5200` in your browser.

To run OpenChamber on a different port, set `OPENCHAMBER_PORT` in `.env` and restart the container:

```env
OPENCHAMBER_PORT=5300
```

The container uses host networking, so OpenChamber binds directly to `OPENCHAMBER_PORT`; there is no separate Docker port mapping to update.

To protect the UI, set `UI_PASSWORD` in `.env`.

## How to update

Rebuild the image to pull the latest versions of OpenCode and OpenChamber:

```bash
docker compose build --no-cache
docker compose up -d
```

## Managing repositories

Set `REPOSITORIES_PATH` in `.env` to the host directory that contains repositories OpenCode should work on:

```env
REPOSITORIES_PATH=./repositories
```

The directory is mounted at `/home/repositories` inside the container.

## Browser and PWA notifications

OpenChamber can send browser notifications for prompt completion, questions, errors, and subtasks.

To receive notifications, open OpenChamber in your browser or installed PWA and allow notifications for the site/app when prompted. If notifications were previously blocked, reset the site notification permission in your browser settings.
