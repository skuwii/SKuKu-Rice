#!/usr/bin/env bash
# sync-brain.sh — sync Obsidian vault context ↔ ~/.claude/context/
# Usage: sync-brain.sh [pull|push]  (default: pull)

VAULT="$HOME/notes/SKuKu-Brain"
CTX="$HOME/.claude/context"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

pull() {
    echo "brain-pull: vault → ~/.claude/"
    mkdir -p "$CTX"
    cp "$VAULT/STR/rice.md"          "$CTX/rice.md"          2>/dev/null && echo "  rice.md" || echo "  rice.md [missing]"
    cp "$VAULT/brain/projects.md"    "$CTX/projects.md"      2>/dev/null && echo "  projects.md" || echo "  projects.md [missing]"
    cp "$VAULT/AI/ai.md"             "$CTX/ai.md"            2>/dev/null && echo "  ai.md" || echo "  ai.md [missing, skipped]"
    cp "$VAULT/cybersec/cybersec.md" "$CTX/cybersec.md"      2>/dev/null && echo "  cybersec.md" || echo "  cybersec.md [missing]"
    cp "$VAULT/uni/uni.md"           "$CTX/uni.md"           2>/dev/null && echo "  uni.md" || echo "  uni.md [missing]"
    cp "$VAULT/CLAUDE.md"            "$CLAUDE_MD"            2>/dev/null && echo "  CLAUDE.md" || echo "  CLAUDE.md [missing]"
    echo "done."
}

push() {
    echo "brain-push: ~/.claude/ → vault + git push"
    cp "$CTX/rice.md"        "$VAULT/STR/rice.md"
    cp "$CTX/projects.md"    "$VAULT/brain/projects.md"
    cp "$CTX/ai.md"          "$VAULT/AI/ai.md"
    cp "$CTX/cybersec.md"    "$VAULT/cybersec/cybersec.md"
    cp "$CTX/uni.md"         "$VAULT/uni/uni.md"
    cp "$CLAUDE_MD"          "$VAULT/CLAUDE.md"
    cd "$VAULT" && git add -A && git commit -m "sync: claude context update" && git push
    echo "done."
}

case "${1:-pull}" in
    pull) pull ;;
    push) push ;;
    *) echo "Usage: sync-brain.sh [pull|push]"; exit 1 ;;
esac
