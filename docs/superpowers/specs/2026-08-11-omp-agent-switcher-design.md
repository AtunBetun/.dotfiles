# OMP Agent Switcher Design

## Goal

Add an on-demand tmux popup that lists every tracked OMP pane across all tmux sessions, shows one of three states, and switches to the selected pane. The popup must not create persistent UI.

## Scope

The switcher tracks OMP panes only. It does not replace tmux, add a sidebar, send desktop notifications, manage worktrees, alter the existing sessionizer, or infer whether arbitrary assistant prose is asking a question.

## User experience

`prefix + a` opens a centered `fzf` popup. Each row contains a colored state marker, repository or working-directory label, tmux session/window label, and a short reason when useful.

Example:

```text
● repo-a  dev:api      needs approval
● repo-b  dev:worker   working
● repo-c  misc:agent   done
```

Rows sort by urgency: red, yellow, then green. Rows within a state have a stable tmux target order. `Enter` closes the popup and redirects the invoking tmux client to the selected session, window, and pane. `Esc` closes the popup without changing focus. Opening the same binding again after closing it creates a fresh snapshot.

The popup does not live-refresh while open. OMP continues updating state in the background, and the next opening reflects the latest state.

## State model

Each tracked OMP pane stores these tmux pane options:

- `@omp_state`: `done`, `working`, or `input`
- `@omp_session`: the best available OMP session name or stable identifier
- `@omp_reason`: a short actionable reason, empty when none applies

Display mapping:

| Stored state | Color | Meaning |
| --- | --- | --- |
| `done` | green | The agent completed cleanly and is ready for another prompt. |
| `working` | yellow | The agent is processing a prompt or executing tools. |
| `input` | red | The agent opened an OMP ask dialog, awaits tool approval, or ended with an error. |

Transitions:

- OMP session start registers the current pane as `done`.
- User input or agent start sets `working` and clears `@omp_reason`.
- A terminal `agent_end` examines the last assistant message. `willContinue` keeps the state `working`; otherwise `stopReason: "error"` or a non-empty `errorMessage` sets `input`, and a clean end sets `done`.
- An OMP `ask` `tool_call` sets `input` until its matching `tool_result`; completion returns the state to `working`.
- `tool_approval_requested` sets `input` until its matching `tool_approval_resolved`; resolution returns the state to `working`, whether approved or denied.
- `credential_disabled` sets `input` with the provider and bounded failure cause.
- A new user prompt clears a prior red state and sets `working`.
- Session shutdown clears all switcher-specific pane options so stale panes disappear.

Ordinary assistant text ending in a question is not classified as `input`; there is no reliable structured signal for that case. Clean completion remains green.

## Components

### OMP extension

A global TypeScript extension under the user OMP extension directory subscribes to structured OMP lifecycle, input, `ask` tool, approval, credential, and shutdown events. It identifies the containing pane through `TMUX_PANE` and updates only that pane's options with direct `tmux set-option -p -t <pane>` calls. The session label comes from `pi.getSessionName()` when present, with the tmux pane label as the display fallback.

The extension tracks outstanding `ask` and approval tool-call IDs in memory so unrelated tool events cannot clear a real input wait. It must fail open: missing tmux, a missing `TMUX_PANE`, or a failed state update must not block prompts, tools, approvals, or OMP shutdown. Reasons written to pane options must be single-line and bounded so untrusted tool or error text cannot distort the picker.

### Picker script

A shell script queries `tmux list-panes -a` once, includes only panes with a valid `@omp_state`, maps each pane to a colored display row plus an opaque tmux target, and passes the rows to `fzf`.

The display text and target identity remain separate. Selection must use the opaque pane ID rather than parsing human-readable labels. If no tracked panes exist, the popup displays a short empty-state message and exits successfully.

### tmux binding

The tmux configuration binds `prefix + a` to `display-popup`, launching the picker script in a centered, bounded popup. The popup inherits enough `PATH` to find tmux and `fzf` without depending on an interactive shell startup file.

## Cross-session switching

On selection, the picker determines the pane's owning session and window from tmux metadata, switches the invoking client to that session, selects the owning window, and selects the exact pane. A pane that disappears between snapshot and selection produces a concise error and leaves the client on its current target.

## Error handling

- Invalid or missing pane state is omitted.
- Unknown future states are omitted rather than assigned a misleading color.
- Missing `fzf` or tmux returns a concise popup error.
- A vanished selected pane does not trigger fallback selection.
- OMP event-handler failures are contained and logged without changing agent behavior.
- Error and reason text is sanitized to one line and truncated.

## Verification

Verification uses a real tmux server and a minimal OMP extension event harness:

1. Start three disposable tmux panes and assign `done`, `working`, and `input` through the same state-writing function used by the extension.
2. Open the picker and confirm ordering and green/yellow/red rendering.
3. Select each row and confirm tmux focuses the exact pane, including a pane in another session.
4. Confirm `Esc` leaves focus unchanged.
5. Remove a pane after snapshot creation and confirm selection fails safely.
6. Exercise OMP event transitions for session start, prompt/agent start, clean end, continued end, `ask` start/result, approval request/resolution, terminal assistant error, credential disablement, and shutdown.
7. Run the actual popup from `prefix + a` as a smoke test.

## Acceptance criteria

- The popup is absent until invoked and leaves no pane or sidebar behind after closing.
- It lists tracked OMP panes across every tmux session.
- Green means cleanly done, yellow means working, and red means structured input/approval or error attention is required.
- Red rows appear before yellow rows, which appear before green rows.
- `Enter` redirects to the exact selected pane, including across sessions.
- `Esc` closes without redirecting.
- OMP continues normally if switcher state updates fail.
