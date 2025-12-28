#!/usr/bin/env bash
# session-start.sh - Claude Code session initialization hook for Beads
#
# This hook runs at the start of each Claude Code session to:
# 1. Check if bd (beads) is installed
# 2. Import any changes from git
# 3. Display ready work items
# 4. Show project stats
#
# Installation:
#   mkdir -p .claude/hooks
#   cp session-start.sh .claude/hooks/
#   chmod +x .claude/hooks/session-start.sh

set -euo pipefail

# Skip if not in a beads-enabled project
if [[ ! -d ".beads" ]]; then
    exit 0
fi

# Check if bd is installed
if ! command -v bd &> /dev/null; then
    echo "Note: bd (beads) not installed."
    echo "Install: brew tap steveyegge/beads && brew install bd"
    exit 0
fi

echo "=== Beads Issue Tracker ==="
echo ""

# Show version
bd version 2>/dev/null || echo "bd version: unknown"
echo ""

# Import any changes from git (in case of recent pull)
bd import -i .beads/issues.jsonl 2>/dev/null || true

# Show ready work (top 5)
echo "Ready work (no blockers):"
if bd ready --limit 5 2>/dev/null; then
    :
else
    echo "  (no issues or error querying)"
fi
echo ""

# Show blocked count
blocked_count=$(bd blocked --json 2>/dev/null | grep -c '"id"' || echo "0")
if [[ "$blocked_count" -gt 0 ]]; then
    echo "Blocked issues: $blocked_count"
    echo "  Run 'bd blocked' for details"
    echo ""
fi

# Show stats
echo "Stats:"
bd stats 2>/dev/null || echo "  (unable to get stats)"
echo ""

echo "Commands: bd ready | bd create | bd show <id> | bd sync"
echo "==========================="
