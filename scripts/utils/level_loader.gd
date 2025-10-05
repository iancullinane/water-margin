@tool
extends Node2D

signal map_loaded(map: GameMap)

const DEFAULT_MAP_SCENE_PATH := "res://scenes/map/Map.tscn"

@export var map_scene: PackedScene
@export var map_node_name: String = "Map"

# func _ready():
# 	_ensure_map_loaded()

func ensure_map_loaded() -> GameMap:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return null

	var existing_map: Node = parent_node.get_node_or_null(map_node_name)
	if existing_map != null and existing_map is GameMap:
		return existing_map

	var scene_to_use: PackedScene = map_scene
	if scene_to_use == null:
		var loaded_resource := load(DEFAULT_MAP_SCENE_PATH)
		if loaded_resource is PackedScene:
			scene_to_use = loaded_resource

	if scene_to_use == null:
		push_error("LevelLoader: No map scene provided and default not found: %s" % DEFAULT_MAP_SCENE_PATH)
		return null

	var map_instance: Node = scene_to_use.instantiate()
	map_instance.name = map_node_name
	parent_node.add_child(map_instance)

	if map_instance is GameMap:
		map_loaded.emit(map_instance)
		return map_instance

	print("Map Loaded")
	return null

func load_map_by_path(scene_path: String) -> GameMap:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return null

	var packed: Resource = load(scene_path)
	if packed is PackedScene:
		var instance: Node = (packed as PackedScene).instantiate()
		instance.name = map_node_name
		parent_node.add_child(instance)
		if instance is GameMap:
			map_loaded.emit(instance)
			return instance
	return null