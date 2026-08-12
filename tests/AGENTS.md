# Tests

This project **does** have a test framework: GUT, vendored at `addons/gut/`.
(The top-level `CLAUDE.md` claims otherwise — it is out of date.) There is no
`.gutconfig.json`; everything is passed on the command line.

## Running

Whole suite:

```
/Applications/Godot.app/Contents/MacOS/Godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

One file:

```
/Applications/Godot.app/Contents/MacOS/Godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_save_ctl.gd -gexit
```

The run always prints SQLite chatter from the `GameData` autoload, including a
line reading `ERROR: SQLite reported error on open, checking usability...`
followed by `Database opened and is accessible.` **This is pre-existing noise,
not a failure.** Grep for `passed`/`failed` rather than `error`.

## Reading a failure

A missing `preload()` target makes the whole file fail to parse, and GUT
reports it as `Ignoring script ... because it does not extend GutTest` plus
`Nothing was run.` That is a broken dependency, not a broken test — the class
under test probably doesn't exist yet.

## Conventions

- One test file per unit under test, named `test_<script>.gd`, `extends GutTest`.
- Prefer hand-written fake subclasses over mocks. `test_entity_ctl.gd` has the
  reference examples (`FakeEntity`, `FakeMap`, `FakeMapCtl`).
- `IEntity` and `EntityCtl` resolve children via `@onready`. A double must add
  the expected named children in `_init()` or the lookups push "Node not found"
  engine errors, which GUT counts as failures. See `FakeEntity._init`.
- Nodes not added to the tree never run `_ready`, which is usually what you want
  for a double. Free them explicitly; use `add_child_autofree()` for the rest.

## Touching autoloads from a test

Anything reading an autoload (`SaveCtl`, `GameData`, `SignalBus`) is touching
real global state, including the player's real save directory.

- For scripts you can instantiate directly, `preload()` the script and `new()`
  it rather than using the singleton — see `test_save_ctl.gd`.
- When the code under test reaches the singleton by name and you can't avoid it,
  save the fields you change in `before_each` and restore them in `after_each` —
  see `test_saver_loader.gd`.
- `SaveCtl.save_dir` is deliberately a `var`, not a `const`, so it can be pointed
  at a scratch directory. Never let a test write to `user://savegames/`.

## Smoke-testing a scene

Unit tests won't catch scene wiring, missing nodes, or autoload availability.
Boot the scene headless:

```
/Applications/Godot.app/Contents/MacOS/Godot --headless scenes/game.tscn --quit-after 60
```

`ObjectDB instances were leaked at exit` and `resources still in use at exit` on
shutdown are expected in headless runs and not worth chasing.
