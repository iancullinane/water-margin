extends Node2D
class_name InputCtl

@onready var entity_ctl: Node2D = get_parent().get_node("EntityCtl")
@onready var camera: Camera2D = get_parent().get_node("Camera")

@export var pan_speed: float = 200.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 1.0
@export var max_zoom: float = 10.0

var _is_dragging: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO

const DIRECTIONS = ["up", "down", "left", "right"]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if not is_instance_valid(SignalBus):
		return
	if SignalBus.has_signal("current_player_changed"):
		SignalBus.current_player_changed.connect(_on_current_player_changed)
	if SignalBus.has_signal("current_player_moved"):
		SignalBus.current_player_moved.connect(_on_current_player_moved)

func _process(delta: float) -> void:
	handle_pan_and_zoom(delta)


func _input(event: InputEvent) -> void:
	# Middle mouse button drag to pan
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var grid_pos := GameConstants.world_to_grid(get_global_mouse_position())
			print("[InputCtl] Left click at grid position: ", grid_pos)
			SignalBus.left_clicked.emit(grid_pos)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_is_dragging = true
				_last_mouse_pos = event.position
			else:
				_is_dragging = false


	if event is InputEventMouseMotion and _is_dragging:
		var delta = event.position - _last_mouse_pos
		_last_mouse_pos = event.position
		# Divide by zoom so pan feels consistent at all zoom levels
		camera.position -= delta / camera.zoom

	var move_dir = Input.get_vector("player_left", "player_right", "player_up","player_down")
	if move_dir:
		entity_ctl.move_current_player(move_dir)


func _unhandled_input(_event):
	if entity_ctl.get_entity_group(EntityCtl.EntityType.PARTY).size() == 0:
		return
	if Input.is_action_just_pressed("previous_character"):
		entity_ctl.previous_player()
	elif Input.is_action_just_pressed("next_character"):
		entity_ctl.next_player()


func _on_current_player_changed(entity: Node2D):
	if entity:
		camera.position = entity.position


func _on_current_player_moved(entity: Node2D):
	if entity:
		camera.position = entity.position


func handle_pan_and_zoom(delta: float) -> void:
	var pan_dir := Vector2.ZERO

	if Input.is_action_pressed("world_left"):
		pan_dir.x -= 1
	if Input.is_action_pressed("world_right"):
		pan_dir.x += 1
	if Input.is_action_pressed("world_up"):
		pan_dir.y -= 1
	if Input.is_action_pressed("world_down"):
		pan_dir.y += 1

	if pan_dir != Vector2.ZERO:
		camera.position += pan_dir.normalized() * pan_speed * delta / camera.zoom

	if Input.is_action_pressed("zoom_in"):
		var new_zoom = camera.zoom.x + zoom_speed
		new_zoom = clampf(new_zoom, min_zoom, max_zoom)
		camera.zoom = Vector2(new_zoom, new_zoom)

	if Input.is_action_pressed("zoom_out"):
		var new_zoom = camera.zoom.x - zoom_speed
		new_zoom = clampf(new_zoom, min_zoom, max_zoom)
		camera.zoom = Vector2(new_zoom, new_zoom)

# func get_input():
# 	direction = Input.get_vector("player_left", "player_right", "player_up","player_down")
# 	if !current_player:
# 		return

# 	# Manage press/release transitions
# 	for dir in DIRECTIONS:
# 		var action = "player_" + dir
# 		if Input.is_action_just_pressed(action):
# 			mover._move(dir)
