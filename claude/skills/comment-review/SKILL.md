---
name: comment-review
description: Reviews code comments for quality issues. Use when checking comments in code files, after writing new code with comments, before commits, or when user asks to review/check comments. Ensures comments explain WHY not WHAT, and eliminates noise.
---

# Comment Review Skill

This skill validates code comments against best practices, ensuring comments add value by explaining rationale rather than restating obvious code.

## Core Principle

**Comments must explain WHY, not WHAT** - Code should be self-documenting through good naming; comments provide context, decisions, and constraints.

---

## Review Checklist

### ✅ Good Comments (Keep These)

1. **Complex Technical Decisions**
   - Explains non-obvious implementation choices
   - Mentions trade-offs or alternatives considered
   - Example: `// Use sorted list instead of hash map for O(log n) lookups; maps add unnecessary memory overhead for small datasets`

2. **Business Logic Rationale**
   - Clarifies WHY the logic exists
   - Documents assumptions, rules, or limitations
   - Example: `// Prioritize payloads by descending score per business rules; assumes all inputs are pre-validated`

3. **Safety Constraints and Validations**
   - Documents guards that prevent errors
   - Explains why validation is necessary
   - Example: `// Enforce minimum 1KB buffer to avoid config-induced crashes`

4. **Non-Obvious Algorithms**
   - Explains algorithms that aren't immediately clear
   - Documents edge cases or timing considerations
   - Example: `// Use first element's timestamp as baseline for relative durations; handles clock skew`

5. **External References**
   - Links to specs, RFCs, docs, or tickets
   - Provides context from external sources
   - Example: `// Per RFC 3264: https://datatracker.ietf.org/doc/html/rfc3264`

6. **Public API Documentation**
   - Documents behavior, parameters, returns, constraints
   - Uses language-specific doc comments (`///`, `/** */`, docstrings)
   - Example: `// ProcessInput handles validation and transformation. Returns error on invalid formats.`

### ❌ Noise Comments (Remove These)

1. **Obvious Code Patterns**
   - Restates what the code clearly shows
   - Example: `// Check if enabled` before `if enabled { ... }`
   - **Fix**: Remove - code is self-explanatory

2. **Variable Names or Function Calls**
   - Paraphrases descriptive names
   - Example: `// Initialize the collector` before `initCollector()`
   - **Fix**: Remove - function name is clear

3. **Simple State Changes**
   - Narrates basic operations
   - Example: `// Add packet to list` before `packets.append(packet)`
   - **Fix**: Remove - obvious from code

4. **Step-by-Step Descriptions**
   - Play-by-play of what code does
   - Example: `// Build request object` before `request = buildRequest()`
   - **Fix**: Remove - adds clutter

5. **Redundant Public API Comments**
   - Repeats function signature without adding value
   - Example: `// GetName returns name` for `func GetName() string`
   - **Fix**: Remove or add actual documentation

### ⚠️ Warning Signs

1. **Length Violations**
   - Comments longer than 1-2 lines
   - **Fix**: Consider refactoring code for clarity instead

2. **Missing Context**
   - Complex code without explanation
   - Non-obvious business rules without rationale
   - **Fix**: Add comment explaining WHY

3. **Outdated Comments**
   - Comments contradicting code behavior
   - References to removed features
   - **Fix**: Update or remove

---

## Review Process

When reviewing comments:

1. **Read the code first** - Understand what it does without comments
2. **Classify each comment**:
   - ✅ Adds insight (WHY, constraints, context) → Keep
   - ❌ Restates obvious code (WHAT) → Remove
   - ⚠️ Unclear or outdated → Update or remove
3. **Check public APIs** - Are they documented?
4. **Verify conciseness** - Are comments 1-2 lines max?
5. **Look for missing context** - Should complex logic have comments?

---

## Output Format

Provide findings as:

### Noise Comments (Remove)
- `file:line` - "Comment text" → **WHY**: Restates obvious code

### Missing Documentation
- `file:line` - Public function/class without documentation

### Good Comments (Keep)
- `file:line` - "Comment text" → **GOOD**: Explains business logic rationale

### Suggestions
- `file:line` - Improve or clarify existing comment

---

## Examples

### Bad Comment (Noise)
```go
// Check if collector is enabled
if collectorEnabled {
    startCollector()
}
```
**Issue**: Restates obvious conditional check
**Fix**: Remove comment

---

### Good Comment (Rationale)
```go
// Skip validation in test mode to allow invalid data for fuzzing
if !testMode {
    validate(input)
}
```
**Why Good**: Explains WHY validation is skipped (not obvious)

---

### Bad Comment (Function Call)
```go
// Initialize the RTP collector
initRTPCollector()
```
**Issue**: Paraphrases function name
**Fix**: Remove comment

---

### Good Comment (Algorithm)
```go
// Use exponential backoff (50ms -> 200ms) to avoid overwhelming server during outages
retry := backoff.NewExponentialBackOff()
```
**Why Good**: Explains algorithm choice and business rationale

---

### Bad Comment (Step-by-Step)
```go
// Create config
config := NewConfig()
// Set timeout
config.Timeout = 30 * time.Second
// Initialize client
client := NewClient(config)
```
**Issue**: Narrates obvious steps
**Fix**: Remove all comments (code is clear)

---

### Good Comment (Safety)
```go
// Enforce 30s timeout; LLM calls in trading must fail fast to avoid stale decisions
ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
defer cancel()
```
**Why Good**: Explains constraint and consequence (financial safety)

---

## Language-Specific Patterns

### Go
- Use `//` for regular comments
- Use `// FunctionName` for godoc (public APIs)
- Focus on WHY, not parameter descriptions

### Rust
- Use `//` for regular comments
- Use `///` for rustdoc (public APIs)
- Document panics and safety invariants

### Python
- Use `#` for regular comments
- Use `"""docstrings"""` for public APIs
- Focus on behavior and constraints

### JavaScript/TypeScript
- Use `//` for regular comments
- Use `/** JSDoc */` for public APIs
- Document types and nullability in JSDoc

---

## When to Invoke This Skill

Use this skill when:
- User asks to "check comments" or "review comments"
- After writing significant new code
- Before committing code (pre-commit review)
- Reviewing pull requests
- User mentions "comment quality" or "code readability"
- Refactoring code (comments may become outdated)

---

## Critical Context

For financial/trading software:
- Comments on safety constraints are CRITICAL
- Document WHY limits exist (e.g., timeouts, validations)
- Explain business rules that aren't obvious
- Remove noise aggressively - clarity over verbosity
