const { execFileSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

function readScopes(root) {
    try {
        const parsed = JSON.parse(fs.readFileSync(path.join(root, ".commitlint-scopes.json"), "utf8"));
        return Array.isArray(parsed) ? parsed : [];
    } catch {
        return [];
    }
}

function repoScopes() {
    const roots = new Set([process.cwd()]);
    try {
        const worktrees = execFileSync("git", ["worktree", "list", "--porcelain", "-z"], {
            encoding: "utf8",
            stdio: ["ignore", "pipe", "pipe"],
            windowsHide: true,
        });
        roots.add(path.resolve(worktrees.split("\0", 1)[0].slice("worktree ".length)));
    } catch (error) {
        console.warn(`commitlint: unable to locate the primary worktree: ${error.message}`);
    }

    return [...new Set([...roots].flatMap(readScopes))];
}

const scopes = repoScopes();

module.exports = {
    extends: ["@commitlint/config-conventional"],
    rules: {
        "type-enum": [2, "always", ["build", "chore", "ci", "docs", "feat", "fix", "perf", "refactor", "revert", "test"]],
        "type-case": [2, "always", ["lower-case"]],
        "type-empty": [2, "never"],
        "scope-case": [2, "always", ["lower-case"]],
        ...(scopes.length > 0
            ? { "scope-enum": [2, "always", scopes] }
            : { "scope-empty": [2, "always"] }),
        "subject-case": [2, "always", ["lower-case", "sentence-case"]],
        "subject-empty": [2, "never"],
        "subject-full-stop": [2, "never", "."],
        "subject-max-length": [2, "always", 50],
        "header-case": [2, "always", ["lower-case", "sentence-case"]],
        "header-full-stop": [2, "never", "."],
        "header-trim": [2, "always"],
        "header-max-length": [2, "always", 72],
        "body-case": [2, "always", ["sentence-case"]],
        "body-full-stop": [2, "always", "."],
        "body-leading-blank": [2, "always"],
        "body-max-line-length": [2, "always", 80],
        "footer-leading-blank": [2, "always"],
        "footer-max-line-length": [2, "always", 80],
        "breaking-change-exclamation-mark": [2, "always"],
    },
};
