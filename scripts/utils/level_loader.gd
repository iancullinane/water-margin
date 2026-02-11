@tool
extends Node2D

# TODO actually load a default map
# const DEFAULT_MAP_SCENE_PATH := "res://scenes/map/map_001.tscn"

var _current_map_instance: GameMap

var _selected_map_scene: PackedScene
@export var selected_map_scene: PackedScene:
	get: return _selected_map_scene
	set(value):
		_selected_map_scene = value
		if Engine.is_editor_hint() and reload_on_change_in_editor:
			ensure_map_loaded()

@export var map_data: GameMapData
@export var reload_on_change_in_editor: bool = true
@export var clear_previous_on_load: bool = true

## ensure_map_loaded looks for a sibling called
## MapCtl and attempts to load a map to it. When loading
## a map any other maps will be free'd.
func ensure_map_loaded() -> void:
	"""Returns the bounding rectangle of this map"""
	logging.log("attempt scene load")
	if selected_map_scene == null:
		return
	var target := _get_map_mount_node()
	if target == null:
		return
	var existing := _find_existing_maps(target)
	if not existing.is_empty():
		if not clear_previous_on_load:
			_current_map_instance = existing[0]
			return
		for map in existing:
			map.queue_free()

	var inst := selected_map_scene.instantiate()
	logging.log("instantiate %s" % inst.map_name)
	if not (inst is GameMap):
		push_error("Selected scene root is not GameMap")
		return

	# Add the map data resource to the scene
	if map_data != null:
		inst.game_map_data = map_data

	target.add_child(inst)
	inst.owner = target
	_current_map_instance = inst
	logging.log("map loaded")


func _find_existing_maps(parent: Node) -> Array[GameMap]:
	var result: Array[GameMap] = []
	for child in parent.get_children():
		if child is GameMap:
			result.append(child)
	return result

func _get_map_mount_node() -> Node:
	var parent_node := get_parent()
	if parent_node == null:
		return null

	# TODO find by duck typing once there is more logic in MapCtl
	var target_node = parent_node.get_node_or_null("MapCtl")

	return target_node

func get_current_map() -> GameMap:
	return _current_map_instance
