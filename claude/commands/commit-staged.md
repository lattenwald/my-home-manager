Commit staged changes

**CRITICAL FIRST STEP:** ALWAYS run `git diff --cached` first to check what is currently staged before proceeding. DO NOT assume nothing is staged - verify first.

After checking staged changes, generate a Git commit message for the staged changes following these rules:

**Format:** Single line preferred. Only add body for complex multi-part changes.

1. **Issue-Linked (if applicable):**
   * `{ISSUE-ID}: {description}` (e.g., `PROJECT-123: Fix auth timeout`)
   * Examples:
     * `#456: Add user registration flow`
     * `ENG-101: Optimize database query performance`
     * `AB#234: Update deployment configuration`

2. **Type-Based (no issue):**
   * `{type}: {description}`
   * Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
   * Examples:
     * `docs: update repository URL in service file`
     * `fix: prevent infinite loop in root detection`
     * `feat: add profile page to dashboard`
     * `refactor: extract validation logic to helpers`

**Keep it short:** Fit everything on one line when possible. Skip explanations.
