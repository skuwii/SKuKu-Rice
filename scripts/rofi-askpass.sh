#!/usr/bin/env bash
# SUDO_ASKPASS helper. Lets `sudo -A` prompt via rofi when there is no TTY
# (Claude Code, scripts, keybinds). Without this sudo aborts, and each abort
# counts as a pam_faillock failure — three of those lock the account 10 min.
rofi -dmenu -password -p "sudo" -mesg "${1:-Password required}" -lines 0
