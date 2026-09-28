# Hypr Remote service

How the virtual monitor, WayVNC, and the user service fit together. Derived
from `AGENTS.md`; on a conflict the constitution wins.

```text
hypr_remote.sh          lifecycle: create output, place workspace, serve, clean up
  hyprctl output remove HEADLESS-2       (stale output only; absence ignored)
  hyprctl output create headless HEADLESS-2
  record the active workspace, move workspace 10 onto HEADLESS-2,
  restore the recorded workspace and focus
  wayvnc 127.0.0.1 5900 HEADLESS-2       (backgrounded, PID tracked, waited on)
  on INT/TERM/EXIT: kill only the tracked PID (no-op unless serving
  started), move workspace 10 back to HDMI-A-1, then restore the recorded
  workspace — or focus HDMI-A-1 when the recording is unusable

hypr_remote.service     user unit: WantedBy=graphical-session.target,
                        After=graphical-session.target,
                        ExecStart=%h/.local/bin/hypr_remote.sh,
                        User=RESU placeholder

install.sh              deploy: require wayvnc/hyprctl/jq, substitute RESU/GDX
                        from live env, copy unit -> ~/.config/systemd/user/,
                        copy script -> ~/.local/bin/,
                        systemctl --user daemon-reload
```

## Current values (defaults; overridable via env, see below)

- Virtual monitor: `HEADLESS-2` (created via `hyprctl output create
  headless`; a stale same-name output is removed first).
- Scratch workspace: `10` (moved onto the headless output on start, back
  onto the real monitor on exit).
- Real monitor: `HDMI-A-1` (cleanup target; where the local session keeps
  working while the remote client uses the headless output).
- VNC endpoint: `127.0.0.1:5900` against `HEADLESS-2` (localhost-only).

## Security decision (2.2)

WayVNC serves with no authentication, so the default bind is localhost and
remote access goes over `ssh -L 5900:localhost:5900 <host>`. LAN-wide exposure
(`HYPR_REMOTE_BIND=0.0.0.0`) is supported for trusted networks only — the
traffic is unencrypted VNC either way. Revisit if wayvnc gains usable auth
or TLS-by-default.

Per-host overrides (never edit the script per machine):
`HYPR_REMOTE_MONITOR`, `HYPR_REMOTE_WORKSPACE`, `HYPR_REMOTE_REAL_MONITOR`,
`HYPR_REMOTE_BIND`, `HYPR_REMOTE_PORT` — each falls back to the default
above.

When monitor or workspace names change in the script, the service and
installer need no change unless a path or placeholder moves — but this file
must be updated in the same step (its own commit on `master`).

## Dispatch API (0.56+)

Hyprland 0.56 removed the legacy `hyprctl dispatch <name> <args>` interface.
The script drives the session through the Lua dispatcher API instead:
`hl.dsp.focus({ workspace = ... })` switches workspace,
`hl.dsp.workspace.move({ workspace = ..., monitor = ... })` moves a workspace
to a monitor, and `hl.dsp.focus({ monitor = ... })` focuses a monitor. This
is a hard floor: the script no longer works on pre-0.56 Hyprland.

## Lifecycle notes

- `wayvnc` runs as a tracked background child the script waits on; stopping
  the unit (or a TERM/INT) fires the trap, which kills only that PID and
  returns the workspace to the real monitor. The trap is a no-op if serving
  never started, and idempotent across repeated signals.
- The script records the active workspace (`hyprctl activeworkspace -j` +
  `jq`) before moving the scratch workspace, then restores that workspace
  and focus. Starting or stopping the unit never switches the local monitor
  to an unrelated workspace. WayVNC captures the headless output's active
  workspace, so the headless monitor never needs to hold focus for the
  remote view to show workspace 10.
- WayVNC is a prerequisite binary, not part of this repo. Empty/missing
  output or a dead workspace at serve time means the remote client sees
  nothing — reason through the `hyprctl` ordering dry before changing it.
