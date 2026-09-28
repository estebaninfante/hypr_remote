# Hypr Remote TODO

The work list, in build order. `AGENTS.md` is the constitution; this file is
the queue. Remove items as they land — do not check them off, do not let it
rot.

Authorized work only: the queue grants exactly the steps it lists, top-down,
and never overrides the constitution, `.llm/workflow.md`, or the domain notes
(see `AGENTS.md` → Instruction precedence).

Every step is one action with its own done-criteria. Work top-down, one step
at a time: implement it, prove it without breaking the live Hyprland session
(`bash -n` + `shellcheck`, `systemd-analyze verify` for the unit, dry logic
review of the `hyprctl` ordering — live commands only with a go-ahead), then
remove it. Never remove an unverified step; never batch multiple steps into
one change. Split work that spans the script, the unit, and the installer
into separate steps.

Sizes: S <1 day, M 1–3 days, L 3+ days.

## Open steps

- [ ] **3.3 declare the `jq` prerequisite in `install.sh`** (S). The script
  reads `hyprctl activeworkspace -j` and needs `jq`, which the installer does
  not check the way it checks `wayvnc` and `hyprctl`. Done when: a missing
  `jq` fails the install with the same message shape and `bash -n` +
  `shellcheck` are clean.

- [ ] **3.4 reconcile the README** (S). The README still describes the legacy
  dispatch calls, the pre-0.56 focus-stealing lifecycle, and the
  `graphical.target` unit. Done when: it matches the script and unit as
  landed by 3.1/3.2.

- [ ] **3.5 reconcile `service.md`** (S). The domain notes still document
  `WantedBy=graphical.target`, `After=hyprland.service`, and a lifecycle that
  focuses the headless monitor before serving. Done when: the unit targets
  and the focus/restore lifecycle match 3.1/3.2.



