#!/usr/bin/env bash
# Run with bash tests/init.sh; all installer commands are local stubs.
set -euo pipefail
repo=$(cd -- "$(dirname -- "$0")/.." && pwd)
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/home"

cat > "$fixture/bin/uname" <<'SH'
#!/usr/bin/env bash
case "$1" in
    -s) printf 'Darwin\n' ;;
    -m) printf 'x86_64\n' ;;
esac
SH
cat > "$fixture/bin/mise" <<'SH'
#!/usr/bin/env bash
printf 'mise %s\n' "$*" >> "$COMMAND_LOG"
if [[ $* != 'ls --current' && ${MISE_ENV:-} != "$EXPECTED_ENV" ]]; then
    printf 'Unexpected MISE_ENV: %s (expected %s)\n' "${MISE_ENV:-}" "$EXPECTED_ENV" >&2
    exit 38
fi
if [[ -n ${FAIL_AT:-} && $* == "$FAIL_AT" ]]; then
    printf 'native command failed\n' >&2
    exit 37
fi
case "$*" in
    --version) printf '2026.11.0 test\n' ;;
    'bootstrap packages status') printf 'native package status\n' ;;
    'ls --current')
        [[ $MISE_CONFIG_DIR == "$EXPECTED_PROFILE" && -z $MISE_ENV && $MISE_CEILING_PATHS == "$EXPECTED_REPO" ]] || exit 38
        printf 'node 22.22.2\n'
        ;;
    'run --output=interleave --timings packages')
        read -r answer
        [[ $answer == sudo-input ]] || exit 39
        printf 'native installed/already-installed output\n'
        printf 'native stderr output\n' >&2
        ;;
esac
SH
cat > "$fixture/bin/brew" <<'SH'
#!/usr/bin/env bash
printf 'brew %s\n' "$*" >> "$COMMAND_LOG"
SH
chmod +x "$fixture/bin/uname" "$fixture/bin/mise" "$fixture/bin/brew"
printf 'sudo-input\n' > "$fixture/stdin"

assert_contains() {
    if ! grep -Fq -- "$2" "$1"; then
        printf 'Missing expected output: %s\n' "$2" >&2
        exit 1
    fi
}

assert_absent() {
    if grep -Fq -- "$2" "$1"; then
        printf 'Unexpected output: %s\n' "$2" >&2
        exit 1
    fi
}

run_init() {
    : > "$fixture/commands"
    status=0
    HOME="$fixture/home" PATH="$fixture/bin:$PATH" \
        COMMAND_LOG="$fixture/commands" EXPECTED_PROFILE="$repo/tools/default" \
        EXPECTED_REPO="$repo" EXPECTED_ENV="${EXPECTED_ENV:-}" MISE_ENV=inherited-profile FAIL_AT="$1" \
        bash "$repo/init" < "$fixture/stdin" > "$fixture/output" 2>&1 || status=$?
}

run_init ''
[[ $status == 0 ]]
assert_contains "$fixture/output" '[....................]   0% | started 1/7: Ensure mise is available'
assert_contains "$fixture/output" '[####################] 100% | done 7/7: Check deployed configuration'
assert_contains "$fixture/output" 'Summary: 7/7 stages completed successfully'
assert_contains "$fixture/output" 'Profile: default'
assert_contains "$fixture/output" 'native installed/already-installed output'
assert_contains "$fixture/output" 'native stderr output'
assert_contains "$fixture/commands" 'brew install gnupg pass cmake unzip'
assert_absent "$fixture/commands" 'mise install'
assert_absent "$fixture/commands" 'mise -E'

run_init 'config ls'
[[ $status == 37 ]]
assert_contains "$fixture/output" 'failed 2/7: Trust and load manifest (minimum mise version)'
assert_contains "$fixture/output" 'Summary: 1/7 stages completed;'
assert_absent "$fixture/commands" 'bootstrap packages status'
assert_absent "$fixture/commands" 'brew install'
assert_absent "$fixture/commands" 'run --output=interleave'

run_init 'run --output=interleave --timings packages'
[[ $status == 37 ]]
assert_contains "$fixture/output" 'failed 4/7: Install native OS packages'
assert_contains "$fixture/output" 'exit 37'
assert_absent "$fixture/commands" 'run --output=interleave --timings setup'
assert_absent "$fixture/output" '100%'

run_init 'run --output=interleave --timings editor-setup'
[[ $status == 37 ]]
assert_contains "$fixture/output" 'failed 6/7: Set up editor plugins, tools and parsers'
assert_absent "$fixture/commands" 'run --output=interleave --timings check'
printf 'init boundary checks passed\n'
