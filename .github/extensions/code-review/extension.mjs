import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { defineWorkflow, joinSession } from "@microsoft/copilot-sdk/extension";

const CRITIC_AGENTS = ["rubber-duck", "general-purpose"];
// Workflow-declared agents get no file or shell tools, so lenses run as a built-in catalog agent.
const LENS_AGENT = "rubber-duck";
const LOCAL_REVIEW_RULE =
  "Use only this repository's local diff and relevant source, tests, configuration, and documentation; follow " +
  "code references only as needed to verify findings. Do not use web searches or fetches, remote GitHub lookups, " +
  "past sessions, other repositories, or network commands. If local evidence is insufficient, report that " +
  "limitation instead of researching externally.";
const GUIDES =
  "Before assessing conventions, read .github/copilot-instructions.md, the rules it names as authoritative, and " +
  "any README.md in a changed file's directory or its parents.";
const LENSES = {
  smell: {
    heading: "Code smell",
    task:
      "Find code in the change that is hard to maintain, written for no present need (speculative options, " +
      "configuration, parameters, or abstractions), or over-optimistic about failures: missing tools or " +
      "packages, absent paths, existing files at link targets, failed installs or downloads, and differences " +
      "between Windows and Linux or PowerShell 5 and 7. Check how surrounding scripts handle the same failure " +
      "before reporting.",
  },
  dead_code: {
    heading: "Dead code",
    task:
      "Find code the change adds that nothing uses, and existing code the change makes unused (removed " +
      "callers, unreachable branches, settings no longer read, or files no longer deployed). Configs are " +
      "consumed indirectly: search the whole repository before reporting, including Windows setup.ps1 and " +
      "Linux setup link maps, autosetup lists, dot-sourced scripts, imported modules and their exports, " +
      "Neovim requires, plugin specs and keymaps, git includes and hooks, Copilot agents, skills and MCP " +
      "config, and project files. A file is used when a link map deploys it where its tool loads it.",
  },
  design: {
    heading: "Logic and design",
    task:
      "Find logic errors, and places where the change departs from the repository's established patterns " +
      "or where a better-organised, more maintainable design exists that is no larger. Trace changed config " +
      "through its setup link map to the tool that loads it, on both Windows and Linux where the package " +
      "supports both. Cite the existing pattern (file and line) the change should follow.",
  },
  performance: {
    heading: "Performance",
    task:
      "Find performance problems a user would notice. Examine shell, prompt, completion, and editor startup " +
      "and per-keystroke paths, helper tools and skill scripts on realistic input, and autosetup work " +
      "repeated per package where affected. Show why the path is hot and the likely impact. Ignore " +
      "micro-optimisations and cold paths.",
  },
  simplification: {
    heading: "Simplification",
    task:
      "Question every changed hunk: is it needed for the change's goal? Find what makes the change larger " +
      "than the minimal complete change: extra scripts, extra tests, extra options, handling of cases that " +
      "cannot occur, or custom code where an existing helper, tool option, or platform feature would do. " +
      "Name exactly what to remove or replace.",
  },
  tests: {
    heading: "Tests",
    task:
      "Where the changed component already has a test project or test scripts, check that they cover the " +
      "changed behaviour with assertions that fail without the change: each new or changed branch, boundary, " +
      "error, and success case. Do not request new test suites for configs, setup scripts, or utilities that " +
      "have none. Also report tests that are redundant, cover unchanged code, or restate the implementation. " +
      "Do not build or run tests.",
  },
};
const REPO_ROOT = fileURLToPath(new URL("../../../", import.meta.url));
const SEVERITY_ORDER = { high: 0, medium: 1, low: 2 };

const FINDINGS_SCHEMA = {
  type: "object",
  required: ["findings"],
  additionalProperties: false,
  properties: {
    findings: {
      type: "array",
      items: {
        type: "object",
        required: ["file", "line", "severity", "title", "evidence", "suggestion"],
        additionalProperties: false,
        properties: {
          file: { type: "string" },
          line: { type: "integer" },
          severity: { type: "string", enum: ["high", "medium", "low"] },
          title: { type: "string" },
          evidence: { type: "string" },
          suggestion: { type: "string" },
        },
      },
    },
  },
};
const VERDICTS_SCHEMA = {
  type: "object",
  required: ["verdicts"],
  additionalProperties: false,
  properties: {
    verdicts: {
      type: "array",
      items: {
        type: "object",
        required: ["id", "verdict", "reason"],
        additionalProperties: false,
        properties: {
          id: { type: "string" },
          verdict: { type: "string", enum: ["accept", "downvote", "reject"] },
          reason: { type: "string" },
        },
      },
    },
  },
};
const REVIEWER_PROMPT = `You are one lens of a multi-lens code reviewer for dotfiles, a personal configuration
repository whose setup scripts install packages and link configs on Windows and Linux, alongside PowerShell modules,
Neovim Lua, Copilot customisations, and small C# and Python tools.
- Read-only: never edit, stage, commit, push, or post anywhere. Never run setup scripts, build, or run tests.
- ${LOCAL_REVIEW_RULE}
- Report only issues within your lens, in the change or in code the change directly affects.
- Verify every finding in the source and cite its file and line (0 when no line applies). No speculation.
- ${GUIDES}
- Prefer fewer certain findings. Return an empty list when there are none.
- Severity: high = likely defect or lasting maintenance burden; medium = should fix before merge; low = optional.`;

function git(...args) {
  return execFileSync("git", ["-C", REPO_ROOT, ...args], { encoding: "utf8" }).trim();
}

function lines(text) {
  return text.split(/\r?\n/).filter(Boolean);
}

function resolveScope(requestedBase) {
  let defaultRef = "origin/main";
  try {
    defaultRef = git("symbolic-ref", "--short", "refs/remotes/origin/HEAD");
  } catch {
    // origin/HEAD is unset in clones that never ran `git remote set-head`.
  }
  // Resolving to a commit keeps an option-like base out of the git diff arguments.
  const base = requestedBase
    ? git("rev-parse", "--verify", "--end-of-options", `${requestedBase}^{commit}`)
    : git("merge-base", "HEAD", defaultRef);
  const changed = lines(git("diff", "--name-status", base));
  const untracked = lines(git("ls-files", "--others", "--exclude-standard")).map((file) => `?\t${file}`);
  return { base, files: [...changed, ...untracked] };
}

function changeBrief(scope) {
  return (
    `The change is the diff between base ${scope.base} and the working tree: run \`git diff ${scope.base}\` ` +
    `and read untracked files (status ?). Changed files:\n${scope.files.join("\n")}`
  );
}

function lensPrompt(lens, scope) {
  return `${REVIEWER_PROMPT}

${changeBrief(scope)}

Your lens (${lens.heading}): ${lens.task}`;
}

function criticPrompt(findings, scope) {
  return `You are the critic of a multi-lens code review. ${changeBrief(scope)}

${LOCAL_REVIEW_RULE}

Validate every finding below against the source and give exactly one verdict per id:
- reject: wrong, baseless, outside the change, or a duplicate (name the kept id).
- downvote: valid but not worth doing: low value, subjective, over-engineering, or against repository conventions.
- accept: valid and worth fixing.
Give a one or two sentence reason with evidence. Read-only: never edit, stage, commit, push, build, or run setup
scripts.
${GUIDES}

Findings:
${JSON.stringify(findings, null, 2)}`;
}

async function critique(ctx, findings, scope) {
  for (const agent of CRITIC_AGENTS) {
    const result = await ctx.agent(criticPrompt(findings, scope), {
      agent,
      label: `critic:${agent}`,
      schema: VERDICTS_SCHEMA,
    });
    if (result) {
      return { critic: agent, verdicts: result.verdicts };
    }
    ctx.log(`Critic ${agent} failed`);
  }
  return { critic: "failed", verdicts: [] };
}

const codeReview = defineWorkflow({
  meta: {
    name: "code-review",
    description:
      "Review the current branch's change to dotfiles with six lenses (code smell, dead code, logic and design, " +
      "performance, simplification, tests), then have a critic accept, downvote, or reject each finding. " +
      "args: { base?: string } — diff base; defaults to the merge base with the default branch.",
    phases: [{ title: "Scope" }, { title: "Review" }, { title: "Critique" }, { title: "Report" }],
    argsSchema: { type: "object", properties: { base: { type: "string" } } },
  },
  run: async (ctx) => {
    ctx.phase("Scope");
    const scope = await ctx.step("scope-v1", () => resolveScope(ctx.args.base));
    if (!scope.files.length) {
      return { base: scope.base, status: "empty" };
    }
    ctx.phase("Review");
    const keys = Object.keys(LENSES);
    const results = await ctx.parallel(
      keys.map(
        (key) => () =>
          ctx.agent(lensPrompt(LENSES[key], scope), {
            agent: LENS_AGENT,
            label: `review:${key}`,
            schema: FINDINGS_SCHEMA,
          }),
      ),
    );
    const failedLenses = keys.filter((_, index) => results[index] === null);
    const findings = keys.flatMap((key, index) =>
      (results[index]?.findings ?? []).map((finding, n) => ({ id: `${key}-${n + 1}`, lens: key, ...finding })),
    );

    ctx.phase("Critique");
    const { critic, verdicts } = findings.length
      ? await critique(ctx, findings, scope)
      : { critic: "skipped", verdicts: [] };

    ctx.phase("Report");
    const buckets = { accept: "accepted", downvote: "downvoted", reject: "rejected" };
    const byId = new Map(verdicts.map((verdict) => [verdict.id, verdict]));
    const report = { accepted: [], downvoted: [], rejected: [], unreviewed: [] };
    for (const finding of findings) {
      const verdict = byId.get(finding.id);
      const entry = verdict ? { ...finding, reason: verdict.reason } : finding;
      report[buckets[verdict?.verdict] ?? "unreviewed"].push(entry);
    }
    report.accepted.sort((a, b) => SEVERITY_ORDER[a.severity] - SEVERITY_ORDER[b.severity]);
    return { base: scope.base, fileCount: scope.files.length, critic, failedLenses, ...report };
  },
});

await joinSession({ workflows: [codeReview] });
