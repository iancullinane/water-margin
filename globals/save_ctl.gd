## Owns everything about save slots: where they live on disk, how they are
## listed, and which one the running game reads from and writes back to.
## Registered as the SaveCtl autoload.
##
## Saves occupy a fixed set of numbered slots. Slot number, not modified time,
## determines menu order, so saving never reshuffles the start screen.
##
## The start screen selects a slot here; SaverLoader reads it. Neither knows
## about the other, and change_scene_to_file needs no arguments.
extends Node

## How many save slots the player gets. Slots are numbered 1..SLOT_COUNT.
const SLOT_COUNT := 10

## The world as it should exist when a player starts a new game, authored as a
## normal SavedGame resource. Living in res:// keeps it out of reach of every
## write path, which only ever targets a slot under save_dir.
const NEW_GAME_TEMPLATE := "res://data/saves/new_game.tres"

# Not a const so tests can point at a scratch directory instead of the
# player's real savegames.
var save_dir := "user://savegames/"

## The slot the game loads from and saves back to. Empty until the start
## screen selects one or get_active_slot() resolves the fallback.
var current_slot_path := ""


## list_slots returns all SLOT_COUNT slots in index order, occupied or not, as
## dictionaries of {index, path, exists, modified, display_name}. Slots are
## described from directory metadata alone — no SavedGame resource is
## deserialized just to draw a menu row.
func list_slots() -> Array:
	var slots := []
	for index in range(1, SLOT_COUNT + 1):
		var path := slot_path(index)
		var exists := FileAccess.file_exists(path)
		var modified := FileAccess.get_modified_time(path) if exists else 0
		slots.append({
			"index": index,
			"path": path,
			"exists": exists,
			"modified": modified,
			"display_name": _label_for(index, exists, modified),
		})
	return slots


func _label_for(index: int, exists: bool, modified: int) -> String:
	if not exists:
		return "%d. Empty" % index
	var stamp := Time.get_datetime_string_from_unix_time(modified).replace("T", " ")
	return "%d. %s" % [index, stamp]


## slot_path is where slot `index` lives. Zero padded so filenames sort the
## same way the menu does.
func slot_path(index: int) -> String:
	return save_dir.path_join("savegame_%02d.tres" % index)


## select_slot points the session at a slot. Out-of-range indices are ignored
## rather than silently retargeting the session at some other slot.
func select_slot(index: int) -> void:
	if index < 1 or index > SLOT_COUNT:
		logging.warn("Ignoring out-of-range save slot %d" % index)
		return
	current_slot_path = slot_path(index)


## first_free_slot is the lowest-numbered slot with nothing saved in it, or -1
## when every slot is occupied.
func first_free_slot() -> int:
	for index in range(1, SLOT_COUNT + 1):
		if not FileAccess.file_exists(slot_path(index)):
			return index
	return -1


## get_active_slot resolves which slot the game should use. With nothing
## explicitly selected — running game.tscn directly with F5, bypassing the
## start screen — it falls back to the most recently saved slot so the dev loop
## keeps resuming where it left off. Modified time no longer drives menu order,
## but it is still the right answer for "where was I". The resolved path
## sticks, so a later save overwrites that slot rather than picking another.
## Returns "" when nothing is selected and nothing is saved: a new game.
func get_active_slot() -> String:
	if current_slot_path == "":
		current_slot_path = _most_recently_saved_slot()
	return current_slot_path


# Slots written in the same second share a modified time, so ties fall to the
# lowest index to keep the fallback deterministic.
func _most_recently_saved_slot() -> String:
	var best_path := ""
	var best_modified := -1
	for slot in list_slots():
		if not slot.exists:
			continue
		if slot.modified > best_modified:
			best_modified = slot.modified
			best_path = slot.path
	return best_path


## ensure_save_dir creates the save directory if it is missing. Callers that
## are about to write a slot should call this first.
func ensure_save_dir() -> void:
	DirAccess.make_dir_recursive_absolute(save_dir)
