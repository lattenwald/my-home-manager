---
name: test-validation
description: Validates tests for test theater anti-patterns. Use when reviewing test code, writing new tests, or when user asks to check tests for quality issues. Ensures tests verify real behavior, not just provide false confidence.
---

# Test Validation Skill

This skill helps identify and eliminate "test theater" - tests that look good but don't actually verify real behavior or provide meaningful confidence.

## Core Principle

**Tests must verify real behavior, not just provide false confidence.**

## Validation Checklist

When reviewing tests, check for these anti-patterns and quality issues:

### ❌ Test Theater Anti-Patterns

1. **Meaningless Error Checks**
   - Tests that only check `err == nil` without verifying functionality
   - Example: `if err != nil { t.Fatal(err) }` but never checking what actually happened
   - **Fix**: Verify the actual behavior/side effects, not just error absence

2. **Brittle Timing**
   - Using `time.Sleep` for async operations (flaky on slow CI servers)
   - Arbitrary wait durations that may or may not be sufficient
   - **Fix**: Use channels with timeout or deterministic coordination

3. **Shallow Validation**
   - Checking counts without verifying data integrity
   - Example: `if len(results) != 3` but not checking if the data is correct
   - **Fix**: Validate actual data content and correctness

4. **Redundant Coverage**
   - Tests that duplicate existing coverage without adding value
   - Multiple tests checking the exact same behavior
   - **Fix**: Remove or consolidate redundant tests

5. **Thread-Safety Theater**
   - Concurrent tests that only check counts, not data corruption
   - Missing race detector usage
   - **Fix**: Verify data integrity, detect torn writes, use `-race` flag

### ✅ Quality Testing Patterns

1. **Deterministic Async Testing**
   ```go
   // Use channels with timeout
   done := make(chan Result, 1)
   go asyncOperation(func(r Result) { done <- r })

   select {
   case result := <-done:
       // Verify result content
       if result.Value != expected {
           t.Errorf("got %v, want %v", result.Value, expected)
       }
   case <-time.After(100 * time.Millisecond):
       t.Fatal("Timeout - operation not completed")
   }
   ```

2. **Goroutine Coordination**
   ```go
   // Use sync.WaitGroup for multiple goroutines
   var wg sync.WaitGroup
   wg.Add(3)
   for i := 0; i < 3; i++ {
       go func() {
           defer wg.Done()
           // test operation
       }()
   }
   wg.Wait()
   // Verify results
   ```

3. **Thread-Safe Counters**
   ```go
   // Use atomic.Int64 for concurrent counting
   var counter atomic.Int64
   for i := 0; i < 10; i++ {
       go func() {
           counter.Add(1)
       }()
   }
   // Wait and verify
   ```

4. **Data Integrity Checks**
   - For financial/critical software: verify notification delivery (missed signal = missed trade)
   - Check for data corruption (corrupted price = wrong trade)
   - Validate all fields, not just existence

### Language-Specific Considerations

**Go**:
- Always use `go test -race` for concurrent code
- Use `t.Parallel()` for independent tests
- Prefer table-driven tests for multiple cases
- Use `t.Helper()` for test utilities

**Rust**:
- Use `#[tokio::test]` for async tests
- Consider `proptest` for property-based testing
- Use `Arc<Mutex<T>>` or channels for thread coordination

## Review Process

When reviewing tests:

1. **Read the test name** - Does it clearly describe what's being tested?
2. **Identify the assertion** - What is actually being verified?
3. **Check for theater** - Is this just checking `err == nil` or counting things?
4. **Verify completeness** - Are all important aspects of behavior validated?
5. **Check reliability** - Will this test pass consistently on slow CI servers?
6. **Race conditions** - For concurrent code, is `-race` being used?

## Example Review

**Bad Test** (Test Theater):
```go
func TestProcessData(t *testing.T) {
    result, err := ProcessData(input)
    if err != nil {
        t.Fatal(err)  // Only checks no error
    }
    // Never verifies result content!
}
```

**Good Test** (Real Validation):
```go
func TestProcessData(t *testing.T) {
    result, err := ProcessData(input)
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }

    // Verify actual behavior
    if result.Status != StatusComplete {
        t.Errorf("got status %v, want %v", result.Status, StatusComplete)
    }
    if result.Count != 3 {
        t.Errorf("got count %d, want 3", result.Count)
    }
    if !reflect.DeepEqual(result.Items, expectedItems) {
        t.Errorf("got items %v, want %v", result.Items, expectedItems)
    }
}
```

## When to Invoke This Skill

Use this skill when:
- Writing new test code
- Reviewing pull requests with tests
- User asks to "check tests" or "review tests"
- User mentions "test quality" or "test theater"
- Debugging flaky tests
- Before committing test code

## Output Format

Provide findings as:
1. **Anti-patterns found** (with file:line references)
2. **Severity** (critical/warning/suggestion)
3. **Specific fix recommendations**
4. **Example of improved test** (if applicable)

## Critical Context

For financial/trading software:
- Missed notifications = missed trades = lost money
- Data corruption = wrong trades = catastrophic losses
- Tests MUST be reliable on slow CI servers
- Race conditions are unacceptable in production
