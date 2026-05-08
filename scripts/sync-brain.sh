#!/usr/bin/env bash
# sync-brain.sh — sync Obsidian vault context ↔ ~/.claude/context/
# Usage: sync-brain.sh [pull|push]  (default: pull)

VAULT="$HOME/notes/SKuKu Brain"
CTX="$HOME/.claude/context"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

pull() {
    echo "brain-pull: vault → ~/.claude/"
    mkdir -p "$CTX"
    cp "$VAULT/STR/rice.md"        "$CTX/rice.md"
    cp "$VAULT/brain/projects.md"  "$CTX/projects.md"
    cp "$VAULT/AI/ai.md"           "$CTX/ai.md"
    cp "$VAULT/cybersec/cybersec.md" "$CTX/cybersec.md"
    cp "$VAULT/uni/uni.md"         "$CTX/uni.md"
    cp "$VAULT/CLAUDE.md"          "$CLAUDE_MD"
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
