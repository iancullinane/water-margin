extends GutTest

## Unit tests for GameMode — the Real-Time / Turn-Based toggle. GameMode is an
## autoload at runtime, but we instantiate the script directly here so tests
## never mutate the singleton's state. toggle() emits on the real SignalBus,
## which is harmless: emitting a signal with no game running has no listeners
## beyond GUT's watcher.

const GameModeScript = preload("res://globals/game_mode.gd")

var game_mode


func before_each() -> void:
	game_mode = GameModeScript.new()


func after_each() -> void:
	game_mode.free()


# --- default state ----------------------------------------------------------

func test_default_mode_is_real_time() -> void:
	assert_eq(game_mode.current, GameModeScript.Mode.REAL_TIME,
		"the game starts in real-time; mode is runtime-only and never persisted")


# --- toggle -----------------------------------------------------------------

func test_toggle_switches_to_turn_based() -> void:
	game_mode.toggle()
	assert_eq(game_mode.current, GameModeScript.Mode.TURN_BASED)


func test_toggle_twice_returns_to_real_time() -> void:
	game_mode.toggle()
	game_mode.toggle()
	assert_eq(game_mode.current, GameModeScript.Mode.REAL_TIME)


func test_toggle_returns_the_new_mode() -> void:
	assert_eq(game_mode.toggle(), GameModeScript.Mode.TURN_BASED,
		"callers should not have to read current after toggling")


func test_toggle_emits_mode_changed_with_the_new_mode() -> void:
	watch_signals(SignalBus)
	game_mode.toggle()
	assert_signal_emitted_with_parameters(SignalBus, "mode_changed",
		[GameModeScript.Mode.TURN_BASED])


# --- mode_name --------------------------------------------------------------

func test_mode_name_labels_real_time() -> void:
	assert_eq(game_mode.mode_name(GameModeScript.Mode.REAL_TIME), "Real-Time")


func test_mode_name_labels_turn_based() -> void:
	assert_eq(game_mode.mode_name(GameModeScript.Mode.TURN_BASED), "Turn-Based")
