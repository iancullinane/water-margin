@tool
extends Node2D
class_name LevelLoader

# TODO actually load a default map
# const DEFAULT_MAP_SCENE_PATH := "res://scenes/map/map_001.tscn"

@onready var map_ctl: MapCtl = %MapCtl

# This is a PackScene type because it is the scene
# itself, not an instance of that the scene type.
var _selected_map_scene: PackedScene
# this however will be an instance of the scene type
# which we load in ensure_map_loaded
var _current_map_instance: GameMap

# This is so we change maps in the editor, the
# underlying value has an underscore, so think
# of this a a getter and setter on a private variable
@export var selected_map_scene: PackedScene:
	get: return _selected_map_scene
	set(value):
		_selected_map_scene = value
		update_configuration_warnings()
		if Engine.is_editor_hint() and reload_on_change_in_editor and is_node_ready():
			ensure_map_loaded()


@export var reload_on_change_in_editor: bool = true

## ensure_map_loaded looks for a sibling called
## MapCtl and attempts to load a map to it. When loading
## a map any other maps will be free'd.
func ensure_map_loaded() -> void:
	logging.log("attempt scene load")
	if selected_map_scene == null:
		# It might make sense to allow this if we were
		# in between maps or showing some other
		# type like a cinematic that is "map like"
		return

	if _current_map_instance != null:
		_current_map_instance.queue_free()
		_current_map_instance = null

	# TODO here do some more with the map data, like adding landmarks
	var inst := selected_map_scene.instantiate()
	logging.log("instantiate %s" % inst.map_name)
	if not (inst is GameMap):
		push_error("Selected scene root is not GameMap")
		inst.queue_free()
		return

	map_ctl.add_child(inst)
	_current_map_instance = inst

	logging.log("map loaded")


func get_current_map() -> GameMap:
	return _current_map_instance


func _get_configuration_warnings() -> PackedStringArray:
	if selected_map_scene == null:
		return ["selected_map_scene is required"]
	return []
