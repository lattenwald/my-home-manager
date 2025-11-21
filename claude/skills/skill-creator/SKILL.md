---
name: skill-creator
description: Creates or modifies Claude Code skills. Use when user asks to create a new skill, modify an existing skill, or needs help with skill structure. Always checks online documentation first to ensure accuracy and best practices.
---

# Skill Creator

This skill helps you create and modify Claude Code skills following best practices and official documentation.

## Core Principle

**Always check Claude Code documentation before creating or modifying skills** to ensure accuracy, follow current best practices, and use the correct structure.

## Skill Structure

Every skill requires:

1. **SKILL.md file** - The main skill definition with YAML frontmatter
2. **Supporting files** (optional) - Scripts, templates, documentation
3. **Proper location** - Either personal (`~/.claude/skills/`) or project (`.claude/skills/`)

### SKILL.md Format

```yaml
---
name: skill-name-in-lowercase-with-hyphens
description: What it does and when to use it (max 1024 characters, be specific about triggers)
allowed-tools: [Read, Write, Edit]  # Optional: restrict tool access
---

# Skill Title

Detailed documentation here...
```

## Creation Process

When creating a skill:

1. **Check Documentation First**
   - Fetch latest docs from https://docs.claude.com/en/docs/claude-code/skills.md
   - Review examples and best practices
   - Check for any updates or changes to skill structure

2. **Define Clear Triggers**
   - Be specific about when Claude should use this skill
   - Include concrete phrases users might say
   - Examples: "when user asks to...", "use when reviewing...", "invoke before committing..."

3. **Choose Appropriate Location**
   - Personal skills: `~/.claude/skills/[skill-name]/`
   - Project skills: `.claude/skills/[skill-name]/`
   - Consider team sharing needs

4. **Structure the Skill**
   - Write clear, concise description (under 1024 chars)
   - Document core principles and usage
   - Provide examples and patterns
   - Include checklists if applicable

5. **Add Tool Restrictions (if needed)**
   - Use `allowed-tools` to limit capabilities
   - Example: `[Read, Grep, Glob]` for read-only skills
   - Omit for full tool access

## Description Best Practices

The description is critical for Claude to discover and use your skill:

✅ **Good Description**:
```yaml
description: Validates tests for test theater anti-patterns. Use when reviewing test code, writing new tests, or when user asks to check tests for quality issues. Ensures tests verify real behavior, not just provide false confidence.
```

❌ **Bad Description**:
```yaml
description: A skill for tests
```

### Description Checklist
- [ ] Under 1024 characters
- [ ] Clearly states what the skill does
- [ ] Specifies when to use it (triggers)
- [ ] Uses concrete, searchable phrases
- [ ] Mentions user request patterns

## Common Skill Patterns

### Code Review Skill
- Check code quality, patterns, anti-patterns
- Provide severity levels (critical/warning/suggestion)
- Reference file:line locations
- Suggest fixes with examples

### Analysis Skill
- Systematic investigation approach
- Document findings and evidence
- Provide actionable recommendations
- Include examples and patterns

### Creation/Generation Skill
- Template-based generation
- Follow project conventions
- Include validation steps
- Provide usage examples

### Validation Skill
- Define criteria and checklists
- Identify violations
- Provide specific fixes
- Include good/bad examples

## Skill Organization

```
~/.claude/skills/
├── skill-name/
│   ├── SKILL.md              # Required: main skill definition
│   ├── templates/            # Optional: code/file templates
│   ├── scripts/              # Optional: helper scripts
│   └── docs/                 # Optional: additional documentation
```

## Testing Skills

After creating a skill:

1. **Restart Claude Code** - Skills load on startup
2. **Test invocation** - Ask Claude to use it with trigger phrases
3. **Verify behavior** - Ensure it activates when expected
4. **Check output** - Validate results match expectations

### Debugging

If skill doesn't activate:
- Verify YAML frontmatter syntax
- Check description specificity
- Ensure file is in correct location
- Review Claude Code logs for errors
- Make triggers more concrete

## Modification Guidelines

When modifying existing skills:

1. **Read current skill** - Understand existing structure
2. **Check documentation** - Verify no breaking changes
3. **Preserve working elements** - Don't break what works
4. **Test changes** - Verify modifications work as expected
5. **Update description** - If triggers or behavior change

## Example Skill Templates

### Minimal Skill
```yaml
---
name: example-skill
description: Does X when user asks for Y. Use when user mentions Z or requests W.
---

# Example Skill

Brief explanation of what this skill does.

## When to Use

- User asks for X
- Reviewing Y
- Before doing Z

## Process

1. Step one
2. Step two
3. Step three
```

### Read-Only Analysis Skill
```yaml
---
name: code-analyzer
description: Analyzes code for specific patterns. Use when user asks to analyze, check, or review code for [specific pattern].
allowed-tools: [Read, Grep, Glob]
---

# Code Analyzer

## Analysis Checklist

### ✅ Good Patterns
1. Pattern description
2. Example

### ❌ Anti-Patterns
1. Pattern description
2. Fix recommendation
```

## When to Invoke This Skill

Use this skill when:
- User asks to "create a skill" or "make a skill"
- User wants to "modify a skill" or "update a skill"
- User needs help with skill structure or format
- User mentions "Claude Code skill" or "agent skill"
- User wants to add capabilities to Claude Code

## Output Format

When creating/modifying skills:

1. **Confirm understanding** - Summarize what skill should do
2. **Check documentation** - Fetch latest guidelines
3. **Create/modify files** - Generate SKILL.md and supporting files
4. **Provide location** - Show where skill was created
5. **Usage instructions** - Explain how to test and use the skill

## Critical Reminders

- ⚠️ **Always check documentation first** - Skills API may change
- ⚠️ **Description is critical** - Vague descriptions = skill won't activate
- ⚠️ **Skills are model-invoked** - Unlike slash commands, Claude decides when to use them
- ⚠️ **Restart required** - Skills load on Claude Code startup
- ⚠️ **Personal vs Project** - Choose location based on sharing needs

## Documentation Reference

Primary documentation:
- Skills: https://docs.claude.com/en/docs/claude-code/skills.md
- Docs map: https://docs.claude.com/en/docs/claude-code/claude_code_docs_map.md

Related features:
- Sub-agents for delegation
- Slash commands for explicit invocation
- Plugins for distributing reusable components
