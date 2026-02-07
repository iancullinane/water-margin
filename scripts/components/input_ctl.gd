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

func _input(event: InputEvent) -> void:
	# Middle mouse button drag to pan
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
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

func _process(delta: float) -> void:
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
