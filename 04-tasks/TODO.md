**Purpose:** Current sprint backlog and task status for v0.2

---

# TODO - v0.2 Sprint Backlog

**Version:** v0.2 (in development)
**Phase:** v0.2 pre-release hardening
**Last Updated:** 2026-06-18

---

## Current Sprint Goals

1. Finish `.plan/epic-v0.2-ptty/` release blockers.
2. Keep runtime behavior, README, CLAUDE.md, and CI gates aligned.
3. Do not publish v0.2 until `.plan/REVIEW.md` changes from NO-GO to GO.

**Current quality gate:** NO-GO pending E002 clean-install verification.

---

## 🆕 New v0.2 Tasks (from 2026-05-16 positioning review)

**Recommended sequence: 019 → 020 → 021 → 022.** Each depends on the previous; running in parallel = merge hell.

- **[019-always-10-consoles.md](019-always-10-consoles.md)** ⭐ — Drop the "5 active + 5 on-demand" model. Make pTTY always create 10 consoles on startup. Simpler setup, simpler tmux.conf, simpler status bar (2 visual states instead of 3), simpler README. Cost: ~30–50 MB idle bash RSS on server (noise on any modern VPS). Supersedes task 018. High priority, 1–2h.
- **[020-readme-devex-pass.md](020-readme-devex-pass.md)** — Apply the 15 DevEx fixes from the README review: asciinema GIF in hero, "Try locally in 30s" Docker path, trim Quick Start, TOC, Uninstall section, fix mental-model whiplash, dedupe "Why This Exists" vs "The Problem", move Oracle Cloud Terraform out of README. High priority, 2–3h. Depends on 019.
- **[021-readme-tech-correctness.md](021-readme-tech-correctness.md)** — Apply the 20 technical correctness fixes: `curl|bash` safety story, real tmux minimum version (verify against features used; "2.0+" is wrong), `Ctrl+H`/`Ctrl+Alt+R` collision warnings, scoped session reset (no more `tmux kill-server` nuking unrelated sessions), `sudo` clarity in manual install, function-keys troubleshooting depth. High priority, 2–3h. Depends on 020.
- **[022-ssh-agent-and-secrets.md](022-ssh-agent-and-secrets.md)** — Net-new README section: SSH agent forwarding for `gh` / `git push` / cloud CLIs in long AI sessions, plus the stale-socket fix for detach/reattach. Common pain point, currently undocumented. Medium priority, 1–2h. Depends on 021.
- **[023-marketing-screenshots.md](023-marketing-screenshots.md)** — Marketing / visual presentation pass: study how [standardagents/dmux](https://github.com/standardagents/dmux) and other tmux+AI projects present themselves (hero visuals, asciinema, captions), then produce our own hero recording + F11/F12/status-bar screenshots. Satisfies 020-D2. Medium priority, 2–4h. Depends on 019/020.
- **[018-on-demand-consoles.md](018-on-demand-consoles.md)** — ⚠️ Superseded by task 019. Body kept for history; do not implement.

---

## Historical UX Gate

**[011-pre-implementation-ux-review.md](011-pre-implementation-ux-review.md)** - UX review process
**[011-UX-ISSUES.md](011-UX-ISSUES.md)** - Issues discovered during review

Task 011 is historical context. The active release gate now lives in
`.plan/REVIEW.md` and `.plan/epic-v0.2-ptty/ORCHESTRATOR.md`.

---

## ✅ Completed Documentation Tasks

### 🔴 CRITICAL (Documentation Foundation) ✅ DONE

**[007-fix-task-dependencies.md](007-fix-task-dependencies.md)** - Fix version references
- **Status:** ✅ COMPLETE
- **Result:** All tasks now reference correct v0.2 and task numbers 001-010

**[008-create-code-standards.md](008-create-code-standards.md)** - Create CODE-STANDARDS.md
- **Status:** ✅ COMPLETE
- **Result:** Comprehensive CODE-STANDARDS.md (946 lines, 12 sections)

---

### 🟡 HIGH (Documentation Quality) ✅ DONE

**[009-testing-strategy.md](009-testing-strategy.md)** - Testing strategy document
- **Status:** ✅ COMPLETE
- **Result:** Complete testing-strategy.md (874 lines, test pyramid, mocks, coverage)

**[010-add-cross-references.md](010-add-cross-references.md)** - Cross-reference docs
- **Status:** ✅ COMPLETE
- **Result:** Systematic cross-references between specs, ADRs, and tasks

---

### ⏳ Refactoring Tasks (BLOCKED - Waiting for UX approval)

**[001-refactor-state-management.md](001-refactor-state-management.md)** - State module
- **Blocked by:** Task 011 (UX review paused)
- **Ready:** ✅ CODE-STANDARDS complete
- **Status:** ⏳ WAITING FOR UX APPROVAL

**[002-refactor-ui-components.md](002-refactor-ui-components.md)** - UI components
- **Blocked by:** Task 011 (UX review paused), Task 001
- **Ready:** ✅ CODE-STANDARDS complete
- **Status:** ⏳ WAITING FOR UX APPROVAL

**[003-refactor-actions.md](003-refactor-actions.md)** - Action layer
- **Blocked by:** Task 011, Tasks 001-002
- **Ready:** ✅ CODE-STANDARDS complete
- **Status:** ⏳ WAITING FOR UX APPROVAL

**[004-testing-framework.md](004-testing-framework.md)** - bats testing
- **Blocked by:** Task 011 (UX review paused)
- **Ready:** ✅ Testing strategy complete
- **Status:** ⏳ WAITING FOR UX APPROVAL

**[005-code-standards.md](005-code-standards.md)** - ⚠️ REPLACED BY TASK 008
- **Note:** This task number kept for historical tracking
- **Actual work:** Task 008 created the document
- **Status:** ✅ See Task 008 (COMPLETE)

---

## ✅ Completed Tasks

### Documentation Phase (Tasks 006-011)

**Week 1: Foundation & Reorganization**
- ✅ **Task 006:** Documentation reorganization (2025-10-09)
  - Lifecycle structure (00-05 folders)
  - CLAUDE.md pattern established
  - Purpose headers added
  - ADRs created (002-005)
  - Vision documents (PURPOSE, ROADMAP, principles)
  - Score: 7.5/10

**Week 2: Critical Documentation Fixes**
- ✅ **Task 007:** Fix task dependencies (2025-10-09)
  - Corrected version references (v1.0 → v0.2)
  - Fixed old task numbers (013-017 → 001-010)
  - Clear dependency chain established

- ✅ **Task 008:** Create CODE-STANDARDS.md (2025-10-09)
  - 946 lines, 12 comprehensive sections
  - Function naming, error handling, testing
  - Migration guide and examples
  - Unblocked refactoring tasks

- ✅ **Task 009:** Testing strategy document (2025-10-09)
  - 874 lines, complete testing approach
  - Test pyramid (50/30/15/5)
  - Mock strategy with code examples
  - Coverage goals: v0.2 60%, v1.0 80%

- ✅ **Task 010:** Add cross-references (2025-10-09)
  - Systematic links: specs ↔ ADRs ↔ tasks
  - "Used In" sections in ADRs
  - Implementation status in specs
  - 90% faster navigation (10min → 1min)

**Documentation Quality:** 7.5/10 → 9.0/10 ⭐

### Foundation (Before Task 006)
- ✅ Lifecycle folder structure created
- ✅ Files moved to proper locations
- ✅ VERSIONING.md rules established
- ✅ Task numbering system defined

---

## 📊 Sprint Timeline

### Week 1: Foundation ✅ DONE (2025-10-09)
- [x] Folder reorganization
- [x] Versioning strategy
- [x] Documentation structure (Task 006)

### Week 2: Documentation Fixes ✅ DONE (2025-10-09)
- [x] Task 007: Fix dependencies
- [x] Task 008: CODE-STANDARDS.md
- [x] Task 009: Testing strategy
- [x] Task 010: Cross-references
- [x] Documentation quality: 7.5/10 → 9.0/10

### Quality Gate: UX Review ✅ PASSED (2025-10-09)
- [x] Task 011: Pre-implementation UX review (90 minutes)
- [x] GO/NO-GO decision: 🟢 **GO**
- [x] Issues: 3 found (0 critical, 2 medium, 1 low)
- [x] Status: Approved for implementation

### Week 3-4: Refactoring 🟢 APPROVED TO START
- [ ] Task 001: State management ✅ READY
- [ ] Task 002: UI components (after 001)
- [ ] Task 003: Actions layer (after 002)

### Week 5: Testing 🟢 APPROVED TO START
- [ ] Task 004: Testing framework ✅ READY (parallel)
- [ ] Write tests for refactored code

---

## Current Status

**NO-GO for v0.2 release until E002 completes:**

- 10-console runtime behavior is implemented and verified.
- F11 Manager binding is verified against the installed script set.
- Server reboot claims are limited to daemon autostart / empty-session recreation.
- CI fails on shell, tmux config, installer reference, and markdown-link errors.
- Clean install verification is recorded in `.plan/REVIEW.md`.

---

## 📝 Notes from Documentation Review

**Score:** 7.5/10 (Very Good)

**Strengths:**
- ⭐ Lifecycle structure excellent
- ⭐ ADR quality high
- ⭐ SSOT pattern clear

**Critical Issues Fixed by Tasks 007-010:**
1. Task dependencies confusion → Task 007
2. Missing CODE-STANDARDS → Task 008
3. Missing testing strategy → Task 009
4. Incomplete cross-references → Task 010

**See:** [03-architecture/DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md) for complete review

---

## 🎯 Next Actions

### ✅ Quality Gate Complete
1. ✅ Task 011: UX review complete (GO decision)

### 🟢 Ready to Implement (v0.2 Refactoring)
2. 🎯 **START NEXT:** Task 001 (State Management refactoring)
   - Create `src/core/state.sh` module
   - Implement console state caching (5s TTL)
   - Follow CODE-STANDARDS.md

3. ⏳ Task 002 (UI components - after 001)
   - Refactor Manager, Help, Status Bar
   - Implement UX-001 fix (Kill confirmation)

4. ⏳ Task 003 (Actions - after 002)
   - Extract attach, restart, detach actions

5. 🎯 Task 004 (Testing framework - parallel with 001)
   - Setup bats testing infrastructure
   - Write tests for State module

### 📋 Backlog (v0.2.1)
- UX-001: Add Kill confirmation in Manager
- UX-002: Test status bar on 80-column terminal
- UX-003: Add examples to F12 Help (v0.3)

---

## 🔗 Related Documents

- **[TASK-MANAGEMENT.md](../00-rules/TASK-MANAGEMENT.md)** - How to create and manage tasks
- **[VERSIONING.md](../00-rules/VERSIONING.md)** - Version planning
- **[DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md)** - Review that created tasks 007-010
- **[../02-planning/SPEC.md](../02-planning/SPEC.md)** - What we're building

---

## 📋 Future Tasks (v0.2+ Backlog)

**Moved to 02-planning/backlog/:**
- Status bar improvements (shadows, icons)
- Suspended terminals F8-F10 configuration
- Ctrl+Esc detach enhancement
- Ctrl+Del restart enhancement
- GitHub Pages (ptty.zentala.io)
- Contributions guide
- Website structure

**Pre-release rename:**
- **[012-rename-repo-to-ptty.md](012-rename-repo-to-ptty.md)** — Rename repo `tmux-persistent-console` → `ptty` (persistent TTY). Update GitHub repo, `package.json`/scripts, install paths (`~/.tmux-persistent-console` → `~/.ptty`), service file `tmux-console.service` → `ptty.service`, README, docs, GitHub Pages domain. Coordinate with v0.2 release.

**📜 Epic:** [.plan/epic-v0.2-ptty/](../.plan/epic-v0.2-ptty/) — full v0.2 deep refactor (PRD + ARCHITECTURE + REVIEW + 7 wave files). Decisions locked Q1–Q5 (env-var paths, hybrid plugins, K=kill, popup-only, pTTY rebrand). 5 waves, ~9 days. Start with [wave-1-paths.md](../.plan/epic-v0.2-ptty/wave-1-paths.md) (BLOCKER).

**🔴 BLOCKERS for v0.2:**
- **[013-fix-path-mismatch-universal.md](013-fix-path-mismatch-universal.md)** — `tmux.conf` references `~/.vps/sessions/...` (broken). Fix via `PTTY_DIR` env-var templating in install.sh. Currently F11/F12/Ctrl+H/Ctrl+R all silently fail.

**F11/F12 redesign (v0.2):**
- **[014-f11-popup-redesign.md](014-f11-popup-redesign.md)** — F11 Manager: popup overlay (no pseudo-session), single-key actions (Enter/K kill/r restart/n new/R rename), live metrics (uptime, CPU, last cmd).
- **[015-f12-which-key-help.md](015-f12-which-key-help.md)** — F12 Help: which-key style popup, auto-generated from `tmux list-keys`, grouped, searchable, replaces static text wall + `sleep infinity`.

**Strategic:**
- **[016-tmux-plugins-evaluation.md](016-tmux-plugins-evaluation.md)** — Evaluate sessionx / which-key / resurrect+continuum vs. own implementation (v0.3).
- **[017-rewrite-in-go.md](017-rewrite-in-go.md)** — Long-term: rewrite in Go + bubbletea, single static binary (v1.0).

---

**Current phase:** v0.2 release hardening.

**Quality gate:** NO-GO until `.plan/epic-v0.2-ptty/tasks/E002-T07-clean-install-release-verification.md`
is completed.
