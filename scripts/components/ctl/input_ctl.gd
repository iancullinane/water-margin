## Handles the input of the game like pan and zoom, responding
## to input for the player movement
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
var _clamp_debug_printed: bool = false

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
	_handle_player_movement()
	_clamp_camera_position()


func _input(event: InputEvent) -> void:
	# Middle mouse button drag to pan
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var grid_pos := GameConstants.world_to_grid(get_global_mouse_position())
			print("[InputCtl] Left click at grid position: ", grid_pos)
			SignalBus.main_click.emit(grid_pos)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_is_dragging = true
				_last_mouse_pos = event.position
			else:
				_is_dragging = false
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			var new_zoom = camera.zoom.x + zoom_speed
			camera.zoom = Vector2.ONE * clampf(new_zoom, min_zoom, max_zoom)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			var new_zoom = camera.zoom.x - zoom_speed
			camera.zoom = Vector2.ONE * clampf(new_zoom, min_zoom, max_zoom)


	if event is InputEventMouseMotion and _is_dragging:
		var delta = event.position - _last_mouse_pos
		_last_mouse_pos = event.position
		# Divide by zoom so pan feels consistent at all zoom levels
		camera.position -= delta / camera.zoom
		_clamp_camera_position()



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


func _handle_player_movement() -> void:
	if not entity_ctl.current_player:
		return

	var dir := Vector2.ZERO
	if Input.is_action_pressed("player_up"):
		dir = Vector2.UP
	elif Input.is_action_pressed("player_down"):
		dir = Vector2.DOWN
	elif Input.is_action_pressed("player_left"):
		dir = Vector2.LEFT
	elif Input.is_action_pressed("player_right"):
		dir = Vector2.RIGHT

	if dir != Vector2.ZERO:
		entity_ctl.move_current_player(dir)

# TODO: Move camera clamp to the camera node
# Labels: Story
func _clamp_camera_position() -> void:
	var vp_size := get_viewport().get_visible_rect().size / camera.zoom
	var half_vp := vp_size * 0.5

	var min_x := camera.limit_left + half_vp.x
	var max_x := camera.limit_right - half_vp.x
	var min_y := camera.limit_top + half_vp.y
	var max_y := camera.limit_bottom - half_vp.y

	if not _clamp_debug_printed:
		_clamp_debug_printed = true
		print("[InputCtl] Clamp debug — vp_size:%s half_vp:%s limits: L:%d T:%d R:%d B:%d → clamp X:[%s, %s] Y:[%s, %s]" % [vp_size, half_vp, camera.limit_left, camera.limit_top, camera.limit_right, camera.limit_bottom, min_x, max_x, min_y, max_y])

	# If the map is smaller than the viewport, center the camera
	if min_x > max_x:
		camera.position.x = (camera.limit_left + camera.limit_right) * 0.5
	else:
		camera.position.x = clampf(camera.position.x, min_x, max_x)

	if min_y > max_y:
		camera.position.y = (camera.limit_top + camera.limit_bottom) * 0.5
	else:
		camera.position.y = clampf(camera.position.y, min_y, max_y)
