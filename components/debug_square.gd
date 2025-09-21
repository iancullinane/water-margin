@tool
extends Node2D

@export var show_in_game: bool = false:
	set(value):
		show_in_game = value
		queue_redraw()


@export var height: int = GameConstants.CELL_SIZE * 1:
	set(value):
		height = value
		queue_redraw()

@export var width: int = GameConstants.CELL_SIZE * 1:
	set(value):
		width = value
		queue_redraw()



# @export var show_in_editor: bool = true:

@export var color: Color = Color(1.0, 0.2, 0.2, 0.9):
	set(value):
		color = value
		queue_redraw()

# @export var outline_only: bool = true:
# 	set(value):
# 		outline_only = value
# 		queue_redraw()

@export_range(0.5, 16.0, 0.5) var line_width: float = 2.0:
	set(value):
		line_width = value
		queue_redraw()

@export var centered: bool = true:
	set(value):
		centered = value
		queue_redraw()

@export var offset: Vector2 = Vector2.ZERO:
	set(value):
		offset = value
		queue_redraw()

func _ready() -> void:
	set_notify_transform(true)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()

func _draw() -> void:
	var should_draw := Engine.is_editor_hint() or (show_in_game and OS.is_debug_build())
	if not should_draw:
		return

	var cell_size = GameConstants.CELL_SIZE
	var draw_size := Vector2(width * cell_size, width * cell_size)
	if draw_size.x <= 0.0 or draw_size.y <= 0.0:
		return

	var pos := offset
	if centered:
		pos -= draw_size * 0.5

	var rect := Rect2(pos, draw_size)
	# if outline_only:
	var top_left := rect.position
	var top_right := rect.position + Vector2(rect.size.x, 0.0)
	var bottom_left := rect.position + Vector2(0.0, rect.size.y)
	var bottom_right := rect.position + rect.size
	print("DRAW")
	draw_line(top_left, top_right, color, line_width)
	draw_line(top_right, bottom_right, color, line_width)
	draw_line(bottom_right, bottom_left, color, line_width)
	draw_line(bottom_left, top_left, color, line_width)
	# else:
	# 	draw_rect(rect, color, true)


