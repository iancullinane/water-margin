extends GutTest

## Unit tests for SaveCtl — slot discovery, minting and selection.
## SaveCtl is an autoload at runtime, but we instantiate the script directly
## here and point save_dir at a scratch directory so tests never touch the
## player's real savegames.

const SaveCtlScript = preload("res://globals/save_ctl.gd")

const TEST_DIR := "user://test_savegames/"

var save_ctl


func before_each() -> void:
	_clear_test_dir()
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	save_ctl = SaveCtlScript.new()
	save_ctl.save_dir = TEST_DIR


func after_each() -> void:
	save_ctl.free()
	_clear_test_dir()


func _clear_test_dir() -> void:
	var dir := DirAccess.open(TEST_DIR)
	if dir == null:
		return
	for file_name in dir.get_files():
		dir.remove(file_name)
	DirAccess.remove_absolute(TEST_DIR)


# Writes a real file so DirAccess and get_modified_time see it. Contents are
# irrelevant — SaveCtl lists slots without deserializing them.
func _touch(file_name: String) -> String:
	var path := TEST_DIR + file_name
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("stub")
	f.close()
	return path


# --- list_slots -------------------------------------------------------------

func test_list_slots_missing_dir_returns_empty() -> void:
	save_ctl.save_dir = "user://no_such_dir/"
	assert_eq(save_ctl.list_slots(), [], "a missing save dir should list no slots")


func test_list_slots_empty_dir_returns_empty() -> void:
	assert_eq(save_ctl.list_slots(), [], "an empty save dir should list no slots")


func test_list_slots_ignores_non_tres_files() -> void:
	_touch("savegame_100.tres")
	_touch("notes.txt")
	_touch("savegame_200.png")

	var slots = save_ctl.list_slots()
	assert_eq(slots.size(), 1, "only .tres files are slots")
	assert_true(slots[0].path.ends_with("savegame_100.tres"))


func test_list_slots_returns_every_tres_file() -> void:
	_touch("savegame_100.tres")
	_touch("savegame_200.tres")
	_touch("savegame.tres")

	assert_eq(save_ctl.list_slots().size(), 3, "all .tres files should be listed")


func test_list_slots_orders_newest_first() -> void:
	# Files created within the same test share a modified time (filesystem
	# granularity is one second), so this pins the name-descending tiebreak
	# that makes ordering deterministic for same-second slots.
	_touch("savegame_100.tres")
	_touch("savegame_300.tres")
	_touch("savegame_200.tres")

	var slots = save_ctl.list_slots()
	assert_true(slots[0].path.ends_with("savegame_300.tres"), "newest slot first")
	assert_true(slots[1].path.ends_with("savegame_200.tres"))
	assert_true(slots[2].path.ends_with("savegame_100.tres"), "oldest slot last")


func test_list_slots_entries_have_a_display_name() -> void:
	_touch("savegame_100.tres")
	var slot = save_ctl.list_slots()[0]
	assert_ne(slot.display_name, "", "every slot needs a label for the start screen")


# --- new_slot ---------------------------------------------------------------

func test_new_slot_sets_current_slot_path() -> void:
	var path: String = save_ctl.new_slot()
	assert_eq(save_ctl.current_slot_path, path, "minting a slot selects it")


func test_new_slot_path_is_in_save_dir_and_is_tres() -> void:
	var path: String = save_ctl.new_slot()
	assert_true(path.begins_with(TEST_DIR), "slot should live in the save dir")
	assert_true(path.ends_with(".tres"), "slot should be a .tres resource")


func test_new_slot_does_not_write_a_file() -> void:
	save_ctl.new_slot()
	assert_eq(save_ctl.list_slots().size(), 0,
		"a minted slot reserves a path only — the file appears on first save")


func test_new_slot_does_not_collide_with_an_existing_slot() -> void:
	var path: String = save_ctl.new_slot()
	_touch(path.get_file())
	assert_ne(save_ctl.new_slot(), path, "minting twice must not reuse an occupied path")


# --- select_slot ------------------------------------------------------------

func test_select_slot_sets_current_slot_path() -> void:
	save_ctl.select_slot(TEST_DIR + "savegame_100.tres")
	assert_eq(save_ctl.current_slot_path, TEST_DIR + "savegame_100.tres")


# --- get_active_slot (lazy fallback) ---------------------------------------

func test_get_active_slot_returns_explicit_selection() -> void:
	_touch("savegame_100.tres")
	_touch("savegame_300.tres")
	save_ctl.select_slot(TEST_DIR + "savegame_100.tres")
	assert_true(save_ctl.get_active_slot().ends_with("savegame_100.tres"),
		"an explicit selection wins over the fallback")


func test_get_active_slot_falls_back_to_newest_when_unset() -> void:
	# This is the F5 path: straight into game.tscn, no start screen, nothing
	# selected. Should resume the most recent slot rather than start fresh.
	_touch("savegame_100.tres")
	_touch("savegame_300.tres")
	assert_true(save_ctl.get_active_slot().ends_with("savegame_300.tres"),
		"with no selection, fall back to the newest slot")


func test_get_active_slot_is_empty_when_no_slots_exist() -> void:
	assert_eq(save_ctl.get_active_slot(), "",
		"no selection and no slots means a new game")


func test_get_active_slot_caches_the_fallback() -> void:
	_touch("savegame_300.tres")
	var resolved: String = save_ctl.get_active_slot()
	assert_eq(save_ctl.current_slot_path, resolved,
		"resolving the fallback should stick, so later saves target that slot")
