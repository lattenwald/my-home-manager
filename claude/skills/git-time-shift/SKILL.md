---
name: git-time-shift
description: Shifts git commit timestamps to any specified time windows (weekends, evenings, specific hours, or custom ranges). Use for privacy or adjusting commit history patterns.
---

# Git Time Shift Skill

You are helping the user modify git commit timestamps to appear as if work was done during specific time windows.

## Key Requirements

1. **Common Time Windows** (examples, but accept any custom range):
   - **Evenings**: 19:30 (7:30 PM) to 02:00 (2:00 AM next day)
   - **Weekends**: Saturday and Sunday (any time)
   - **Early Mornings**: 05:00 to 08:00
   - **Lunch Hours**: 12:00 to 14:00
   - **Custom**: Any user-specified time range or pattern

2. **Preservation**:
   - Maintain relative commit order and timing relationships
   - Preserve commit content, messages, and authorship (except timestamps)
   - Keep reasonable time gaps between commits (don't cluster them unnaturally)

3. **Implementation Approach**:
   - Use `git filter-branch` or `git rebase` with `--committer-date-is-author-date`
   - Use environment variables `GIT_AUTHOR_DATE` and `GIT_COMMITTER_DATE`
   - Consider using `git filter-repo` for larger repositories (more efficient)

## Workflow

When the user requests to shift commit times:

1. **Analyze Current Commits**:
   ```bash
   git log --pretty=format:"%H|%ai|%ci|%s" --all
   ```

2. **Ask Clarifying Questions**:
   - Which branch(es) to modify?
   - Entire history or specific date range?
   - Target time window(s)? (weekends, evenings, custom hours, specific days)
   - Time zone considerations?
   - Should remote be force-pushed afterward? (warn about dangers)

3. **Create Backup**:
   ```bash
   # Create timestamp for backup files
   BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)

   # CRITICAL: Export original commit hash to timestamp mapping
   # This CSV is the ONLY way to restore original timestamps!
   # Git tags/branches do NOT preserve timestamp information.
   BACKUP_DIR=".git/time-shift-backups"
   mkdir -p "$BACKUP_DIR"
   BACKUP_FILE="$BACKUP_DIR/commit-timestamps-$BACKUP_TIMESTAMP.csv"

   # Save original timestamps (CSV format for easy parsing)
   echo "commit_hash,author_date,committer_date,author_name,subject" > "$BACKUP_FILE"
   git log --all --pretty=format:"%H,%ai,%ci,%an,%s" >> "$BACKUP_FILE"

   echo "✓ Backup saved to: $BACKUP_FILE"
   echo "⚠ This CSV file is your ONLY way to restore original timestamps!"

   # Optional: Create git references for commit tree structure (doesn't preserve times)
   git tag backup-before-time-shift-$BACKUP_TIMESTAMP 2>/dev/null
   git branch backup-$BACKUP_TIMESTAMP 2>/dev/null
   ```

4. **Generate New Timestamps**:
   - Create a script that maps old commits to new timestamps
   - Ensure new times fall within specified windows
   - Maintain relative ordering and reasonable gaps

5. **Apply Changes**:
   ```bash
   git filter-branch --env-filter '
   if [ "$GIT_COMMIT" = "commit_hash" ]; then
       export GIT_AUTHOR_DATE="new_date"
       export GIT_COMMITTER_DATE="new_date"
   fi
   ' --tag-name-filter cat -- --branches --tags
   ```

6. **Verify Results**:
   ```bash
   git log --pretty=format:"%h %ai %s" --graph
   ```

7. **Cleanup**:
   ```bash
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   ```

## Example Script Template

```bash
#!/bin/bash
# git-time-shift.sh - Shift commits to evenings/weekends

BRANCH="${1:-HEAD}"
MODE="${2:-evening}" # evening, weekend, morning, lunch, custom, or mixed
START_HOUR="${3:-19}" # Default start hour
END_HOUR="${4:-2}"   # Default end hour
DAYS_FILTER="${5:-}" # Optional: 1-7 for Mon-Sun, or "weekend"

# Create backup timestamp
BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Create backup directory
BACKUP_DIR=".git/time-shift-backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/commit-timestamps-$BACKUP_TIMESTAMP.csv"

# Save original commit timestamps BEFORE any changes
echo "Creating backup of original timestamps..."
echo "commit_hash,author_date,committer_date,author_name,subject" > "$BACKUP_FILE"
git log --all --pretty=format:"%H,%ai,%ci,%an,%s" >> "$BACKUP_FILE"
echo "Backup saved to: $BACKUP_FILE"

# Optional: Create git references for commit structure (NOT for timestamps!)
# Tags and branches do NOT preserve timestamp information
git tag "backup-before-time-shift-$BACKUP_TIMESTAMP" 2>/dev/null || true
git branch "backup-$BACKUP_TIMESTAMP" 2>/dev/null || true

# Get all commits and generate new timestamps
echo "Generating new timestamps..."
git log --reverse --pretty=format:"%H %ai" "$BRANCH" | while read hash date time tz; do
    # Parse current date
    current_date="$date $time $tz"

    # Calculate new date based on mode and parameters
    # (Implementation would go here - accepts custom ranges)
    new_date="..." # New timestamp in specified window

    echo "$hash|$new_date"
done > /tmp/commit-time-map.txt

# Apply the changes using filter-branch
echo "Applying time shifts..."
git filter-branch -f --env-filter '
while IFS="|" read commit_hash new_timestamp; do
    if [ "$GIT_COMMIT" = "$commit_hash" ]; then
        export GIT_AUTHOR_DATE="$new_timestamp"
        export GIT_COMMITTER_DATE="$new_timestamp"
        break
    fi
done < /tmp/commit-time-map.txt
' --tag-name-filter cat -- --branches --tags

# Save the mapping of old to new timestamps
MAPPING_FILE="$BACKUP_DIR/time-shift-mapping-$BACKUP_TIMESTAMP.txt"
cp /tmp/commit-time-map.txt "$MAPPING_FILE"
echo "Timestamp mapping saved to: $MAPPING_FILE"

# Cleanup temp file
rm /tmp/commit-time-map.txt

echo "Time shift complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠  CRITICAL: Save this CSV backup immediately!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Original timestamps: $BACKUP_FILE"
echo "Mapping file: $MAPPING_FILE"
echo ""
echo "Git references (structure only, NO timestamp data):"
echo "  - Tag: backup-before-time-shift-$BACKUP_TIMESTAMP"
echo "  - Branch: backup-$BACKUP_TIMESTAMP"
echo ""
echo "Without the CSV file, original timestamps CANNOT be restored!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

## Backup and Recovery

### Automatic Backups Created

Every time shift operation automatically creates:

1. **Timestamp Backup CSV** (`.git/time-shift-backups/commit-timestamps-YYYYMMDD-HHMMSS.csv`) **← CRITICAL**:
   - Format: `commit_hash,author_date,committer_date,author_name,subject`
   - Contains original timestamps for all commits
   - **This is the ONLY file that preserves timestamp information**
   - **MUST be kept safe** - without this, original timestamps cannot be restored

2. **Timestamp Mapping** (`.git/time-shift-backups/time-shift-mapping-YYYYMMDD-HHMMSS.txt`):
   - Format: `old_hash|new_timestamp`
   - Maps which timestamps were applied to each commit
   - Used for audit trail

3. **Git References** (optional, for commit tree structure only):
   - Tag: `backup-before-time-shift-YYYYMMDD-HHMMSS`
   - Branch: `backup-YYYYMMDD-HHMMSS`
   - **⚠ WARNING: Git tags and branches do NOT preserve timestamps!**
   - These only preserve the commit tree structure (parents, children)
   - Useful for comparing content/structure, but NOT for restoring times

### Restoring Original Timestamps

To restore original timestamps from backup:

```bash
# Find your backup file
ls -la .git/time-shift-backups/

# Use the backup CSV to restore
BACKUP_FILE=".git/time-shift-backups/commit-timestamps-20250102-143000.csv"

# Create restore script
git filter-branch -f --env-filter '
while IFS="," read hash author_date committer_date author_name subject; do
    if [ "$GIT_COMMIT" = "$hash" ]; then
        export GIT_AUTHOR_DATE="$author_date"
        export GIT_COMMITTER_DATE="$committer_date"
        break
    fi
done < "'$BACKUP_FILE'"
' --tag-name-filter cat -- --branches --tags
```

### Viewing Backup History

```bash
# List all backups
ls -lah .git/time-shift-backups/

# View a specific backup
cat .git/time-shift-backups/commit-timestamps-20250102-143000.csv

# Compare current vs backup timestamps
git log --pretty=format:"%H %ai" > /tmp/current.txt
awk -F',' '{print $1, $2}' .git/time-shift-backups/commit-timestamps-20250102-143000.csv > /tmp/backup.txt
diff /tmp/current.txt /tmp/backup.txt
```

## Important Warnings

Always inform the user:

1. **Destructive Operation**: This rewrites git history and changes commit hashes
2. **Collaboration Impact**: Will cause issues for anyone else working on the repository
3. **Remote Repositories**: Requires force push (`git push --force`) which can be dangerous
4. **Signatures**: Will break GPG signatures on commits
5. **CRITICAL - Backup Files**:
   - CSV backups are created in `.git/time-shift-backups/` directory
   - **This is the ONLY way to restore original timestamps**
   - Git tags/branches do NOT preserve timestamp data
   - Consider copying the CSV backup outside the repository immediately
6. **Reflogs**: Original commits remain in reflog until garbage collected (but timestamps are still changed)
7. **No Undo Without CSV**: Without the backup CSV file, original timestamps are permanently lost

## Time Shifting Logic

Provide flexible helper functions to shift timestamps to any window:

```python
from datetime import datetime, timedelta
import random

def shift_to_time_window(dt, start_hour, end_hour):
    """
    Shift datetime to specified time window.

    Args:
        dt: Original datetime
        start_hour: Start of window (0-23, can be >23 for next day)
        end_hour: End of window (0-23, can be >23 for next day)

    Examples:
        shift_to_time_window(dt, 19, 26)  # 19:00 to 02:00 next day
        shift_to_time_window(dt, 5, 8)    # 05:00 to 08:00
        shift_to_time_window(dt, 12, 14)  # 12:00 to 14:00
    """
    # Handle wrap-around (e.g., 23:00 to 02:00)
    if end_hour <= start_hour:
        end_hour += 24

    hour = random.randint(start_hour, end_hour - 1)
    minute = random.randint(0, 59)

    # Handle next-day overflow
    if hour >= 24:
        dt = dt + timedelta(days=(hour // 24))
        hour = hour % 24

    return dt.replace(hour=hour, minute=minute, second=random.randint(0, 59))

def shift_to_evening(dt):
    """Shift datetime to evening (19:30-02:00)"""
    return shift_to_time_window(dt, 19, 26)  # 19:00 to 02:00

def shift_to_weekend(dt, start_hour=10, end_hour=23):
    """Shift datetime to nearest weekend with optional time window"""
    # Calculate days until next Saturday
    days_ahead = 5 - dt.weekday()  # Saturday = 5
    if days_ahead <= 0:
        days_ahead += 7

    weekend_date = dt + timedelta(days=days_ahead)
    # Randomly pick Saturday or Sunday
    if random.random() > 0.5:
        weekend_date += timedelta(days=1)

    return shift_to_time_window(weekend_date, start_hour, end_hour)

def shift_to_specific_days(dt, allowed_weekdays, start_hour=9, end_hour=17):
    """
    Shift to specific days of week.

    Args:
        dt: Original datetime
        allowed_weekdays: List of allowed days (0=Monday, 6=Sunday)
        start_hour, end_hour: Time window within those days

    Example:
        shift_to_specific_days(dt, [0, 2, 4], 9, 17)  # Mon/Wed/Fri 9-5
    """
    current_weekday = dt.weekday()

    if current_weekday not in allowed_weekdays:
        # Find next allowed day
        for i in range(1, 8):
            next_day = (current_weekday + i) % 7
            if next_day in allowed_weekdays:
                dt = dt + timedelta(days=i)
                break

    return shift_to_time_window(dt, start_hour, end_hour)
```

## Usage Examples

**Example 1**: Shift all commits to evenings (19:30-02:00)
```bash
/skill git-time-shift "shift all commits to evenings"
```

**Example 2**: Shift last 30 days to weekends
```bash
/skill git-time-shift "move commits from last 30 days to weekends"
```

**Example 3**: Shift to early mornings (5:00-8:00)
```bash
/skill git-time-shift "move all commits to early morning hours between 5am and 8am"
```

**Example 4**: Shift to lunch hours on weekdays
```bash
/skill git-time-shift "shift commits to lunch time 12:00-14:00 on weekdays only"
```

**Example 5**: Custom time window (22:00-01:00)
```bash
/skill git-time-shift "move commits to late night between 10pm and 1am"
```

**Example 6**: Specific days only (Mon/Wed/Fri)
```bash
/skill git-time-shift "shift commits to Monday, Wednesday, Friday between 14:00-18:00"
```

**Example 7**: Mixed pattern
```bash
/skill git-time-shift "distribute commits randomly between weekends and weekday evenings"
```

## Best Practices

1. **Natural Distribution**: Don't make all commits at exactly 19:30 - vary the times
2. **Commit Gaps**: Maintain realistic time gaps between commits
3. **Consistency**: If original commits were close together, keep them close in shifted version
4. **Testing**: Test on a branch first before applying to main history
5. **Backup Safety**:
   - Automatic backups are saved to `.git/time-shift-backups/`
   - Keep this directory safe - add to `.gitignore` if needed
   - Consider copying backups outside the repo for extra safety
6. **Documentation**: Backups include original timestamps and mapping files for reference

## Alternative: Using git-filter-repo

For better performance on large repositories:

```bash
# Install: pip install git-filter-repo

git filter-repo --commit-callback '
import random
from datetime import datetime, timedelta

# Your time shifting logic here
commit.author_date = new_timestamp.encode()
commit.committer_date = new_timestamp.encode()
'
```

This approach is faster and more reliable for large repositories.
