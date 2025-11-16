extends ColorRect

@export var cam: CameraCtl

func _ready() -> void:
	anchors_preset = PRESET_TOP_LEFT

func _process(delta: float) -> void:
	if not cam:
		return

	var view_size: Vector2 = get_viewport_rect().size

	global_position = cam.get_screen_center_position() - view_size * 0.5
	size = view_size

	var mat := material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("world_top_left", global_position)
		mat.set_shader_parameter("rect_size_world", view_size)
