Check #$ARGUMENTS comments against following guidelines.

# Universal Commenting Guidelines

## ✅ DO Comment For

Focus on comments that add insight not evident from the code itself. These explain rationale, constraints, or context to aid future maintainers. Always prioritize *why* (decisions, trade-offs) over *what* (literal code descriptions).

### 1. Complex Technical Decisions
Explain non-obvious implementation choices, including trade-offs or alternatives considered.
```
// Use a sorted list here instead of a hash map for O(log n) lookups;
// maps would add unnecessary memory overhead for our small dataset sizes.
sorted_list.insert(value);
```

### 2. Business Logic Rationale and Constraints
Clarify why the logic exists, including assumptions, rules, or limitations driven by business needs.
```
// Prioritize payloads by descending score to match business rules favoring high-priority formats.
// Assumes all inputs are pre-validated; fails open if scores tie.
selectHighestScore(payloads);
```

### 3. Safety Constraints and Validations
Document checks or guards that prevent errors, especially in error-prone areas like concurrency or input handling.
```
// Enforce minimum buffer size of 1KB to avoid configuration-induced crashes.
if buffer_size < 1024 { buffer_size = 1024; }
```

### 4. Non-Obvious Algorithms or Behaviors
Explain algorithms that aren't immediately clear, including edge cases or timing considerations.
```
// Use first element's timestamp as baseline for relative durations;
// handles clock skew in distributed systems.
baseline = elements[0].timestamp;
```

### 5. External References or Context
Link to specs, docs, or resources that influenced the code.
```
// Per RFC 3264: https://datatracker.ietf.org/doc/html/rfc3264
negotiateProtocol();
```

## 📄 Use Documentation Comments For

For public APIs (functions, classes, modules), use language-specific doc comments (e.g., `///` in Rust, `/** */` in Java/Go, or docstrings in Python). These should describe behavior, parameters, returns, and constraints without delving into internals.

```
// ProcessInput handles data validation and transformation.
// Constraints: Input must be non-empty; throws error on invalid formats.
// Returns: Processed data or error if validation fails.
func ProcessInput(input string) (string, error) { ... }
```

## ❌ DON'T Comment For

Avoid comments that restate the obvious—the code should be self-explanatory through good naming and structure. Removing these reduces noise and keeps focus on high-value insights.

### 1. Obvious Code Patterns
No need to explain standard constructs like conditionals or loops.
```
// BAD: Check if collector is enabled
if collectorEnabled { ... }
```

### 2. Variable Names or Function Calls
Trust descriptive names; don't paraphrase them.
```
// BAD: Initialize the RTP collector
initRTPCollector();
```

### 3. Simple State Changes
Don't narrate basic operations like assignments or additions.
```
// BAD: Add packet to the list
packets.append(packet);
```

### 4. Step-by-Step or Redundant Descriptions
Skip play-by-play of what the code does—it's clutter.
```
// BAD: Build the request object
request = buildRequest(params);
```

## 📝 Core Principles

1. **Explain WHY, Not WHAT**: Code reads like prose; comments provide the "because" (e.g., decisions, constraints)
2. **Document Assumptions and Constraints**: Highlight non-obvious rules or limitations to prevent misuse
3. **Provide Necessary Context**: Include external factors like APIs, specs, or architectural choices
4. **Prioritize Public API Docs**: Always document exposed interfaces for usability
5. **Eliminate Noise**: Regularly review and remove comments that become obsolete or redundant as code evolves
6. **Be Concise and Actionable**: Comments should fit on 1-2 lines; if longer, consider refactoring the code for clarity
