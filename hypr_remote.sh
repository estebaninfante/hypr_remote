#!/usr/bin/env bash
set -euo pipefail

VIRTUAL_MONITOR="${HYPR_REMOTE_MONITOR:-HEADLESS-2}"
VIRTUAL_WORKSPACE="${HYPR_REMOTE_WORKSPACE:-10}"
REAL_MONITOR="${HYPR_REMOTE_REAL_MONITOR:-HDMI-A-1}"
VNC_BIND="${HYPR_REMOTE_BIND:-127.0.0.1}"
VNC_PORT="${HYPR_REMOTE_PORT:-5900}"

WAYVNC_PID=""
STARTED=0
PREV_WORKSPACE=""

focus_workspace() {
  hyprctl dispatch "hl.dsp.focus({ workspace = $1 })"
}

move_workspace_to_monitor() {
  hyprctl dispatch "hl.dsp.workspace.move({ workspace = $1, monitor = '$2' })"
}

focus_monitor() {
  hyprctl dispatch "hl.dsp.focus({ monitor = '$1' })"
}

capture_active_workspace() {
  PREV_WORKSPACE="$(hyprctl activeworkspace -j | jq -r '.id')"
}

restore_workspace() {
  [[ "$PREV_WORKSPACE" =~ ^[0-9]+$ ]] || return 1
  [[ "$PREV_WORKSPACE" != "$VIRTUAL_WORKSPACE" ]] || return 1
  focus_workspace "$PREV_WORKSPACE"
}

cleanup() {
  [[ "$STARTED" -eq 1 ]] || return 0
  STARTED=0
  if [[ -n "$WAYVNC_PID" ]] && kill -0 "$WAYVNC_PID" 2>/dev/null; then
    kill "$WAYVNC_PID" 2>/dev/null || true
  fi
  move_workspace_to_monitor "$VIRTUAL_WORKSPACE" "$REAL_MONITOR"
  if ! restore_workspace; then
    focus_monitor "$REAL_MONITOR"
  fi
}

trap cleanup INT TERM EXIT

main() {
  hyprctl output remove "$VIRTUAL_MONITOR" 2>/dev/null || true
  sleep 0.2
  hyprctl output create headless "$VIRTUAL_MONITOR"
  sleep 0.5

  capture_active_workspace
  focus_workspace "$VIRTUAL_WORKSPACE"
  move_workspace_to_monitor "$VIRTUAL_WORKSPACE" "$VIRTUAL_MONITOR"
  sleep 0.2
  restore_workspace || true

  wayvnc "$VNC_BIND" "$VNC_PORT" "$VIRTUAL_MONITOR" &
  WAYVNC_PID=$!
  STARTED=1
  wait "$WAYVNC_PID"
}

main
