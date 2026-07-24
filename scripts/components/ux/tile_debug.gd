## The tiny orange square

@tool
extends Node2D
class_name TileDebugger

@export var enabled: bool = true:
	set(value):
		enabled = value
		queue_redraw()

@export var show_in_game: bool = false:
	set(value):
		show_in_game = value
		queue_redraw()

@export var static_tile: Vector2i = Vector2i.ZERO:
	set(value):
		static_tile = value
		queue_redraw()

@export var color: Color = Color(1.0, 0.8, 0.0, 0.9):
	set(value):
		color = value
		queue_redraw()

@export_range(0.5, 16.0, 0.5) var line_width: float = 2.0:
	set(value):
		line_width = value
		queue_redraw()

func _ready() -> void:
	set_notify_transform(true)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()

func _process(_delta: float) -> void:
	if !enabled:
		return
	queue_redraw()

func _draw() -> void:
	if !enabled:
		return

	var should_draw := Engine.is_editor_hint() or (show_in_game and OS.is_debug_build())
	if not should_draw:
		return

	var cell_size := GameConstants.CELL_SIZE
	var pos := Vector2(static_tile) * cell_size
	var rect := Rect2(pos, Vector2(cell_size, cell_size))

	var top_left := rect.position
	var top_right := rect.position + Vector2(rect.size.x, 0.0)
	var bottom_left := rect.position + Vector2(0.0, rect.size.y)
	var bottom_right := rect.position + rect.size

	draw_line(top_left, top_right, color, line_width)
	draw_line(top_right, bottom_right, color, line_width)
	draw_line(bottom_right, bottom_left, color, line_width)
	draw_line(bottom_left, top_left, color, line_width)
