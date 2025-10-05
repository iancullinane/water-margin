extends Node


@onready var party_ctl = $Party
var entity_scene = preload("res://scripts/entities/entity.tscn")

var entities: Array[Entity] = []

@export var player_party: Array[Entity] = []

func _ready():
	load_entity_children()

func load_entity_children():
	entities.clear()
	for child in get_children():
		if child is Entity:
			entities.append(child)
	print("Loaded %d entities" % [entities.size()])

	for entity in player_party:
		var new_entity = entity_scene.instantiate()
		new_entity.stats = entity.stats
		party_ctl.add_child(new_entity)

func get_entities() -> Array[Entity]:
	return entities

func get_entity_count() -> int:
	return entities.size()

func get_entity_by_index(index: int) -> Entity:
	if index >= 0 and index < entities.size():
		return entities[index]
	return null

func get_entity_by_name(entity_name: String) -> Entity:
	for entity in entities:
		if entity.stats and entity.stats.name == entity_name:
			return entity
		elif entity.name == entity_name:
			return entity
	return null

# Control methods
func set_current_player(entity: Entity):
	if entity and entity in entities:
		# Disable all others first
		for e in entities:
			e.current_player = false
		# Enable the selected one
		entity.current_player = true
		# Emit signal for camera tracking
		SignalBus.current_player_changed.emit(entity)

func set_current_player_by_index(index: int):
	var entity = get_entity_by_index(index)
	if entity:
		set_current_player(entity)

func set_current_player_by_name(entity_name: String):
	var entity = get_entity_by_name(entity_name)
	if entity:
		set_current_player(entity)

func get_current_player() -> Entity:
	for entity in entities:
		if entity.current_player:
			return entity
	return null




# # Manipulation methods
# func move_entity(entity: Entity, direction: String):
#	 if entity and entity in entities:
#		 entity._on_move(direction)

# func move_entity_by_index(index: int, direction: String):
#	 var entity = get_entity_by_index(index)
#	 if entity:
#		 move_entity(entity, direction)

# func move_current_player(direction: String):
#	 var current = get_current_player()
#	 if current:
#		 move_entity(current, direction)

# func set_entity_position(entity: Entity, new_position: Vector2):
#	 if entity and entity in entities:
#		 entity.position = new_position

# func set_entity_position_by_index(index: int, new_position: Vector2):
#	 var entity = get_entity_by_index(index)
#	 if entity:
#		 set_entity_position(entity, new_position)
