import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { defineWorkflow, joinSession } from "@microsoft/copilot-sdk/extension";

const CRITIC_AGENTS = ["rubber-duck", "general-purpose"];
// Workflow-declared agents get no file or shell tools, so lenses run as a built-in catalog agent.
const LENS_AGENTS = ["rubber-duck", "general-purpose"];
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
      "For implementation and configuration changes, first assess whether the change is logically correct and " +
      "preserves intended behavior. Determine that behavior from relevant contracts, callers, tests, and " +
      "documentation; trace changed inputs and state through affected code and callers. Check invariants, " +
      "success, boundary, and error paths, and identify unintended behavior changes. For correctness or regression " +
      "findings, require a concrete defect supported by source evidence; do not infer bugs from style or missing " +
      "tests. Then find places where the change departs from established patterns or where a no-larger design " +
      "is more maintainable. Trace changed config through its setup link map to the tool that loads it, on both " +
      "Windows and Linux where the package supports both. Cite the existing pattern (file and line) the change " +
      "should follow.",
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

function git(cwd, ...args) {
  return execFileSync("git", ["-C", cwd, ...args], { encoding: "utf8" }).trim();
}

function lines(text) {
  return text.split(/\r?\n/).filter(Boolean);
}

function resolveWorktree(requestedWorktree) {
  if (typeof requestedWorktree !== "string" || !path.isAbsolute(requestedWorktree)) {
    throw new Error("worktree must be an absolute checkout root");
  }
  const worktree = path.resolve(git(requestedWorktree, "rev-parse", "--show-toplevel"));
  const commonDir = (dir) => git(dir, "rev-parse", "--path-format=absolute", "--git-common-dir");
  if (path.relative(worktree, requestedWorktree) || path.relative(commonDir(worktree), commonDir(REPO_ROOT))) {
    throw new Error(`${requestedWorktree} is not a worktree of ${REPO_ROOT}`);
  }
  return worktree;
}

function resolveScope(requestedBase, requestedWorktree) {
  let defaultRef = "origin/main";
  const worktree = resolveWorktree(requestedWorktree);
  try {
    defaultRef = git(worktree, "symbolic-ref", "--short", "refs/remotes/origin/HEAD");
  } catch {
    // origin/HEAD is unset in clones that never ran `git remote set-head`.
  }
  // Resolving to a commit keeps an option-like base out of the git diff arguments.
  const base = requestedBase
    ? git(worktree, "rev-parse", "--verify", "--end-of-options", `${requestedBase}^{commit}`)
    : git(worktree, "merge-base", "HEAD", defaultRef);
  const changed = lines(git(worktree, "diff", "--name-status", base));
  const untracked = lines(git(worktree, "ls-files", "--others", "--exclude-standard")).map((file) => `?\t${file}`);
  return { base, files: [...changed, ...untracked], worktree };
}

function changeBrief(scope) {
  const worktree = `'${scope.worktree.replaceAll("'", "''")}'`;
  return (
    `Review only the worktree at ${scope.worktree}; relative paths in this prompt are relative to it. Your ` +
    `working directory may be another checkout: read and search only files under that worktree, by absolute ` +
    `path, and run git as \`git -C ${worktree}\`. The change is the diff between base ${scope.base} ` +
    `and that working tree: run \`git -C ${worktree} diff ${scope.base}\` and read untracked files ` +
    `(status ?). Changed files:\n${scope.files.join("\n")}`
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

async function reviewLens(ctx, key, scope) {
  for (const agent of LENS_AGENTS) {
    const result = await ctx.agent(lensPrompt(LENSES[key], scope), {
      agent,
      label: `review:${key}:${agent}`,
      schema: FINDINGS_SCHEMA,
    });
    if (result) {
      return result;
    }
    ctx.log(`Review lens ${key} failed with ${agent}`);
  }
  return null;
}

const codeReview = defineWorkflow({
  meta: {
    name: "code-review",
    description:
      "Review the current branch's change to dotfiles with six lenses (code smell, dead code, logic and design, " +
      "performance, simplification, tests), then have a critic accept, downvote, or reject each finding. " +
      "args: { base?: string, worktree: string } — diff base, defaulting to the merge base with the default " +
      "branch; absolute path of the worktree to review.",
    phases: [{ title: "Scope" }, { title: "Review" }, { title: "Critique" }, { title: "Report" }],
    argsSchema: {
      type: "object",
      properties: { base: { type: "string" }, worktree: { type: "string" } },
      required: ["worktree"],
    },
  },
  run: async (ctx) => {
    ctx.phase("Scope");
    const scope = await ctx.step("scope-v2", () => resolveScope(ctx.args.base, ctx.args.worktree));
    if (!scope.files.length) {
      return { base: scope.base, status: "empty", worktree: scope.worktree };
    }
    ctx.phase("Review");
    const keys = Object.keys(LENSES);
    const results = await ctx.parallel(
      keys.map((key) => () => reviewLens(ctx, key, scope)),
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
    return {
      base: scope.base,
      fileCount: scope.files.length,
      critic,
      failedLenses,
      worktree: scope.worktree,
      ...report,
    };
  },
});

await joinSession({ workflows: [codeReview] });
