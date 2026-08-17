## Owns which mode the game is running in. Many systems will eventually branch
## on this; they either read `current` directly or connect to
## SignalBus.mode_changed. Runtime-only — the mode is never saved.
extends Node

enum Mode { REAL_TIME, TURN_BASED }

var current: Mode = Mode.REAL_TIME


func toggle() -> Mode:
	current = Mode.TURN_BASED if current == Mode.REAL_TIME else Mode.REAL_TIME
	SignalBus.mode_changed.emit(current)
	return current


func mode_name(m: Mode) -> String:
	match m:
		Mode.TURN_BASED:
			return "Turn-Based"
		_:
			return "Real-Time"
