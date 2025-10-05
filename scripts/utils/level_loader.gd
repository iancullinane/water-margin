@tool
extends Node2D

signal map_loaded(map: GameMap)

const DEFAULT_MAP_SCENE_PATH := "res://scenes/map/Map.tscn"

@export var map_scene: PackedScene : set = set_map_scene
# @export var map_node_name: String = "Map"
@export var auto_load_in_editor: bool = true
@export var reload_on_change_in_editor: bool = true
@export var clear_previous_on_load: bool = true

var _current_map_instance: GameMap

func _ready():
	if Engine.is_editor_hint() and auto_load_in_editor:
		ensure_map_loaded()

func ensure_map_loaded() -> GameMap:
	var target_map_node := _get_map_mount_node()
	if target_map_node == null:
		print("LevelLoader: No node to attach map to")
		return null

	for child in target_map_node.get_children():
		if child is GameMap:
			_current_map_instance = child
			return child

	var scene_to_use: PackedScene = map_scene
	if scene_to_use == null:
		print("LevelLoader: No map scene provided, loading default: %s" % DEFAULT_MAP_SCENE_PATH)
		var loaded_resource := load(DEFAULT_MAP_SCENE_PATH)
		if loaded_resource is PackedScene:
			scene_to_use = loaded_resource

	if scene_to_use == null:
		push_error("LevelLoader: No map scene provided and default not found: %s" % DEFAULT_MAP_SCENE_PATH)
		return null

	var map_instance: Node = scene_to_use.instantiate()
	map_instance.name = map_instance.get_map_name()
	target_map_node.add_child(map_instance)
	move_child(map_instance, 1)
	_current_map_instance = map_instance as GameMap

	if map_instance is GameMap:
		map_loaded.emit(map_instance)
		return map_instance

	print("Map Loaded")
	return null

# func load_map_by_path(scene_path: String) -> GameMap:
# 	var parent_node: Node = get_parent()
# 	if parent_node == null:
# 		return null

# 	var packed: Resource = load(scene_path)
# 	if packed is PackedScene:
# 		var instance: Node = (packed as PackedScene).instantiate()
# 		instance.name = instance.get_map_name()
# 		parent_node.add_child(instance)
# 		move_child(instance, 0)
# 		if instance is GameMap:
# 			map_loaded.emit(instance)
# 			return instance
# 	return null

func reload_map() -> GameMap:
	var target_map_node := _get_map_mount_node()
	if target_map_node == null:
		return null
	var existing := target_map_node.get_node_or_null(_current_map_instance.get_map_name())
	if existing != null:
		existing.queue_free()
	_current_map_instance = existing as GameMap
	return ensure_map_loaded()

func set_map_scene(value: PackedScene) -> void:
	map_scene = value
	if Engine.is_editor_hint() and reload_on_change_in_editor:
		reload_map()

func _get_map_mount_node() -> Node:
	var parent_node := get_parent()
	if parent_node == null:
		return null

	var target_node = parent_node.get_node("Map")
		
	return target_node