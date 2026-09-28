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

- [ ] **3.5 reconcile `service.md`** (S). The domain notes still document
  `WantedBy=graphical.target`, `After=hyprland.service`, and a lifecycle that
  focuses the headless monitor before serving. Done when: the unit targets
  and the focus/restore lifecycle match 3.1/3.2.

- [ ] **3.6 reconcile `AGENTS.md`** (S). The constitution's "What it is"
  section still names `graphical.target`/`hyprland.service` as the unit's
  targets, which 3.2 replaced. Done when: `AGENTS.md` describes the unit as
  installed, in its own commit.



