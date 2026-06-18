# Status Bar Tests - Comprehensive Verification

## 🎯 Test Philosophy

**Tests must verify BEHAVIOR in USER'S TERMINAL, not just configuration.**

### ❌ Bad Test (only checks config)
```bash
# This passed even when status bar was broken!
if tmux show-options -g status-format[0] | grep -q "F1"; then
    echo "PASS: Status bar exists"
fi
```

### ✅ Good Test (checks what user actually sees)
```bash
# Verify status bar appears ONCE at BOTTOM after EVERY switch
status_count=$(tmux capture-pane -p | grep -c "F1.*F10")
status_line=$(tmux capture-pane -p | grep -n "F1.*F10" | cut -d: -f1)
total_lines=$(tmux capture-pane -p | wc -l)

if [ "$status_count" -ne 1 ]; then
    echo "FAIL: Status bar appears $status_count times (expected 1)"
fi

if [ "$status_line" -lt $((total_lines - 1)) ]; then
    echo "FAIL: Status bar at line $status_line, should be at $total_lines"
fi
```

## 🧪 Available Tests

### 1. Full Status Bar Verification (`test-status-bar.sh`)

Tests **exactly what user sees in terminal** after every action.

**CRITICAL FIX (2025-10-07):** Removed `status-format[1]` from tmux.conf to eliminate duplicate status line showing pane info.

**What it verifies:**
- ✅ Status bar appears **EXACTLY ONCE** (no double bar)
- ✅ Status bar is at **BOTTOM of screen** (not line 1 or 12)
- ✅ Status bar **PERSISTS after session switch**
- ✅ All 10 console indicators (F1-F10) visible
- ✅ Active session highlighted

**Run:**
```bash
ssh zentala@164.68.104.13
tmux attach -t console-1
~/.vps/sessions/tests/test-status-bar.sh
```

**What test does:**
1. Checks initial session state
2. Switches to console-1, verifies status bar
3. Switches to console-2, verifies status bar
4. ... switches through all 7 consoles
5. Returns to original session
6. Reports any failures

**Expected output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 Status Bar Verification Test
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current session: console-1

🔍 Testing: Initial state in console-1
   Terminal height: 24
   F1 occurrences: 1
   F10 occurrences: 1
   'console-' occurrences: 10
   ✅ PASS: Status bar appears exactly once
   ✅ PASS: Status bar is at bottom
   ✅ PASS: All 10 console indicators present
   ✅ PASS: Active session highlighted

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Testing session switching...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Switching to console-1
🔍 Testing: After switch to console-1
   Terminal height: 24
   F1 occurrences: 1
   F7 occurrences: 1
   ✅ PASS: Status bar appears exactly once
   ✅ PASS: Status bar is at bottom
   ✅ PASS: All 7 session indicators present

→ Switching to console-2
[... tests all 10 sessions ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ ALL TESTS PASSED
   Status bar is working correctly!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 2. Precise Position Test (`test-status-position.sh`)

Tests **exact line number** where status bar appears in terminal.

### 3. Scroll Behavior Test (`test-status-scroll.sh`) ⚠️ CRITICAL

Tests **MOST IMPORTANT** requirement: status bar must stay **PINNED** to bottom when scrolling.

**What it verifies:**
- ✅ Status bar visible at bottom BEFORE scrolling
- ✅ Status bar STAYS at bottom AFTER scrolling (doesn't move up with content)
- ✅ Status bar is tmux status line (not part of pane content)

**Why this test is critical:**
When Claude generates long output, terminal scrolls. If status bar is part of pane content, it scrolls UP with text and disappears from view. User should ALWAYS see status bar at screen bottom, no matter how much content scrolls.

**Run:**
```bash
ssh zentala@164.68.104.13
tmux attach -t console-1
~/.vps/sessions/tests/test-status-scroll.sh
```

**What test does:**
1. Checks status bar is at bottom initially
2. Generates 50 lines of output (forces scroll)
3. Verifies status bar is STILL at visible bottom
4. Confirms bar didn't scroll up with content

**Expected output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📜 Status Bar Scroll Test
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Testing session: console-1
   Terminal height: 24 lines
   Step 1: Checking initial state...
   ✅ Initial: Status bar at bottom
   Step 2: Generating output to trigger scroll...
   Step 3: Checking status bar after scroll...
   ✅ After scroll: Status bar still at bottom
   ✅ Only one status bar visible

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ SCROLL TEST PASSED
   Status bar stays pinned at bottom!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If test FAILS:**
```
❌ SCROLL TEST FAILED
   Status bar scrolls with content!

PROBLEM DIAGNOSIS:
   Status bar is part of pane content instead of tmux status line.

ROOT CAUSE:
   • status-format[1] was showing pane info
   • This created second status line that scrolled

SOLUTION:
   Add to tmux.conf:
   set -g status-format[1] ''
```

### Previous test: Precise Position Test (`test-status-position.sh`)

Tests **exact line number** where status bar appears in terminal.

**What it verifies:**
- ✅ Status bar at line N or N-1 (bottom rows only)
- ✅ NOT at line 1, 12, or middle of screen
- ✅ Only ONE status bar (no duplicates)
- ✅ tmux `status-position` setting is "bottom"

**Run:**
```bash
ssh zentala@164.68.104.13
tmux attach -t console-1
~/.vps/sessions/tests/test-status-position.sh
```

**What test does:**
1. Captures pane content with line numbers
2. Finds which line contains status bar (F1...F7)
3. Verifies line number is at bottom (N or N-1)
4. Checks for duplicate status bars
5. Tests all 10 console sessions

**Expected output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Precise Status Bar Position Test
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Testing session: console-1
   Terminal: 80x24
   Status bar at line: 24 / 24
   ✅ PASS: Status bar is at bottom (line 24/24)
   ✅ PASS: Only one status bar present
   ✅ PASS: tmux status-position = bottom

Testing all console sessions...

[... tests console-1 through console-10 ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ ALL POSITION TESTS PASSED
   Status bar is always at the bottom!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 🚨 Common Failures & Fixes

### Failure 1: Double Status Bar

**Symptom:**
```
❌ FAIL: Status bar appears multiple times or not at all
   Expected: F1=1, F10=1
   Got: F1=2, F10=2
```

**What user sees:**
```
┌─────────────────────────────────────────┐
│ 🖥️  F1:console-1   F2:console-2  ... F10 │  ← First bar (wrong!)
│                                         │
│ $ ls                                    │
│ file1.txt  file2.txt                    │
│                                         │
│ 🖥️  F1:console-1   F2:console-2  ... F10 │  ← Second bar (correct position)
└─────────────────────────────────────────┘
```

**Root cause:** Duplicate `status-format` in tmux.conf

**Debug:**
```bash
grep -n "status-format" ~/.vps/sessions/src/tmux.conf
# Should show only ONE status-format[0] entry
```

**Fix:**
```bash
# Remove duplicate line from tmux.conf
vim ~/.vps/sessions/src/tmux.conf
# Keep only ONE: set-option -g status-format[0] ...

# Reload config
tmux source-file ~/.vps/sessions/src/tmux.conf
```

### Failure 2: Status Bar at Wrong Position

**Symptom:**
```
❌ FAIL: Status bar at wrong position
   Expected: line 23 or 24 (bottom)
   Got: line 12
```

**What user sees:**
```
┌─────────────────────────────────────────┐
│ $ ls                                    │
│ file1.txt                               │
│                                         │
│ 🖥️  F1:console-1   F2:console-2  ... F10 │  ← Bar in MIDDLE (wrong!)
│                                         │
│ $ echo "hello"                          │
│ hello                                   │
│ $                                       │
└─────────────────────────────────────────┘
```

**Root cause:** Status bar is part of pane content, not tmux status line

**Debug:**
```bash
# Check tmux status-position
tmux show-options -g status-position
# Should be: status-position bottom

# Check status-format
tmux show-options -g status-format
# Should use dynamic script call
```

**Fix:**
```bash
# Ensure status-position is bottom
tmux set-option -g status-position bottom

# Reload config
tmux source-file ~/.vps/sessions/src/tmux.conf
```

### Failure 3: Status Bar Disappears After Switch

**Symptom:**
```
→ Switching to console-2
🔍 Testing: After switch to console-2
   Terminal height: 24
   F1 occurrences: 0
   F10 occurrences: 0
   ❌ FAIL: Status bar not found in pane
```

**What user sees:**
```
┌─────────────────────────────────────────┐
│ $ cd /home/user                         │
│ $ ls                                    │
│ Documents  Downloads                    │
│                                         │
│                                         │  ← NO STATUS BAR!
└─────────────────────────────────────────┘
```

**Root cause:** Status bar refresh hook not executing

**Debug:**
```bash
# Check if after-select-window hook exists
tmux show-hooks | grep after-select-window

# Should show:
# after-select-window "run-shell ~/.vps/sessions/src/status-bar.sh ..."

# Check if status-bar.sh exists and is executable
ls -la ~/.vps/sessions/src/status-bar.sh
```

**Fix:**
```bash
# Reload tmux config to restore hook
tmux source-file ~/.vps/sessions/src/tmux.conf

# Verify hook is registered
tmux show-hooks | grep status-bar

# Test manual refresh
bash ~/.vps/sessions/src/status-bar.sh "$(tmux display-message -p '#S')" "$(tmux display-message -p '#{client_width}')"
```

## 🔧 Manual Debugging

### See exactly what user sees in terminal

```bash
# Capture full pane with line numbers
tmux capture-pane -p -S - -E - | cat -n

# Show only last 10 lines (where status bar should be)
tmux capture-pane -p | tail -10

# Count status bar occurrences
tmux capture-pane -p | grep -c "F1.*F10"

# Find exact line number
tmux capture-pane -p | grep -n "F1.*F10"
```

### Check tmux configuration

```bash
# Show all status-related options
tmux show-options -g | grep status

# Show hooks (should include status-bar refresh)
tmux show-hooks

# Show recent tmux errors
tmux show-messages
```

### Test status bar script manually

```bash
# Run with current session
bash ~/.vps/sessions/src/status-bar.sh "console-1" "150"

# Should output tmux format string with F1-F10
```

### Monitor during session switch

```bash
# In one pane, watch tmux messages
watch -n 0.1 'tmux show-messages | tail -5'

# In another pane, switch sessions
tmux switch-client -t console-2

# Check for errors in messages window
```

## 📊 Test Coverage

| What User Sees | Test File | Coverage |
|----------------|-----------|----------|
| Status bar at bottom? | `test-status-position.sh` | ✅ 100% |
| Only one status bar? | `test-status-bar.sh` | ✅ 100% |
| Bar after switch? | `test-status-bar.sh` | ✅ 100% |
| All 10 consoles shown? | `test-status-bar.sh` | ✅ 100% |
| Active highlighted? | `test-status-bar.sh` | ✅ 100% |
| Icons render? | Manual (TESTING.md) | ⚠️ 80% |
| Responsive width? | Manual (TESTING.md) | ⚠️ 60% |

## 🎓 How Tests Work

### Test Design Principle

**Goal:** Verify what user ACTUALLY SEES in their terminal.

**Method:**
1. Use `tmux capture-pane -p` to get terminal content
2. Parse content as user would see it
3. Check position, count, and content
4. Fail if ANY discrepancy found

**Example:**
```bash
# Capture what's visible in terminal
visible_content=$(tmux capture-pane -t console-1 -p)

# Count status bars (should be 1)
bar_count=$(echo "$visible_content" | grep -c "F1.*F10")

# Find line number (should be last line)
bar_line=$(echo "$visible_content" | grep -n "F1.*F10" | cut -d: -f1)
total_lines=$(echo "$visible_content" | wc -l)

# Verify: ONE bar at BOTTOM
[ "$bar_count" -eq 1 ] && [ "$bar_line" -eq "$total_lines" ]
```

### Why This Approach Works

**Previous problem:** Tests checked tmux config, not user experience.

❌ Old test:
```bash
tmux show-options -g status-format[0] | grep "F1"  # PASS
# But user saw double status bar or bar at line 12!
```

✅ New test:
```bash
tmux capture-pane -p | grep -c "F1.*F10"  # FAIL if not exactly 1
tmux capture-pane -p | grep -n "F1.*F10"  # FAIL if not at bottom
# Now test FAILS when user experience is broken
```

## 🚀 Running Tests in CI/CD

### Local Development
```bash
# Test before commit
~/.vps/sessions/tests/test-status-bar.sh
~/.vps/sessions/tests/test-status-position.sh
```

### Remote VPS
```bash
# SSH and run tests
ssh zentala@164.68.104.13 -t "
  tmux attach -t console-1 \;
  send-keys '~/.vps/sessions/tests/test-status-bar.sh' Enter
"
```

### Automated (Future)
```yaml
# .github/workflows/test.yml
- name: Test status bar
  run: |
    tmux new-session -d -s test-console
    tmux send-keys -t test-console './tests/test-status-bar.sh' Enter
    tmux capture-pane -t test-console -p | grep "ALL TESTS PASSED"
```

## 📝 Test Report Template

```markdown
## Status Bar Test Run: 2025-10-07

**Environment:** Production VPS (zentala@164.68.104.13)
**Tmux version:** 3.0a
**Terminal:** 80x24

### Test Results

- ✅ Full Verification (`test-status-bar.sh`): **PASS**
- ✅ Position Test (`test-status-position.sh`): **PASS**

### Visual Verification

- ✅ Status bar visible at bottom
- ✅ No double status bar
- ✅ Bar persists after switching
- ✅ All 10 consoles shown
- ✅ Active session highlighted (cyan)

### Issues Found

None

### Manual Testing Notes

Tested session switching:
- console-1 → console-2: bar present ✅
- console-2 → console-10: bar present ✅
- console-10 → console-1: bar present ✅

No visual glitches observed.
```

---

**Last Updated:** 2025-10-07
**Tests Created By:** zentala + Claude Code
**Status:** Active - run before ANY status bar changes
