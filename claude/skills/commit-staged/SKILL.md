---
name: commit-staged
description: Creates git commits for already-staged changes following conventional commit format. ALWAYS check git diff --cached FIRST to verify staged changes. Use when user asks to commit staged changes, create a commit, or mentions commit-staged. Generates concise one-liner messages or overview with bullet points. Never stages files - only commits what user already staged.
---

# Commit Staged Skill

This skill generates git commit messages for staged changes following strict conventions and commits them WITHOUT staging any files.

## Core Principles

1. **Never stage files** - This skill only commits files already staged by the user
2. **Concise messages** - Commits are table of contents, not a book
3. **No commit stats** - Git history provides details; commit messages provide overview
4. **One-liner strongly preferred** - Use bullet lists only as a last resort

---

## Commit Message Format

### Issue-Linked Commits (if applicable)

```
{ISSUE-ID}: {concise description}
```

**Examples:**
- `FME-157: Fix authentication timeout`
- `PROJ-42: Add user registration flow`
- `BUG-891: Prevent race condition in cache`

### Type-Based Commits (no issue)

```
{type}: {concise description}
{type}({scope}): {concise description}
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Formatting, whitespace (no code change)
- `refactor` - Code restructuring (no behavior change)
- `test` - Adding or updating tests
- `chore` - Build, dependencies, tooling

**Scope (optional):** One word describing area (e.g., `engine`, `api`, `ui`)

**Examples:**
- `feat: add profile page to dashboard`
- `fix(engine): prevent infinite loop in root detection`
- `docs: update repository URL in service file`
- `chore(deps): upgrade pytest to 8.0`
- `refactor: extract validation logic to helpers`

---

## Multi-Part Changes Format

**IMPORTANT:** Prefer one-liners whenever possible. Only use bullet lists as a last resort for many unrelated changes that cannot be summarized concisely.

For many unrelated changes that absolutely require separation:

```
{prefix}: {high-level overview}

- {bullet for first set of changes}
- {bullet for second set of changes}
- {bullet for third set of changes}
```

**Keep bullets:**
- Very high-level (one per conceptual group)
- Short and concise
- Focused on WHAT changed, not details

**Example:**
```
chore: system configuration updates

- Update Sway window manager keybindings and app settings
- Add systemd service units for user session
- Enhance shell scripts for better error handling
```

---

## Process

When creating a commit:

1. **Check staged changes FIRST** - ⚠️ ALWAYS run `git diff --cached` to verify what is staged. DO NOT assume nothing is staged without checking first
2. **Analyze changes** - Identify if there's an issue ID or type pattern
3. **Determine format**:
   - Single focused change → One-liner
   - Multiple related changes → One-liner
   - Multiple unrelated changes → Try one-liner first, only use bullets if absolutely necessary (max 3-5 bullets)
4. **Generate message** - Follow format rules strictly
5. **Commit** - Use `git commit -m` (with HEREDOC for multi-line)
6. **Verify** - Run `git log -1` to confirm

---

## Rules and Constraints

### ✅ Do This

- **Check for issue IDs** - Look in branch names, file contents, or recent commits
- **Use conventional types** - Stick to defined types (feat, fix, docs, etc.)
- **Be concise** - Every word should add value
- **Group related changes** - Combine conceptually related changes in bullets
- **Strongly prefer one-liner** - Bullet lists are a last resort; challenge yourself to summarize in one line

### ❌ Don't Do This

- **Never stage files** - CRITICAL: Don't run `git add` or `git stage`
- **No commit stats** - Don't mention "5 files changed, 120 insertions"
- **No exhaustive lists** - Don't list every single change
- **No redundancy** - Avoid "This commit..." or "Changes include..."
- **No vague descriptions** - "Update files" or "Fix stuff" is unacceptable

---

## Decision Tree

```
Is there an issue ID?
├─ YES → Use: {ISSUE-ID}: {description}
└─ NO ↓

Is this a single focused change?
├─ YES → Use: {type}: {description} OR {type}({scope}): {description}
└─ NO ↓

Are changes conceptually related?
├─ YES → Use one-liner: {type}: {description covering all}
└─ NO ↓

Can you summarize all changes in one concise line?
├─ YES → Use one-liner: {type}: {broad summary}
└─ NO (only as last resort) → Use: {type}: {overview}\n\n- {bullet 1}\n- {bullet 2}\n- {bullet 3}
```

---

## Examples

### Good One-Liner (Issue-Linked)
```bash
git commit -m "FME-157: Fix session timeout in authentication flow"
```

### Good One-Liner (Type-Based)
```bash
git commit -m "fix(auth): prevent token expiration race condition"
```

### Good Multi-Part (Overview + Bullets)
```bash
git commit -m "$(cat <<'EOF'
chore: development environment improvements

- Add debugging utilities and logging helpers
- Update build scripts with better error handling
- Configure editor settings for consistent formatting
EOF
)"
```

### Bad Examples (Don't Do This)

❌ **Too verbose:**
```
feat: Add new user authentication system

This commit adds a comprehensive user authentication system including:
- JWT token generation with RS256 signing
- Password hashing using bcrypt with cost factor 12
- Rate limiting middleware to prevent brute force attacks
- Session management with Redis backend
- Email verification flow with token expiration

5 files changed, 234 insertions(+), 12 deletions(-)
```

❌ **Missing type prefix:**
```
Update configuration files
```

❌ **Staging files (forbidden):**
```bash
git add .
git commit -m "feat: add new feature"
```

---

## Git Command Format

### One-Liner Commit
```bash
git commit -m "type: description"
```

### Multi-Line Commit (Use HEREDOC)
```bash
git commit -m "$(cat <<'EOF'
type: overview

- Bullet point one
- Bullet point two
- Bullet point three
EOF
)"
```

**CRITICAL:** Always use HEREDOC for multi-line commits to ensure proper formatting.

---

## When to Invoke This Skill

Use this skill when:
- User asks to "commit staged changes"
- User requests "create a commit" or "make a commit"
- User mentions "commit" after staging files
- User invokes `/commit-staged` slash command
- User says "commit this" or "commit these changes"

**DO NOT** use this skill when:
- User asks to stage files (use `git add` directly instead)
- User wants to review changes (use `git diff` or `git status`)
- User mentions "commit" but nothing is staged

---

## Critical Reminders

⚠️ **NEVER STAGE FILES** - This skill assumes files are already staged by the user
⚠️ **CONCISE MESSAGES** - Commit log is table of contents, not documentation
⚠️ **NO STATS** - Never include file counts or line changes
⚠️ **HEREDOC FOR MULTI-LINE** - Always use HEREDOC format for bodies
