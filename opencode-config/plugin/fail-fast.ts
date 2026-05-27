/**
 * Fail Fast Plugin
 * Converts denied permissions and missing shell utilities into explicit task
 * failures so agents do not repeatedly retry or stall on unavailable actions.
 */

import type { Plugin } from "@opencode-ai/plugin"

const MISSING_UTILITY_PATTERNS = [
  /(?:^|\n)(?:sh|bash|zsh|fish):\s*(?<command>[\w./-]+):\s*command not found\b/i,
  /(?:^|\n)(?<command>[\w./-]+):\s*command not found\b/i,
  /(?:^|\n)(?:sh|bash|zsh|fish):\s*(?<command>[\w./-]+):\s*not found\b/i,
  /(?:^|\n)(?<command>[\w./-]+):\s*not found\b/i,
  /(?:^|\n)env:\s*(?<command>[\w./-]+):\s*No such file or directory\b/i,
  /(?:^|\n).*spawn\s+(?<command>[\w./-]+)\s+ENOENT\b/i,
]

const SHELL_BUILTINS = new Set([
  "alias",
  "break",
  "cd",
  "command",
  "continue",
  "dirs",
  "echo",
  "eval",
  "exec",
  "exit",
  "export",
  "false",
  "fg",
  "hash",
  "jobs",
  "popd",
  "printf",
  "pushd",
  "pwd",
  "read",
  "return",
  "set",
  "shift",
  "source",
  "test",
  "true",
  "type",
  "ulimit",
  "unalias",
  "unset",
])

function normalizeCommand(command: string): string {
  return command.replace(/^['"]|['"]$/g, "").trim()
}

function findMissingUtility(output: string): string | undefined {
  for (const pattern of MISSING_UTILITY_PATTERNS) {
    const match = pattern.exec(output)
    const command = match?.groups?.command

    if (!command) {
      continue
    }

    const normalized = normalizeCommand(command)

    if (normalized && !SHELL_BUILTINS.has(normalized)) {
      return normalized
    }
  }

  return undefined
}

function getBashCommand(args: unknown): string | undefined {
  if (!args || typeof args !== "object") {
    return undefined
  }

  const record = args as Record<string, unknown>
  const command = record.command ?? record.cmd ?? record.script

  return typeof command === "string" ? command : undefined
}

function describePermission(input: {
  type: string
  pattern?: string | string[]
  title: string
}): string {
  const pattern = Array.isArray(input.pattern)
    ? input.pattern.join(", ")
    : input.pattern

  return [input.type, pattern].filter(Boolean).join(" ") || input.title
}

export const FailFastPlugin = (async () => {
  return {
    "permission.ask": async (input, output) => {
      if (output.status !== "deny") {
        return
      }

      throw new Error(
        [
          "FAIL_FAST_PERMISSION_DENIED: A required tool permission was denied.",
          `Permission: ${describePermission(input)}`,
          `Title: ${input.title}`,
          "Next action: reroute to an agent with the required permission, request permission from the user, or fail the task explicitly.",
        ].join("\n")
      )
    },

    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") {
        return
      }

      const command = getBashCommand(output.args)

      if (command === undefined || command.trim()) {
        return
      }

      throw new Error(
        "FAIL_FAST_INVALID_COMMAND: The bash tool was called without a command. Stop and report the missing command instead of retrying."
      )
    },

    "tool.execute.after": async (input, output) => {
      if (input.tool !== "bash") {
        return
      }

      const missingUtility = findMissingUtility(output.output ?? "")

      if (!missingUtility) {
        return
      }

      const command = getBashCommand(input.args)

      const commandLine = command ? `\nCommand: ${command}` : ""

      throw new Error(
        [
          `FAIL_FAST_MISSING_UTILITY: Required shell utility "${missingUtility}" is not available in this environment.`,
          commandLine.trim(),
          "Next action: install or mount the missing utility, choose a different validation path, or fail the task explicitly.",
        ]
          .filter(Boolean)
          .join("\n")
      )
    },
  }
}) satisfies Plugin
