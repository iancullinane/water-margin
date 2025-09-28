Recent changes summary

- Entities are now centralized under `EntityCtl` (Node2D).
  - `components/entity_ctl.gd` auto-loads child `Entity` nodes on `_ready()`.
  - `Game` cycles active entity with `next_character`/`previous_character` and calls `entity_ctl.set_current_player(...)`.

- Signals added to `SignalBus`:
  - `current_player_changed(entity: Entity)` — emitted in `entity_ctl.set_current_player`.
  - `current_player_moved(entity: Entity)` — emitted in `Entity._on_move/_on_swipe` when `current_player`.

- Camera behavior:
  - `Game` connects both signals in `_ready()` and sets `CameraCtl.position` to the entity.
  - Camera has smoothing enabled; movement follows the active entity.

- Focus:
  - `GameFocus.player` is updated to the active entity on switch (when present).

- Notes:
  - Movement helpers in `entity_ctl.gd` are optional; selection is handled via the controller and signals.

