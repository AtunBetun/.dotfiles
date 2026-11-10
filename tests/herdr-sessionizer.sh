#!/usr/bin/env bash
# Run with /bin/bash on macOS, or bash on Linux. No live Herdr calls are made.
set -euo pipefail
repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
fixture=$(CDPATH= cd -- "$fixture" && pwd -P)
test_shell=${SESSIONIZER_SHELL:-$BASH}
jq_bin=$(command -v jq)
if [[ $jq_bin == */shims/jq ]]; then
    jq_bin=$(mise which jq)
fi
mkdir -p "$fixture/bin" "$fixture/home/work/project space" \
    "$fixture/company/service/src/nested" "$fixture/current/project space" \
    "$fixture/elsewhere/project space" "$fixture/empty-home"
ln -s work "$fixture/home/personal"
ln -s "$fixture/company" "$fixture/home/workplace"
ln -s "$jq_bin" "$fixture/bin/jq"

cat > "$fixture/bin/mise" <<'SH'
#!/bin/sh
[ "$*" = "-C $HOME env --shell bash" ] || exit 90
[ "$MISE_CEILING_PATHS" = "$HOME" ] || exit 91
printf 'export PATH=%s\n' '"'"$TEST_BIN:/usr/bin:/bin"'"'
SH
cat > "$fixture/bin/id" <<'SH'
#!/bin/sh
[ "$1" = -un ] || exit 90
printf 'dotfiles-sessionizer-fixture\n'
SH
cat > "$fixture/bin/fzf" <<'SH'
#!/bin/sh
cat > "$CANDIDATES"
[ "${FZF_EXIT:-0}" = 0 ] || exit "$FZF_EXIT"
printf '%s\n' "$FZF_SELECTION"
SH
cat > "$fixture/bin/herdr" <<'SH'
#!/bin/sh
printf '%s\n' "$@" >> "$CALLS"
if [ "$*" = "workspace list" ]; then
    cat "$LISTING"
fi
SH
chmod +x "$fixture/bin/mise" "$fixture/bin/id" "$fixture/bin/fzf" "$fixture/bin/herdr"

export TEST_BIN="$fixture/bin" CANDIDATES="$fixture/candidates" \
    CALLS="$fixture/calls" LISTING="$fixture/workspaces.json"
export FZF_SELECTION="$fixture/home/work/project space" FZF_EXIT=0
printf '{"result":{"workspaces":[]}}\n' > "$LISTING"

run_sessionizer() {
    : > "$CALLS"
    : > "$CANDIDATES"
    status=0
    HOME="${TEST_HOME:-$fixture/home}" PATH="$fixture/bin:/usr/bin:/bin" \
        CDPATH="${TEST_CDPATH:-}" "$test_shell" "$repo/scripts/herdr-sessionizer" "$@" \
        > "$fixture/stdout" 2> "$fixture/stderr" || status=$?
}

expect_success() {
    if [[ $status != 0 ]]; then
        printf 'FAIL: %s (exit %s)\n' "$1" "$status" >&2
        cat "$fixture/stderr" >&2
        exit 1
    fi
}

expect_calls() {
    printf '%s\n' "$@" > "$fixture/expected"
    if ! diff -u "$fixture/expected" "$CALLS"; then
        printf 'FAIL: unexpected Herdr arguments\n' >&2
        exit 1
    fi
}

# The regression: macOS's Bash 3.2 must reach the picker and create a workspace.
run_sessionizer
expect_success 'picker supports the system Bash'
expect_calls workspace list workspace create --cwd \
    "$fixture/home/work/project space" --label 'project space' --focus

# AL2's symlink deduplication must survive the portability fix.
[[ $(grep -Fxc "$fixture/home/work/project space" "$CANDIDATES") == 1 ]]
if grep -Fq "$fixture/home/personal/project space" "$CANDIDATES"; then
    printf 'FAIL: symlinked root was listed twice\n' >&2
    exit 1
fi
grep -Fxq "$fixture/home/workplace/service/src/nested" "$CANDIDATES"

# A relative argument must stay relative to the caller, even with CDPATH set.
(
    cd -- "$fixture/current"
    TEST_CDPATH="$fixture/elsewhere"
    run_sessionizer 'project space'
    expect_success 'relative paths ignore inherited CDPATH'
    expect_calls workspace list workspace create --cwd \
        "$fixture/current/project space" --label 'project space' --focus
)

# Legacy full-path labels are renamed and focused instead of duplicated.
printf '{"result":{"workspaces":[{"workspace_id":"existing","label":"%s"}]}}\n' \
    "$fixture/home/work/project space" > "$LISTING"
run_sessionizer "$fixture/home/work/project space"
expect_success 'existing workspace is reused'
expect_calls workspace list workspace rename existing 'project space' \
    workspace focus existing

# Cancellation and an empty home must be successful no-ops.
FZF_EXIT=130
run_sessionizer
expect_success 'cancel is a no-op'
[[ ! -s $CALLS ]]
FZF_EXIT=0
TEST_HOME="$fixture/empty-home" run_sessionizer
expect_success 'no directories is a no-op'
[[ ! -s $CALLS && ! -s $CANDIDATES ]]

# Invalid workspace responses must fail without creating anything.
printf '{"result":{}}\n' > "$LISTING"
run_sessionizer "$fixture/home/work/project space"
[[ $status != 0 ]]
expect_calls workspace list

printf 'sessionizer checks passed (%s)\n' "$test_shell"
