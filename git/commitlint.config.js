const fs = require("node:fs");
const path = require("node:path");

function repoScopes() {
    try {
        return JSON.parse(fs.readFileSync(path.join(process.cwd(), ".commitlint-scopes.json"), "utf8"));
    } catch {
        return [];
    }
}

module.exports = {
    extends: ["@commitlint/config-conventional"],
    rules: {
        "type-enum": [2, "always", ["build", "chore", "ci", "docs", "feat", "fix", "perf", "refactor", "revert", "test"]],
        "type-case": [2, "always", ["lower-case"]],
        "type-empty": [2, "never"],
        "scope-case": [2, "always", ["lower-case"]],
        "scope-enum": [2, "always", repoScopes()],
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
