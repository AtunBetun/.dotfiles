#!/usr/bin/env bash
# agent-notify.sh — desktop nudge when a Claude Code agent needs attention.
#
# Driven by Claude Code hooks (see ~/.claude/settings.json):
#   --state needs-input   yellow : blocked on a permission prompt or an
#                                   arrow-key selection menu (AskUserQuestion /
#                                   ExitPlanMode), i.e. it's waiting on you.
#   --state done          green  : finished a turn and handed back to you.
#
# Quieter cousin of the mwinit cron reminder: same notify-send / X11 path,
# but -u normal/low instead of critical. Reads the hook JSON payload on stdin
# and titles the notification with the session name (transcript customTitle).
#
# Self-contained: all notify-send logic lives here so it travels via dotfiles.
#
# A notification hook must be fire-and-forget: it must ALWAYS exit 0 so Claude
# Code never surfaces a hook error. Hence we deliberately do NOT use `set -e`
# or `pipefail` (a grep that finds no customTitle exits non-zero, which would
# otherwise abort the script before notify-send and report a phantom failure).
# `set -u` is kept to catch genuine unset-variable typos; every external value
# is guarded. The script ends with an explicit `exit 0`.

set -u

# --- args ---------------------------------------------------------------
state=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --state) state="${2:-}"; shift 2 ;;
        *)       shift ;;
    esac
done
case "$state" in
    needs-input|done) ;;
    *) echo "usage: agent-notify.sh --state <needs-input|done>" >&2; exit 1 ;;
esac

# --- no-op if we can't notify (e.g. headless box) -----------------------
command -v notify-send >/dev/null 2>&1 || exit 0
# notify-send delivers over the session DBus bus (libnotify), NOT over X11 —
# so DISPLAY is largely irrelevant; the session bus is what matters. A hook
# (like a cron job) may inherit XDG_RUNTIME_DIR but not DBUS_SESSION_BUS_ADDRESS,
# so derive the standard per-user bus path when it's unset. DISPLAY is still
# exported as a harmless fallback for any daemon that does consult it.
export DISPLAY="${DISPLAY:-localhost:10.0}"
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    _runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    if [ -S "${_runtime_dir}/bus" ]; then
        export DBUS_SESSION_BUS_ADDRESS="unix:path=${_runtime_dir}/bus"
    fi
fi

# --- read hook payload from stdin (jq: always installed) ----------------
payload="$(cat 2>/dev/null || true)"
transcript=""
cwd=""
if [ -n "$payload" ]; then
    transcript="$(printf '%s' "$payload" | jq -r '.transcript_path // empty' 2>/dev/null || true)"
    cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null || true)"
fi

# --- resolve the session name -------------------------------------------
# The human title lives as the latest `customTitle` line in the transcript
# JSONL. Use grep+tail (streaming) rather than `jq -s` so we don't slurp a
# multi-MB transcript on every Stop. grep keeps spaces in the title intact.
session_name=""

extract_title() {
    # $1 = transcript file
    [ -n "${1:-}" ] && [ -f "$1" ] || return 0
    grep -o '"customTitle":"[^"]*"' "$1" 2>/dev/null \
        | tail -1 \
        | sed 's/^"customTitle":"//; s/"$//'
}

if [ -n "$transcript" ]; then
    session_name="$(extract_title "$transcript")"
fi

# Fallback 1: locate <session_id>.jsonl under ~/.claude/projects/*/
if [ -z "$session_name" ] && [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then
    for alt in "$HOME"/.claude/projects/*/"${CLAUDE_CODE_SESSION_ID}".jsonl; do
        [ -f "$alt" ] || continue
        session_name="$(extract_title "$alt")"
        break
    done
fi

# Fallback 2: working-directory basename. Fallback 3: literal "Claude".
if [ -z "$session_name" ]; then
    if [ -n "$cwd" ]; then
        session_name="$(basename "$cwd")"
    else
        session_name="Claude"
    fi
fi

# --- compose + fire ------------------------------------------------------
# Emoji is the guaranteed-visible colour signal; bg/fgcolor hints render true
# yellow/green on daemons that honour them (e.g. dunst) and are ignored
# elsewhere. Body is intentionally brief.
case "$state" in
    needs-input)
        icon="🟡"; bg="#f5c211"; urgency="normal"; body="needs input" ;;
    done)
        icon="🟢"; bg="#33d17a"; urgency="low";    body="done" ;;
esac

notify-send \
    -a "Claude Code" \
    -u "$urgency" \
    -t 8000 \
    -h "string:bgcolor:${bg}" \
    -h "string:fgcolor:#000000" \
    "${icon} ${session_name}" \
    "${body}" \
    2>/dev/null || true

# Always succeed — a notifier must never report a hook failure.
exit 0
