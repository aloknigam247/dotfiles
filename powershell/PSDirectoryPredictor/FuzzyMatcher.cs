namespace PSDirectoryPredictor;

/// <summary>
/// Subsequence-based fuzzy scorer optimized for file system paths.
/// Returns -1 for no match, higher score = better match.
/// </summary>
public static class FuzzyMatcher {
    private const int ConsecutiveBaseBonus = 5;
    private const int SegmentStartBonus = 10;
    private const int SeparatorBoundaryBonus = 5;
    private const int ExactCaseBonus = 1;

    public static int Score(string pattern, string candidate) {
        if (pattern.Length == 0) return 0;
        if (pattern.Length > candidate.Length) return -1;

        int score = 0;
        int patternIdx = 0;
        int consecutive = 0;

        for (int i = 0; i < candidate.Length && patternIdx < pattern.Length; i++) {
            char pc = pattern[patternIdx];
            char cc = candidate[i];

            if (char.ToLowerInvariant(pc) == char.ToLowerInvariant(cc)) {
                // Base match point
                score += 1;

                // Exact case bonus
                if (pc == cc)
                    score += ExactCaseBonus;

                // Consecutive character bonus (escalating)
                consecutive++;
                if (consecutive > 1)
                    score += ConsecutiveBaseBonus + (consecutive - 2);

                // Segment start bonus: match right after a separator
                if (i > 0 && IsSeparator(candidate[i - 1]))
                    score += SegmentStartBonus;

                // First character bonus
                if (i == 0)
                    score += SegmentStartBonus;

                // Separator boundary bonus: pattern char matches at a word boundary
                if (i > 0 && !IsSeparator(candidate[i - 1]) && char.IsUpper(cc) && char.IsLower(candidate[i - 1]))
                    score += SeparatorBoundaryBonus;

                patternIdx++;
            } else {
                consecutive = 0;
            }
        }

        // All pattern chars must be consumed
        return patternIdx == pattern.Length ? score : -1;
    }

    private static bool IsSeparator(char c) => c == '\\' || c == '/' || c == ' ' || c == '-' || c == '_';
}
