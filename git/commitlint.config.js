module.exports = {
    extends: ["@commitlint/config-conventional"],
    rules: {
        // Keep this enum aligned with the repo's accepted conventional commit types.
        "type-enum": [
            2,
            "always",
            [
                "build",
                "chore",
                "ci",
                "docs",
                "feat",
                "fix",
                "perf",
                "refactor",
                "spike",
                "style",
                "test",
            ],
        ],
    },
};
