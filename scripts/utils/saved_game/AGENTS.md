# Save / load

## Shape

Three pieces, deliberately ignorant of each other:

- **`SaveCtl`** (`globals/save_ctl.gd`, autoload) owns slot layout: where saves
  live, how they're listed, which one is active. Nothing else should build a
  save path.
- **`SaverLoader`** (this directory) serializes a `SavedGame` to the active slot
  and reads it back. It asks `SaveCtl` for the path; it never composes one.
- **`SavedGame` / `ObjectData`** are plain `Resource`s. `SavedGame` holds
  `last_selected_player` plus an `Array[ObjectData]`; each `ObjectData` is one
  entity's `scene_path` and `position`.

The start screen writes a selection into `SaveCtl` and then calls
`change_scene_to_file` with no arguments. The slot travels through the autoload,
not through the scene swap. Don't add a slot argument to `Game`.

## Invariants worth not breaking

**A new game is just a load.** `res://data/saves/new_game.tres` is a committed
`SavedGame` describing the starting world. `load_game()` falls back to it, so it
never returns null and `game.gd` has no new-game branch. New Game and Load are
the same code path — that's the point, and it means breaking loading breaks new
games loudly instead of silently.

**Writes can never reach the template.** Slots live under `user://`, the
template under `res://`. Keep it that way; `test_saver_loader.gd` pins it.

**Slot number, not modified time, determines menu order.** Ordering by mtime
meant every save reshuffled the start screen. Modified time is still used for
one thing only: resolving "where was I" when nothing is selected.

**Slots are fixed at `SaveCtl.SLOT_COUNT` (10).** `list_slots()` always returns
all of them, occupied or not, so the menu can render empty rows. Callers check
`slot.exists`.

## Gotchas

- `game.gd` is a `@tool` script. Non-`@tool` autoloads like `SaveCtl` are not
  instantiated in the editor, so anything touching them must sit **below** the
  `Engine.is_editor_hint()` guard in `_ready`.
- `SaverLoader` is nested at `Game/Utils/SaverLoader`, so it reaches the root via
  `owner`, not `get_parent()`.
- Entity identity is the node name (`last_selected_player` matches
  `restored_node.name`). Packed scene roots must keep their names — renaming
  `Llew_v2` in `llew_v2.tscn` silently breaks restore, which then falls through
  to selecting party member 0.
- `EntityCtl.set_current_player()` is the only correct way to change selection;
  it assigns `current_player` *and* syncs `_current_party_member_idx`. Assigning
  `current_player` directly leaves Tab cycling from a stale index.

## Changing the save format

`SavedGame` is versionless. Adding a field is safe — old `.tres` files load with
the new field at its default, which is why `last_selected_player` reads as `""`
on pre-existing saves and falls back to party member 0. Removing or renaming a
field is not safe. If you need a real migration, that's a new capability, not a
tweak.
