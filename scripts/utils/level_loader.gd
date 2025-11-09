@tool
extends Node2D


const DEFAULT_MAP_SCENE_PATH := "res://scenes/map/map_001.tscn"

var _current_map_instance: GameMap

var _selected_map_scene: PackedScene
@export var selected_map_scene: PackedScene:
	get: return _selected_map_scene
	set(value):
		_selected_map_scene = value
		if Engine.is_editor_hint() and reload_on_change_in_editor:
			ensure_map_loaded()

# @export var selected_map_scene: PackedScene
@export var auto_load_in_editor: bool = true
@export var reload_on_change_in_editor: bool = true
@export var clear_previous_on_load: bool = true

func _ready():
	if Engine.is_editor_hint():
		ensure_map_loaded()
	ensure_map_loaded()

func ensure_map_loaded() -> void:
	print("ensure_map_loaded")
	if selected_map_scene == null:
		return
	var target := _get_map_mount_node()
	if target == null:
		return
	# Handle existing map instances before adding a new one
	var existing_found: GameMap = null
	for child in target.get_children():
		if child is GameMap:
			existing_found = child
			break
	if existing_found != null:
		if clear_previous_on_load:
			# Remove all existing GameMap instances to prevent duplicates
			for child in target.get_children():
				if child is GameMap:
					child.queue_free()
		else:
			_current_map_instance = existing_found
			return

	var inst := selected_map_scene.instantiate()
	if not (inst is GameMap):
		push_error("Selected scene root is not GameMap")
		return
	target.add_child(inst)
	inst.owner = target
	_current_map_instance = inst

func _load_map() -> void:
	print("Load map")
	var map_instance: GameMap = selected_map_scene.instantiate() as GameMap
	map_instance.name = map_instance.get_map_name()
	_get_map_mount_node().add_child(map_instance)
	map_instance.owner = _get_map_mount_node()

	_current_map_instance = map_instance
	print("Map Loaded")
	return

func _get_map_mount_node() -> Node:
	var parent_node := get_parent()
	if parent_node == null:
		return null

	var target_node = parent_node.get_node_or_null("MapCtl")
		
	return target_node

func get_current_map() -> GameMap:
	return _current_map_instance
