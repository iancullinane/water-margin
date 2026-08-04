extends GutTest

## Unit tests for SaveCtl — ten numbered save slots, their listing and
## selection. SaveCtl is an autoload at runtime, but we instantiate the script
## directly here and point save_dir at a scratch directory so tests never touch
## the player's real savegames.

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


# Occupies a slot by writing a real file, so DirAccess and get_modified_time
# see it. Contents are irrelevant — slots are listed from directory metadata.
func _occupy(index: int) -> String:
	var path: String = TEST_DIR + "savegame_%02d.tres" % index
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("stub")
	f.close()
	return path


# --- list_slots -------------------------------------------------------------

func test_list_slots_always_returns_every_slot() -> void:
	assert_eq(save_ctl.list_slots().size(), save_ctl.SLOT_COUNT,
		"the menu shows a fixed set of slots, empty or not")


func test_list_slots_returns_every_slot_when_the_dir_is_missing() -> void:
	save_ctl.save_dir = "user://no_such_dir/"
	assert_eq(save_ctl.list_slots().size(), save_ctl.SLOT_COUNT,
		"a missing save dir still lists ten empty slots")


func test_list_slots_is_ordered_by_index() -> void:
	var slots = save_ctl.list_slots()
	for i in slots.size():
		assert_eq(slots[i].index, i + 1, "slots run 1..N in order")


func test_list_slots_order_is_stable_regardless_of_write_order() -> void:
	# The bug this replaces: ordering by modified time meant saving reshuffled
	# the menu. Occupy slots out of order and the listing must not care.
	_occupy(5)
	_occupy(2)
	var slots = save_ctl.list_slots()
	assert_eq(slots[1].index, 2)
	assert_eq(slots[4].index, 5)
	assert_true(slots[1].exists, "slot 2 was written")
	assert_true(slots[4].exists, "slot 5 was written")


func test_list_slots_marks_unwritten_slots_as_empty() -> void:
	_occupy(3)
	var slots = save_ctl.list_slots()
	assert_true(slots[2].exists, "slot 3 was written")
	assert_false(slots[0].exists, "slot 1 was never written")


func test_list_slots_labels_every_slot() -> void:
	_occupy(1)
	var slots = save_ctl.list_slots()
	assert_ne(slots[0].display_name, "", "occupied slots need a label")
	assert_ne(slots[1].display_name, "", "empty slots need a label too")
	assert_ne(slots[0].display_name, slots[1].display_name,
		"an occupied slot should not read the same as an empty one")


func test_list_slots_paths_are_zero_padded_in_the_save_dir() -> void:
	var slots = save_ctl.list_slots()
	assert_eq(slots[0].path, TEST_DIR + "savegame_01.tres")
	assert_eq(slots[9].path, TEST_DIR + "savegame_10.tres")


# --- select_slot ------------------------------------------------------------

func test_select_slot_sets_current_slot_path() -> void:
	save_ctl.select_slot(3)
	assert_eq(save_ctl.current_slot_path, TEST_DIR + "savegame_03.tres")


func test_select_slot_ignores_an_out_of_range_index() -> void:
	save_ctl.select_slot(4)
	save_ctl.select_slot(0)
	save_ctl.select_slot(save_ctl.SLOT_COUNT + 1)
	assert_eq(save_ctl.current_slot_path, TEST_DIR + "savegame_04.tres",
		"a bad index must not clobber the current selection")


# --- first_free_slot --------------------------------------------------------

func test_first_free_slot_is_one_when_nothing_is_saved() -> void:
	assert_eq(save_ctl.first_free_slot(), 1)


func test_first_free_slot_skips_occupied_slots() -> void:
	_occupy(1)
	_occupy(2)
	assert_eq(save_ctl.first_free_slot(), 3)


func test_first_free_slot_finds_a_gap() -> void:
	_occupy(1)
	_occupy(3)
	assert_eq(save_ctl.first_free_slot(), 2, "a freed slot should be reused")


func test_first_free_slot_is_negative_when_full() -> void:
	for i in range(1, save_ctl.SLOT_COUNT + 1):
		_occupy(i)
	assert_eq(save_ctl.first_free_slot(), -1,
		"a full slot list must report no room rather than overwriting")


# --- get_active_slot (lazy fallback) ---------------------------------------

func test_get_active_slot_returns_explicit_selection() -> void:
	_occupy(1)
	_occupy(2)
	save_ctl.select_slot(2)
	assert_eq(save_ctl.get_active_slot(), TEST_DIR + "savegame_02.tres",
		"an explicit selection wins over the fallback")


func test_get_active_slot_falls_back_to_the_most_recent_save() -> void:
	# This is the F5 path: straight into game.tscn, no start screen, nothing
	# selected. Modified time no longer drives display order, but it is still
	# the right answer for "where was I".
	_occupy(4)
	assert_eq(save_ctl.get_active_slot(), TEST_DIR + "savegame_04.tres",
		"with no selection, resume the most recently saved slot")


func test_get_active_slot_breaks_modified_time_ties_by_lowest_index() -> void:
	# Slots written in the same second share a modified time (filesystem
	# granularity), so the tiebreak keeps the fallback deterministic.
	_occupy(7)
	_occupy(3)
	assert_eq(save_ctl.get_active_slot(), TEST_DIR + "savegame_03.tres")


func test_get_active_slot_is_empty_when_nothing_is_saved() -> void:
	assert_eq(save_ctl.get_active_slot(), "",
		"no selection and no saves means a new game")


func test_get_active_slot_caches_the_fallback() -> void:
	_occupy(6)
	var resolved: String = save_ctl.get_active_slot()
	assert_eq(save_ctl.current_slot_path, resolved,
		"resolving the fallback should stick, so later saves target that slot")
